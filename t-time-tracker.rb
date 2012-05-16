# yardoc info: http://cheat.errtheblog.com/s/yard/

class TTimeTracker
  require 'time'

  # @author Christian Genco (@cgenco)

  # @attribute directory [String] the parent directory that the log files are stored in
  # @attribute subdirectory [String] the subdirectory in which the current task will be stored
  # @attribute filename [String] the full path to the log file of the current task
  # @attribute task [String] the users entered task
  # @attribute at [Time] the time that the task (or range) starts at
  # @attribute to [Time] the time that the task (or range) ends at
  attr_accessor :directory, :subdirectory, :filename, :task, :at, :to, :now

  # A new instance of TTimeTracker.
  # @param [Hash] params Options hash
  # @option params [Symbol] :now the date to consider when deciding which log file to use
  # @option params [Symbol] :directory the parent directory that the log files are stored in
  # @option params [Symbol] :subdirectory the subdirectory in which the current task will be stored
  # @option params [Symbol] :filename the full path to the log file of the current task
  def initialize(params = {})
    @now          = params[:now] || Time.now
    @directory    = params[:directory] || File.join(Dir.home, '.ttimetracker')
    @subdirectory = params[:subdirectory] || File.join(@directory, now.year.to_s, now.strftime("%m_%b"), '')
    @filename     = params[:filename] || File.join(@subdirectory, now.strftime('%Y-%m-%d') + '.csv')

    self.class.mkdir @subdirectory
  end

  # Returns information about the specified task.
  # 
  # @param task_name [Symbol] the stored task to return, `:current` or `:last`
  def task(task_name)
    task_filename = File.join(@directory, task_name.to_s)
    return nil unless File.exists?(task_filename)
    File.open(task_filename,'r') do |f|
      line = f.gets
      return if line.nil?
      parse_line(line)
    end
  end

  # equivalent to task(:current)
  def current_task; task(:current); end

  # equivalent to task(:last)
  def last_task; task(:last); end

  def task=(task = {})
    # forget the last task
    last = File.join(@directory, "last")
    File.unlink(last) if File.exists?(last)

    task[:at] ||= @now

    # save this as the current task if it doesn't have an ending time
    unless task[:to]
      File.open(File.join(@directory, "current"),'w') do |f|
        f.puts [task[:at], task[:description].strip].join(", ")
      end
    else
      # save directly to today's log
      File.open(@filename,'w') do |f|
        f.puts [task[:at], task[:to], task[:description].strip].join(", ")
      end
    end
  end

  # Converts an integer of minutes into a more human readable format.
  # 
  # @example
  #   format_minutes(95) #=> "1:15"
  #   format_minutes(5)  #=> "0:05"
  # 
  # @param minutes [Integer] a number of minutes
  # @return [String] the formatted minutes
  def self.format_minutes(minutes)
    "#{minutes.to_i / 60}:#{'%02d' % (minutes % 60)}"
  end

  # Parses a comma separated stored task in csv form
  # 
  # @example
  #   parse_line("12:56, 13:10, did the dishes") 
  #   #=> {:start=>2012-05-16 12:56:00, :finish=>2012-05-16 13:10:00, :description=>"did the dishes", :duration=>14}
  #   parse_line("14:32, homework")
  #   #=> {:start=>2012-05-16 14:32:00, :finish=>Time.now, :description=>"homework", :duration=>36}
  # 
  # @param line [String] the CSV stored task
  # @return [{:start=>Time, :finish=>Time, :description=>String, :duration=>Integer}] the parsed data in the line
  def parse_line(line)
    data = line.split(",").map(&:strip)
    start = Time.parse(data.shift)

    if data.length == 2
      # if there are two more values, they are the finished time and the description
      finish = Time.parse(data.shift)
    else 
      # otherwise the last value is the description; get finish elsewhere
      finish = @now
    end

    description = data.shift
    duration = ((finish - start).to_f / 60).ceil

    return {:start => start, :finish => finish, :description => description, :duration => duration}
  end

  # Create directory if it doesn't exist, creating intermediate 
  # directories as required. Equivalent to `mkdir -p`.
  # 
  # @param dir [String] a directory name
  def self.mkdir(dir)
    mkdir(File.dirname dir) unless File.dirname(dir) == dir
    Dir.mkdir(dir) unless dir.empty? || File.directory?(dir)
  end

  # Converts a Time object into a human readable condensed string.
  # Options for strftime may be found here: 
  # http://www.ruby-doc.org/core-1.9.3/Time.html#method-i-strftime
  # 
  # @example
  #   time = Time.new   #=> 2012-05-16 00:32:31 +0800
  #   format_time(time) #=> "00:32:31"
  # 
  # @param time [Time] a time
  # @return [String] the formatted time
  def self.format_time(time)
    time.strftime("%H:%M:%S")
  end
end