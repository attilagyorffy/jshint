require 'jshint/errors'
require 'jshint/utils'
require 'jshint/lint'

if defined?(Rails) && Rails::VERSION::MAJOR == 3
  require 'jshint/railtie'
end
