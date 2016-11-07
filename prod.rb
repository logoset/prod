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
if Gem.win_platform?
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end
# ------------------------------------------------------------------------------
# Если defug=true, то обойти все gets, обойти ввод значений с терминала, со стандартного вводжа $input
$debug=false

# ---------Определения классов--------------------------------------------------
class Products
  attr_reader  :prod

  def initialize
    @prod=Array.new
  end

  def create(a)
    puts 'Method Create'
    @alpha = a
  end

  def add(*args)
    tovar=ProductItem.new
    if args.size==1
      v=args[0]
      if (v.class==Array) && (v.size==tovar.item.size)
        i=0
        tovar.item.each_key do |key|
          tovar.add(key,v[i])
          i+=1
        end
      end
      v.each { |key, val| tovar.item[key]=val } if (v.class==Hash) && (v.size==tovar.item.size)
      # v="Val1 Val2 Val3 Val4" (рабиваем на массив по пробелу) или символом-разделителем через split(",")
      if v.class==String && v.split.size==tovar.item.size
        i=0
        v=v.split
        tovar.item.each_key do |key|
          tovar.add(key,v[i])
          i+=1
        end
      end
    else
      if args.size==0
        tovar.item.each_key do |key|
          puts "Введите \"#{key}\" :"
          print '>'
          if !$debug
            tovar.add(key,gets.chomp)
          else
            tovar.add(key,"#{key}#{rand(100)}")
          end
        end
      end
    end
    @prod.push(tovar.item)
  end

  def del(id)
    if @prod[id] != nil
      @prod.delete_at(id)
      puts "Элемент с индексом #{id} успешно удален"
      puts
    else
      puts "Ошибка! Такого индекса #{id} в массиве нет!"
    end
  end

  def show
    if @prod.size >0
      puts
      puts '-'*79
      print "%-4s" % '№'
      @prod[0].each_key { |key| print "%-15s" % [key] }
      puts
      puts '-'*79
      @prod.each_with_index do |x,i|
        print "%-4s" % [i+1]
        x.each_value { |v| print "%-15s" % [v] }
        puts
      end
      puts '-'*79
      puts
    else
      puts 'Все пусто, отображать нечего! :(  Нажмите ENTER'
      gets
    end
  end
end

#------------------------------------

class ProductItem
  attr_accessor :item

  def initialize
    @item=Hash.new
    @item['name']=nil
    @item['price']=nil
    @item['count']=nil
    @item['descr']=nil
    @item['code']=nil
  end

  def add(key,val)
    @item[key]=val
  end
end

# -----------Основная программа -----------------------------------------------

pobj=Products.new

tobj=ProductItem.new
tobj.add('name', 'Гитара')
tobj.add('price', 20)
tobj.add('count', 40)
tobj.add('descr', 'Музыкальный инструмент')
tobj.add('code', '12ASWE-77')
pobj.add(tobj.item)

#  ---------методы основной программы-------------------------------------------
def add(pobj)
  t=ProductItem.new
  value=Array.new
  t.item.each_key do |key|
    print "Введите \"#{key}:\" "
    if !$debug
      value<<gets.chomp
    else
      value<<"#{key}#{rand(100)}"
    end
  end
  pobj.add(value)
end

def del(pobj)
  puts 'Посмотрите список и выберите элемент, каторый нужно удалить'
  puts 'Введите его порядковый'
  print ':'
  n=gets.chomp
  n=n.to_i
  if n > 0
    pobj.del(n-1)
  else
    puts 'Ошибка! Введите целое число > 0 !'
  end
end

def list(pobj)
  pobj.show
end
# ------------------------------------------------------------------------------
#
exit=false
kpress=false
until exit
  unless kpress
    puts <<-HEREDOC

                  +--------------------------------------------+
                  |                   МЕНЮ                     |
                  +--------------------------------------------+
                  | Нажмите A, чтобы добавить новый товар      |
                  | Нажмите P, чтобы распечатать список товаров|
                  | Нажмите D, чтобы удалить товар из базы     |
                  | Нажмите Q, чтобы выйти                     |
                  +--------------------------------------------+

    HEREDOC
  end
  if !$debug
    c=$stdin.gets.chomp.upcase
  else
    c='A'
  end
  case c
    when 'A', 'a', 'Ф', 'ф'
      add(pobj)
      kpress=false
    when 'P', 'p', 'З', 'з', 'L', 'l', 'Д', 'д'
      list(pobj)
      kpress=false
    when 'D', 'd', 'В', 'в'
      del(pobj)
      kpress=false
    when 'Q', 'q', 'Й', 'й'
      exit=true
      kpress=false
    else
      kpress=true
  end
end

