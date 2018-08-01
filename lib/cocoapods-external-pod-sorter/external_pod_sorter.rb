require 'cocoapods'
require 'cocoapods-external-pod-sorter/cocoapods/podfile'
require 'cocoapods-external-pod-sorter/cocoapods/sources_manager'
require 'cocoapods-external-pod-sorter/cocoapods/specification'
require 'cocoapods-external-pod-sorter/external_pod_sorter/pod_item'
require 'cocoapods-external-pod-sorter/cocoapods/source'
require 'cocoapods-external-pod-sorter/external_pod_sorter/data_source'
require 'cocoapods-external-pod-sorter/external_pod_sorter/data_source/local_data_source'

class ExternalPodSorter
	attr_accessor :grouped_pods

	def initialize(data_source = LocalDataSource.new)
		@data_source = data_source
	end

	public
	def sort
		@grouped_pods = group_pods_by_dependency_depth(@data_source.untagged_dependencies, @data_source.reference_specifications)
		@grouped_pods
	end

	private 
	def group_pods_by_dependency_depth(untagged_dependencies, reference_specifications)
		result = []

		untagged_dependency_names = untagged_dependencies.map(&:name)
		untagged_specs = reference_specifications.select do |spec|
			untagged_dependency_names.include?(spec.name)
		end

		while untagged_specs.length > 0
			pods = []
			untagged_specs.each do |spec|
				dependency_names = spec.recursive_dependencies(reference_specifications).map { |dep| dep.name }
				untagged_name = spec.name

				if untagged_specs.select { |spec| dependency_names.include?(spec.name) }.empty?
					pod = ExternalPodSorter::PodItem.new(untagged_name)
					pod.spec = reference_specifications.find { |spec| spec.name == untagged_name }	
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