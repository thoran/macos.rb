require_relative '../../../helper'
require 'MacOS/Defaults/NSGlobalDomain/NSUserKeyEquivalents'

describe MacOS::Defaults::NSGlobalDomain::NSUserKeyEquivalents do
  let(:keys){MacOS::Defaults::NSGlobalDomain::NSUserKeyEquivalents}

  describe ".key_code" do
    it "codes modifier and arrow keys, in either case" do
      _(keys.key_code(%w{cmd alt left})).must_equal('@~\\UF702')
      _(keys.key_code(%w{CMD ALT LEFT})).must_equal('@~\\UF702')
      _(keys.key_code(:ctrl, :shift, :right)).must_equal('^$\\UF703')
    end

    it "keeps a letter as itself" do
      _(keys.key_code(%w{cmd D})).must_equal('@d')
    end

    it "raises for a key it doesn't know" do
      _{keys.key_code(%w{cmd hyper})}.must_raise(RuntimeError)
    end
  end

  describe ".parse_key_code" do
    it "splits a key code at each \\U" do
      _(keys.parse_key_code('@~\UF702')).must_equal(['@~', 'F702'])
    end
  end

  describe "assigning keys" do
    it "makes a defaults write command for each menu item" do
      _(keys.assign_key_code_command_strings('@~\\UF702', ['Previous Tab', 'Show Previous Tab'])).must_equal([
        "defaults write NSGlobalDomain NSUserKeyEquivalents -dict-add 'Previous Tab' '@~\\UF702'",
        "defaults write NSGlobalDomain NSUserKeyEquivalents -dict-add 'Show Previous Tab' '@~\\UF702'",
      ])
    end

    it "runs them, succeeding where each does" do
      result = nil
      commands = commands_run_by(keys){result = keys.assign_keys(%w{cmd alt left}, 'Previous Tab')}
      _(result).must_equal(true)
      _(commands).must_equal([["defaults write NSGlobalDomain NSUserKeyEquivalents -dict-add 'Previous Tab' '@~\\UF702'"]])
    end

    it "loads several shortcuts at once" do
      shortcuts = [{keys: %w{cmd alt left}, menu_items: ['Previous Tab']}, {keys: %w{cmd shift d}, menu_items: ['Find Previous']}]
      commands = commands_run_by(keys){keys.load(shortcuts)}
      _(commands.size).must_equal(2)
    end
  end

  describe ".read_keys" do
    it "reads the shortcuts back, as keys and the menu items they're for" do
      keys.stub(:`, fixture('defaults-read-NSUserKeyEquivalents.txt')) do
        _(keys.read_keys).must_equal([
          {keys: [:cmd, :alt, :left], menu_items: ['Previous Tab']},
          {keys: [:cmd, :shift, 'd'], menu_items: ['Find Previous']},
        ])
      end
    end

    it "writes them as YAML" do
      keys.stub(:`, fixture('defaults-read-NSUserKeyEquivalents.txt')) do
        _(YAML.load(keys.to_yaml, permitted_classes: [Symbol]).first[:menu_items]).must_equal(['Previous Tab'])
      end
    end
  end
end
