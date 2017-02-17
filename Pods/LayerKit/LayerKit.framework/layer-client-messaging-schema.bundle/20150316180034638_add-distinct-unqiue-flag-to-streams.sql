-------------------------------------------------------------------------------
-- Adding `is_distinct` flag to streams table
-- Default is 0
-------------------------------------------------------------------------------

ALTER TABLE streams ADD is_distinct INTEGER NOT NULL DEFAULT 0;

-------------------------------------------------------------------------------
-- Adding `is_distinct` flag to conversations table
-- Default is 0
-------------------------------------------------------------------------------

ALTER TABLE conversations ADD is_distinct INTEGER NOT NULL DEFAULT 0;