#! /bin/bash
# ping HOST and write "up" or "down" to STDOUT

HOST='google.com'

up_count=0
down_count=0

while true
do
  ping -c1 -w4 $HOST > /dev/null 2> /dev/null
  if [ $? == 0 ]; then
    up_count=$((up_count+1))
    printf 'UP     '
  else
    down_count=$((down_count+1))
    printf 'DOWN   '
  fi

  printf 'up: '
  printf $up_count

  printf '   down: '
  printf $down_count

  printf '\n'

  sleep 1
done
