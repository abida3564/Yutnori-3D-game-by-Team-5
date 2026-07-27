-- Yutnori social multiplayer schema (InfinityFree MySQL / MariaDB)
-- Run once in phpMyAdmin on database: if0_42509113_game_loop

CREATE TABLE IF NOT EXISTS players (
  id CHAR(36) NOT NULL PRIMARY KEY,
  friend_code VARCHAR(12) NOT NULL,
  name VARCHAR(20) NOT NULL,
  token_hash CHAR(64) NOT NULL,
  wins INT NOT NULL DEFAULT 0,
  games INT NOT NULL DEFAULT 0,
  presence VARCHAR(20) NOT NULL DEFAULT 'offline',
  presence_at BIGINT NULL,
  current_room VARCHAR(8) NULL,
  created_at BIGINT NOT NULL,
  UNIQUE KEY uniq_friend_code (friend_code),
  KEY idx_token_hash (token_hash)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS friendships (
  id CHAR(36) NOT NULL PRIMARY KEY,
  player_a CHAR(36) NOT NULL,
  player_b CHAR(36) NOT NULL,
  status ENUM('pending','accepted') NOT NULL DEFAULT 'pending',
  created_at BIGINT NOT NULL,
  UNIQUE KEY uniq_friend_pair (player_a, player_b),
  KEY idx_player_a (player_a),
  KEY idx_player_b (player_b)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS rooms (
  code VARCHAR(8) NOT NULL PRIMARY KEY,
  host_id CHAR(36) NOT NULL,
  max_players TINYINT NOT NULL,
  status ENUM('waiting','playing','closed') NOT NULL DEFAULT 'waiting',
  invite_active TINYINT(1) NOT NULL DEFAULT 1,
  rematch_open TINYINT(1) NOT NULL DEFAULT 0,
  match_recorded TINYINT(1) NOT NULL DEFAULT 0,
  state_json LONGTEXT NULL,
  created_at BIGINT NOT NULL,
  updated_at BIGINT NOT NULL,
  KEY idx_host (host_id),
  KEY idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS room_seats (
  room_code VARCHAR(8) NOT NULL,
  seat_index TINYINT NOT NULL,
  player_id CHAR(36) NULL,
  rematch VARCHAR(20) NULL,
  PRIMARY KEY (room_code, seat_index),
  KEY idx_seat_player (player_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS matches (
  id VARCHAR(64) NOT NULL PRIMARY KEY,
  room_code VARCHAR(8) NOT NULL,
  winner_id CHAR(36) NULL,
  player_ids_json LONGTEXT NULL,
  finished_at BIGINT NOT NULL,
  KEY idx_room (room_code),
  KEY idx_winner (winner_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
