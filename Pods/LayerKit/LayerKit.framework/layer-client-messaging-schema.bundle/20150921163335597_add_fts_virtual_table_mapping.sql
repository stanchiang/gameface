-- Creating mapping table for fts

CREATE TABLE fts_trigger_mime_type_mapping (
	database_identifier INTEGER PRIMARY KEY AUTOINCREMENT,
	mime_type TEXT NOT NULL,
	fts_trigger_name TEXT UNIQUE NOT NULL
);