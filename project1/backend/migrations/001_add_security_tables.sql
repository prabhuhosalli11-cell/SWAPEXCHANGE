-- ===================================================
-- Production Security Enhancement Migration
-- Add login_attempts table for brute force protection
-- ===================================================

USE skillxchange_db;

-- Table for tracking failed login attempts
CREATE TABLE IF NOT EXISTS login_attempts (
    attempt_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    ip_address VARCHAR(45) NOT NULL,
    attempted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_email_time (email, attempted_at),
    INDEX idx_ip_time (ip_address, attempted_at)
) ENGINE=InnoDB;

-- Add indexes to existing tables for better performance
ALTER TABLE users ADD INDEX idx_email_status (email, account_status);
ALTER TABLE sessions ADD INDEX idx_user_expires (user_id, expires_at);

-- Add IP address and user agent to sessions table if not exists
ALTER TABLE sessions 
ADD COLUMN IF NOT EXISTS last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

-- ===================================================
-- Cleanup procedure for expired sessions
-- ===================================================
DROP PROCEDURE IF EXISTS cleanup_expired_sessions;

DELIMITER $$
CREATE PROCEDURE cleanup_expired_sessions()
BEGIN
    DELETE FROM sessions WHERE expires_at < NOW();
    DELETE FROM login_attempts WHERE attempted_at < DATE_SUB(NOW(), INTERVAL 24 HOUR);
END$$

DELIMITER ;

-- ===================================================
-- Create event for automatic cleanup (if event scheduler is enabled)
-- ===================================================
SET GLOBAL event_scheduler = ON;

DROP EVENT IF EXISTS auto_cleanup_sessions;

CREATE EVENT auto_cleanup_sessions
ON SCHEDULE EVERY 1 HOUR
DO CALL cleanup_expired_sessions();
