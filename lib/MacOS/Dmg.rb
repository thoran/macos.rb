# MacOS/Dmg.rb
# MacOS::Dmg

# History: Extracted the methods from install_macports to be used in install_homebrew, but didn't finish this and just placed the methods (with some modification) directly into install_homebrew.

require 'shellwords'

module MacOS
  class Dmg

    class << self
      attr_accessor :verbose

      def mount(path_to_dmg)
        puts "hdiutil attach #{Shellwords.escape(path_to_dmg)}" if verbose
        system "hdiutil attach #{Shellwords.escape(path_to_dmg)}"
      end
      alias_method :attach, :mount

      def run_installer(mount_point:, pkg_name:)
        starting_working_directory = Dir.pwd
        puts "cd #{full_path_to_mount_point(mount_point)}" if verbose
        Dir.chdir(full_path_to_mount_point(mount_point))
        puts "sudo installer -pkg #{Shellwords.escape(pkg_name)} -target '/'" if verbose
        system "sudo installer -pkg #{Shellwords.escape(pkg_name)} -target '/'"
        Dir.chdir(starting_working_directory)
      end

      def unmount(mount_point)
        puts "hdiutil detach -Force #{Shellwords.escape(full_path_to_mount_point(mount_point))}" if verbose
        system "hdiutil detach -Force #{Shellwords.escape(full_path_to_mount_point(mount_point))}"
      end
      alias_method :detach, :unmount

      def install(path_to_dmg:, disk_image_name:, mount_point: nil, package: nil)
        dmg = new(path_to_dmg: path_to_dmg, disk_image_name: disk_image_name, mount_point: mount_point, package: package)
        dmg.mount
        dmg.run_installer
        dmg.unmount
      end

      private

      def full_path_to_mount_point(mount_point)
        File.join('/', 'Volumes', mount_point)
      end
    end # class << self

    attr_accessor :disk_image_name
    attr_accessor :package
    attr_accessor :path_to_dmg

    attr_writer :mount_point
    attr_writer :pkg_name

    def initialize(path_to_dmg:, disk_image_name: nil, mount_point: nil, package: nil)
      @path_to_dmg = path_to_dmg
      @disk_image_name = disk_image_name
      @mount_point = mount_point
      @package = package
    end

    alias_method :filename, :disk_image_name
    alias_method :dmg_filename, :disk_image_name
    alias_method :image_name, :disk_image_name
    alias_method :filename=, :disk_image_name=
    alias_method :dmg_filename=, :disk_image_name=
    alias_method :image_name=, :disk_image_name=

    def pkg_name
      @pkg_name || (@package + '.pkg')
    end

    def mount_point
      @mount_point || @disk_image_name.split('.').first
    end

    def mount
      MacOS::Dmg.mount(@path_to_dmg)
    end
    alias_method :attach, :mount

    def run_installer
      MacOS::Dmg.run_installer(pkg_name: pkg_name, mount_point: mount_point)
    end

    def unmount
      MacOS::Dmg.unmount(mount_point)
    end
    alias_method :detach, :unmount

    def install
      mount
      run_installer
      unmount
    end

  end
end

if __FILE__ == $0
  require 'URI/write'
  url = 'https://distfiles.macports.org/MacPorts/MacPorts-2.0.4-10.7-Lion.dmg'
  URI.write(url)
  MacOS::Dmg.verbose = true
  dmg = MacOS::Dmg.new(path_to_dmg: 'MacPorts-2.0.4-10.7-Lion.dmg', package: 'MacPorts-2.0.4', mount_point: 'MacPorts-2.0.4')
  dmg.mount
  #dmg.install
  dmg.dismount
end
