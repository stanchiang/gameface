-- Due to new sync notifications, we need to reindex in-memory to alert all updated message index changes.
-- For this reason, it makes more sense to drop the message_index table and add messages.message_index.

DROP TABLE IF EXISTS message_index;

ALTER TABLE messages ADD message_index INT;