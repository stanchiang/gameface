CREATE TABLE "block_list" (
user_id TEXT NOT NULL,
synced_at DATETIME,
unblocked_at DATETIME);

CREATE INDEX block_list_user_id_idx ON block_list(user_id);
