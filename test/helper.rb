require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/mock'

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

# What a command printed, captured with its MAC addresses, IP addresses and names made anonymous.
def fixture(name)
  File.read(File.expand_path("fixtures/#{name}", __dir__))
end

# Runs the block with system stubbed on receiver, returning the commands it was given; each succeeds, setting $?.
def commands_run_by(receiver)
  commands = []
  succeed = ->(*command, **options){commands << command; Kernel.system('true')}
  receiver.stub(:system, succeed){yield}
  commands
end
