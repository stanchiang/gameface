-------------------------------------------------------------------------------
-- This migration adds support for data import.
--
-- JIRA ticket: APPS-2351
-- Contact: kevin@layer.com for more insight on this issue.
-------------------------------------------------------------------------------

ALTER TABLE streams ADD mutation_seq INTEGER;