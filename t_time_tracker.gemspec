Gem::Specification.new do |s|
  s.name        = 't_time_tracker'
  s.version     = '0.0.1'
  s.add_runtime_dependency "chronic", ["~> 0.6.7"]
  s.add_runtime_dependency "activesupport", ["~> 3.2.1"]
  s.date        = '2012-05-29'
  s.summary     = "simple comand line time tracking"
  s.description = "Simple comand line time tracking - it's like a log file for your life. Keep track of everything from freelance project billing to how many hours per week you spend eating with `t reading about t_time_tracker --at 'five minutes ago'`"
  s.authors     = ["Christian Genco", "Chris Houhoulis"]
  s.email       = 'chris@chrishouhoulis.com'
  s.files       = ["lib/t_time_tracker.rb"]
  s.executables << 't_time_tracker'
  s.homepage    =
    'https://github.com/houhoulis/t_time_tracker'
end
