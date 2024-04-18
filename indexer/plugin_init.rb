require 'aspace_logger'
require_relative 'aspace_search_mod_helper'

unless AppConfig.has_key?(:aspace_search_modifications_excludes) && AppConfig[:aspace_search_modifications_excludes].is_a?(Array)
  AppConfig[:aspace_search_modifications_excludes] = [
    "persistent_id",
    "ref",
    "uri"
  ]
end

class IndexerCommonConfig

  def self.fullrecord_excludes
    core_excludes = [ 
      "created_by",
      "last_modified_by",
      "system_mtime",
      "user_mtime",
      "json",
      "types",
      "create_time",
      "date_type",
      "jsonmodel_type",
      "publish",
      "extent_type",
      "language",
      "script",
      "system_generated",
      "suppressed",
      "source",
      "rules",
      "name_order",
      "repository",
      "top_container"
    ]

    core_excludes.concat(AppConfig[:aspace_search_modifications_excludes]).uniq
  end

end

class IndexerCommon

  override_method = AspaceSearchModHelpers.find_as_version

  if override_method == 'pre'
    puts "Using extract_string_values for v3.3.1 and earlier"
    def self.extract_string_values(doc)
      queue = [doc]
      strings = []
  
      while !queue.empty?
        doc = queue.pop
  
        doc.each do |key, val|
          if IndexerCommonConfig.fullrecord_excludes.include?(key) || key =~ /_enum_s$/
            # ignored
          elsif val.is_a?(String)
            strings.push(val)
          elsif val.is_a?(Hash)
            queue.push(val)
          elsif val.is_a?(Array)
            val.each do |v|
              if v.is_a?(String)
                strings.push(v)
              elsif v.is_a?(Hash)
                queue.push(v)
              end
            end
          end
        end
      end
  
      strings.join(' ').strip
    end
  else
    puts "Using patched fullrecord_excludes for v3.4.0+"
  end

end
