require 'cocoapods'
require 'cocoapods-external-pod-sorter/cocoapods/source'

module Pod
	class Source
		class Manager
			DEFAULT_SOURCE_URL = 'git@git.2dfire-inc.com:ios/cocoapods-spec.git'.freeze

			def newest_specs_with_source_name_or_url(name_or_url)
				source = source_with_name_or_url(name_or_url)
				source.newest_specs if source
			end

			def default_source
				source_with_name_or_url(DEFAULT_SOURCE_URL)
			end
		end
	end
end