require 'spec_helper'
require 'jshint/railtie'

describe JSHint::Railtie do
  before :all do
    File.open(JSHint::DEFAULT_CONFIG_FILE, "w") { |f| f.write "foo" }
    JSHint.config_path = "custom_config.yml"
  end

  before :each do
    File.delete(JSHint.config_path) if File.exist?(JSHint.config_path)
  end

  describe "create_example_config" do
    it "should create a config file if it doesn't exist" do
      JSHint::Railtie.create_example_config

      File.exist?(JSHint.config_path).should be_true
      File.read(JSHint.config_path).should == "foo"
    end

    it "should not do anything if config already exists" do
      File.open(JSHint.config_path, "w") { |f| f.write "bar" }

      JSHint::Railtie.create_example_config

      File.exist?(JSHint.config_path).should be_true
      File.read(JSHint.config_path).should == "bar"
    end
  end
end
