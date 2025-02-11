# String/to_boolean.rb
# String#to_boolean

# 20130605, 06
# 0.9.0

# Description: Convert strings to booleans.  

# Changes since 0.8: 
# 1. Added 't' and 'f' to the list of true and false values respectively, so as to account for the way in which Postgres will sometimes represent these values.  
# 2. + require 'Module/alias_methods'

require 'Module/alias_methods'

class NonBooleanError < RuntimeError; end

class String
  
  def to_boolean(default_is_false = false)
    if ['true', 't', '1', 'yes', 'on'].include?(self.downcase)
      true
    elsif default_is_false
      false
    elsif ['false', 'f', '0', 'no', 'off'].include?(self.downcase)
      false
    else
      raise NonBooleanError, "The string, \'#{self}\', cannot be converted to a boolean."
    end
  end
  alias_methods :to_b, :to_bool, :to_boolean

end
