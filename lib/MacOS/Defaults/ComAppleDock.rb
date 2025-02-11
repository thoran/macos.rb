# MacOS/Defaults/ComAppleDock.rb
# MacOS::Defaults::ComAppleDock

# 20250211
# 0.2.0

module MacOS
  module Defaults
    module ComAppleDock

      class << self
        def item_plist(urlified_item_string)
          <<~DOCK_ITEM
            <dict>
              <key>tile-data</key>
              <dict>
                <key>file-data</key>
                <dict>
                  <key>_CFURLString</key>
                  <string>#{urlified_item_string}</string>
                  <key>_CFURLStringType</key>
                  <integer>15</integer>
                </dict>
              </dict>
            </dict>
          DOCK_ITEM
        end

        def urlified_item_string(item)
          "file://#{File.expand_path(item)}"
        end

        def defaults_write_command(urlified_item_string)
          "defaults write com.apple.dock persistent-apps -array-add '#{urlified_item_string}'"
        end

        def add_item(item)
          system(defaults_write_command(item_plist(urlified_item_string(item))))
        end

        def load_items(dock_config_items)
          dock_config_items.each do |item|
            add_item(item)
          end
        end

        def delete_all_items
          delete_items('persistent-apps')
          delete_items('persistent-others')
          delete_items('recent-apps')
        end

        def delete_items(scope)
          system("defaults delete com.apple.dock #{scope}")
        end

        def attribute_command_string(attr, value)
          "defaults write com.apple.dock #{attr} #{value}"
        end

        def load_attribute(attr, value)
          system(attribute_command_string(attr, value))
        end

        def load_attributes(dock_config)
          dock_config.each do |attr, value|
            next if attr == 'items'
            load_attribute(attr, value)
          end
        end

        def load(dock_config)
          dock_config.each do |attr, value|
            if attr == 'items'
              load_items(value)
            else
              load_attribute(attr, value)
            end
          end
        end
      end
    end
  end
end
