-- ===================================================
-- Security Tables Migration
-- Run this script to add production security tables
-- ===================================================

USE skillxchange_db;

-- ===================================================
-- Table: login_attempts
-- Tracks failed login attempts for brute force protection
-- ===================================================
CREATE TABLE IF NOT EXISTS login_attempts (
    attempt_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    ip_address VARCHAR(45) NOT NULL,
    attempt_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    success BOOLEAN DEFAULT FALSE,
    INDEX idx_email_ip (email, ip_address),
    INDEX idx_attempt_time (attempt_time)
) ENGINE=InnoDB;

-- ===================================================
-- Table: rate_limits
-- Tracks API rate limiting per IP
-- ===================================================
CREATE TABLE IF NOT EXISTS rate_limits (
    limit_id INT AUTO_INCREMENT PRIMARY KEY,
    ip_address VARCHAR(45) NOT NULL,
    endpoint VARCHAR(255) NOT NULL,
    request_count INT DEFAULT 1,
    window_start TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_request TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_ip_endpoint (ip_address, endpoint),
    INDEX idx_window_start (window_start)
) ENGINE=InnoDB;

-- ===================================================
-- Table: security_logs
-- Logs security events for audit trail
-- ===================================================
CREATE TABLE IF NOT EXISTS security_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    event_type ENUM('login_success', 'login_fail', 'logout', 'signup', 'rate_limit', 'brute_force', 'suspicious_activity') NOT NULL,
    user_id INT NULL,
    email VARCHAR(255) NULL,
    ip_address VARCHAR(45) NOT NULL,
    user_agent TEXT NULL,
    details TEXT NULL,
    severity ENUM('low', 'medium', 'high', 'critical') DEFAULT 'low',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    INDEX idx_event_type (event_type),
    INDEX idx_created_at (created_at),
    INDEX idx_severity (severity),
    INDEX idx_ip_address (ip_address)
) ENGINE=InnoDB;

-- ===================================================
-- Table: password_resets
-- Handles password reset tokens
-- ===================================================
CREATE TABLE IF NOT EXISTS password_resets (
    reset_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    token VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_token (token),
    INDEX idx_expires_at (expires_at)
) ENGINE=InnoDB;

-- ===================================================
-- Cleanup procedure for expired data
-- ===================================================
DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS cleanup_security_data()
BEGIN
    -- Clean login attempts older than 24 hours
    DELETE FROM login_attempts 
    WHERE attempt_time < DATE_SUB(NOW(), INTERVAL 24 HOUR);
    
    -- Clean rate limits older than 1 hour
    DELETE FROM rate_limits 
    WHERE window_start < DATE_SUB(NOW(), INTERVAL 1 HOUR);
    
    -- Clean expired sessions
    DELETE FROM sessions 
    WHERE expires_at < NOW();
    
    -- Clean expired password reset tokens
    DELETE FROM password_resets 
    WHERE expires_at < NOW();
    
    -- Keep security logs for 90 days
    DELETE FROM security_logs 
    WHERE created_at < DATE_SUB(NOW(), INTERVAL 90 DAY);
END$$

DELIMITER ;

-- ===================================================
-- Migration Complete!
-- ===================================================
SELECT 'Security tables created successfully!' AS status;
