require "simplecov"

module SimpleCovEnv
  extend self

  def start!
    configure_profile
    configure_job

    SimpleCov.start
  end

  def configure_job
    SimpleCov.configure do
      if ENV["CI_JOB_NAME"]
        job_name = ENV["CI_JOB_NAME"].gsub(/[^\w\d]/, "_").downcase # Poor mans slugify
        coverage_dir "coverage/#{job_name}"
        command_name job_name
      end

      if ENV["CI"]
        SimpleCov.at_exit do
          # In CI environment don't generate formatted reports
          # Only generate .resultset.json
          SimpleCov.result
        end
      end
    end
  end

  def configure_profile
    SimpleCov.configure do
      load_profile "rails"

      add_filter "/vendor/ruby/" # on CI all gems live here and are otherwise included

      merge_timeout 60 * 60 * 24 * 31 # about a month
    end
  end
end
