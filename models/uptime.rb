require 'sequel'
require 'open3'

class Ping
  HOST = 'google.com'
  DB = Sequel.connect('sqlite://db/ping.db')
  COMMAND = "ping -c1 -w4 #{HOST}"

  attr_accessor :exitstatus, :stdout, :stderr, :created_at

  def pings
    DB[:pings]
  end

  def down?
    !up?
  end

  def print
    [:up?, :stdout, :stderr, :created_at, :exitstatus].each do |key|
      puts "#{key}: #{ping.send(key)}"
    end
  end

  def log_current_status_in_thread
    Thread.new do
      log_current_status
    end
  end

  private

  def up?
    exitstatus == 0
  end

  def fire
    self.created_at = Time.now
    Open3.popen3( COMMAND ) do |blockk_stdin, block_stdout, block_stderr, wait_thr|
      self.stdout = block_stdout.read
      self.stderr = block_stderr.read
      self.exitstatus = wait_thr.value.exitstatus
    end
  end

  def log_current_status
    fire
    hash = { up: up?, exitstatus: exitstatus, stdout: stdout, stderr: stderr, created_at: time_at_start_of_ping }
    pings.insert(hash)
    puts hash.to_s
  end
end

