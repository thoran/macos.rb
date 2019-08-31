# String/each.rb
# String#each

# 20130701
# 0.1.0

# Changes: 
# 1. - require 'String/each_char', as it is already provided by Ruby 1.9+.  
# 2. - require 'String/each_line', as it is already provided by Ruby 1.9+.  

# Description: Ruby 1.9 no longer mixes in Enumerable, so here's String's missing #each method.  See String#each_line and String#each_char for the specific implementations.  

class String
  
  def each(unit = :line, &block)
    case unit
    when :line; each_line(&block)
    when :char; each_char(&block)
    end
  end
  
end
