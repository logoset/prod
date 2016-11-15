# С нуля разработать историю хранения сообщений
#кто, кому, дата,время,сообщение
#
# Массив дат, к ним привязаны сообщения
# [11.12.2007,15.01.2008,23.02.16]
#    |        |               |
#    V        V               V
#  "Привет" "Как дела?"   "Нормально"
#  1 выриант хранения сообщений:
#   [[data1,msg1],[data2,msg2],[data3,msg3],...[,]]
#  2 выриант хранения сообщений:
#   [{data=>"data1",msgs=>"msg1"},{data=>"data2",msgs=>"msg2"},..{,}]
#  3 выриант хранения сообщений:
#   {data=>[data1,data2,data3..dataN],msg=>[msg1,msg2,msg3..msgN]}
#
# ------------------- RUSSIAN ENCODING WORKING CORRECTLY -----------------------
if Gem.win_platform?
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end
# ------------------------------------------------------------------------------

require "yaml"

$DEBUG=false

class Message
  attr_accessor :history_messages

  def initialize
    @history_messages=Array.new
    @msg=[]
    open
    #@message=Hash.new
    #@message["data"]=nil
    #@message["msg"]=nil

  end

  def open
    if File.exists?('messages.yml')		#tests whether there is a specified yml file available
      #@history_messages = YAML.load(File.read('messages.yml', encoding: 'UTF-8'))	#replaces the history-messages array with the messages of the yml file.
      #@history_messages = YAML.load(File.read('messages.yml', encoding: 'UTF-8').force_encoding 'UTF-8')
      @history_messages = YAML.load_file("messages.yml")
    end
  end

  def save 		#this will save the contents of the contacts array into a text based yml file
    File.open('messages.yml', 'w:UTF-8') do |file|		#Opens the messages.yml file in the writing("w") mode and UTG-8 encoding. The file requires yaml to load (specify at the top like a ruby file)
      file.write(@history_messages.to_yaml)				#The contents of the history_messages array are written into the file specified above. The object is written into the file each time the method runs.
    end
  end


  def push_msg(data, msg)
    #добавляем значения data в секундах, переводим чеоез метод Time.to_i
    @history_messages << [data.to_i, msg]
    # сортируем массив сообщений
    @history_messages.sort!
  end

  # удаления сообщений
  def delete_msg(id)
    if @history_messages[id-1]!=nil
      puts "Сообщение с номером #{id} успешно удалено"
      @history_messages.delete_at(id-1)
      # сортируем массив сообщений
      @history_messages.sort!
    else
      puts "Ошибка! Такого сообщения с номером #{id} не существует!!!".center(79)
    end
  end

  # what = выборка по диапазону дат, в днях, разница в днях
  # year ago, month ago,week ago, yesterday, today
  def archive_msg(what)
    # или получаем через методы класса Date дату what дней назад и переводим ее в числовое значение секунд формата unix
    what=(Time.now.to_i)-(what*86400) #86400 - кол-во секунд в сутках, т.е. приводим ко дню, но в секундах
    if @history_messages.any?
      # сортируем массив, чтобы даты были по возрастающей
      @history_messages.sort!
      # устанавливаем индекс перебора в массивае на его конец...
      i=@history_messages.size-1
      # и далее ищем в цикле сообщение, у которого дата меньше или равна той, что передана, как параметр в what
      while i >= 0 do
        # если меньше, то добрались до того индекса в массиве, с которого нужно печатать историю сообщений
        if @history_messages[i][0]<= what
          # Передаем на печать индекс элемента, с которого надо начинать печатать сообщения
          # в direction - направление вывода списка сообщений, т.е "+" новые сообщения вверху, а когда "-" внизу
          list_messages_from(i, '-')
          # выходим из цикла,т.к. от какой "архивной даты" начинать выводить на экран сообщения уже нашли,
          # дальше перебирать массив не нужно (при условии, что он отсортирован по датам)
          break
        end
        # уменьшаем счетчик индекса, чтобы "просмотреть" в цикле while следующее (точнее предыдущее) значение в @history_messages
        i-=1
      end
    else
      puts 'Сообщений нет!!! Отображать нечего ;('.center(79)
    end
  end

  def list_messages_from(index, direction)
    # если массив сообщений не пустой, то
    if @history_messages.any?
      # вычисляем максимальную ширину колонки под номера сообщений
      num_col_size=@history_messages.size.to_s.size
      # считаем, что даты в массиве @history_messages записаны последовательно и упорядочены по возрастанию даты
      # т.е. в самом начале более поздние сообщения, чем вконце
        # в зависимости от направления вывода списка сообщений - разные условия цикла итерации для распечатки значений
      if direction=='+'
        idx_from=index
        idx_to=0
        step=-1
      else
        idx_from=0
        idx_to=index
        step=1
      end
        # устанавливаем переменную времени, где будет храниться время, если оно отличается от предыдущего
        temp_time_value=''
        # цикл по значениям сообщений в массиве @history_messages реализуем на числовом итераторе step
        # начинаем пошаговую итерацию от значения idx_from до значения idx_to с шагом step
        idx_from.step(idx_to,step) do |i|
          # если в переменной temp_time_value такая же дата дд.мм.гггг, как и в сообщении,
          # которое обрабатывается в этой итерации @history_messages[i][0].strftime('%d.%m.%Y'), то
          if temp_time_value==Time.at(@history_messages[i][0]).strftime('%d.%m.%Y')
            # вычисляем в переменную datetime дату в формате: только время
            datetime=Time.at(@history_messages[i][0]).strftime('%T')
          else
            # печатаем строчку для отделения от предыдущих дат (длиной, равной длине колонок порядкового номера и даты)
            puts '-'*(num_col_size+20)
            # сохраняем дату этого сообщения во временную переменную temp_time_value,
            # потом, на следующей итерации будем сравнивать с датой нового сообщения
            temp_time_value=Time.at(@history_messages[i][0]).strftime('%d.%m.%Y')
            # вычисляем в переменную datetime дату в формате: дата и время
            datetime=Time.at(@history_messages[i][0]).strftime('%d.%m.%Y %T')
          end
          # печатаем все подготовленные данные - номер, дата, сообщение в одну строку с соответвующим форматированием каждого значения
          #puts "%-#{num_col_size}s %20s %s" % [(direction=="+"?idx_from-i+1:i+1), datetime, @history_messages[i][1]]
          puts "%-#{num_col_size}s %20s %s" % [i+1, datetime, @history_messages[i][1]]
        end
    else
      puts 'Сообщений нет, отображать нечего!!!'.center(79)
    end
  end

  # поиск текста txt в массиве сообщений
  def find_msg(txt)
    # если есть сообщения в массиве сообщений @history_messages
    if @history_messages.any?
      # сортируем массив сообщений, если он неупорядочен

      puts 'СПИСОК НАЙДЕННЫХ СООБЩЕНИЙ'.center(79)
      # вычисляем максимальную ширину колонки под номера сообщений
      num_col_size=@history_messages.size.to_s.size
      # заголовок
      puts "%-#{num_col_size}s %20s %s" % %w(№ Дата Сообщение)
      # последовательный перебор значений массива, вмесе со значением его индекса
      @history_messages.each_with_index do |x, i|
        #  если в текущем элементе массива "x", который тоже есть массив, есть фраза "txt"
        if x[1].include?(txt)
          # то выводим на экран в формате списка #, дата, сообщение. дату преобразуем из секунд в строку с форматом
          puts "%-#{num_col_size}s %20s %s" % [i+1, Time.at(@history_messages[i][0]).strftime('%m.%d.%Y %T'), @history_messages[i][1]]
        end
      end
    else
      # иначе печатаем о невозможности отобразить список
      puts ' Сообщений нет, искать нечего!!!'.center(79)
    end
  end

  def clear_msg
    @history_messages.clear
    puts 'Все сообщения удалены успешно!'.center(79)
  end

