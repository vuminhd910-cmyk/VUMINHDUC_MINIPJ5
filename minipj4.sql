DROP DATABASE IF EXISTS mini_social_network;
CREATE DATABASE mini_social_network;
USE mini_social_network;

-- bảng users
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- bảng posts
CREATE TABLE posts (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    content TEXT NOT NULL,
    like_count INT DEFAULT 0,
    comment_count INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id)
    REFERENCES users(user_id)
);

-- fulltext search
CREATE FULLTEXT INDEX idx_posts_content
ON posts(content);

-- bảng comments
CREATE TABLE comments (
    comment_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT,
    user_id INT,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (post_id)
    REFERENCES posts(post_id),

    FOREIGN KEY (user_id)
    REFERENCES users(user_id)
);

-- bảng likes
CREATE TABLE likes (
    like_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    post_id INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(user_id, post_id),

    FOREIGN KEY (user_id)
    REFERENCES users(user_id),

    FOREIGN KEY (post_id)
    REFERENCES posts(post_id)
);

-- bảng friends
CREATE TABLE friends (
    friendship_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    friend_id INT,
    status VARCHAR(20) DEFAULT 'pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id)
    REFERENCES users(user_id),

    FOREIGN KEY (friend_id)
    REFERENCES users(user_id)
);

-- bảng log
CREATE TABLE post_logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT,
    post_content TEXT,
    deleted_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- users
INSERT INTO users(username, password, email)
VALUES
('alice', '123456', 'alice@gmail.com'),
('bob', '123456', 'bob@gmail.com'),
('charlie', '123456', 'charlie@gmail.com');

-- posts
INSERT INTO posts(user_id, content)
VALUES
(1, 'Hello from Alice'),
(2, 'Learning MySQL Trigger'),
(3, 'Database project is interesting');

-- likes
INSERT INTO likes(user_id, post_id)
VALUES
(2, 1),
(3, 1),
(1, 2);

-- comments
INSERT INTO comments(post_id, user_id, content)
VALUES
(1, 2, 'Nice post'),
(1, 3, 'Very good'),
(2, 1, 'Keep learning');

-- friends
INSERT INTO friends(user_id, friend_id, status)
VALUES
(1, 2, 'accepted'),
(1, 3, 'pending'); 

CREATE VIEW view_user_info AS
SELECT user_id, username, email, created_at
FROM users; 

DELIMITER //
CREATE PROCEDURE sp_add_user(
    IN p_username VARCHAR(50),
    IN p_password VARCHAR(255),
    IN p_email VARCHAR(100)
)
BEGIN
    IF EXISTS (SELECT 1 FROM users WHERE username = p_username OR email = p_email) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Username hoặc Email đã tồn tại!';
    ELSE
        INSERT INTO users (username, password, email) 
        VALUES (p_username, p_password, p_email);
    END IF;
END //
DELIMITER ; 

DELIMITER //

-- Trigger khi thêm Like
CREATE TRIGGER tg_after_like_insert
AFTER INSERT ON likes
FOR EACH ROW
BEGIN
    UPDATE posts SET like_count = like_count + 1 WHERE post_id = NEW.post_id;
END //

-- Trigger khi xóa Like (Chặn giá trị âm)
CREATE TRIGGER tg_after_like_delete
AFTER DELETE ON likes
FOR EACH ROW
BEGIN
    UPDATE posts 
    SET like_count = GREATEST(0, like_count - 1) 
    WHERE post_id = OLD.post_id;
END //

-- Trigger khi thêm Comment
CREATE TRIGGER tg_after_comment_insert
AFTER INSERT ON comments
FOR EACH ROW
BEGIN
    UPDATE posts SET comment_count = comment_count + 1 WHERE post_id = NEW.post_id;
END //

-- Trigger khi xóa Comment (Chặn giá trị âm)
CREATE TRIGGER tg_after_comment_delete
AFTER DELETE ON comments
FOR EACH ROW
BEGIN
    UPDATE posts 
    SET comment_count = GREATEST(0, comment_count - 1) 
    WHERE post_id = OLD.post_id;
END //

DELIMITER ; 



