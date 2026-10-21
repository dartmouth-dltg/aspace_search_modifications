# ArchivesSpace Search Modifications

## About

An ArchivesSpace plugin which modifies the `fullrecord` search field(s) to omit
additional fields which would pollute the standard keyword search result set. The 
`fullrecord` field is the field searched against when doing a keyword search in
the staff interface and the PUI.

The default additional fields omitted are
```
persistent_id
ref
uri
```

Consider also omitting the following fields:
```
ead_id
ead_location
```

You may also want to consider removing any `_resolved` data. This will narrow search results
to only data contained within the object itself. Note that this will *not* return results for
agents linked to the object, so if you searched for an agent's name, you would *only* get that
agent record, unless the agent's name was mentioned in a note or other field on the object
itself.

To compensate for the removal of the ability to search for an object's id by keyword,
a new advanced search option is added which allows a staff user to search for a specific
object id.

## Installation

Install as you normally would. Add `aspace_search_modifications` to `AppConfig[:plugins]`
in your configuration.

The plugin does not have any additional dependencies so you do not need to 
run the `initialize-plugin` script.

There is one optional configuration option which allows you to set your own list of fields to
exclude from the fullrecord field. For example, if you wanted to exclude the default fields
provided by the plugin as well as omit the ead_id from the fullrecord for an object:
```
AppConfig[:aspace_search_modifications_excludes] = [
    "ead_id",
    "persistent_id",
    "ref",
    "uri"
]
```

If you add additional excluded fields, consider adding additional advanced search options if your users
may want to search on information found in the excluded fields. See the `search_definitions` file in
this plugin for an example.

Note that `uri` is a Solr `string` field, so the advanced search for it matches the full
value exactly; partial URIs will not match.

A reindex is required to fully benefit from these changes, though this can be a soft reindex.
See the ArchivesSpace [Tech Docs](https://archivesspace.github.io/tech-docs/administration/indexes.html).

## Compatibility

Compatible with ArchivesSpace v3.4.0 - 4.2.1. Support for v3.3.1 and earlier was removed.

## Core Overrides

`IndexerCommonConfig.fullrecord_excludes` is patched via `prepend`, so the core list is
kept and the plugin's excludes are appended. If you patch this method in other plugins,
make sure they also call `super`.

## Credits

Plugin developed by Joshua Shaw [Joshua.D.Shaw@dartmouth.edu], Digital Library Technologies Group
Dartmouth Library, Dartmouth College