end
# ---------------------------------------------------------------------

#  метод печати меню
def print_menu
  puts <<-MENUDOC
           +-------------------------------------------------------+
           |                        MENU                           |
           |----------------View Messages History------------------|
           |Nazhmite (A), chtobi posmotret perepisku god nazad     |
           |Nazhmite (B), chtobi posmotret perepisku mesyac nazad  |
           |Nazhmite (C), chtobi posmotret perepisku nedelyuo nazad|
           |Nazhmite (D), chtobi posmotret perepisku vchera        |
           |Nazhmite (E), chtobi posmotret perepisku segodnya      |
           |--------------------Service Menu-----------------------|
           |Add test (M)essages to History                         |
           |List all message (L)                                   |
           |Find message with (T)ext                               |
           |Remove (R) message                                     |
           |Clear messaging database (DEL)                         |
           |Quit (Q)                                               |
           +-------------------------------------------------------+
  MENUDOC
end

# метод генерации строки сообщения случайным образом(случаайной длины от 1 до 4 слов и с набором случайных слов из массива строк "s")
def sgen
  # массив с набором разных строк, так сказать словарь, по которому генерируется сообщение
  s=['Привет', 'как дела', 'что нового?', 'приезжай', 'люблю вкусно поесть', 'играю', 'велосипед', 'водитель', 'на работе', 'солнце', 'погода', 'дожди', 'друзья придут', 'You have a good joke', 'Do you love to play games?', 'Today i received two', 'Do you whant to meet me?']
  sgen=''
  # длина слова от 1 до 4 фраз из массива s. Каждая новая фразаз сива "s" соединяется через пробел " "
  rand(1..4).times { sgen=sgen+' '+s[rand(s.length-1)]+' ' }
  # возвращаем строку
  sgen
