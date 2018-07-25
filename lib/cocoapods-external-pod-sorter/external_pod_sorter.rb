require 'cocoapods'
require 'cocoapods-external-pod-sorter/cocoapods/podfile'
require 'cocoapods-external-pod-sorter/cocoapods/sources_manager'
require 'cocoapods-external-pod-sorter/cocoapods/specification'
require 'cocoapods-external-pod-sorter/external_pod_sorter/pod_item'
require 'cocoapods-external-pod-sorter/cocoapods/source'

class ExternalPodSorter
	attr_accessor :grouped_pods

	def initialize(config = Pod::Config.instance)
		@config = config
		@untagged_dependencies = config.podfile.untagged_dependencies
	end

	public
	def sort
		podfile_specs = analyze_podfile_specs
		@grouped_pods = group_pods_by_dependency_depth(@untagged_dependencies, podfile_specs)
		@grouped_pods
	end

	private 

	def analyze_podfile_specs
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

	def group_pods_by_dependency_depth(untagged_dependencies, podfile_specs)
		result = []

		untagged_dependency_names = untagged_dependencies.map(&:name)
		untagged_specs = podfile_specs.select do |spec|
			untagged_dependency_names.include?(spec.name)
		end

		while untagged_specs.length > 0
			pods = []
			untagged_specs.each do |spec|
				dependency_names = spec.recursive_dependencies(podfile_specs).map { |dep| dep.name }
				untagged_name = spec.name

				if untagged_specs.select { |spec| dependency_names.include?(spec.name) }.empty?
					pod = ExternalPodSorter::PodItem.new(untagged_name)
					pod.spec = podfile_specs.find { |spec| spec.name == untagged_name }	
					pod.dependency = untagged_dependencies.find { |dep| dep.name == untagged_name }
					pod.external_dependency_names = dependency_names.select { |name| untagged_dependency_names.include?(name) }
					pods << pod
				end
			end
			untagged_specs = untagged_specs.reject do |spec|
				pods.select { |pod| pod.name == spec.name }.any?
			end

			result << pods
		end

		result
	end
end	