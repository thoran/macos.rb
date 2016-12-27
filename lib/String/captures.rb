# String/captures
# String#captures

# 20111025
# 0.0.0

# Changes since 0.0: 
# 1. - capture().  The functionality is the same as per String#capture, but now String#capture only returns the first capture.  This returns the array of captures.  

class String
  
  def captures(regex)
    if md = self.match(regex)
      md.captures
    else
      nil
    end
  end
  
end
