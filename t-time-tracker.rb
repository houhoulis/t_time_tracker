class TTimeTracker
  @data_dir = File.join(Dir.home, '.ttimetracker')
  @dirname  = File.join(@data_dir, now.year.to_s, now.strftime("%m_%b"), '')
  @filename = File.join(@dirname, now.strftime('%Y-%m-%d') + '.csv')
end