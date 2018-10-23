# OSX/Defaults.rb
# OSX::Defaults

# 20181023
# 0.2.0

# Transformations:

# 1. database/plist
# database --> plist
# plist --> database

# 2. plist/hash
# plist --> hash
# hash --> plist

# 3. yaml/database
# yaml --> database
# database --> yaml

# Todo;
# 1. Handle compound/vector values in to_yaml().  Currently dumping hashes when it should be creating another level or more levels of hierarchy.

require 'cfpropertylist'

module OSX
  class Defaults

    DEFAULT_PLIST_DIRECTORY = '/tmp'

    class << self

      def domains
        `defaults domains`.split('\n')
      end
      alias_method :all_domains, :domains

      def all
        domains.collect do |domain|
          self.new(domain)
        end
      end

      def bulk_export_to_plist_files
        domains.each do |domain|
          self.new(domain).export
        end
      end

      def bulk_import_from_plist_files
        domains.each do |domain|
          self.new(domain).import
        end
      end

    end # class << self

    def initialize(**args)
      @domain = args[:domain]
    end

    def export
      if domain_valid?
        `defaults export #{@domain} #{DEFAULT_PLIST_DIRECTORY}/#{@domain}.plist`
      else
        raise "Domain: #{@domain} was not found in the defaults database."
      end
      true
    end

    def import
      if File.exist?("#{DEFAULT_PLIST_DIRECTORY}/#{@domain}.plist")
        `defaults import #{@domain} #{DEFAULT_PLIST_DIRECTORY}/#{@domain}.plist`
      else
        raise "File: #{DEFAULT_PLIST_DIRECTORY}/#{@domain}.plist was not found in the filesystem."
      end
      true
    end

    def to_h
      plist = CFPropertyList::List.new(file: "#{DEFAULT_PLIST_DIRECTORY}/#{@domain}.plist")
      CFPropertyList.native_types(plist.value)
    end

    def to_yaml
      yaml_parts = []
      yaml_parts << "#{@domain}:"
      to_h.each do |k,v|
        yaml_parts << "  - #{k}: #{v}"
      end
      yaml_parts.join("\n")
    end
    alias_method :to_yml, :to_yaml

    def domain_valid?
      self.class.domains.include?(@domain) || global_domain?
    end

    def global_domain?
      @domain == '-globalDomain'
    end

  end
end

if __FILE__ == $0
  p OSX::Defaults.domains
  defaults = OSX::Defaults.new(domain: '-globalDomain')
  p defaults.domain_valid?
  p defaults.global_domain?
  defaults.export
  p defaults.to_h
  defaults.import
  p defaults.to_h
  puts defaults.to_yaml
end
