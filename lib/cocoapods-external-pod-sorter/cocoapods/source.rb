require 'cocoapods'

module Pod
	class Source
		def newest_specs 
			pods.map do |pod|
		    versions = versions(pod)
		    if versions
	        version = versions.sort.last
	        spec = specification(pod, version)
		    end
			end.compact
		end
	end
end