end

def addtest(m)
  # 5.times {'что-то'} - значит сделать 'что-то' 5 раз
  # Time.now - возвращает текущую дату , Time - это стандартный класс работы со временем в Ruby
  # Time.now.to_i - переводит полученую текущую дату в формат unix epoch, т.е в количество секунд начиная с 01.01.1970 года
  # а rand((N..(N+K)))*86400) расчет случайного значения в интервале от N и до N+K, приведенное к секундам
  # где N - количество дней, относительно текущей даты, а K количество дней в глубину прошлого, задающего интервал разброса
  # например, n=rand(365..(365+30)) - случайное кол-во дней в диапазоне от заданного значения 365, до 365+30 дней
  # если его умножить на *86400 , то получатся секунды. Их и вычитаем из Time.now.to_i
  # чем больше верхняя граница диапазона у метода rand(нижняя...верхняя), тем глубже в прошлое опускается дата, тем больше разброс
  # т.е. будут генерироваться даты с днями позднее чем 365, позднее на 30 дней...как как-то так
  # Time.at(sec) - переводит секунды в формат даты-времени, его то и передаем, как первый параметр метода m.push_msg(data,msg)
  # +rand(-24..24)*3600 + rand(-60..60)*60) - это соответственно случайные +- 24 часы и +-60 минуты
  # от вычесленной ранее в выражении случайной даты Time.now.to_i-rand((730..(730+30)))*86400
  # sgen - это его второй параметр, само сообщение, точнее это значение строки, которое генерируется методом sgen() (см.выше по тексту программы)

  # цикл по следующим значениям [[d1,t1,h1], [d2,t2,h2]...[d1,t1,h1]], где в [dN,tN,hN]:
  # первое значение dN: 730:2года,365:1год,30дней,7дней,1день,0дней(сегодня)
  # второе значение tN: отклонение в днях(относительно первого значения), задающим интервал для случайной даты в этом диапазоне
  # третье значение hN: отклонение часов, тут величина стандартная 24 часа, в формуле это случайная величина от -24 часов до 0
  # в цикле эти значения появляются в переменной param[0] и param[1] и param[2], как элементы подмассива, соответственно
  # последний rand - это случайные минуты от -60 до 0 (минус - это значит в прошлое)
  [[730, 30, 24], [365, 30, 24], [30, 10, 24], [7, 5, 24], [1, 3, 24], [0, 0, 0]].each { |param|
    5.times { m.push_msg(Time.at(Time.now.to_i-rand((param[0]..(param[0]+param[1])))*86400+rand(-param[2]..0)*3600+rand(-60..0)*60), sgen) }
  }
  # 5 раз добавить сообщения со случайным значением даты в пределах последних 24-х часов
  ## 5.times {m.push_msg(Time.now-rand(24*60*60),sgen) }

  puts 'Тестовые сообщения сгерерированы случайным образом!'.center(79)
end

