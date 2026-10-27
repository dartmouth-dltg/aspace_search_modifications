# ancestors: plugins that resolve ancestors for indexing would otherwise add every
# ancestor's text to each archival object's fullrecord in the staff index (the PUI
# indexer already removes ancestors before building fullrecord)
default_excludes = ["ancestors", "persistent_id", "ref", "uri"]

configured = AppConfig[:aspace_search_modifications_excludes] if AppConfig.has_key?(:aspace_search_modifications_excludes)

if configured && !configured.is_a?(Array)
  Log.warn("aspace_search_modifications: AppConfig[:aspace_search_modifications_excludes] must be an Array; using defaults")
  configured = nil
end

AppConfig[:aspace_search_modifications_excludes] = configured || default_excludes

# Prepend rather than redefine so the core exclude list is preserved across ArchivesSpace upgrades
module AspaceSearchModExcludes
  def fullrecord_excludes
    # Called per key during indexing; both lists are fixed after startup, so build once
    @aspace_search_mod_excludes ||= (super + AppConfig[:aspace_search_modifications_excludes]).uniq
  end
end

IndexerCommonConfig.singleton_class.prepend(AspaceSearchModExcludes)
