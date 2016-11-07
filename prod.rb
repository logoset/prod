# DEDUG in console:
# ruby -rdebug myscript.rb
# then,
#     b <line>: put break-point
#     and n(ext) or s(tep) and c(ontinue)
#     p(uts),pp for display
#     w/where to Display frame/call stack,
#     l to Show the current code,
#     cat to show catchpoints.
#     h for more Help.


# ------------------- RUSSIAN ENCODING WORKING CORRECTLY -----------------------
if (Gem.win_platform?)
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end
# ------------------------------------------------------------------------------

# ---------��।������ ����ᮢ--------------------------------------------------
class Products
  attr_reader  :prod

  def initialize
    @prod=Array.new
  end

  def create(a)
    puts "Method Create"
  end

  def add(*args)
    tovar=ProductItem.new
    if args.size==1 then
      v=args[0]
      if (v.class==Array) && (v.size==tovar.item.size) then
        i=0
        tovar.item.each_key do |key|
          tovar.add(key,v[i])
          i+=i
        end
      end
      if (v.class==Hash) && (v.size==tovar.item.size) then
        v.each {|key,val| tovar.item[key]=val}
      end
      # v="Val1 Val2 Val3 Val4" (ࠡ����� �� ���ᨢ �� �஡���) ��� ᨬ�����-ࠧ����⥫�� �१ split(",")
      if v.class==String && v.split.size==tovar.item.size then
        i=0
        v=v.split
        tovar.item.each_key do |key|
          tovar.add(key,v[i])
          i+=1
        end
      end
    else
      if args.size==0 then
        tovar.item.each_key do |key|
          puts "������ \"#{key}\" :"
          print ">"
          tovar.add(key,gets.chomp)
        end
      end
    end
    @prod.push(tovar.item)
  end

  def del(id)
    if @prod[id] != nil then
      @prod.delete_at(id)
      puts "������� � �����ᮬ #{id} �ᯥ譮 㤠���"
      puts
    else
      puts "�訡��! ������ ������ #{id} � ���ᨢ� ���!"
    end
  end

  def show
    if @prod.size >0 then
      puts
      puts "-"*79
      print "%-4s" % "�"
      @prod[0].each_key do |key|
        print "%-15s" % [key]
      end
      puts
      puts "-"*79
      @prod.each_with_index do |x,i|
        print "%-4s" % [i+1]
        x.each_value do |v|
          print "%-15s" % [v]
        end
        puts
      end
      puts "-"*79
      puts
    else
      puts "�� ����, �⮡ࠦ��� ��祣�! :(  ������ ENTER"
      gets
    end
  end
end

#------------------------------------

class ProductItem
  attr_accessor :item

  def initialize
    @item=Hash.new
    @item["name"]=nil
    @item["price"]=nil
    @item["count"]=nil
    @item["descr"]=nil
    @item["code"]=nil
  end

  def add(key,val)
    @item[key]=val
  end
end

# -----------�᭮���� �ணࠬ�� -----------------------------------------------

pobj=Products.new

tobj=ProductItem.new
tobj.add("name","����")
tobj.add("price",20)
tobj.add("count",40)
tobj.add("descr","��몠��� �����㬥��")
tobj.add("code","12ASWE-77")
pobj.add(tobj.item)

#  ---------��⮤� �᭮���� �ணࠬ��-------------------------------------------
def add(pobj)
  t=ProductItem.new
  value=Array.new
  t.item.each_key do |key|
    print "������ #{key}: "
    value<<gets.chomp
  end
  pobj.add(value)
end

def del(pobj)
  puts "��ᬮ��� ᯨ᮪ � �롥�� �����, ����� �㦭� 㤠����"
  puts "������ ��� ���浪���"
  print ":"
  n=gets.chomp
  n=n.to_i
  if n > 0 then
    pobj.del(n-1)
  else
    puts "�訡��! ������ 楫�� �᫮ > 0 !"
  end
end

def list(pobj)
  pobj.show
end
# ------------------------------------------------------------------------------
#
exit=false
kpress=false
while exit==false
  if kpress==false then
    puts <<-HEREDOC

                    +--------------------------------------------+
                    |                   ����                     |
                    +--------------------------------------------+
                    | ������ A, �⮡� �������� ���� ⮢��      |
                    | ������ P, �⮡� �ᯥ���� ᯨ᮪ ⮢�஢|
                    | ������ D, �⮡� 㤠���� ⮢�� �� ����     |
                    | ������ Q, �⮡� ���                     |
                    +--------------------------------------------+

    HEREDOC
  end
  c=$stdin.gets.chomp.upcase
  case c
    when "A","a","�","�"
      add(pobj)
      kpress=false
    when "P","p","�","�","L","l","�","�"
      list(pobj)
      kpress=false
    when "D","d","�","�"
      del(pobj)
      kpress=false
    when "Q","q","�","�"
      exit=true
      kpress=false
    else
      kpress=true
  end
end

