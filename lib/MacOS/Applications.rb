# MacOS/Applications.rb
# MacOS::Applications

# Description: Locates and detects installed .app application bundles across the system, local, and user
# file-system domains, in the manner of `which` for command-line executables.

require 'MacOS/Users'

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
      raise "Application: #{application_name} was not found." unless path = path_for(application_name)
      system('open', path, exception: true)
    end
    alias_method :launch, :start
    alias_method :open, :start
    alias_method :run, :start
    module_function :launch, :open, :run
  end
end
