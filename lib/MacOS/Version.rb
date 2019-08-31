# MacOS/Version.rb
# MacOS

# 20190831
# 0.1.0

require 'MacOS/SystemProfiler'

module MacOS

  module_function

  def version
    MacOS::SystemProfiler.system_version
  end

  module VERSION; STRING = MacOS.version.to_s; end

end

if __FILE__ == $0
  p MacOS::VERSION::STRING
  p MacOS.version
  p MacOS.version.major
  p MacOS.version.minor
  p MacOS.version.tiny
end
