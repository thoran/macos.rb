require_relative '../helper'
require 'MacOS/Dmg'

describe MacOS::Dmg do
  def run_quietly(&block)
    Dir.stub(:chdir, nil){commands_run_by(MacOS::Dmg, &block)}
  end

  describe "the class" do
    it "mounts, installs from and unmounts a disk image, escaping each name for the shell" do
      commands = run_quietly do
        MacOS::Dmg.mount('Example App.dmg')
        MacOS::Dmg.run_installer(mount_point: 'Example App', pkg_name: 'Example App.pkg')
        MacOS::Dmg.unmount('Example App')
      end
      _(commands).must_equal([
        ['hdiutil attach Example\\ App.dmg'],
        ["sudo installer -pkg Example\\ App.pkg -target '/'"],
        ['hdiutil detach -Force /Volumes/Example\\ App'],
      ])
    end

    it "installs from a disk image it's given the names of" do
      commands = run_quietly{MacOS::Dmg.install(path_to_dmg: '/tmp/Example-1.0.dmg', disk_image_name: 'Example-1.0.dmg', package: 'Example')}
      _(commands).must_equal([
        ['hdiutil attach /tmp/Example-1.0.dmg'],
        ["sudo installer -pkg Example.pkg -target '/'"],
        ['hdiutil detach -Force /Volumes/Example-1'],
      ])
    end

    it "prints each command where verbose" do
      MacOS::Dmg.verbose = true
      _{run_quietly{MacOS::Dmg.mount('Example.dmg')}}.must_output("hdiutil attach Example.dmg\n")
    ensure
      MacOS::Dmg.verbose = nil
    end
  end

  describe "an instance" do
    let(:dmg){MacOS::Dmg.new(path_to_dmg: '/tmp/Example-1.0.dmg', disk_image_name: 'Example-1.0.dmg', package: 'Example')}

    it "takes its package's name and its mount point from its other names, where they aren't given" do
      _(dmg.pkg_name).must_equal('Example.pkg')
      _(dmg.mount_point).must_equal('Example-1')
    end

    it "takes them as given" do
      dmg.pkg_name = 'Other.pkg'
      dmg.mount_point = 'Other'
      _(dmg.pkg_name).must_equal('Other.pkg')
      _(dmg.mount_point).must_equal('Other')
    end

    it "answers to each of its disk image's names" do
      dmg.filename = 'Renamed.dmg'
      _([dmg.disk_image_name, dmg.filename, dmg.dmg_filename, dmg.image_name]).must_equal(['Renamed.dmg'] * 4)
    end

    it "mounts, installs and unmounts" do
      commands = run_quietly{dmg.install}
      _(commands).must_equal([
        ['hdiutil attach /tmp/Example-1.0.dmg'],
        ["sudo installer -pkg Example.pkg -target '/'"],
        ['hdiutil detach -Force /Volumes/Example-1'],
      ])
    end
  end
end
