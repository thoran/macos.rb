# MacOS/LaunchControl.rb
# MacOS::LaunchControl

module MacOS
  class LaunchControl

    class << self

      def load(path_to_plist)
        system("launchctl load -w #{path_to_plist}")
      end

      def unload(path_to_plist)
        system("launchctl unload -w #{path_to_plist}")
      end

    end # class << self

    attr_accessor :path_to_plist

    def init(path_to_plist = nil)
      @path_to_plist = path_to_plist
    end

    def load
      MacOS::LaunchControl.load(path_to_plist)
    end

    def unload(path_to_plist)
      MacOS::LaunchControl.unload(path_to_plist)
    end

  end
end
