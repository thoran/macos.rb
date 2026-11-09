# MacOS/Dmg.rb
# MacOS::Dmg

require 'plist'
require 'shellwords'

module MacOS
  class Dmg

    class << self
      attr_accessor :verbose

      def xml_attach_plist(path_to_dmg)
        `hdiutil attach -plist #{Shellwords.escape(path_to_dmg)}`
      end

      # Where the volume was mounted, as hdiutil reports it, or nil where nothing was.
      def mount(path_to_dmg)
        puts "hdiutil attach -plist #{Shellwords.escape(path_to_dmg)}" if @verbose
        mounted_volume_path(Plist.parse_xml(xml_attach_plist(path_to_dmg)))
      end
      alias_method :attach, :mount

      # The packages at the top of a mounted volume.
      def pkg_names(mount_point)
        check_mount_point(mount_point)
        Dir.glob('*.pkg', base: full_path_to_mount_point(mount_point)).sort
      end

      def run_installer(mount_point:, pkg_name:)
        check_mount_point(mount_point)
        check_pkg_name(pkg_name)
        puts "sudo installer -pkg #{Shellwords.escape(full_path_to_pkg(mount_point, pkg_name))} -target '/'" if @verbose
        system "sudo installer -pkg #{Shellwords.escape(full_path_to_pkg(mount_point, pkg_name))} -target '/'"
      end

      def unmount(mount_point)
        check_mount_point(mount_point)
        puts "hdiutil detach -Force #{Shellwords.escape(full_path_to_mount_point(mount_point))}" if @verbose
        system "hdiutil detach -Force #{Shellwords.escape(full_path_to_mount_point(mount_point))}"
      end
      alias_method :detach, :unmount

      def install(path_to_dmg:, mount_point: nil, package: nil)
        new(path_to_dmg: path_to_dmg, mount_point: mount_point, package: package).install
      end

      private

      def check_mount_point(mount_point)
        raise "No mount point was given." unless mount_point
      end

      def check_pkg_name(pkg_name)
        raise "No package was given." unless pkg_name
      end

      # A name is taken to be under /Volumes, and a path as it is.
      def full_path_to_mount_point(mount_point)
        File.expand_path(mount_point, '/Volumes')
      end

      # A name is taken to be on the volume, and a path as it is.
      def full_path_to_pkg(mount_point, pkg_name)
        File.expand_path(pkg_name, full_path_to_mount_point(mount_point))
      end

      def mounted_volume_path(attach_plist)
        attach_plist['system-entities'].map{|entity| entity['mount-point']}.compact.first if attach_plist
      end
    end # class << self

    attr_accessor :mount_point
    attr_accessor :package
    attr_accessor :path_to_dmg

    attr_writer :pkg_name

    def initialize(path_to_dmg:, mount_point: nil, package: nil)
      @path_to_dmg = path_to_dmg
      @mount_point = mount_point
      @package = package
    end

    # Where neither it nor the package is given, the one package at the top of the mounted volume.
    def pkg_name
      @pkg_name || ("#{@package}.pkg" if @package) || mounted_pkg_name
    end

    # Where it mounts a volume, the volume's path becomes the mount point.
    def mount
      if volume_path = MacOS::Dmg.mount(@path_to_dmg)
        @mount_point = volume_path
      end
    end
    alias_method :attach, :mount

    def run_installer
      check_mounted_pkg_names unless @pkg_name || @package
      MacOS::Dmg.run_installer(pkg_name: pkg_name, mount_point: @mount_point)
    end

    def unmount
      MacOS::Dmg.unmount(@mount_point)
    end
    alias_method :detach, :unmount

    # Where the installer can't be run, the volume is unmounted before raising.
    def install
      mount
      run_installer
      unmount
    rescue
      unmount if @mount_point
      raise
    end

    private

    def check_mounted_pkg_names
      pkg_names = MacOS::Dmg.pkg_names(@mount_point)
      raise "No package was found on #{@mount_point}." if pkg_names.empty?
      raise "More than one package was found on #{@mount_point}: #{pkg_names.join(', ')}." if pkg_names.size > 1
    end

    def mounted_pkg_name
      return unless @mount_point
      pkg_names = MacOS::Dmg.pkg_names(@mount_point)
      pkg_names.first if pkg_names.size == 1
    end

  end
end
