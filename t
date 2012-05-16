#!/usr/bin/env ruby
# Christian Genco (@cgenco)

require 'time'
require 'optparse'
load './t-time-tracker.rb'

@tracker = TTimeTracker.new
@options = {:at => Time.now, :from => Time.now, :to => nil, :filter => ''}
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

  opt.on('-l', '--list', 'Print the tallied activities from --from to --to') do
    total, linewidth = 0, 0
    @tracker.tasks(:from => @from, :to => @to).each{ |task|
      line = "#{task[:start].strftime('%l:%M')}-" +
            "#{task[:finish] ? task[:finish].strftime('%l:%M%P') : ' '*7}: " +
            "#{TTimeTracker.format_minutes task[:duration]}" +
            " #{task[:description]} "
      linewidth = [linewidth, line.length].max
      puts line
      total += task[:duration]
    }
    puts "-" * linewidth
    puts "total".rjust(13) + ": " + TTimeTracker.format_minutes(total).to_s
    exit
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


# default action: show current task
unless current = @tracker.current_task
  STDERR.puts "You're not working on anything"
  exit
end
  
STDERR.puts "In progress: #{current[:description]} (#{TTimeTracker.format_minutes current[:duration]})"
exit