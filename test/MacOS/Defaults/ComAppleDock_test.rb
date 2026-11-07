require_relative '../../helper'
require 'MacOS/Defaults/ComAppleDock'

describe MacOS::Defaults::ComAppleDock do
  let(:dock){MacOS::Defaults::ComAppleDock}

  def with_dock(&block)
    MacOS::Defaults::ComAppleDock.stub(:`, fixture('defaults-export-com.apple.dock.xml'), &block)
  end

  describe "writing attributes" do
    it "marks booleans as -bool and integers as -int" do
      _(dock.attribute_write_command('autohide', true)).must_equal('defaults write com.apple.dock autohide -bool true')
      _(dock.attribute_write_command('tilesize', 48)).must_equal('defaults write com.apple.dock tilesize -int 48')
      _(dock.attribute_write_command('orientation', 'left')).must_equal('defaults write com.apple.dock orientation left')
    end

    it "loads a configuration, adding each persistent app and writing each other attribute" do
      commands = commands_run_by(dock){dock.load('persistent-apps' => ['/Applications/Example.app'], 'autohide' => true)}
      _(commands.size).must_equal(2)
      _(commands.first.first).must_match(%r{\Adefaults write com\.apple\.dock persistent-apps -array-add '<dict>.*file:///Applications/Example\.app}m)
      _(commands.last).must_equal(['defaults write com.apple.dock autohide -bool true'])
    end

    it "deletes the persistent apps and others, and the recent apps" do
      commands = commands_run_by(dock){dock.delete_all_items}
      _(commands.flatten).must_equal(%w{persistent-apps persistent-others recent-apps}.map{|item| "defaults delete com.apple.dock #{item}"})
    end
  end

  describe "an app's tile" do
    it "is the app's file URL in the Dock's tile data" do
      _(dock.urlified_app_string('/Applications/Example.app')).must_equal('file:///Applications/Example.app')
      _(dock.app_plist_data('file:///Applications/Example.app')).must_include('<string>file:///Applications/Example.app</string>')
    end
  end

  describe "reading" do
    it "reads the persistent apps back as paths, a user's own with ~ for their home" do
      with_dock do
        _(dock.read('persistent-apps')).must_equal('persistent-apps' => ['/System/Applications/Mail.app/', '~/Applications/Example App.app'])
      end
    end

    it "reads booleans as yes and no, and other attributes as they are" do
      with_dock do
        _(dock.read('autohide', 'magnification', 'tilesize', 'orientation')).must_equal(
          'autohide' => 'yes', 'magnification' => 'no', 'tilesize' => 48, 'orientation' => 'bottom'
        )
      end
    end

    it "leaves out the persistent others and the recent apps" do
      with_dock do
        _(dock.read.keys).wont_include('recent-apps')
        _(dock.read.keys).wont_include('persistent-others')
      end
    end

    it "writes what it reads as YAML" do
      with_dock do
        _(YAML.load(dock.to_yaml)['tilesize']).must_equal(48)
      end
    end
  end
end
