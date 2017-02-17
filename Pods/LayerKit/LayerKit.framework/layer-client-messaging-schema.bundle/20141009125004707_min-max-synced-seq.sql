-- Create or alter tables

ALTER TABLE streams ADD min_synced_seq INTEGER;

ALTER TABLE streams ADD max_synced_seq INTEGER;
