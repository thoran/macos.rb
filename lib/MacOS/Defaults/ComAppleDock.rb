# MacOS/Defaults/ComAppleDock.rb
# MacOS::Defaults::ComAppleDock

# 20250212
# 0.5.2

require 'plist'

module MacOS
  module Defaults
    module ComAppleDock
      ARRAY_ATTRIBUTES = %w{
        persistent-apps
        persistent-others
        recent-apps
      }
      BOOLEAN_ATTRIBUTES = %w{
        autohide
        expose-group-apps
        launchanim
        magnification
        minimize-to-application
        show-process-indicators
        single-app
        trash-full
      }
      INTEGER_ATTRIBUTES = %w{
        tilesize
      }
      STRING_ATTRIBUTES = %w{
        mineffect
        orientation
      }
      ALL_ATTRIBUTES = (ARRAY_ATTRIBUTES + BOOLEAN_ATTRIBUTES + INTEGER_ATTRIBUTES + STRING_ATTRIBUTES).sort

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

        def peristent_app_paths(plist)
          plist['persistent-apps'].map do |persistent_app|
            file_url = persistent_app['tile-data']['file-data']['_CFURLString']
            file_url.sub(/file:\/\//, '').gsub(/%20/, ' ').sub(/\/Users\/.+?(\/.+)\//, '~\1')
          end
        end

        def boolean_to_yes_no(boolean_string)
          case boolean_string
          when true; 'yes'
          when false; 'no'
          end
        end

        def read(*attributes)
          return_value = {}
          plist = Plist.parse_xml(`defaults export com.apple.dock -`)
          attribute_list = (attributes.empty? ? ALL_ATTRIBUTES : attributes)
          attribute_list.each do |attribute|
            next if %w{persistent-others recent-apps}.include?(attribute)
            if attribute == 'persistent-apps'
              return_value[attribute] = peristent_app_paths(plist)
            elsif BOOLEAN_ATTRIBUTES.include?(attribute)
              return_value[attribute] = boolean_to_yes_no(plist[attribute])
            else
              return_value[attribute] = plist[attribute]
            end
          end
          return_value
        end

        def to_yaml
          YAML.dump(read).gsub(/['"]/, '')
        end
        alias_method :dump, :to_yaml
      end
    end
  end
end
