# MacOS/Version.rb
# MacOS

# 20190831
# 0.0.0

require 'MacOS/SystemProfiler'

module MacOS

  VERSION ||= MacOS::SystemProfiler.system_version

  module_function

  def version
    VERSION
  end

  def major_version
    VERSION.split('.').first
  end

  def minor_version
    VERSION.split('.').second
  end

  def tiny_version
    VERSION.split('.').third
  end

end

if __FILE__ == $0
  p MacOS.version
end
