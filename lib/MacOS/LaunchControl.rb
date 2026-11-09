# MacOS/LaunchControl.rb
# MacOS::LaunchControl

require 'shellwords'

module MacOS
  class LaunchControl

    class << self

      def load(path_to_plist)
        check_plist(path_to_plist)
        system("launchctl load -w #{Shellwords.escape(path_to_plist)}")
      end

      def unload(path_to_plist)
        check_plist(path_to_plist)
        system("launchctl unload -w #{Shellwords.escape(path_to_plist)}")
      end

      private

      def check_plist(path_to_plist)
        raise "No plist was given." unless path_to_plist
        raise "File: #{path_to_plist} was not found in the filesystem." unless File.exist?(path_to_plist)
      end

    end # class << self

    attr_accessor :path_to_plist

    def initialize(path_to_plist = nil)
      @path_to_plist = path_to_plist
    end

    def load
      MacOS::LaunchControl.load(path_to_plist)
    end

    def unload
      MacOS::LaunchControl.unload(path_to_plist)
    end

  end
end
