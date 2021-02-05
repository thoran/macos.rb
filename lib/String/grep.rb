# String/grep.rb
# String#grep

# 20200616
# 0.2.0

# Changes since 0.1:
# 0/1: No longer mixing in Enumerable as it was causing an infinite loop when used with net/http/header.rb:94.
# 0. ~ String#grep: Now splitting the string and relying upon Enumerable being on Array.

class String

  def grep(pattern)
    self.split("\n").select{|line| line =~ pattern}.join("\n")
  end

end
