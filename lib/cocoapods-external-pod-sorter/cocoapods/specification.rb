require 'cocoapods'

module Pod
	class Specification
		module RecursiveDependency
			def recursive_dependencies(all_specs)
				@recursive_dependencies ||= begin
					resolve_recursive_dependencies(all_specs)
				end
			end

			def direct_dependencies
				@direct_dependencies ||= begin 
					direct_value('dependencies')
				end
			end

			protected
			def direct_value(name, platform = :ios)
				subspec_consumers = recursive_subspecs.select { |s| s.supported_on_platform?(platform) }
																							.map { |s| s.consumer(platform) }
																							.uniq
				value = (Array(consumer(platform)) + subspec_consumers).map { |c| c.send(name) }.flatten.uniq
				value
			end

			def resolve_recursive_dependencies(specs)
				direct_dependencies.map do |dep|
					spec = specs.find { |s| s.name == dep.name }
					next dep if spec.nil? || spec.direct_dependencies.empty?
						
					(Array(dep) + spec.resolve_recursive_dependencies(specs)).flatten
				end.compact.flatten.uniq
			end
		end

		include Pod::Specification::RecursiveDependency
	end
end