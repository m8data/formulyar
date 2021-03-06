# Change Log
Все заметные изменения в этом проекте будут документированы в этом файле.

## [Unrelised]

## [0.9] - 2017-02-19
### Добавления
- функция m8:time
- скрипт mail.pl и функционал отправки писем через google-аккаунт

### Изменения
- Числа нормализуются стандартной perl-процедурой вместо применения выражений
- В админке панели поменялись местами: факт переместился налево, а квест направо.

## [0.8] - 2016-12-16
### Добавления
- m8-функции в стилях
- Поддержка отмены кэширования в IE
- Минимизация вида рабочих путей
- Архивация базы перед любыми удалениями в сушке

### Исправления
- Отцепление данных от сайта: скрипт и все стили перенастроены на единый реестр типов (name->nechto) m8/type.xml
- Лог-файлы перенесены в папку /formulyar, а основной скрипт грузится из /.plane/formulyar
- Интерфейс перемещений переработан
- Функция контроля вернулась на полные два круга (т.е. с повторным обходом юзеров)
- Интерфейс админки стал двухпанельным
- Полностью удален уровень данных 'author' в индексе и коде - авторство определяется по квесту или инициирующему триплу
- Тип данных определяется обнаружением d в портах предков, текущий предок идет из r порта, квест не зайствован при создании сущности
- Последовательная процедура создания номеров вместо "расширенного режима"
- Механизм установления связей в квестах
- Механизм перемещения нечто по дереву иерархии
- Многоуровневое размещение экземпляров в типах
- Параметры для квестов устанавливаются связями, а не в d
- Механизм поддержки атрибута состояния 'n/shag' - он не только сохраняется в порту, но и прокидывается сквозь редирект
- Редирект идет с статусом 307 - иначе браузер не корректно формирует историю
- Предохранители от множественности значений в портах


## [0.7] - 2016-10-18
### Добавления
- Требование использования квестов - иерархия/таксономия, 
- Автоматическое пореформатирование данных под иерархии
- Блока работы с соединениями/перемещениями/объединениями в админке
- Возможность переиндексаций по клику в админке
- Цветовая индикация собственника нечто
- Установлена блокировка версионирования статусов чужих нечто (т.е. в subject_r может быть только одна ветка)

### Изменения
- Отцепление данных и кода от текущих сайта и юзера
- Новый API редактирования базы: при любых редактированиях и созданиях в рабочем пути факт и только факт
- Новая система основных понятий
- В идентификатор нечто добавляется имя сайта

## [0.6] - 2016-10-05
### Добавления
- Возможно задействовать функцию обновления индекса после комитов
- Готовность работать в составе мультидоменного сайта
- Требование установки git

### Иcправления
- Префиксы
- Чистка триплов с любым уничтоженным нечто или нечно-квестом (ранее проверялись не все нечто)
- Автоподключение RAM-папки дезактивировано


## [0.0.5] - 2016-09-14
### Добавления
- Возможность функционирования системы внутри любых подпапок сайтов
- Параметры wwwRoot и tempfsFolder
- Процесс установки: автоматическое первичное индексирование сайта

### Изменения
- Директория фреймворка 'p' переименована в '.plane'
- Приведение инструкции в соответствие с добавлением "свободы" перемещения под папкам сайта
- Процесс установки: отказ от стандартного apache-конфига в пользу добавления в любой конфиг определенных директив

### Удаления
- Исключение необходимости устанавливать perl-модуль XML::LibXSLT


## [0.0.4] - 2016-09-09
### Иcправления
- Корректировка ссылки на дистрибутив wkhtmltopdf
- Правка Readme.md

## [0.0.3] - 2016-09-06
### Добавления
- Вывод на экран версии DMF
- Данные проекта хранятся в папке репозитория 
- Конфигурация сайта


## [0.0.2] - 2016-08-23
### Добавления
- Стиль "formulyar.xsl" отвечающий за административный раздел (в директории xslt-стилей "а").
- Данный лог и README.md.
- Возможность для любых авторизованных пользователей включать для текущего браузера режим отладки (отражается через аттрибут @debug в xml-файле сессии).
- Инструкции по установке и администрированию в директории "doc"

### Исправления
- Исправлена ошибка некорректного формирования pdf-отчета в linux (issue1).
- В корень добавлен файл шаблонного apache-конфига m8data.conf.

### Удаления
- Множество лишних директорий и файлов


## [0.0.1] - 2016-08-09
### Добавления
- Файлы проекта представлены в директориях "a" и "pl" и других.
