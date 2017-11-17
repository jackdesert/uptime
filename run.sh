#! /bin/bash
# Evaluate network uptime
#
# WHY cURL?
# Curl is a simple way to do tcp.
# We care about tcp because that is how our webserver accesses data.
# If curl fails, our webserver will fail.
#
# In the beginning we used ping (icmp) as our smoke test.
# But according to https://en.wikipedia.org/wiki/Packet_loss
# ping is considered low priority traffic, and when they are dropped they are not re-sent.
#
# Why Yahoo?
# Yahoo provides a small payload. (The word "redirect")
# Yahoo is ubiquitous.
# Yahoo is assumed to be up all the time.
#
# Why Bash?
# So we don't have to install anything extra to run this.
# Dependencies change things.



HOST='yahoo.com'

up_count=0
down_count=0

while true
do
  printf $(date +'%FT%H:%M:%S.%N')
  printf '  '

  curl --connect-timeout 4 $HOST > /dev/null 2> /dev/null
  if [ $? == 0 ]; then
    up_count=$((up_count+1))
    printf 'UP     '
  else
    down_count=$((down_count+1))
    printf 'DOWN   '
  fi


  printf 'successes: '
  printf $up_count

  printf '   failures: '
  printf $down_count

  printf '\n'

  sleep 1
done
