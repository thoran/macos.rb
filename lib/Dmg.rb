# OSX/Dmg.rb
# OSX::Dmg

# 20130622
# 0.2.0

# History: Extracted the methods from install_macports to be used in install_homebrew, but didn't finish this and just placed the methods (with some modification) directly into install_homebrew.  

# Changes since 0.1: 
# 1. + attr_accessor :verbose in class-level.  
# 2. ~ initialize, so that it actually does something!  
# 3. + OSX::Dmg#mount.  
# 4. + OSX::Dmg#install.  
# 5. + OSX::Dmg#dismount.  
# 6. + working self-run section.  
# 7. /mount_disk_image/mount/.  
# 8. /run_installer/install/.  
# 9. /dismount_disk_image/dismount/.  
# 10. ~ OSX::Dmg#image_name, so as it makes use of directly set values via options rather than derived from the url.  
# 11. ~ OSX::Dmg#package, so as it makes use of directly set values via options rather than derived from the url.  
# 12. ~ OSX::Dmg#pkg_name, so as it makes use of directly set values via options rather than derived from the url.  

require 'Array/extract_optionsX'
require 'Array/all_but_last'
require 'shellwords'

module OSX
  class Dmg

    class << self

      attr_accessor :verbose

      def mount(disk_image_name)
        puts "hdiutil attach #{Shellwords.escape(disk_image_name)}" if verbose
        system "hdiutil attach #{Shellwords.escape(disk_image_name)}"
      end

      def install(package, pkg_name)
        puts "cd /Volumes/#{package}" if verbose
        Dir.chdir "/Volumes/#{package}"
        puts "sudo installer -pkg #{Shellwords.escape(pkg_name)} -target '/'" if verbose
        system "sudo installer -pkg #{Shellwords.escape(pkg_name)} -target '/'"
      end

      def dismount(package)        
        puts "hdiutil detach -Force /Volumes/#{Shellwords.escape(package)}" if verbose
        system "hdiutil detach -Force /Volumes/#{Shellwords.escape(package)}"
      end

    end # class << self

    attr_reader :args, :options
    attr_writer :url, :image_name, :package, :pkg_name

    def initialize(*args)
      @args = args
      @options = args.extract_options!
    end

    def url
      if args.size > 0
        args.first
      else
        options[:url]
      end
    end
    alias_method :set_url, :url

    def image_name
      @image_name ||= options[:image_name] || options[:disk_image_name] || url.split('/').last
    end
    alias_method :disk_image_name, :image_name

    def package
      @package ||= options[:package] || url.split('/').all_but_last.last
    end

    def pkg_name
      @pkg_name ||= options[:pkg_name] || package + '.pkg'
    end

    def mount
      OSX::Dmg.mount(image_name)
    end

    def install
      OSX::Dmg.install(package, pkg_name)
    end

    def dismount
      OSX::Dmg.dismount(package)
    end

  end # class Dmg
end # module OSX

if __FILE__ == $0
  require 'URI/write'
  url = 'https://distfiles.macports.org/MacPorts/MacPorts-2.0.4-10.7-Lion.dmg'
  URI.write(url)
  OSX::Dmg.verbose = true
  dmg = OSX::Dmg.new(url, package: 'MacPorts-2.0.4')
  dmg.mount
  #dmg.install
  dmg.dismount
end
