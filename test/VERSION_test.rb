require_relative './helper'
require 'MacOS/VERSION'

describe MacOS do
  describe "VERSION" do
    it "is a string" do
      _(MacOS::VERSION).must_be_instance_of String
    end

    it "is three numbers separated by dots" do
      _(MacOS::VERSION).must_match(/\A\d+\.\d+\.\d+\z/)
    end

    it "matches the newest entry in the CHANGELOG" do
      changelog = File.read(File.expand_path('../CHANGELOG', __dir__))
      _(changelog[/^(\d+\.\d+\.\d+):/, 1]).must_equal(MacOS::VERSION)
    end
  end
end
