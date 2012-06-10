require 'fileutils'
require 'yaml'

module JSHint

  VERSION = "0.1.0"
  DEFAULT_CONFIG_FILE = File.expand_path(File.dirname(__FILE__) + "/config/jshint.yml")

  class << self
    attr_accessor :config_path
  end

  module Utils
    class << self

      def xprint(txt)
        print txt
      end

      def xputs(txt)
        puts txt
      end

      def load_config_file(file_name)
        if file_name && File.exists?(file_name) && File.file?(file_name) && File.readable?(file_name)
          YAML.load_file(file_name)
        else
          {}
        end
      end

      # workaround for a problem with case-insensitive file systems like HFS on Mac
      def unique_files(list)
        files = []
        list.each do |entry|
          files << entry unless files.any? { |f| File.identical?(f, entry) }
        end
        files
      end

      # workaround for a problem with case-insensitive file systems like HFS on Mac
      def exclude_files(list, excluded)
        list.reject { |entry| excluded.any? { |f| File.identical?(f, entry) }}
      end

      def paths_from_command_line(field)
        argument = ENV[field] || ENV[field.upcase]
        argument && argument.split(/,/)
      end

      def copy_config_file
        raise ArgumentError, "Please set JSHint.config_path" if JSHint.config_path.nil?
        xprint "Creating example JSHint config file in #{File.expand_path(JSHint.config_path)}... "
        if File.exists?(JSHint.config_path)
          xputs "\n\nWarning: config file exists, so it won't be overwritten. " +
                "You can copy it manually from the jshint_on_rails directory if you want to reset it."
        else
          FileUtils.copy(JSHint::DEFAULT_CONFIG_FILE, JSHint.config_path)
          xputs "done."
        end
      end

      def remove_config_file
        raise ArgumentError, "Please set JSHint.config_path" if JSHint.config_path.nil?
        xprint "Removing config file... "
        if File.exists?(JSHint.config_path) && File.file?(JSHint.config_path)
          if File.read(JSHint.config_path) == File.read(JSHint::DEFAULT_CONFIG_FILE)
            File.delete(JSHint.config_path)
            xputs "OK."
          else
            xputs "File was modified, so it won't be deleted automatically."
          end
        else
          xputs "OK (no config file found)."
        end
      end

    end
  end
end
