class ExternalPodSorter
	class PodItem
		attr_accessor :name
		attr_accessor :external_dependency_names
		attr_accessor :dependency
		attr_accessor :spec

		def initialize(name)
			@name = name
		end

		def to_s
			name
		end

		def inspect
			name
		end
	end
end