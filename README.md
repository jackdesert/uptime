Uptime
======

A micro tool for evaluating the uptime of your internet service provider (ISP).

Bash-Only Version
-----------------

If you want to run a bash-only version of Uptime (fewer dependencies),
simply start `screen`, then call:

    ./run.sh


Why
---

Reliable Internet is sometimes more important that fast Internet. When it goes
down, even if it's just for a few seconds, it interrupts thought processes,
disconnects from Skype calls, halts downloads, and aborts ssh sessions. Is
your ISP living up to its promise of four nines? You can find out.


How it Works
------------

Every second, a new thread initiates a ping to google.com to see whether it
gets a response or not. The ping is given a four second timeout. A ping that
returns an exit status of 0 is logged as a success. Any other exit status
is logged as a failure. Each ping (including its stdout and stderr) is saved
to an sqlite database in db/ping.db so you can query for distinct failure modes.


Storage Size
------------

You can limit the total size of data captured by editing Ping::MAX_AGE_IN_HOURS

Also, make sure you are not storing the entire log unless you have
some method of log rotation in place.


OSX
---

If you are running this on OSX, you will need to change Ping::COMMAND
to use "-t" instead of "-w"


Prerequisites
-------------

    sudo apt-get install libsqlite3-dev


Installation
------------

    git clone git@github.com:jackdesert/uptime.git
    cd uptime
    bundle


Gather Data
-----------

    ruby run.rb

Sample output:

>   --- google.com ping statistics ---
>
>   1 packets transmitted, 1 received, 0% packet loss, time 0ms
>
>   rtt min/avg/max/mdev = 44.124/44.124/44.124/0.000 ms
>
>   stderr:
>
>   created_at: 2014-03-28 08:29:46 -0700
>
>   exitstatus: 0
>
>   up?: true
>
>   stdout: PING google.com (173.194.33.97) 56(84) bytes of data.
>
>   64 bytes from sea09s16-in-f1.1e100.net (173.194.33.97): icmp_req=1 ttl=128 time=42.9 ms



Display Stats
-------------

In a separate terminal window, you can ask for the running average.

    ruby stats.rb

Sample output from Century Link:

> Total pings: 32215
>
> Up: 29359
>
> Down: 2856
>
> 91.135% uptime


Starting Fresh
--------------

    rm db/ping.db
    ruby run.rb


