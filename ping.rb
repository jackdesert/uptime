require 'pry'
require 'sequel'

class Ping
  HOST = 'google.com'
  DB = Sequel.connect('sqlite://db/ping.db')

  def initialize
  end

  def up?
    !down?
  end

  def log_current_status
    time_at_start_of_ping = Time.now
    hash = { status: current_status, created_at: time_at_start_of_ping }
    pings.insert(hash)
    puts hash.to_s
  end

  def run
    while true
      sleep 1
      log_current_status_in_thread
    end
  end

  def create_table
    DB.create_table :pings do
      primary_key :id
      String :status
      DateTime :created_at
    end
  end


  private

  def log_current_status_in_thread
    Thread.new do
      log_current_status
    end
  end

  def current_status
    up? ? 'up' : 'down'
  end

  def pings
    DB[:pings]
  end

  def down?
    output = `ping -c1 -w4 #{HOST}`
    output.include?('100% packet loss')
  end


end


pinger = Ping.new
pinger.run
