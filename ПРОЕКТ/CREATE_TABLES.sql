DROP TABLE IF EXISTS priority_audit;
DROP TABLE IF EXISTS task;
DROP TABLE IF EXISTS task_priority;
DROP TABLE IF EXISTS task_status;
DROP TABLE IF EXISTS list;
DROP TABLE IF EXISTS users_boards;
DROP TABLE IF EXISTS board;
DROP TABLE IF EXISTS task_user;

CREATE TABLE task_user (
id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
name VARCHAR(30) NOT NULL,
login VARCHAR(30) UNIQUE NOT NULL,
password VARCHAR(30) NOT NULL);

CREATE TABLE board (
id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
title VARCHAR(30) NOT NULL,
deadline DATE);

CREATE TABLE users_boards (
id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
board_id INT NOT NULL,
task_user_id INT NOT NULL);

CREATE TABLE task (
id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
author_id INT NOT NULL,
title VARCHAR(30) NOT NULL,
body VARCHAR(30),
responsible_id INT,
priority_id INT,
status_id INT,
list_id INT NOT NULL,
deadline DATE,
date_of_appointment DATE NOT NULL,
date_of_complete DATE);

CREATE TABLE priority_audit (
id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
task_id INT,
old_priority_id INT,
new_priority_id INT,
date_of_change DATE,
task_user_id INT,);

CREATE TABLE task_status (
id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
title  VARCHAR(30) NOT NULL,
status_type INT NOT NULL);

CREATE TABLE task_priority (
id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
priority INT NOT NULL,
title VARCHAR(30) NOT NULL);

CREATE TABLE list (
id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
board_id INT NOT NULL,
title VARCHAR(30) NOT NULL,
deadline DATE);

ALTER TABLE users_boards ADD CONSTRAINT users_boards_task_user_id FOREIGN KEY (task_user_id) REFERENCES task_user(id);
ALTER TABLE users_boards ADD CONSTRAINT users_boards_board_id FOREIGN KEY (board_id) REFERENCES board(id);
ALTER TABLE task ADD CONSTRAINT task_author_id FOREIGN KEY (author_id) REFERENCES task_user(id);
ALTER TABLE task ADD CONSTRAINT task_responsible_id FOREIGN KEY (responsible_id) REFERENCES task_user(id);
ALTER TABLE task ADD CONSTRAINT task_priority_id FOREIGN KEY (priority_id) REFERENCES task_priority(id);
ALTER TABLE task ADD CONSTRAINT task_status_id FOREIGN KEY (status_id) REFERENCES task_status(id);
ALTER TABLE task ADD CONSTRAINT task_list_id FOREIGN KEY (list_id) REFERENCES list(id);
ALTER TABLE priority_audit ADD CONSTRAINT priority_audit_old_priority_id FOREIGN KEY (old_priority_id) REFERENCES task_priority(id);
ALTER TABLE priority_audit ADD CONSTRAINT priority_audit_new_priority_id FOREIGN KEY (new_priority_id) REFERENCES task_priority(id);
ALTER TABLE priority_audit ADD CONSTRAINT priority_audit_task_user_id FOREIGN KEY (task_user_id) REFERENCES task_user(id);
ALTER TABLE priority_audit ADD CONSTRAINT priority_audit_task_id FOREIGN KEY (task_id) REFERENCES task(id);
ALTER TABLE list ADD CONSTRAINT list_board_id FOREIGN KEY (board_id) REFERENCES board(id);
