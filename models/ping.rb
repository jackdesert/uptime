require 'sequel'
require 'open3'

class Ping
  HOST = 'google.com'
  DB = Sequel.connect('sqlite://db/ping.db')
  COMMAND = "ping -c1 -w4 #{HOST}"

  MAX_AGE_IN_HOURS = 72
  MAX_AGE_IN_SECONDS = MAX_AGE_IN_HOURS * 3600

  attr_accessor :exitstatus, :stdout, :stderr, :created_at

  def pings
    DB[:pings]
  end

  def down?
    !up?
  end

  def print
    status = up? ? 'up  ' : 'down'
    timestamp = created_at.strftime('%H:%M:%S')
    puts "#{status} #{timestamp}"
  end

  def log_current_status_in_thread
    Thread.new do
      log_current_status
      trim_table
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
    hash = { up: up?, exitstatus: exitstatus, stdout: stdout, stderr: stderr, created_at: created_at }
    pings.insert(hash)
    print
  end


  def trim_table
    old_pings = DB[:pings].where('created_at < ?', Time.now - MAX_AGE_IN_SECONDS)
    count = old_pings.delete
  end


  def self.create_table_if_not_present
    unless DB.table_exists?(:pings)
      DB.create_table :pings do
        primary_key :id
        Boolean :up
        String :stdout
        String :stderr
        Integer :exitstatus
        DateTime :created_at
      end
      DB.add_index :pings, :stdout
      DB.add_index :pings, :stderr
      DB.add_index :pings, :exitstatus
      DB.add_index :pings, :created_at
    end
  end
end

