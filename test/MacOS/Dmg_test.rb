require_relative '../helper'
require 'MacOS/Dmg'

describe MacOS::Dmg do
  # Runs the block with hdiutil attach -plist giving attach_plist and the mounted volume holding pkg_names, returning the commands it was given.
  def run_quietly(attach_plist = fixture('hdiutil-attach-plist.xml'), pkg_names: ['Example.pkg'], &block)
    MacOS::Dmg.stub(:xml_attach_plist, attach_plist) do
      MacOS::Dmg.stub(:pkg_names, pkg_names){commands_run_by(MacOS::Dmg, &block)}
    end
  end

  describe "the class" do
    it "mounts a disk image, giving where hdiutil mounted the volume" do
      MacOS::Dmg.stub(:xml_attach_plist, fixture('hdiutil-attach-plist.xml')) do
        _(MacOS::Dmg.mount('/tmp/Example-1.0.dmg')).must_equal('/Volumes/Example 1.0')
      end
    end

    it "gives nil where hdiutil mounted nothing" do
      MacOS::Dmg.stub(:xml_attach_plist, ''){_(MacOS::Dmg.mount('/tmp/Example-1.0.dmg')).must_be_nil}
    end

    it "installs from and unmounts a volume, escaping each path for the shell" do
      commands = run_quietly do
        MacOS::Dmg.run_installer(mount_point: '/Volumes/Example 1.0', pkg_name: 'Example App.pkg')
        MacOS::Dmg.unmount('/Volumes/Example 1.0')
      end
      _(commands).must_equal([
        ["sudo installer -pkg /Volumes/Example\\ 1.0/Example\\ App.pkg -target '/'"],
        ['hdiutil detach -Force /Volumes/Example\\ 1.0'],
      ])
    end

    it "takes a mount point which is a name to be under /Volumes, and a path as it is" do
      commands = run_quietly do
        MacOS::Dmg.unmount('Example')
        MacOS::Dmg.unmount('/private/tmp/Example')
      end
      _(commands).must_equal([['hdiutil detach -Force /Volumes/Example'], ['hdiutil detach -Force /private/tmp/Example']])
    end

    it "takes a package which is a name to be on the volume, and a path as it is" do
      commands = run_quietly do
        MacOS::Dmg.run_installer(mount_point: 'Example', pkg_name: 'Packages/Example.pkg')
        MacOS::Dmg.run_installer(mount_point: 'Example', pkg_name: '/private/tmp/Example.pkg')
      end
      _(commands).must_equal([
        ["sudo installer -pkg /Volumes/Example/Packages/Example.pkg -target '/'"],
        ["sudo installer -pkg /private/tmp/Example.pkg -target '/'"],
      ])
    end

    it "raises where it's given no mount point or no package, running nothing" do
      commands = run_quietly do
        _(_{MacOS::Dmg.run_installer(mount_point: nil, pkg_name: 'Example.pkg')}.must_raise(RuntimeError).message).must_equal('No mount point was given.')
        _(_{MacOS::Dmg.unmount(nil)}.must_raise(RuntimeError).message).must_equal('No mount point was given.')
        _(_{MacOS::Dmg.run_installer(mount_point: 'Example', pkg_name: nil)}.must_raise(RuntimeError).message).must_equal('No package was given.')
      end
      _(commands).must_equal([])
    end

    it "installs the package on the volume it mounted, given only the disk image's path" do
      result = nil
      commands = run_quietly{result = MacOS::Dmg.install(path_to_dmg: '/tmp/Example-1.0.dmg')}
      _(commands).must_equal([
        ["sudo installer -pkg /Volumes/Example\\ 1.0/Example.pkg -target '/'"],
        ['hdiutil detach -Force /Volumes/Example\\ 1.0'],
      ])
      _(result).must_equal(true)
    end

    it "installs the package it's given, and from the mount point it's given where nothing was mounted" do
      commands = run_quietly(''){MacOS::Dmg.install(path_to_dmg: '/tmp/Example-1.0.dmg', mount_point: 'Example', package: 'Other')}
      _(commands).must_equal([
        ["sudo installer -pkg /Volumes/Example/Other.pkg -target '/'"],
        ['hdiutil detach -Force /Volumes/Example'],
      ])
    end

    it "prints each command where verbose" do
      MacOS::Dmg.verbose = true
      expected = [
        "hdiutil attach -plist /tmp/Example-1.0.dmg",
        "sudo installer -pkg /Volumes/Example\\ 1.0/Example.pkg -target '/'",
        "hdiutil detach -Force /Volumes/Example\\ 1.0",
      ].map{|line| "#{line}\n"}.join
      _{run_quietly{MacOS::Dmg.install(path_to_dmg: '/tmp/Example-1.0.dmg')}}.must_output(expected)
    ensure
      MacOS::Dmg.verbose = nil
    end
  end

  describe "an instance" do
    let(:dmg){MacOS::Dmg.new(path_to_dmg: '/tmp/Example-1.0.dmg')}

    it "takes its disk image's path, a mount point and a package, and nothing else" do
      _{MacOS::Dmg.new(path_to_dmg: '/tmp/Example-1.0.dmg', disk_image_name: 'Example-1.0.dmg')}.must_raise(ArgumentError)
    end

    it "has no mount point until it mounts its disk image, or is given one" do
      _(dmg.mount_point).must_be_nil
      _(MacOS::Dmg.new(path_to_dmg: '/tmp/Example-1.0.dmg', mount_point: 'Example').mount_point).must_equal('Example')
    end

    it "takes a mount point as given" do
      dmg.mount_point = 'Other'
      _(dmg.mount_point).must_equal('Other')
    end

    it "takes its mount point from the volume it mounted, in place of one given" do
      given = MacOS::Dmg.new(path_to_dmg: '/tmp/Example-1.0.dmg', mount_point: 'Other')
      run_quietly do
        _(dmg.mount).must_equal('/Volumes/Example 1.0')
        given.mount
      end
      _([dmg.mount_point, given.mount_point]).must_equal(['/Volumes/Example 1.0'] * 2)
    end

    it "keeps the mount point it was given where nothing was mounted" do
      given = MacOS::Dmg.new(path_to_dmg: '/tmp/Example-1.0.dmg', mount_point: 'Other')
      run_quietly(''){_(given.mount).must_be_nil}
      _(given.mount_point).must_equal('Other')
    end

    it "takes its package's name from the one package on the volume it mounted" do
      run_quietly do
        _(dmg.pkg_name).must_be_nil
        dmg.mount
        _(dmg.pkg_name).must_equal('Example.pkg')
      end
    end

    it "has no package's name where the volume holds none, or more than one" do
      [[], ['Example.pkg', 'Other.pkg']].each do |pkg_names|
        run_quietly(pkg_names: pkg_names) do
          dmg.mount
          _(dmg.pkg_name).must_be_nil
        end
      end
    end

    it "takes its package's name from the package, or as given, over what's on the volume" do
      with_package = MacOS::Dmg.new(path_to_dmg: '/tmp/Example-1.0.dmg', package: 'Other')
      run_quietly do
        with_package.mount
        dmg.mount
        dmg.pkg_name = 'Given.pkg'
        _([with_package.pkg_name, dmg.pkg_name]).must_equal(['Other.pkg', 'Given.pkg'])
      end
    end

    it "mounts, installs from and unmounts the volume it mounted" do
      commands = run_quietly{dmg.install}
      _(commands).must_equal([
        ["sudo installer -pkg /Volumes/Example\\ 1.0/Example.pkg -target '/'"],
        ['hdiutil detach -Force /Volumes/Example\\ 1.0'],
      ])
    end

    it "raises where the volume it mounted holds no package, or more than one, unmounting it first" do
      {
        [] => 'No package was found on /Volumes/Example 1.0.',
        ['Example.pkg', 'Other.pkg'] => 'More than one package was found on /Volumes/Example 1.0: Example.pkg, Other.pkg.',
      }.each do |pkg_names, message|
        fresh_dmg = MacOS::Dmg.new(path_to_dmg: '/tmp/Example-1.0.dmg')
        commands = run_quietly(pkg_names: pkg_names){_(_{fresh_dmg.install}.must_raise(RuntimeError).message).must_equal(message)}
        _(commands).must_equal([['hdiutil detach -Force /Volumes/Example\\ 1.0']])
      end
    end

    it "raises where nothing was mounted, running nothing" do
      commands = run_quietly(''){_(_{dmg.install}.must_raise(RuntimeError).message).must_equal('No mount point was given.')}
      _(commands).must_equal([])
    end
  end
end
