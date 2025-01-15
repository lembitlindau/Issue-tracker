-- Create database
CREATE DATABASE IF NOT EXISTS issue_tracker;
USE issue_tracker;

-- Users table
CREATE TABLE users (
                       id INT AUTO_INCREMENT PRIMARY KEY,
                       email VARCHAR(255) NOT NULL UNIQUE,
                       username VARCHAR(50) NOT NULL UNIQUE,
                       password_hash VARCHAR(255) NOT NULL,
                       full_name VARCHAR(100) NOT NULL,
                       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                       is_active BOOLEAN DEFAULT TRUE,
                       INDEX idx_email (email),
                       INDEX idx_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Projects table
CREATE TABLE projects (
                          id INT AUTO_INCREMENT PRIMARY KEY,
                          name VARCHAR(100) NOT NULL,
                          description TEXT,
                          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                          owner_id INT NOT NULL,
                          INDEX idx_owner (owner_id),
                          FOREIGN KEY (owner_id) REFERENCES users(id)
                              ON DELETE RESTRICT
                              ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- User Stories table
CREATE TABLE user_stories (
                              id INT AUTO_INCREMENT PRIMARY KEY,
                              title VARCHAR(200) NOT NULL,
                              description TEXT,
                              status ENUM('NEW', 'IN_PROGRESS', 'REVIEW', 'DONE') DEFAULT 'NEW',
                              priority ENUM('LOW', 'MEDIUM', 'HIGH', 'URGENT') DEFAULT 'MEDIUM',
                              created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                              updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                              due_date TIMESTAMP NULL,
                              project_id INT NOT NULL,
                              creator_id INT NOT NULL,
                              owner_id INT NOT NULL,
                              INDEX idx_project (project_id),
                              INDEX idx_creator (creator_id),
                              INDEX idx_owner (owner_id),
                              INDEX idx_status (status),
                              INDEX idx_priority (priority),
                              FOREIGN KEY (project_id) REFERENCES projects(id)
                                  ON DELETE CASCADE
                                  ON UPDATE CASCADE,
                              FOREIGN KEY (creator_id) REFERENCES users(id)
                                  ON DELETE RESTRICT
                                  ON UPDATE CASCADE,
                              FOREIGN KEY (owner_id) REFERENCES users(id)
                                  ON DELETE RESTRICT
                                  ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Criteria table
CREATE TABLE criteria (
                          id INT AUTO_INCREMENT PRIMARY KEY,
                          title VARCHAR(200) NOT NULL,
                          description TEXT,
                          is_mandatory BOOLEAN DEFAULT TRUE,
                          story_id INT NOT NULL,
                          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                          INDEX idx_story (story_id),
                          FOREIGN KEY (story_id) REFERENCES user_stories(id)
                              ON DELETE CASCADE
                              ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Comments table
CREATE TABLE comments (
                          id INT AUTO_INCREMENT PRIMARY KEY,
                          content TEXT NOT NULL,
                          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                          user_id INT NOT NULL,
                          story_id INT NOT NULL,
                          INDEX idx_user (user_id),
                          INDEX idx_story (story_id),
                          FOREIGN KEY (user_id) REFERENCES users(id)
                              ON DELETE RESTRICT
                              ON UPDATE CASCADE,
                          FOREIGN KEY (story_id) REFERENCES user_stories(id)
                              ON DELETE CASCADE
                              ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Labels table
CREATE TABLE labels (
                        id INT AUTO_INCREMENT PRIMARY KEY,
                        name VARCHAR(50) NOT NULL,
                        color VARCHAR(7) NOT NULL DEFAULT '#808080',
                        project_id INT NOT NULL,
                        INDEX idx_project (project_id),
                        FOREIGN KEY (project_id) REFERENCES projects(id)
                            ON DELETE CASCADE
                            ON UPDATE CASCADE,
                        UNIQUE KEY unique_label_per_project (name, project_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- User Story Labels (junction table for many-to-many relationship)
CREATE TABLE user_story_labels (
                                   story_id INT NOT NULL,
                                   label_id INT NOT NULL,
                                   PRIMARY KEY (story_id, label_id),
                                   FOREIGN KEY (story_id) REFERENCES user_stories(id)
                                       ON DELETE CASCADE
                                       ON UPDATE CASCADE,
                                   FOREIGN KEY (label_id) REFERENCES labels(id)
                                       ON DELETE CASCADE
                                       ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;