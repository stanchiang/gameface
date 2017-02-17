-------------------------------------------------------------------------------
-- Create a table that represent reconciled identity profiles which are bound
-- to messages and conversation participants.
-------------------------------------------------------------------------------
CREATE TABLE "identities" (
  database_identifier INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  object_identifier TEXT NOT NULL,
  user_id TEXT,
  display_name TEXT,
  first_name TEXT,
  last_name TEXT,
  email_address TEXT,
  phone_number TEXT,
  avatar_image_url TEXT,
  public_key TEXT,
  followed BOOLEAN NOT NULL DEFAULT 0,
  should_follow INTEGER NOT NULL DEFAULT 0,
  version INTEGER NOT NULL,
  deleted_at DATETIME,
  UNIQUE(database_identifier)
);

-------------------------------------------------------------------------------
-- Identity Indexes
-------------------------------------------------------------------------------

CREATE INDEX identities_user_id_idx ON identities(user_id);


-------------------------------------------------------------------------------
-- Create a table that stores the synced identity mutation version
-------------------------------------------------------------------------------
CREATE TABLE "mutations_sequence" (
  identity_sequence INTEGER NOT NULL DEFAULT 0
);
