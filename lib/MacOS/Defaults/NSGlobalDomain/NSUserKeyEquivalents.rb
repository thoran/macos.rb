# MacOS/Defaults/NSGlobalDomain/NSUserKeyEquivalents.rb
# MacOS::Defaults::NSGlobalDomain::NSUserKeyEquivalents

# 20250211
# 0.2.0

# Changes:
# -/0: Parse existing assignments and dump yaml.
# 1. + read_keys()
# 2. + to_yaml()

require 'String/grep'

module MacOS
  module Defaults
    module NSGlobalDomain
      class NSUserKeyEquivalents
        KEY_MAP = {
          [:cmd, :command, :command_key] => '@',
          [:alt, :alt_key, :option, :option_key] => '~',
          [:ctrl, :control, :control_key] => '^',
          [:shift, :shift_key] => '$',
          [:left, :left_key, :left_arrow, :left_arrow_key] => '\UF702', # Also '\U2190'?
          [:right, :right_key, :right_arrow, :right_arrow_key] => '\UF703', # Also '\U2192'?
        }

        class << self
          def key_code(*keys)
            return_value = []
            keys.flatten.each do |key|
              if ('a'..'z').include?(key.to_s.downcase)
                return_value << key.downcase
              elsif matching_pair = KEY_MAP.find{|key_mapping| key_mapping.first.map(&:to_s).map(&:downcase).include?(key.to_s.downcase)}
                return_value << matching_pair.last
              else
                raise "No key #{key} found."
              end
            end
            return_value.join
          end

          def assign_key_code_command_string(key_code, menu_item)
            "defaults write NSGlobalDomain NSUserKeyEquivalents -dict-add '#{menu_item}' '#{key_code}'"
          end

          def assign_key_code_command_strings(key_code, menu_item_or_items)
            return_value = []
            [menu_item_or_items].flatten.each do |menu_item|
              return_value << assign_key_code_command_string(key_code, menu_item)
            end
            return_value
          end

          def assign_key_code(key_code, menu_item_or_items)
            return_value = true
            assign_key_code_command_strings(key_code, menu_item_or_items).each do |assign_key_code_command_string|
              system(assign_key_code_command_string)
              return_value = return_value && $?.success?
            end
            return_value
          end

          def assign_keys(key_or_keys, menu_item_or_items)
            assign_key_code(key_code(key_or_keys), menu_item_or_items)
          end

          def load(shortcuts)
            shortcuts.map do |shortcut|
              assign_keys(shortcut[:keys], shortcut[:menu_items])
            end
          end

          def parse_key_code(key_code)
            key_code.split('\U')
          end

          def read_keys
            return_value = []
            plist_dict = `defaults read .GlobalPreferences NSUserKeyEquivalents -`
            menu_item_to_keys_map = plist_dict.grep(/=/).split("\n").map{|e| e.split('=')}.map{|k,v| [k.strip, v.strip]}.map{|k,v| [k.tr('"',''), v.tr('"','')]}
            menu_item_to_keys_map.each do |shortcut|
              menu_item, key_code = shortcut.first, shortcut.last
              md = key_code.match(/([\@~\^\$]+)(.+);/)
              modifier_key_codes, key_code = md[1], md[2]
              modifier_key_names = modifier_key_codes.split('').map{|e| KEY_MAP.find{|km| km.last == e}.first.first}
              key_code = key_code.sub(/\\/, '')
              key_name = (
                if ('a'..'z').include?(key_code)
                  key_code
                else
                  KEY_MAP.find do |km|
                    km.last == key_code.upcase
                  end.first.first
                end
              )
              keys = [modifier_key_names, key_name].flatten
              found_shortcut = return_value.find{|e| Set.new(e[:keys]) == Set.new(keys)}
              if found_shortcut = return_value.find{|e| Set.new(e[:keys]) == Set.new(keys)}
                index = return_value.index(found_shortcut)
                return_value[index][:menu_items] << menu_item
              else
                return_value << {keys: keys, menu_items: [menu_item]}
              end
            end
            return_value.reverse
          end

          def to_yaml
            YAML.dump(read_keys)
          end
          alias_method :dump, :to_yaml
        end
      end
    end
  end
end

if __FILE__ == $0
  print(MacOS::Defaults::NSGlobalDomain::NSUserKeyEquivalents.key_code(['cmd', 'alt', 'left']) == "@~\\UF702" ? '.' : 'x')
  print(MacOS::Defaults::NSGlobalDomain::NSUserKeyEquivalents.key_code(['CMD', 'ALT', 'LEFT']) == "@~\\UF702" ? '.' : 'x')

  print(MacOS::Defaults::NSGlobalDomain::NSUserKeyEquivalents.assign_key_code_command_string("@~\\UF702", "Previous Tab") == "defaults write NSGlobalDomain NSUserKeyEquivalents -dict-add 'Previous Tab' '@~\\UF702'" ? '.' : 'x')
  print(MacOS::Defaults::NSGlobalDomain::NSUserKeyEquivalents.assign_key_code_command_strings("@~\\UF702", ["Previous Tab", "Select Previous Tab", "Show Previous Tab"]) == ["defaults write NSGlobalDomain NSUserKeyEquivalents -dict-add 'Previous Tab' '@~\\UF702'", "defaults write NSGlobalDomain NSUserKeyEquivalents -dict-add 'Select Previous Tab' '@~\\UF702'", "defaults write NSGlobalDomain NSUserKeyEquivalents -dict-add 'Show Previous Tab' '@~\\UF702'"] ? '.' : 'x')

  print(MacOS::Defaults::NSGlobalDomain::NSUserKeyEquivalents.assign_key_code("@~\\UF702", "Previous Tab") == true ? '.' : 'x')
  print(MacOS::Defaults::NSGlobalDomain::NSUserKeyEquivalents.assign_key_code("@~\\UF702", "Select Previous Tab") == true ? '.' : 'x')

  print(MacOS::Defaults::NSGlobalDomain::NSUserKeyEquivalents.assign_keys(%w{cmd alt left}, "Previous Tab") == true ? '.' : 'x')
  print(MacOS::Defaults::NSGlobalDomain::NSUserKeyEquivalents.assign_keys(%w{CMD ALT LEFT}, "Previous Tab") == true ? '.' : 'x')
  print(MacOS::Defaults::NSGlobalDomain::NSUserKeyEquivalents.assign_keys(%w{cmd alt left}, ["Previous Tab", "Select Previous Tab", "Show Previous Tab"]) == true ? '.' : 'x')
  print(MacOS::Defaults::NSGlobalDomain::NSUserKeyEquivalents.assign_keys(%w{CMD ALT LEFT}, ["Previous Tab", "Select Previous Tab", "Show Previous Tab"]) == true ? '.' : 'x')
  print(MacOS::Defaults::NSGlobalDomain::NSUserKeyEquivalents.assign_keys(%w{CMD D}, "Find Previous") == true ? '.' : 'x')

  puts
end
