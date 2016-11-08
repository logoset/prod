# encoding: UTF-8
# ------------------------------------------------------------------------------
#  ЭТОТ БЛОК КОДА НУЖЕН, чтобы переменные в методах puts, p, inspect
# выводились на экран в правильной русской кодировке
# найдено в интернете
if (Gem.win_platform?)
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end
# ------------------------------------------------------------------------------
#
# Таблица-массив продуктов
# ╔═════════╤══════╤══════════╗
# ║ Артикул │ цена │ описание ║
# ╠═════════╪══════╪══════════╣
# ║         │      │          ║
# ╚═════════╧══════╧══════════╝
# [[articul1,price1,comment1],[article2,price2,comment3],[]...]
#
# ------------------------------------------------------------------------------

# Класс для работы с массивом товаров
class Products
  def initialize
    @products=[]
  end
  # метод добавляющий тестовые значения товаров в @products
  def  add_test_values
    @products << ["AS23FGH-12","123","Baton"]
    @products << ["AS23","50","Steel"]
    @products << ["B17","300","Смартфон"]
    puts "-"*49
    puts "Тестовые значения добавлены успешно"
    list
    msg_enter
  end

  # метод добавляет в @products значения нового товара, как массив b
  def add_by_array(b)
    @products.push(b)
    puts "Добавлен товар с полями #{b} в ввиде массива"
    list
    msg_enter
  end

  # удаление из @products товара с порядковым номеров id
  def delete_by_id(id)
    # Если значение с индексом id существует в массиве @products, т.е. не равно nil
    if @products[id]!=nil then
      puts "Удален товар #{@products[id]} с порядковым номером #{id+1}"
      @products.delete_at(id)
      msg_enter
    else
      puts "!!!Удаляемый элемент в массиве товаров c номером #{id} не найден!!!"
      msg_enter
    end
  end

  # метод изменяет в @products товар с порядковым номером id на значения массива b
  def change_index_by_array(id,b)
    # если в массиве "b" пустые значения элементов "" или nil, то не изменяем их
    # для этого "старые" значения берем в @products[id][i] и сохраняем в b[i]
    b.each_with_index do |val,i|
      b[i]=@products[id][i] if (val==""||val==nil)
    end
    if @products[id]!=nil then
      puts "Товару с номером #{id+1}"
      puts "изменили поля #{@products[id]} на #{b}"
      @products[id]=b
      list
      msg_enter
    else
      puts "!!!Изменяемый элемент в массиве товаров c номером #{id} не найден!!!"
      msg_enter
    end
  end

  # метод выводит список товаров, которые есть в @products
  def list
    if @products.length >0 then

      puts "┌──────────────┐".center(79)
      puts "│СПИСОК ТОВАРОВ│".center(79)
      puts "─"*31+"┴"+"─"*14+"┴"+"─"*32
      i=1
      # строку форматируем: %-числоs 30символов для строк, перечисленных в массиве
      puts("%-4s %-15s %-8s %-35s" % ["№","Артикул", "Цена,руб","Описание"])
      puts "═"*79
      # Проходим по всему массиву товаров a
      @products.each do |item|
        # и распечатываем индекс элемента i,  а также с форматированием значения элеметов item каждого товара
        puts "%-4s %-15s %-8s %-35s" % [i,item[0],item[1],item[2]]
        i+=1
      end
      puts "─"*79
    else
      puts "-"*49
      puts "ТОВАРОВ ЕЩЕ НЕТ!"
      msg_enter
    end
  end

  # метод, который выводит сообщение и ждет нажатия клавиши ENTER
  def msg_enter
    puts "Для продолжения нажмите клавишу ENTER"
    gets
  end
end

# ------------------------------------------------------------------------------
#                     Методы основной программы
# ------------------------------------------------------------------------------

# метод добавления нового товара, где t - экземпляр класса Products
def add(t)
  puts "ДОБАВЛЕНИЕ НОВОГО ТОВАРА, введите следующие поля:\n\r"
  input=Array.new
  puts 'артикул(уникальный номер):'
  print ">"
  # символ << одна из форм добаления в конец массива inp значения
  # все, что мы ввели на экран, возвращается функцией gets и заносится в массив inp
  input<<gets.chomp
  puts 'цена:'
  print ">"
  input<<gets.chomp
  puts 'описание товара:'
  print ">"
  input<<gets.chomp
  t.add_by_array(input)
end

# метод удаления товара, где t - экземпляр класса Products
def del(t)
  puts "УДАЛЕНИЕ ТОВАРА"
  t.list
  puts 'Найдите в списке товар, который необходимо УДАЛИТЬ:'
  print "Введите номер>"
  input=gets.chomp
  # если input не число, то метод to_i вернет 0
  # т.к. у нас выввод порядковогономера в списке товаров
  # на экране начинается с 1, то у нас значение input
  # заведомо должно быть >0
  if input.to_i > 0 then
    t.delete_by_id(input.to_i-1)
  else
    puts "#{input} -> Порядковый номер должен быть целым числом >0!!!"
    t.msg_enter
  end
end

# метод изменения товара, где t - экземпляр класса Products
def change(t)
  puts "ИЗМЕНЕНИЕ ТОВАРА"
  t.list
  puts "Найдите в списке товар, который необходимо ИЗМЕНИТЬ"
  print "Введите номер>"
  input=gets.chomp
  if input.to_i > 0 then
    puts "Теперь введите НОВЫЕ ЗНАЧЕНИЯ:"
    puts "(если значение пустое, то оно не изменится)\n\r"
    vinput=Array.new
    puts 'артикул(уникальный номер):'
    print ">"
    vinput<<gets.chomp
    puts 'цена:'
    print ">"
    vinput<<gets.chomp
    puts 'описание товара:'
    print ">"
    vinput<<gets.chomp
    t.change_index_by_array(input.to_i-1,vinput)
  else
    puts "#{input} -> Порядковый номер должен быть целым числом >0!!!"
    t.msg_enter
  end
end

# ------------------------------------------------------------------------------
#                       Основная программа
# ------------------------------------------------------------------------------

# Создаем объект товара tovar на основе класса Products
tovar=Products.new
# exitval - переменная флаг, в которой хранится истина или ложь
exitval=false
# пока в переменной exitval ложь, будет выполняться вечный цикл
# программа выйдет из вечного цикла, когда мы присвоим переменной exitval значение true
while (exitval==false)
  # На экран печатем меню, для взаимодейсствия с пользователем
  puts "-"*49
  puts "МЕНЮ - выберете первую букву меню и нажмите ENTER"
  puts "-"*49
  puts "(L) Список товаров"
  puts "(T) Добавить тестовые значения товара"
  puts "(A) Добавить товар"
  puts "(D) Удалить товар"
  puts "(С) Изменить товар"
  puts "(Q) Выход из программы"

  # ожидаем ввода значения с клавиатуры и сохраняем его в переменной choice
  choice=gets.chomp

  # переменная choice приводится к верхнему регистру, методом upcase.
  # в зависимости от значения choice
  # отрабатывается соответсвующая ветка операторв case->when
  case choice.upcase
    when "L","Д","д"
      system('cls');tovar.list
    when "A","Ф","ф"
      system('cls');add(tovar)
    when "D","В","в"
      system('cls');del(tovar)
    when "C","С","с"
      system('cls');change(tovar)
    when "T","Е","е"
      system('cls');tovar.add_test_values
    when "Q","Й","й"
      # если нажата q , то выходим из вечного цикла и завершаем программу
      exitval=true
  end
end
