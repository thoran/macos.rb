# OSX/Defaults.rb
# OSX::Defaults

# 20181023
# 0.0.0

# database --> plist
# plist --> hash
# hash --> plist
# hash --> database
# yaml --> database
# yaml --> plist

require 'cfpropertylist'

module OSX
  class Defaults

    class << self

      def domains
        `defaults domains`.split(', ')
      end
      alias_method :all_domains, :domains

      def all
        domains.collect do |domain|
          self.new(domain)
        end
      end

      def bulk_export_to_plist_files(export_directory = '/tmp')
        domains.each do |domain|
          `defaults export #{domain} #{export_directory}/#{domain}.plist`
        end
      end

      def bulk_import_from_plist_files(import_directory = '/tmp')
        domains.each do |domain|
          if File.exist?("#{import_directory}/#{domain}.plist")
            `defaults import #{domain} #{import_directory}/#{domain}.plist`
          end
        end
      end

    end # class << self

    def initialize(**args)
      @domain = args[:domain]
    end

    def to_h
      plist = CFPropertyList::List.new(file: "/tmp/#{domain}")
      CFPropertyList.native_types(plist.value)
    end

  end
end

if __FILE__ == $0
  p OSX::Defaults.domains
  p OSX::Defaults.new(domain: '-globalDomain')
end
