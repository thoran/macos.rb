# MacOS/Defaults/NSGlobalDomain/NSUserKeyEquivalents.rb
# MacOS::Defaults::NSGlobalDomain::NSUserKeyEquivalents

# 20250210
# 0.1.0

# Changes:
# -/0 (More modifier keys and matching letters.)
# 1. ~ KEY_MAP: + ctrl
# 2. ~ KEY_MAP: + shift
# 3. ~ key_code(): Check if a key is alphabetic and use that.

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
              if ('a'..'z').include?(key.downcase)
                return_value << key.downcase
              elsif matching_pair = KEY_MAP.find{|key_mapping| key_mapping.first.map(&:to_s).map(&:downcase).include?(key.downcase)}
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
