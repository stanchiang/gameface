-- Add type to streams, conversations, and messages table to support announcements, with options Conversation or Announcement.

ALTER TABLE streams ADD COLUMN type INTEGER NOT NULL DEFAULT 1;

ALTER TABLE conversations ADD COLUMN type INTEGER NOT NULL DEFAULT 1;

ALTER TABLE messages ADD COLUMN type INTEGER NOT NULL DEFAULT 1;

CREATE INDEX streams_type_idx ON streams(type);

CREATE INDEX conversations_type_idx ON conversations(type);

CREATE INDEX messages_type_idx ON messages(type);
