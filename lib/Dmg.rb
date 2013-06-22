# OSX/Dmg.rb
# OSX::Dmg

# 20130603, 22
# 0.0.0

# History: Extracted the methods from install_macports to be used in install_homebrew, but didn't finish this and just placed the methods (with some modification) directly into install_homebrew.  

module OSX?

  class Dmg

    class << self
      def mount_image(image_name)
        puts "hdiutil attach #{image_name}"
        system "hdiutil attach #{image_name}"
      end

      def run_installer(package, pkg_name)
        puts "cd /Volumes/#{package}"
        Dir.chdir "/Volumes/#{package}"
        puts "sudo installer -pkg #{pkg_name} -target '/'"
        system "sudo installer -pkg #{pkg_name} -target '/'"
      end

      def dismount_image(package)
        puts "hdiutil detach -Force /Volumes/#{package}"
        system "hdiutil detach -Force /Volumes/#{package}"
      end

    end # class << self

    def initialize

    end

    def image_name
      url.split('/').last
    end

    def package
      url.split('/').all_but_last.last
    end

    def pkg_name
      package + '.pkg'
    end

  end # class Dmg

end


OSX::Dmg.new()

mount_image(image_name)
run_installer(package, pkg_name)
dismount_image(package)
