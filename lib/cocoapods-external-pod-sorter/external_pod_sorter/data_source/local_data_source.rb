require 'cocoapods'

class ExternalPodSorter
	class LocalDataSource < DataSource
		def initialize(config = Pod::Config.instance)
			@config = config
		end

		def untagged_dependencies
			@config.podfile.untagged_dependencies
		end

		def reference_specifications
			analyzer = Pod::Installer::Analyzer.new(@config.sandbox, @config.podfile, @config.lockfile)			
			podfile_specs = @config.with_changes(skip_repo_update: true) do 
				# allow fetch ，初次install时，或者新增external source 时，由于Pods/Local Podspecs 是空，会抛出找不到specification异常
				begin
					analyzer.analyze(false).specs_by_target.values.flatten(1)	
				rescue 
					analyzer.analyze(true).specs_by_target.values.flatten(1)
				end
			end

			podfile_specs
		rescue
			puts 'Can`t fetch specs from project directory, fetch from private source cache'.yellow
			@config.sources_manager.default_source.newest_specs
		end
	end
end