-- Deletes accidentally created syncable changes.

DELETE FROM syncable_changes WHERE change_identifier IN (SELECT syncable_changes.change_identifier from syncable_changes LEFT JOIN local_keyed_values ON (syncable_changes.table_name = "local_keyed_values" AND syncable_changes.row_identifier = local_keyed_values.database_identifier) WHERE object_type = "identity")
