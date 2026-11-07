require_relative '../helper'
require 'MacOS/Keychain'

describe MacOS::Keychain do
  it "asks security for a generic password, the key escaped for the shell" do
    _(MacOS::Keychain.find_generic_password_command('Example Net')).must_equal('security find-generic-password -ga Example\\ Net')
  end

  it "gives a Wi-Fi network's password, which security writes to standard error" do
    found = ["keychain: \"/Library/Keychains/System.keychain\"\n", "password: \"example-passphrase\"\n", nil]
    MacOS::Keychain.stub(:find_generic_password, found) do
      _(MacOS::Keychain.wifi_password('ExampleNet')).must_equal('example-passphrase')
    end
  end

  it "gives nil where the keychain has no password for the network" do
    missing = ['', "security: SecKeychainSearchCopyNext: The specified item could not be found in the keychain.\n", nil]
    MacOS::Keychain.stub(:find_generic_password, missing) do
      _(MacOS::Keychain.wifi_password('Nowhere')).must_be_nil
    end
  end
end
