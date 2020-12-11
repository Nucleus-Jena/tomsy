begin
  require "rubycritic_small_badge"
  require "rubycritic/rake_task"

  RubyCriticSmallBadge.configure do |config|
    config.minimum_score = 85
    config.output_path = "tmp/rubycritic"
  end

  RubyCritic::RakeTask.new do |task|
    task.options = %(--custom-format RubyCriticSmallBadge::Report
  --minimum-score #{RubyCriticSmallBadge.config.minimum_score} --no-browser)

    task.paths = FileList["app/**/*.rb"] # be careful not to include vendor as on CI we have all gems ever installed in this directory (causes Stacklevel to Deep Errors)

    # Defaults to false
    task.verbose = true
  end
rescue LoadError => error
  raise error if ENV["DEBUG"]
  puts "\nEXCEPTION rescued: #{error.class} #{error}"
  puts "  Set environment DEBUG=true to raise error\n"
end
