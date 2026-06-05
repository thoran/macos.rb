# MacOS/Applications.rb
# MacOS::Applications

# 20260605
# 0.0.0

# Description: Locates and detects installed .app application bundles across the system, local, and user
# file-system domains, in the manner of `which` for command-line executables.

require 'Kernel/run'
require 'MacOS/Users'
require 'Module/alias_methods'

module MacOS
  module Applications
    module_function

    def paths(username = ENV['USER'])
      system_paths +
        system_utility_paths +
        local_paths +
        local_utility_paths +
        user_paths(username)
    end

    def system_paths
      in_directory('/System/Applications')
    end

    def system_utility_paths
      in_directory('/System/Applications/Utilities')
    end

    def local_paths
      in_directory('/Applications')
    end

    def local_utility_paths
      in_directory('/Applications/Utilities')
    end

    def user_paths(username = ENV['USER'])
      under_directory("/Users/#{username}/Applications")
    end

    def all_user_paths
      MacOS::Users.all.collect{|username| user_paths(username)}.flatten
    end

    def in_directory(directory)
      Dir["#{directory}/*.app"]
    end

    def under_directory(directory)
      Dir["#{directory}/**/*.app"].reject{|path| path.sub(/\.app$/, '').match?(/\.app\//)}
    end

    def path_for(application_name)
      paths.detect do |path|
        File.basename(path) == application_name ||
          File.basename(path, '.app') == application_name
      end
    end

    def installed?(application_name)
      path_for(application_name) ? true : false
    end

    def start(application_name)
      return unless path = path_for(application_name)
      Kernel.run('open', path)
    end
    alias_methods :launch, :open, :run, :start
    module_function :launch, :open, :run
  end
end

if __FILE__ == $0
  p MacOS::Applications.installed?(ARGV[0])
end
