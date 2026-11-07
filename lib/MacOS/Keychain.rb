# MacOS/Keychain.rb
# MacOS::Keychain

require 'open3'
require 'shellwords'

module MacOS
  class Keychain
    class << self

      def find_generic_password_command(key)
        "security find-generic-password -ga #{Shellwords.escape(key)}"
      end

      def find_generic_password(key)
        Open3.capture3(find_generic_password_command(key))
      end

      def wifi_password(wifi_ssid)
        stdout, stderr, status = find_generic_password(wifi_ssid)
        stderr[/password: "(.+)"/, 1]
      end

    end # class << self
  end
end
