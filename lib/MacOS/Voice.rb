# MacOS/Voice.rb
# MacOS::Voice

# 20261107
# 0.0.0

# Notes:
# 1. Taken from Kernel/say.rb 0.4.2.

module MacOS
  class Voice
    attr_reader :name, :localization, :description

    class << self
      
      def all
        `say -v ?`.lines.collect{|line| new_from_line(line)}
      end
      alias_method :list, :all

      def random_voice
        list.sample
      end

      private

      def new_from_line(line)
        name_and_localization, description = line.split('#')
        description = description.lstrip
        name, localization = name_and_localization.strip.split
        Voice.new(name: name, localization: localization, description: description)
      end

    end # class << self

    def initialize(name:, localization:, description:)
      @name = name
      @localization = localization
      @description = description
    end

  end
end

if __FILE__ == $0
  p MacOS::Voice.list
  p MacOS::Voice.random_voice
end
