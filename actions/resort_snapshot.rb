module Fastlane
  module Actions
    module SharedValues
      RESORT_SNAPSHOT_CUSTOM_VALUE = :RESORT_SNAPSHOT_CUSTOM_VALUE
    end

    class ResortSnapshotAction < Action
      def self.run(options)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        UI.message "Resort and Generate resorted Report"

        dir_execute = Dir.pwd
        # 说明是在fastlane的父目录下
        if Dir.exist?(File.join(dir_execute,'fastlane'))
            dir_execute = File.join(dir_execute,'fastlane')
        end

        @data = {}
        screenshots_path = File.join(dir_execute, options[:screenshots_path])

        puts screenshots_path
        Dir[File.join(screenshots_path, "*")].sort.each do |language_folder|
            # UI.error language_folder
            language = File.basename(language_folder)
            # UI.success language
            if Dir.exists?language_folder
                # 创建语言的字典
                @data[language] ||= {};
                server_id = 0
                snapPhotos = {};
                @data[language]["photos"] = snapPhotos;

                Dir[File.join(language_folder, '*.png')].sort.each do |screenshot|
                    fileName = File.basename(screenshot)
                    relative_screenshot_path = File.join("./", language, fileName)

                    full_name_strs = fileName.split('-')
                    # 在swift里是下划线分割线的，所以这里再用_区分
                    custom_xargs = full_name_strs[1].split('_')
                    photo_name = custom_xargs[0]

                    test_seq_id = File.basename(full_name_strs[2], '.png')
                    snapPhotos[test_seq_id] ||= {}
                    if snapPhotos[test_seq_id]["theme_server_id"] ==  nil
                        snapPhotos[test_seq_id]["theme_server_id"] = custom_xargs[1]
                    end

                    snapPhotos[test_seq_id]["list"] ||= []
                    snapPhotos[test_seq_id]["list"] << {"photo_name" => photo_name, "device_name" => full_name_strs[0], "file_name" => fileName, "url" => relative_screenshot_path}
                end
                # 从循环里获取一个serverId
                @data[language]["meta"] = {"language" => language};
            elsif File.exists?language_folder
                puts "#{language} is a file. Skip it"
            else
                puts "what happened to #{language} ?"
            end
        end

        # puts @data
        cwd_dir = File.dirname(__FILE__);

        html_path = File.join(cwd_dir, "page.html.erb")
        puts html_path
        html = ERB.new(File.read(html_path)).result(binding) # http://www.rrn.dk/rubys-erb-templating-system

        export_path = File.join( screenshots_path, "resort_screenshots.html")
        File.write(export_path, html)

        export_path = File.expand_path(export_path)
        UI.success "Successfully created HTML file with an overview of all the screenshots: '#{export_path}'"
        system("open '#{export_path}'") unless options[:skip_open_summary]
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Create a well-refined screenshot reports."
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "This action read png's files under directory of /screenshots, and find, sort, regroup them. Then generate new well-refined summary reports."
      end

      def self.available_options
        # Define all options your action supports.

        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :skip_open_summary,
                                       is_string: false,
                                       optional: true,
                                       default_value: false,
                                       env_name: "FL_RESORT_SNAPSHOT_SKIP_OPEN_SUMMARY", # The name of the environment variable
                                       description: "whether or not open summary html after done", # a short description of this parameter
                                       verify_block: proc do |value|
                                        #   UI.user_error!("No API token for ResortSnapshotAction given, pass using `api_token: 'token'`") unless (value and not value.empty?)
                                      end),
           FastlaneCore::ConfigItem.new(key: :screenshots_path,
                                        is_string: true,
                                        optional: true,
                                        default_value: "./screenshots",
                                        env_name: "FL_RESORT_SNAPSHOT_SCREENSHOT_PATH", # The name of the environment variable
                                        description: "the directory of containing screenshot files", # a short description of this parameter
                                        verify_block: proc do |value|
                                           # UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
                                        end)
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        # [
        #   ['RESORT_SNAPSHOT_CUSTOM_VALUE', 'A description of what this value contains']
        # ]
      end

      def self.return_value
        # If you method provides a return value, you can describe here what it does
        "Everythings is ok if no errors occured"
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["hite"]
      end

      def self.is_supported?(platform)
        # you can do things like
        #
        #  true
        #
        #  platform == :ios
        #
        #  [:ios, :mac].include?(platform)
        #

        platform == :ios
      end
    end
  end
end
