# MacOS/Users.rb
# MacOS::Users

# Description: Lists the real (human) user accounts on the system, excluding system and service accounts.

module MacOS
  module Users
    module_function

    def all
      `dscl . list /users`.split("\n")
        .reject{|username| username =~ /^_/}
        .reject{|username| %w{daemon nobody root}.include?(username)}
    end
  end
end
