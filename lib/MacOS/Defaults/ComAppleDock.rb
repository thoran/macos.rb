# MacOS/Defaults/ComAppleDock.rb
# MacOS::Defaults::ComAppleDock

# 20250210
# 0.1.0

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

        def write_item(item)
          system(defaults_write_command(item_plist(urlified_item_string(item))))
        end

        def write_items(dock_config)
          dock_config.each do |item|
            write_item(item)
          end
        end

        def delete_all_items
          delete('persistent-apps')
          delete('persistent-others')
          delete('recent-apps')
        end

        def delete(scope)
          system("defaults delete com.apple.dock #{scope}")
        end
      end

    end
  end
end
