# OSX/LaunchControl.rb
# OSX::LaunchControl

# 20130624
# 0.0.0

module OSX
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
      OSX::LaunchControl.load(path_to_plist)
    end

    def unload(path_to_plist)
      OSX::LaunchControl.unload(path_to_plist)
    end

  end # class LaunchControl
end # module OSX
