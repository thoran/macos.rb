# OSX/Dmg.rb
# OSX::Dmg

# 20130623, 24
# 0.4.0

# History: Extracted the methods from install_macports to be used in install_homebrew, but didn't finish this and just placed the methods (with some modification) directly into install_homebrew.  

# Changes since 0.3: 
# 1. + OSX::Dmg.install.  
# 2. + OSX::Dmg#run_installer, so as it does what OSX::Dmg#install used to do.  
# 3. ~ OSX::Dmg.install, so as it now mounts, installs, and ummounts.  
# 4. /dismount/unmount/.  

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
      @path_to_dmg ||= options[:path_to_dmg] || options[:disk_image_name] || options[:path_to_dmg]
    end
    alias_methods :image_name, :disk_image_name, :path_to_dmg

    def path_to_dmg=(path_to_dmg)
      @path_to_dmg = path_to_dmg
    end
    alias_methods :image_name=, :disk_image_name=, :path_to_dmg=

    def package
      @package ||= options[:package]
    end

    def pkg_name
      @pkg_name ||= options[:pkg_name] || package + '.pkg'
    end

    def mount
      OSX::Dmg.mount(path_to_dmg)
    end

    def run_installer
      OSX::Dmg.run_installer(package, pkg_name)
    end

    def unmount
      OSX::Dmg.unmount(package)
    end

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
