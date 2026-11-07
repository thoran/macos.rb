require_relative '../helper'
require 'MacOS/Users'

describe MacOS::Users do
  it "lists the real users, without the system and service accounts" do
    MacOS::Users.stub(:`, fixture('dscl-list-users.txt')) do
      _(MacOS::Users.all).must_equal(%w{another example})
    end
  end
end
