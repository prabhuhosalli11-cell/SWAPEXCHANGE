-- ===================================================
-- SkillXchange Database Creation Script
-- ===================================================
-- Run this script in MySQL/phpMyAdmin to create the database and tables
-- ===================================================

-- Create database
CREATE DATABASE IF NOT EXISTS skillxchange_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- Use the database
USE skillxchange_db;

-- ===================================================
-- Table: users
-- ===================================================
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    profile_picture VARCHAR(255) NULL,
    bio TEXT NULL,
    location VARCHAR(100) NULL,
    phone VARCHAR(20) NULL,
    rating DECIMAL(3,2) DEFAULT 0.00,
    total_exchanges INT DEFAULT 0,
    account_status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
    email_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_account_status (account_status)
) ENGINE=InnoDB;

-- ===================================================
-- Table: skill_categories
-- ===================================================
CREATE TABLE IF NOT EXISTS skill_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    icon VARCHAR(10) NULL,
    description TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Insert default categories
INSERT INTO skill_categories (category_name, icon, description) VALUES
('Programming', '💻', 'Software development, coding, and programming languages'),
('Design', '🎨', 'Graphic design, UI/UX, and visual arts'),
('Music', '🎵', 'Musical instruments, composition, and production'),
('Languages', '🌍', 'Foreign languages and linguistic skills'),
('Business', '💼', 'Business management, marketing, and entrepreneurship'),
('Photography', '📷', 'Photography, videography, and visual media'),
('Writing', '✍️', 'Content writing, copywriting, and creative writing'),
('Sports', '⚽', 'Physical fitness, sports, and athletics');

-- ===================================================
-- Table: skills
-- ===================================================
CREATE TABLE IF NOT EXISTS skills (
    skill_id INT AUTO_INCREMENT PRIMARY KEY,
    skill_name VARCHAR(100) NOT NULL UNIQUE,
    category_id INT NOT NULL,
    description TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES skill_categories(category_id) ON DELETE CASCADE,
    INDEX idx_skill_name (skill_name),
    INDEX idx_category_id (category_id)
) ENGINE=InnoDB;

-- Insert some default skills
INSERT INTO skills (skill_name, category_id, description) VALUES
('React Development', 1, 'Building web applications with React.js'),
('Python Programming', 1, 'Python programming language and frameworks'),
('JavaScript', 1, 'JavaScript programming language'),
('UI/UX Design', 2, 'User interface and user experience design'),
('Graphic Design', 2, 'Visual design and graphics creation'),
('Guitar Playing', 3, 'Playing acoustic or electric guitar'),
('Piano', 3, 'Playing piano and keyboard'),
('Spanish Language', 4, 'Spanish language speaking and writing'),
('French Language', 4, 'French language speaking and writing'),
('Digital Marketing', 5, 'Online marketing and social media'),
('Business Strategy', 5, 'Strategic business planning'),
('Portrait Photography', 6, 'Portrait and people photography'),
('Video Editing', 6, 'Video editing and post-production'),
('Content Writing', 7, 'Writing articles and blog posts'),
('Yoga', 8, 'Yoga practice and instruction');