# Метод поиска сообщений по содержащимся в них искомом слове или фразе
def find(m)
  puts 'ПОИСК СOОБЩЕНИЙ'.center(79)
  puts 'Введите текст, который должен содержаться в сообщениях:'
  print '>'
  # $DEBUG нужно для отладки, чтобы gets не повешивал
  if !$DEBUG
    # если $DEBUG=false, то значит получаем значение искомого слова у пользователя с клавиатуры
    input=gets.chomp
  else
    # если $DEBUG=true, то просто переменной input сразу присваиваем слово  "велосипед"
    input='велосипед'
  end
  # вызываем сам метод поиска по массиву ссобщений. метод find_msg - это метод экземпляра "m", класса Message
  m.find_msg(input)
end

# Метод запроса номера сообщения для удаления
def delete(m)
  puts 'Введите порядковый номер сообщения, которое нужно удалить:'
  print '>'
  # если переменная $DEBUG не расно true, т.е. если не установлен флаг отладки, то
  if !$DEBUG
    #  забираем номер удаляемого сообщения с клавиатуры
    input=gets.chomp
  else
    # иначе случайное значение от 0 до размера массива @history_messages -1
    input=rand(m.history_messages.size-1)
  end
  if input.to_i > 0
    # если введенное с клавиатуры значение переводится в целое и при этом > 0,
    # то вызываем матод delete_msg
    m.delete_msg(input.to_i)
  else
    puts "Ошибка! Вы ввели #{input}".center(79)
    puts 'Порядковый номер должен быть положительный целым числом!!!'.center(79)
  end
end

def delete_all(m)
  puts 'Вы уверены, что хотите очистить базу данных сообщений?[yes(Y)/NO(N)]'
  # запрашиваем с клаиатуры ввод строки, которую перевеодим в нижний регист, а затем сравниваем
  if $DEBUG
    input='n'
  else
    input=gets.chomp.downcase
  end
  case input
    when 'y'
      m.clear_msg
    when 'n'
      puts 'Вы отказались от удаления сообщений, спасибо!'
    else
      puts 'нажата другая клавиша выбора, потому по умолчанию она будет "N"'
      puts 'сообщения не удалены!'
  end
end

# генератор случайного символа из строки заданных символов
# нужен для работы меню при отладке, когда установлена переменная $DEBUG в true
def gen_random_char
  s='abcdemq'
  #  возвращает случайный символ из строки,
  #  индекс обращения к строке выбирается случайным образом jn 0 до значения длины этой строки-1
  s[rand(s.length)-1]
end

# метод ожидания нажатия ENTER, плюс показывает уведомление об этом
def msg_enter
  puts
  puts 'Для продолжения нажмите клавишу ENTER '
  STDIN.getc
end

#------------------------------------------------------------------
#              MAIN PROGRAM
#------------------------------------------------------------------
# Создаем экземпляр класса Message
m=Message.new

keypress=true
loop do
  print_menu if keypress
  t=gets.chomp
  # проверяем введенное значения t, для этого переводим его в верхний регистр методом класса String - upcase
  # даже если ввели в маленьком регистре, мы всегда сравним с каким-то одним значением регистра
  t=t.upcase
  case t
    when 'M'
      addtest(m)
      keypress=true
      msg_enter
    when 'A'
      m.archive_msg(365)
      keypress=true
      msg_enter
    when 'B'
      m.archive_msg(30)
      keypress=true
      msg_enter
    when 'C'
      m.archive_msg(7)
      keypress=true
      msg_enter
    when 'D'
      m.archive_msg(1)
      keypress=true
      msg_enter
    when 'E'
      m.archive_msg(0)
      keypress=true
      msg_enter
    when 'T'
      find(m)
      keypress=true
      msg_enter
    when 'R'
      delete(m)
      keypress=true
      msg_enter
    when 'L'
      m.list_messages_from(m.history_messages.size-1, '-')
      keypress=true
      msg_enter
    when 'DEL'
      delete_all(m)
      msg_enter
    when 'Q'
      m.save() # сохранить результат
      break # выйти из вечного цикла loop do...end
    else
      if t.index(/[а-яА-ЯЁё]/)
        puts 'переключите раскладку клавиатуры на EN'.center(79)
      end
      if t.index(/[a-zA-Z]/)
        puts 'такой буквы выбора в меню нет!'.center(79)
        puts 'будьте внимательнее при выборе :)'.center(79)
      end
      keypress=false
  end
end
























