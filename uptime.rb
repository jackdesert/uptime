require 'pry'
require 'sequel'
require 'open3'

module Uptime
  HOST = 'google.com'
  DB = Sequel.connect('sqlite://db/ping.db')
  COMMAND = "ping -c1 -w4 #{HOST}"
  FAILURE_STRINGS = ['100% packet loss']


  class << self

    def run
      create_table_if_not_present
      while true
        sleep 1
        log_current_status_in_thread
      end
    end

    def stats
      ups = pings.where(status: 'up').count
      downs = pings.where(status: 'down').count
      total = ups + downs
      uptime_as_percent = 100.0 * ups / total 
      puts "Total pings: #{total}"
      puts "Up: #{ups}"
      puts "Down: #{downs}"
      puts "#{uptime_as_percent.round(3)}% uptime"
    end

    def pings
      DB[:pings]
    end

    private
    def create_table_if_not_present
      DB.create_table? :pings do
        primary_key :id
        String :status
        String :output
        DateTime :created_at
      end
    end

    def up?(output)
      output.include?('64 bytes from')
    end

    def log_current_status
      time_at_start_of_ping = Time.now
      output = fetch_output
      hash = { status: current_status(output), created_at: time_at_start_of_ping, output: output }
      pings.insert(hash)
      puts hash.to_s
    end

    def fetch_output
      Open3.popen3( COMMAND ) do |stdin, stdout, stderr, wait_thr|
        puts stdin
        puts "\n\n\nstdout: #{stdout.read}"
        puts "\n\n\nstderr: #{stderr.read}"
        puts "\n\n\npid: #{wait_thr.pid}"
        puts "\n\n\nexit_status: #{wait_thr.value.exitstatus}"
        binding.pry
      end
    end

    def log_current_status_in_thread
      Thread.new do
        log_current_status
      end
    end

    def current_status(output)
      up?(output) ? 'up' : 'down'
    end

  end
end


Uptime.send :fetch_output
#Uptime.run
