require_relative '../helper'
require 'fileutils'
require 'tmpdir'
require 'MacOS/Applications'

describe MacOS::Applications do
  let(:paths){['/System/Applications/Mail.app', '/Applications/Example App.app']}

  def with_paths(&block)
    MacOS::Applications.stub(:paths, paths, &block)
  end

  describe "finding an application" do
    it "finds one by its name, with or without .app" do
      with_paths do
        _(MacOS::Applications.path_for('Mail')).must_equal('/System/Applications/Mail.app')
        _(MacOS::Applications.path_for('Example App.app')).must_equal('/Applications/Example App.app')
      end
    end

    it "knows whether one is installed" do
      with_paths do
        _(MacOS::Applications.installed?('Mail')).must_equal(true)
        _(MacOS::Applications.installed?('Nowhere')).must_equal(false)
      end
    end
  end

  describe "where it looks" do
    def by_directory(&block)
      MacOS::Applications.stub(:in_directory, ->(directory){["#{directory}/In.app"]}) do
        MacOS::Applications.stub(:under_directory, ->(directory){["#{directory}/Under.app"]}, &block)
      end
    end

    it "looks in the system, local and user domains, the user's own searched all the way down" do
      by_directory do
        _(MacOS::Applications.paths('example')).must_equal(%w{
          /System/Applications/In.app /System/Applications/Utilities/In.app
          /Applications/In.app /Applications/Utilities/In.app
          /Users/example/Applications/Under.app
        })
      end
    end

    it "looks in every real user's Applications" do
      by_directory do
        MacOS::Users.stub(:all, %w{another example}) do
          _(MacOS::Applications.all_user_paths).must_equal(%w{/Users/another/Applications/Under.app /Users/example/Applications/Under.app})
        end
      end
    end
  end

  describe "the applications in a directory" do
    it "finds those directly in it, and those anywhere under it but not inside another application" do
      Dir.mktmpdir do |directory|
        %w{Top.app Sub/Nested.app Top.app/Contents/Helpers/Helper.app}.each{|path| FileUtils.mkdir_p(File.join(directory, path))}
        _(MacOS::Applications.in_directory(directory).map{|path| File.basename(path)}).must_equal(%w{Top.app})
        _(MacOS::Applications.under_directory(directory).map{|path| File.basename(path)}.sort).must_equal(%w{Nested.app Top.app})
      end
    end
  end

  describe "starting an application" do
    it "opens it, by each of its names" do
      with_paths do
        commands = commands_run_by(MacOS::Applications) do
          %i{start launch open run}.each{|method| MacOS::Applications.send(method, 'Mail')}
        end
        _(commands).must_equal([['open', '/System/Applications/Mail.app']] * 4)
      end
    end

    it "raises for an application which isn't installed, by each of its names, opening nothing" do
      with_paths do
        commands = commands_run_by(MacOS::Applications) do
          %i{start launch open run}.each do |method|
            error = _{MacOS::Applications.send(method, 'Nowhere')}.must_raise(RuntimeError)
            _(error.message).must_equal('Application: Nowhere was not found.')
          end
        end
        _(commands).must_equal([])
      end
    end
  end
end
