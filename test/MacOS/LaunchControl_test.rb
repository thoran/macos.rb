require_relative '../helper'
require 'MacOS/LaunchControl'

describe MacOS::LaunchControl do
  let(:plist){'/Library/LaunchDaemons/com.example.agent.plist'}

  # Runs the block with File.exist? true for the plists named and false for any other.
  def with_plists(*plists, &block)
    File.stub(:exist?, ->(path){plists.include?(path)}, &block)
  end

  it "loads and unloads a plist" do
    commands = with_plists(plist) do
      commands_run_by(MacOS::LaunchControl) do
        MacOS::LaunchControl.load(plist)
        MacOS::LaunchControl.unload(plist)
      end
    end
    _(commands).must_equal([["launchctl load -w #{plist}"], ["launchctl unload -w #{plist}"]])
  end

  it "escapes the plist's path for the shell" do
    spaced_plist = '/Library/Launch Agents/com.example.agent.plist'
    commands = with_plists(spaced_plist){commands_run_by(MacOS::LaunchControl){MacOS::LaunchControl.load(spaced_plist)}}
    _(commands).must_equal([['launchctl load -w /Library/Launch\ Agents/com.example.agent.plist']])
  end

  it "raises where the plist isn't there, or isn't given, running nothing" do
    commands = with_plists do
      commands_run_by(MacOS::LaunchControl) do
        %i{load unload}.each do |method|
          _(_{MacOS::LaunchControl.send(method, plist)}.must_raise(RuntimeError).message).must_equal("File: #{plist} was not found in the filesystem.")
          _(_{MacOS::LaunchControl.send(method, nil)}.must_raise(RuntimeError).message).must_equal('No plist was given.')
        end
      end
    end
    _(commands).must_equal([])
  end

  describe "an instance" do
    it "holds the plist it's made with" do
      _(MacOS::LaunchControl.new(plist).path_to_plist).must_equal(plist)
      _(MacOS::LaunchControl.new.path_to_plist).must_be_nil
    end

    it "loads and unloads its own plist" do
      launch_control = MacOS::LaunchControl.new(plist)
      commands = with_plists(plist) do
        commands_run_by(MacOS::LaunchControl) do
          launch_control.load
          launch_control.unload
        end
      end
      _(commands).must_equal([["launchctl load -w #{plist}"], ["launchctl unload -w #{plist}"]])
    end

    it "unloads another plist where it's given one" do
      commands = with_plists('/tmp/other.plist'){commands_run_by(MacOS::LaunchControl){MacOS::LaunchControl.new.unload('/tmp/other.plist')}}
      _(commands).must_equal([['launchctl unload -w /tmp/other.plist']])
    end

    it "raises where it was made without a plist" do
      launch_control = MacOS::LaunchControl.new
      _{launch_control.load}.must_raise(RuntimeError)
      _{launch_control.unload}.must_raise(RuntimeError)
    end
  end
end