-- ===================================================
-- Table: user_skills
-- ===================================================
CREATE TABLE IF NOT EXISTS user_skills (
    user_skill_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    skill_id INT NOT NULL,
    skill_type ENUM('offering', 'seeking') NOT NULL,
    proficiency_level ENUM('beginner', 'intermediate', 'advanced', 'expert') NULL,
    description TEXT NULL,
    years_experience INT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES skills(skill_id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_skill (user_id, skill_id, skill_type),
    INDEX idx_skill_type (skill_type),
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB;

-- ===================================================
-- Table: exchanges
-- ===================================================
CREATE TABLE IF NOT EXISTS exchanges (
    exchange_id INT AUTO_INCREMENT PRIMARY KEY,
    requester_id INT NOT NULL,
    provider_id INT NOT NULL,
    requested_skill_id INT NOT NULL,
    offered_skill_id INT NULL,
    status ENUM('pending', 'accepted', 'rejected', 'in_progress', 'completed', 'cancelled') DEFAULT 'pending',
    message TEXT NULL,
    start_date DATE NULL,
    end_date DATE NULL,
    meeting_preference ENUM('online', 'in_person', 'hybrid') NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    FOREIGN KEY (requester_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (provider_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (requested_skill_id) REFERENCES skills(skill_id) ON DELETE CASCADE,
    FOREIGN KEY (offered_skill_id) REFERENCES skills(skill_id) ON DELETE CASCADE,
    INDEX idx_status (status),
    INDEX idx_requester_status (requester_id, status),
    INDEX idx_provider_status (provider_id, status)
) ENGINE=InnoDB;

-- ===================================================
-- Table: reviews
-- ===================================================
CREATE TABLE IF NOT EXISTS reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    exchange_id INT NOT NULL,
    reviewer_id INT NOT NULL,
    reviewee_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (exchange_id) REFERENCES exchanges(exchange_id) ON DELETE CASCADE,
    FOREIGN KEY (reviewer_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (reviewee_id) REFERENCES users(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_exchange_reviewer (exchange_id, reviewer_id),
    INDEX idx_reviewee_id (reviewee_id)
) ENGINE=InnoDB;

-- ===================================================
-- Table: messages
-- ===================================================
CREATE TABLE IF NOT EXISTS messages (
    message_id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    exchange_id INT NULL,
    message_text TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (exchange_id) REFERENCES exchanges(exchange_id) ON DELETE SET NULL,
    INDEX idx_receiver_read (receiver_id, is_read),
    INDEX idx_sender_receiver (sender_id, receiver_id)
) ENGINE=InnoDB;

-- ===================================================
-- Table: notifications
-- ===================================================
CREATE TABLE IF NOT EXISTS notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    type ENUM('exchange_request', 'exchange_accepted', 'exchange_completed', 'new_message', 'review_received', 'system') NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    related_id INT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_read (user_id, is_read),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB;

-- ===================================================
-- Table: favorites
-- ===================================================
CREATE TABLE IF NOT EXISTS favorites (
    favorite_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    favorited_user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (favorited_user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_favorite (user_id, favorited_user_id)
) ENGINE=InnoDB;

-- ===================================================
-- Table: sessions
-- ===================================================
CREATE TABLE IF NOT EXISTS sessions (
    session_id VARCHAR(255) PRIMARY KEY,
    user_id INT NOT NULL,
    ip_address VARCHAR(45) NULL,
    user_agent VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_expires_at (expires_at),
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB;

-- ===================================================
-- Insert Sample Test User
-- ===================================================
-- Password: password123
INSERT INTO users (full_name, email, password_hash, bio, rating, total_exchanges) VALUES
('John Doe', 'test@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Test user account', 4.5, 10);

-- Get the user ID
SET @test_user_id = LAST_INSERT_ID();

-- Add some skills to test user
INSERT INTO user_skills (user_id, skill_id, skill_type, proficiency_level, description) VALUES
(@test_user_id, 1, 'offering', 'expert', 'Experienced React developer with 5+ years'),
(@test_user_id, 4, 'seeking', NULL, 'Want to learn UI/UX design principles');

-- ===================================================
-- Triggers for automatic rating updates
-- ===================================================
DELIMITER $$

CREATE TRIGGER update_user_rating_after_review
AFTER INSERT ON reviews
FOR EACH ROW
BEGIN
    UPDATE users 
    SET rating = (
        SELECT AVG(rating) 
        FROM reviews 
        WHERE reviewee_id = NEW.reviewee_id
    )
    WHERE user_id = NEW.reviewee_id;
END$$

CREATE TRIGGER update_exchange_count_after_completion
AFTER UPDATE ON exchanges
FOR EACH ROW
BEGIN
    IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
        UPDATE users 
        SET total_exchanges = total_exchanges + 1 
        WHERE user_id = NEW.requester_id OR user_id = NEW.provider_id;
    END IF;
END$$

DELIMITER ;

-- ===================================================
-- Database Creation Complete!
-- ===================================================
