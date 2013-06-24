# OSX/Dmg.rb
# OSX::Dmg

# 20130623, 24
# 0.5.0

# History: Extracted the methods from install_macports to be used in install_homebrew, but didn't finish this and just placed the methods (with some modification) directly into install_homebrew.  

# Changes since 0.4: 
# 1. + alias_method :attach, :mount.  
# 2. + alias_method :detach, :unmount.  
# 3. + alias_method :filename, :path_to_dmg.  
# 4. + alias_method :filename=, :path_to_dmg=.  

require 'Array/all_but_last'
require 'Module/alias_methods'
require 'shellwords'

module OSX
  class Dmg

    class << self

      attr_accessor :verbose

      def mount(path_to_dmg)
        puts "hdiutil attach #{Shellwords.escape(path_to_dmg)}" if verbose
        system "hdiutil attach #{Shellwords.escape(path_to_dmg)}"
      end
      alias_method :attach, :mount

      def run_installer(package, pkg_name = nil)
        starting_working_directory = Dir.pwd
        puts "cd /Volumes/#{package}" if verbose
        Dir.chdir("/Volumes/#{package}")
        puts "sudo installer -pkg #{Shellwords.escape(pkg_name)} -target '/'" if verbose
        system "sudo installer -pkg #{Shellwords.escape(pkg_name)} -target '/'"
        Dir.chdir(starting_working_directory)
      end

      def unmount(package)        
        puts "hdiutil detach -Force /Volumes/#{Shellwords.escape(package)}" if verbose
        system "hdiutil detach -Force /Volumes/#{Shellwords.escape(package)}"
      end
      alias_method :detach, :unmount

      def install(options = {})
        dmg = new(options)
        dmg.mount
        dmg.run_installer
        dmg.unmount
      end

    end # class << self

    attr_reader :options
    attr_writer :package, :pkg_name

    def initialize(options = {})
      @options = options
    end

    def path_to_dmg
      @path_to_dmg ||= options[:filename] || options[:path_to_dmg] || options[:disk_image_name] || options[:path_to_dmg]
    end
    alias_methods :filename, :image_name, :disk_image_name, :path_to_dmg

    def path_to_dmg=(path_to_dmg)
      @path_to_dmg = path_to_dmg
    end
    alias_methods :filename=, :image_name=, :disk_image_name=, :path_to_dmg=

    def package
      @package ||= options[:package]
    end

    def pkg_name
      @pkg_name ||= options[:pkg_name] || package + '.pkg'
    end

    def mount
      OSX::Dmg.mount(path_to_dmg)
    end
    alias_method :attach, :mount

    def run_installer
      OSX::Dmg.run_installer(package, pkg_name)
    end

    def unmount
      OSX::Dmg.unmount(package)
    end
    alias_method :detach, :unmount

    def install
      mount
      run_installer
      unmount
    end

  end # class Dmg
end # module OSX

if __FILE__ == $0
  require 'URI/write'
  url = 'https://distfiles.macports.org/MacPorts/MacPorts-2.0.4-10.7-Lion.dmg'
  URI.write(url)
  OSX::Dmg.verbose = true
  dmg = OSX::Dmg.new(path_to_dmg: 'MacPorts-2.0.4-10.7-Lion.dmg', package: 'MacPorts-2.0.4')
  dmg.mount
  #dmg.install
  dmg.dismount
end
