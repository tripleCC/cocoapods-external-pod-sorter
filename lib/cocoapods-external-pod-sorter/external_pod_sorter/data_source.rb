class ExternalPodSorter
	class DataSource
		def untagged_dependencies
			raise NotImplementedError.new("#{self.class.name}#untagged_dependencies是抽象方法")
		end

		def reference_specifications
			raise NotImplementedError.new("#{self.class.name}#reference_specifications是抽象方法")
		end
	end
end