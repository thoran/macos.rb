# OSX/Dmg.rb
# OSX::Dmg

# 20130603, 22
# 0.1.0

# History: Extracted the methods from install_macports to be used in install_homebrew, but didn't finish this and just placed the methods (with some modification) directly into install_homebrew.  

# Changes: (Shellwords was needed with install_homebrew, so dropped in only those changes to the incomplete version in 0.0.0.)  
# 1. + require 'shellwords'
# 2. ~ OSX?::Dmg.mount_disk_image, so as to make use of Shellwords.  
# 3. ~ OSX?::Dmg.run_installer, so as to make use of Shellwords.  
# 4. ~ OSX?::Dmg.dismount_disk_image, so as to make use of Shellwords.  

require 'Array/extract_optionsX'
require 'Array/all_but_last'
require 'shellwords'

module OSX?

  class Dmg

    class << self

      def mount_disk_image(disk_image_name)
        puts "hdiutil attach #{Shellwords.escape(disk_image_name)}"
        system "hdiutil attach #{Shellwords.escape(disk_image_name)}"
      end

      def run_installer(package, pkg_name)
        puts "cd /Volumes/#{package}"
        Dir.chdir "/Volumes/#{package}"
        puts "sudo installer -pkg #{Shellwords.escape(pkg_name)} -target '/'"
        system "sudo installer -pkg #{Shellwords.escape(pkg_name)} -target '/'"
      end

      def dismount_disk_image(package)
        puts "hdiutil detach -Force /Volumes/#{Shellwords.escape(package)}"
        system "hdiutil detach -Force /Volumes/#{Shellwords.escape(package)}"
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
