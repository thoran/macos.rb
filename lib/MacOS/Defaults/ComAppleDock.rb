# MacOS/Defaults/ComAppleDock.rb
# MacOS::Defaults::ComAppleDock

# 20250211
# 0.4.0

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
      INTEGER_ATTRIBUTES = %w{
        tilesize
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

        def attribute_write_command(attr, value)
          value = (
            if BOOLEAN_ATTRIBUTES.include?(attr) # Without adding -bool it doesn't work.
              "-bool #{value}"
            elsif INTEGER_ATTRIBUTES.include?(attr) # Adding -int isn't strictly necessary for it to work, but is correct syntax.
              "-int #{value}"
            else
              value
            end
          )
          "defaults write com.apple.dock #{attr} #{value}"
        end

        def load_attribute(attr, value)
          system(attribute_write_command(attr, value))
        end

        def load(dock_config)
          dock_config.each do |attr, value|
            if attr == 'persistent-apps'
              load_persistent_apps(value)
            else
              load_attribute(attr, value)
            end
          end
        end
      end
    end
  end
end
