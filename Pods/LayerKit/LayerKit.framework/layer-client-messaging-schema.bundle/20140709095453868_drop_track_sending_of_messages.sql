-- track_sending_of_messages is redundant to track_message_send_on_update (and lacks NEW.seq null check)

DROP TRIGGER IF EXISTS track_sending_of_messages;
