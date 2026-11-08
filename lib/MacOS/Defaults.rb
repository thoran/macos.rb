# MacOS/Defaults.rb
# MacOS::Defaults

# Todo:
# 1. Handle compound/vector values in to_yaml().  Currently dumping hashes when it should be creating another level or more levels of hierarchy.

# Transformations:
# 1. database <--> plist
# 2. plist <--> hash
# 3. yaml <--> database


require 'cfpropertylist'
require 'shellwords'
require 'yaml'

module MacOS
  class Defaults

    DEFAULT_PLIST_DIRECTORY = '/tmp'
    DEFAULT_YAML_FILENAME = File.expand_path(File.join('~', '.config', 'osx_defaults.yml'))

    class << self

      def domains
        `defaults domains`.chomp.split(', ')
      end
      alias_method :all_domains, :domains

      def all
        domains.collect do |domain|
          self.new(domain: domain)
        end
      end

      def bulk_export_to_plist_files
        domains.each do |domain|
          self.new(domain: domain).export
        end
      end

      def bulk_import_from_plist_files
        domains.each do |domain|
          self.new(domain: domain).import
        end
      end

      def from_yaml(yaml_filename = nil)
        yaml_filename ||= DEFAULT_YAML_FILENAME
        yaml_defaults = YAML.load_file(yaml_filename)
        yaml_defaults.each do |domain, attributes|
          self.new(domain: domain).from_yaml(attributes)
        end
      end

    end # class << self

    def initialize(**args)
      @domain = args[:domain]
    end

    def export
      if domain_valid?
        `defaults export #{Shellwords.escape(@domain)} #{Shellwords.escape("#{DEFAULT_PLIST_DIRECTORY}/#{@domain}.plist")}`
      else
        raise "Domain: #{@domain} was not found in the defaults database."
      end
      true
    end

    def import
      if File.exist?("#{DEFAULT_PLIST_DIRECTORY}/#{@domain}.plist")
        `defaults import #{Shellwords.escape(@domain)} #{Shellwords.escape("#{DEFAULT_PLIST_DIRECTORY}/#{@domain}.plist")}`
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

    # Writes each attribute, as to_yaml writes them, a list of single key: value pairs, true where every write succeeds.
    def from_yaml(attributes)
      attributes.map do |attribute|
        key, value = attribute.to_a.first
        system('defaults', 'write', @domain, key.to_s, *defaults_arguments(value))
      end.all?
    end

    def domain_valid?
      self.class.domains.include?(@domain) || global_domain?
    end

    def global_domain?
      @domain == '-globalDomain'
    end

    private

    # A value as defaults write takes it, its type given first.
    def defaults_arguments(value)
      case value
      when true, false then ['-bool', value.to_s]
      when Integer then ['-int', value.to_s]
      when Float then ['-float', value.to_s]
      when Array then ['-array', *value.map(&:to_s)]
      when Hash then ['-dict', *value.flat_map{|k, v| [k.to_s, v.to_s]}]
      else ['-string', value.to_s]
      end
    end

  end
end
