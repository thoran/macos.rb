require_relative '../helper'
require 'MacOS/LaunchControl'

describe MacOS::LaunchControl do
  let(:plist){'/Library/LaunchDaemons/com.example.agent.plist'}

  it "loads and unloads a plist" do
    commands = commands_run_by(MacOS::LaunchControl) do
      MacOS::LaunchControl.load(plist)
      MacOS::LaunchControl.unload(plist)
    end
    _(commands).must_equal([["launchctl load -w #{plist}"], ["launchctl unload -w #{plist}"]])
  end

  it "escapes the plist's path for the shell" do
    commands = commands_run_by(MacOS::LaunchControl){MacOS::LaunchControl.load('/Library/Launch Agents/com.example.agent.plist')}
    _(commands).must_equal([['launchctl load -w /Library/Launch\ Agents/com.example.agent.plist']])
  end

  describe "an instance" do
    it "holds the plist it's made with" do
      _(MacOS::LaunchControl.new(plist).path_to_plist).must_equal(plist)
      _(MacOS::LaunchControl.new.path_to_plist).must_be_nil
    end

    it "loads and unloads its own plist" do
      launch_control = MacOS::LaunchControl.new(plist)
      commands = commands_run_by(MacOS::LaunchControl) do
        launch_control.load
        launch_control.unload
      end
      _(commands).must_equal([["launchctl load -w #{plist}"], ["launchctl unload -w #{plist}"]])
    end

    it "unloads another plist where it's given one" do
      commands = commands_run_by(MacOS::LaunchControl){MacOS::LaunchControl.new.unload('/tmp/other.plist')}
      _(commands).must_equal([['launchctl unload -w /tmp/other.plist']])
    end
  end
end
