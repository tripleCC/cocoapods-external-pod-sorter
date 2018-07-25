require 'cocoapods-external-pod-sorter/external_pod_sorter'

module Pod
  class Command
    # This is an example of a cocoapods plugin adding a top-level subcommand
    # to the 'pod' command.
    #
    # You can also create subcommands of existing or new commands. Say you
    # wanted to add a subcommand to `list` to show newly deprecated pods,
    # (e.g. `pod list deprecated`), there are a few things that would need
    # to change.
    #
    # - move this file to `lib/pod/command/list/deprecated.rb` and update
    #   the class to exist in the the Pod::Command::List namespace
    # - change this class to extend from `List` instead of `Command`. This
    #   tells the plugin system that it is a subcommand of `list`.
    # - edit `lib/cocoapods_plugins.rb` to require this file
    #
    # @todo Create a PR to add your plugin to CocoaPods/cocoapods.org
    #       in the `plugins.json` file, once your plugin is released.
    #
    class Sort < Command
      self.summary = '对 Podfile 中依赖 external 的组件进行分组.'

      self.description = <<-DESC
        cocoapods-external-pod-sorter 对 Podfile 中依赖 external 的组件进行分组.
      DESC

      def self.options
        [
            ['--project-directory', 'The path to the root of the project directory']
        ].concat(super)
      end

      def initialize(argv)
        @project_directory = argv.option('project-directory')
        super
      end

      def validate!
        super
        podfile_empty = (@project_directory && Pathname.glob(File.join(@project_directory, 'Podfile')).empty?) || 
        Pathname.glob('Podfile').empty?
        help! 'No `Podfile` found in the project directory.' if podfile_empty
      end

      def run
        config = Pod::Config.instance
        config.installation_root = Pathname.new(@project_directory) if @project_directory
        sorter = ExternalPodSorter.new(config)
        sorter.sort
        sorter.grouped_pods.each do |group|
          group.each do |pod|
            display = pod.name.dup
            if pod.external_dependency_names.any?
              pod.external_dependency_names.each do |name|
                display << "\n- #{name}"
              end
            end
            display << "\n\n"
            puts display
          end
        end
      end
    end
  end
end
