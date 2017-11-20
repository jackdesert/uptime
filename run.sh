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
# Why assets/simple.txt from our staging site?
# It's a small file that we control,
# being served directly from nginx so it's FAST.
# And it's in the amazon cloud which appears to have
# super reliable network.
#
# Why Bash?
# So we don't have to install anything extra to run this.
# Dependencies change things.



HOST='https://staging.elitecare.com/assets/simple.txt'

up_count=0
down_count=0


COMMAND="curl -k --max-time 8 $HOST > /dev/null 2> /dev/null"

echo '######################################################'
echo 'Uptime Monitor'
echo ''
echo $COMMAND
echo ''
echo '######################################################'

while true
do
  printf $(date +'%FT%H:%M:%S.%N')
  printf '  '

  eval $COMMAND
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

  sleep 0.1
done
