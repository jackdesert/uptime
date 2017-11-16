#! /bin/bash
# ping HOST and write "up" or "down" to STDOUT

HOST='google.com'


while true
do
  ping -c1 -w4 $HOST > /dev/null 2> /dev/null
  if [ $? == 0 ]; then
    printf 'up\n'
  else
    printf 'down\n'
  fi

  sleep 1
done
