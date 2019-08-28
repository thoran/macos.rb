# MacOS/Defaults.rb
# MacOS::Defaults

# 20190828
# 0.4.0

# Changes since 0.3:
# 1. /OSX/MacOS/

# Todo:
# 1. Handle compound/vector values in to_yaml().  Currently dumping hashes when it should be creating another level or more levels of hierarchy.

# Transformations:
# 1. database <--> plist
# 2. plist <--> hash
# 3. yaml <--> database


require 'cfpropertylist'
require 'yaml'

module MacOS
  class Defaults

    DEFAULT_PLIST_DIRECTORY = '/tmp'
    DEFAULT_YAML_FILENAME = File.expand_path(File.join('~', '.config', 'osx_defaults.yml'))

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

      def from_yaml(yaml_filename = nil)
        yaml_filename ||= DEFAULT_YAML_FILE
        yaml_defaults = YAML.load_file(yaml_filename)
        yaml_defaults.each do |domain, attributes|
          self.new(domain).from_yaml
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

    def to_yaml(yaml_parts = [], hash = to_h, recursion_depth = 1)
      yaml_parts << "#{@domain}:" if recursion_depth == 1
      hash.each do |k,v|
        to_yaml(yaml_parts, v, recursion_depth += 1) if v.is_a?(Hash)
        indent = ' ' * recursion_depth * 2
        yaml_parts << "#{indent}- #{k}: #{v}"
      end
      yaml_parts.join("\n")
    end
    alias_method :to_yml, :to_yaml

    def from_yaml
      attributes.each do |attribute|
        key, value = attribute.to_a.first
      end
    end

    def domain_valid?
      self.class.domains.include?(@domain) || global_domain?
    end

    def global_domain?
      @domain == '-globalDomain'
    end

  end
end

if __FILE__ == $0
  require 'pp'
  defaults = MacOS::Defaults.new(domain: '-globalDomain')
  defaults.export
  pp defaults.to_h
  pp defaults.to_yaml
end
