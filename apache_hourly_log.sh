#!/bin/bash

LOCKFILE=/tmp/otus_bash_lockfile  # для проверки, запущен ли уже скрипт
MAILFILE=/tmp/otus_bash_mailfile  # формируемый текст для передачи по почте
LOGFILE=/var/log/otus_bash.log    # лог запуска скрипта
LOGAPACHE=/root/otus/bash/log2    # анализируемый лог с актуальными датами
TIMELOG=$(date '+%d/%m/%Y:%H' -u -d "1 hour ago")  # начальное время анализа лога

# проверка, заущен ли ужк скрипт
if [[ -f $LOCKFILE ]]; then
  echo "$(date -u) script is already locked!" >> $LOGFILE 
  exit 1
fi

touch $LOCKFILE
trap 'rm -f $LOCKFILE $MAILFILE' EXIT  # удаление временных файлов при завершении

# функция анализа лога. параметр 1 - заголовок, параметр 2 - № анализируемого столбца лога
function myfunc {
  column=$2
  echo "" >> $MAILFILE
  echo $1 >> $MAILFILE
  grep $TIMELOG $LOGAPACHE | awk -v x="$column" '{print $x}' | sort | uniq -c | sort -nr >> $MAILFILE
}

echo "$(date -u) started" >> $LOGFILE 
echo "Log apache" > $MAILFILE
echo "Временной диапазон: "$TIMELOG":00:00 UTC - "$TIMELOG":59:59 UTC" >> $MAILFILE

myfunc "Список IP адресов с указанием количества запросов:" 1

myfunc "Список запрашиваемых URL:" 7

myfunc "Коды HTTP ответа:" 9

echo "" >> $MAILFILE
echo "Ошибки веб-сервера/приложения:" >> $MAILFILE
grep $TIMELOG $LOGAPACHE | grep  -e '" 4' -e '" 5' >> $MAILFILE  # коды ошибок клиента/сервера начинаются с 4/5

# отправление почты
cat $MAILFILE | mail -s "apache log" -S smtp="mx.skudrin.ru:25" -r admin@skudrin.ru admin@skudrin.ru 2>> $LOGFILE





