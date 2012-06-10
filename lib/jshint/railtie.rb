module JSHint
  class Railtie < Rails::Railtie

    rake_tasks do
      require 'jshint/rails'
      require 'jshint/tasks'
      JSHint::Railtie.create_example_config
    end

    def self.create_example_config
      unless File.exists?(JSHint.config_path)
        begin
          JSHint::Utils.copy_config_file
        rescue StandardError => error
          puts "Error: #{error.message}"
        end
      end
    end

  end
end
