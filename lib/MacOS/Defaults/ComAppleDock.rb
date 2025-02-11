# MacOS/Defaults/ComAppleDock.rb
# MacOS::Defaults::ComAppleDock

# 20250211
# 0.3.0

require '_meta/to_boolean'

module MacOS
  module Defaults
    module ComAppleDock
      BOOLEAN_ATTRIBUTES = %w{
        autohide
        expose-group-apps
        launchanim
        magnification
        minimize-to-application
        single-app
        trash-full
      }

      class << self
        def app_plist_data(urlified_app_string)
          <<~APP_PLIST
            <dict>
              <key>tile-data</key>
              <dict>
                <key>file-data</key>
                <dict>
                  <key>_CFURLString</key>
                  <string>#{urlified_app_string}</string>
                  <key>_CFURLStringType</key>
                  <integer>15</integer>
                </dict>
              </dict>
            </dict>
          APP_PLIST
        end

        def urlified_app_string(item)
          "file://#{File.expand_path(item)}"
        end

        def persistent_app_write_command(app_plist_data)
          "defaults write com.apple.dock persistent-apps -array-add '#{app_plist_data}'"
        end

        def add_persistent_app(persistent_app_path)
          system(
            persistent_app_write_command(
              app_plist_data(
                urlified_app_string(
                  persistent_app_path
                )
              )
            )
          )
        end

        def load_persistent_apps(persistent_app_paths)
          persistent_app_paths.each do |persistent_app_path|
            add_persistent_app(persistent_app_path)
          end
        end

        def delete_all_items
          delete_item('persistent-apps')
          delete_item('persistent-others')
          delete_item('recent-apps')
        end

        def delete_item(scope)
          system("defaults delete com.apple.dock #{scope}")
        end

        def general_attribute_write_command_string(attr, value)
          "defaults write com.apple.dock #{attr} #{value}"
        end

        def boolean_attribute_write_command_string(attr, value)
          "defaults write com.apple.dock #{attr} -bool #{value.to_boolean}"
        end

        def load_general_attribute(attr, value)
          system(general_attribute_write_command_string(attr, value))
        end

        def load_boolean_attribute(attr, value)
          system(boolean_attribute_write_command_string(attr, value))
        end

        def load(dock_config)
          dock_config.each do |attr, value|
            if attr == 'persistent-apps'
              load_persistent_apps(value)
            elsif BOOLEAN_ATTRIBUTES.include?(attr)
              load_boolean_attribute(attr, value)
            else
              load_general_attribute(attr, value)
            end
          end
        end
      end
    end
  end
end
