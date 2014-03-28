require 'sequel'
require 'open3'


require 'pry'
require 'sequel'
require 'open3'

module Uptime

  class << self

    def run
      Ping.create_table_if_not_present
      while true
        sleep 1
        Ping.new.log_current_status_in_thread
      end
    end

    def pings
      Ping::DB[:pings]
    end

    def stats
      ups = pings.where(up: true).count
      downs = pings.where(up: false).count
      total = ups + downs
      uptime_as_percent = 100.0 * ups / total 
      puts "Total pings: #{total}"
      puts "Up: #{ups}"
      puts "Down: #{downs}"
      puts "#{uptime_as_percent.round(3)}% uptime"
    end

  end
end


