#!/usr/bin/env ruby
# Christian Genco (@cgenco)

require 'time'
require 'optparse'
load './t-time-tracker.rb'

@tracker = TTimeTracker.new
@options = {:from => nil, :to => nil, :filter => '', :done => false}
parser   = OptionParser.new do |opt|
  opt.banner = "" +
    "t-time-tracker: simple command line time tracking\n" +
    "github.com/christiangenco/t-time-tracker\n\n" +
    "Usage:\n" +
    "  $ t-time-tracker [OPTIONS]\n"
  opt.summary_indent = ' '
  opt.separator "\nOptions:\n"

  opt.on('-h', '--help', 'Shows this help message') do
    puts parser
    exit
  end

  opt.on('-v', '--version', 'Shows the current version') do
    puts '0.1'
    exit
  end

  opt.on('-u', '--update', 'Check github for updates') do
    throw "Not yet implemented"
  end

  opt.on('-a', '--at [AT]', 'A synonym for --from') do |f|
    require 'chronic'
    @options[:from] = Chronic.parse(f, :context => :past)
  end

  opt.on('-f', '--from [FROM]', 'The starting time in words (uses Chronic gem). Include any task that starts after it (inclusive)') do |f|
    require 'chronic'
    @options[:from] = Chronic.parse(f, :context => :past)
  end

  opt.on('-t', '--to [TO]', 'The ending time in words (uses Chronic gem). Include any task that starts before it (inclusive)') do |t|
    require 'chronic'
    @options[:to] = Chronic.parse(t, :context => :past)
  end

  opt.on('-d', '--done', 'End the current task without starting a new one') do
    @options[:done] = true
  end

  opt.on('-l', '--list', 'Print the tallied activities from --from to --to') do
    @options[:list] = true
  end

  opt.on('-e', '--edit', 'Edit saved daily task files with your $EDITOR') do
    STDERR.puts "opening #{@tracker.directory}"

    if ! ENV['EDITOR']
        puts "No EDITOR environment varible defined"
        puts "Set your EDITOR in your .bashrc or .zshrc file by adding one of these lines:"
        puts "\texport EDITOR='vim' # for vim"
        puts "\texport EDITOR='subl' # for Sublime Text 2"
        puts "\texport EDITOR='mate' # for Textmate"
        exit
    end
    
    # batch edit the logs
    `#{ENV['EDITOR']} #{@tracker.directory}`
    exit
  end
end

parser.parse!

if @options[:done]
  task = @tracker.current_task
  task[:finish] = Time.now
  @tracker.save(task)
  puts "Finished: #{task[:description]} (#{TTimeTracker.format_minutes task[:duration]})"
  exit
end

if @options[:list]
  total, linewidth = 0, 0
  day = nil
  # print "@options ="
  # p @options
  @tracker.tasks(:from => @options[:from], :to => @options[:to]).each{ |task|
    if day.nil?  || 
       day.year  != task[:start].year  ||
       day.month != task[:start].month ||
       day.day   != task[:start].day
      puts task[:start].strftime("# %F #")
      day = task[:start]
    end
    line = "#{task[:start].strftime('%l:%M')}-" +
          "#{task[:finish] ? task[:finish].strftime('%l:%M%P') : ' '*7}: " +
          "#{TTimeTracker.format_minutes task[:duration]}" +
          " #{task[:description]}"
    linewidth = [linewidth, line.length].max
    puts line
    total += task[:duration]
  }
  puts "-" * linewidth
  puts "total".rjust(13) + ": " + TTimeTracker.format_minutes(total).to_s
  exit
end

# p @options
# p ARGV
# exit

# add a task
if !ARGV.empty?
  description = ARGV.join(" ")
  print "description="
  p description
  
  exit
end

# default action: show current task
unless current = @tracker.current_task
  STDERR.puts "You're not working on anything"
  exit
end
  
STDERR.puts "In progress: #{current[:description]} (#{TTimeTracker.format_minutes current[:duration]})"
exit