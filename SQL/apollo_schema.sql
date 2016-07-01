CREATE SCHEMA IF NOT EXISTS `apollo` DEFAULT CHARACTER SET latin1 ;
USE `apollo` ;

-- -----------------------------------------------------
-- Admin Permissions
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `admins` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) NOT NULL,
  `rank` varchar(32) NOT NULL DEFAULT 'Administrator',
  `level` int(2) NOT NULL DEFAULT '0',
  `flags` int(16) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 ;

-- -----------------------------------------------------
-- Bans
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ban` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `bantime` datetime NOT NULL,
  `serverip` varchar(32) NOT NULL,
  `bantype` varchar(32) NOT NULL,
  `reason` text NOT NULL,
  `job` varchar(32) DEFAULT NULL,
  `duration` int(11) NOT NULL,
  `rounds` int(11) DEFAULT NULL,
  `expiration_time` datetime NOT NULL,
  `ckey` varchar(32) NOT NULL,
  `computerid` varchar(32) NOT NULL,
  `ip` varchar(32) NOT NULL,
  `a_ckey` varchar(32) NOT NULL,
  `a_computerid` varchar(32) NOT NULL,
  `a_ip` varchar(32) NOT NULL,
  `who` text NOT NULL,
  `adminwho` text NOT NULL,
  `edits` text,
  `unbanned` tinyint(1) DEFAULT NULL,
  `unbanned_datetime` datetime DEFAULT NULL,
  `unbanned_ckey` varchar(32) DEFAULT NULL,
  `unbanned_computerid` varchar(32) DEFAULT NULL,
  `unbanned_ip` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 ;

-- -----------------------------------------------------
-- Player Notes
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `player_notes` (
  `id` int(32) NOT NULL AUTO_INCREMENT,
  `player_ckey` varchar(32) NOT NULL,
  `player_ip` varchar(18) NOT NULL,
  `player_cid` varchar(32) NOT NULL,
  `author_ckey` varchar(32) NOT NULL,
  `author_ip` varchar(18) NOT NULL,
  `author_cid` varchar(32) NOT NULL,
  `author_rank` varchar(32) NOT NULL,
  `date_time` datetime NOT NULL,
  `info` TEXT NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 ;

-- -----------------------------------------------------
-- Error logging
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `feedback` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `time` datetime NOT NULL,
  `round_id` int(8) NOT NULL,
  `var_name` varchar(32) NOT NULL,
  `var_value` int(16) DEFAULT NULL,
  `details` text,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 ;

-- -----------------------------------------------------
-- Admin Logs
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `admin_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `adminckey` varchar(32) NOT NULL,
  `adminip` varchar(18) NOT NULL,
  `log` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 ;

-- -----------------------------------------------------
-- Unique Players
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `player` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) NOT NULL,
  `firstseen` datetime NOT NULL,
  `lastseen` datetime NOT NULL,
  `ip` varchar(18) NOT NULL,
  `computerid` varchar(32) NOT NULL,
  `lastadminrank` varchar(32) NOT NULL DEFAULT 'Player',
  `whitelist_flags` int(16) NOT NULL DEFAULT '0',
  `species_flags` int(16) NOT NULL DEFAULT '0',
  `donator_flags` int(16) NOT NULL DEFAULT '0',
  `playtime` int UNSIGNED NOT NULL DEFAULT '0',
  `character_tokens` text,
  `antag_weights` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ckey` (`ckey`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 ;

-- -----------------------------------------------------
-- Player Preferences
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `preferences` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) NOT NULL,
  `joined_date` date NOT NULL,
  `OOC_color` varchar(7) NOT NULL DEFAULT "#0033CC",
  `UI_style` varchar(50) NOT NULL DEFAULT "Midnight",
  `UI_style_color` varchar(7) NOT NULL DEFAULT "#FFFFFF",
  `UI_style_alpha` tinyint UNSIGNED NOT NULL DEFAULT '255',
  `toggles` int UNSIGNED NOT NULL DEFAULT '0',
  `last_character` bigint,
  `alternate_spawn_option` int UNSIGNED DEFAULT '2', -- What happens to them if they can't be spawned in as their selected role
  `job_antag` int UNSIGNED NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ckey` (`ckey`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 ;

-- -----------------------------------------------------
-- Account Items
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `acc_items` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `ckey` TEXT NOT NULL ,
  `item` TEXT NOT NULL ,
  `time` DATETIME NOT NULL ,
  `donator` BIT NOT NULL ,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 ;

-- -----------------------------------------------------
-- Corporate Accounts
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `accounts` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) NOT NULL,
  `domain_name` varchar(100) NOT NULL DEFAULT "apollo.nt", -- The domain that this account belongs to
  `username` varchar(100) NOT NULL DEFAULT "username", -- The username to log into this character's account, is also for their email acc
  `password` varchar(100) NOT NULL DEFAULT "password", -- The password to log into this character's account
  `pin` varchar(4) NOT NULL DEFAULT "0000",
  `security_level` tinyint NOT NULL DEFAULT '1', -- What kind of authorization is needed to log into this acc?
  `clearence_level` varchar(100) NOT NULL DEFAULT "None",
  `record_access` int UNSIGNED NOT NULL DEFAULT '0',
  `datetime_login` datetime NOT NULL, -- When the account was last logged in
  `datetime_created` datetime NOT NULL, -- When the account was created
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 ;

-- -----------------------------------------------------
-- Character Records
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `character_records` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `acc_id` bigint NOT NULL, -- ID of the assocaited account
  `name` varchar(100) NOT NULL, -- The username to log into this character's account
  `gender` varchar(11) NOT NULL,
  `birth_date` varchar(100) NOT NULL,
  `spawnpoint` varchar(100) NOT NULL DEFAULT "Arrivals Shuttle",
  `species` varchar(100) NOT NULL DEFAULT "Human",
  `additional_language` varchar(100),
  `home_system` varchar(100) NOT NULL DEFAULT "Unset",
  `citizenship` varchar(100) NOT NULL DEFAULT "None",
  `faction` varchar(100) NOT NULL DEFAULT "None",
  `religion` varchar(100) NOT NULL DEFAULT "None",
  `department` tinyint NOT NULL DEFAULT '0',
  `last_job` varchar(100) NOT NULL DEFAULT "Unassigned",
  `last_role` varchar(100) NOT NULL DEFAULT "Unassigned",
  `roles` text,
  `player_alt_titles` text,
  `med_record` text,
  `sec_record` text,
  `gen_record` text,
  `exploit_record` text,
  `nanotrasen_relation` varchar(100) NOT NULL DEFAULT "Neutral",
  `DNA` varchar(32) NOT NULL,
  `fingerprints` varchar(32) NOT NULL,
  `blood_type` varchar(10) NOT NULL,
  `employment_status` varchar(100) NOT NULL DEFAULT "Active",
  `felon` tinyint UNSIGNED NOT NULL DEFAULT '0', 
  `prison_date` text,
  `antag_data` text,
  `uplink_location` varchar(100) NOT NULL DEFAULT "PDA",
  `first_shift_day` bigint UNSIGNED NOT NULL DEFAULT '0',
  `last_shift_day` bigint UNSIGNED NOT NULL DEFAULT '0',
  FOREIGN KEY (`acc_id`) REFERENCES accounts(`id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 ;

-- -----------------------------------------------------
-- Library Books
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `library` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `author` TEXT NOT NULL ,
  `title` TEXT NOT NULL ,
  `content` MEDIUMTEXT NOT NULL ,
  `category` TEXT NOT NULL ,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 ;

-- -----------------------------------------------------
-- Paperwork Records
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paperwork_records` (
  `id` int(32) NOT NULL AUTO_INCREMENT,
  `author_ckey` varchar(32) NOT NULL,
  `author_name` varchar(32) NOT NULL,
  `author_ip` varchar(18) NOT NULL,
  `author_id` bigint NOT NULL,
  `recipient_id` bigint NOT NULL, -- ID of the account that this record belongs to
  `clearence` varchar(32) NOT NULL DEFAULT  "Unclassified",
  `category` varchar(255) NOT NULL DEFAULT "Uncategorized",
  `date_time` datetime NOT NULL,
  `title` varchar(50),
  `info` MEDIUMTEXT NOT NULL,
  FOREIGN KEY (`author_id`) REFERENCES accounts(`id`),
  FOREIGN KEY (`recipient_id`) REFERENCES accounts(`id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 ;

-- -----------------------------------------------------
-- Universe Data
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `universe` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`name` varchar(255) NOT NULL,
	`ic_date` varchar(20) NOT NULL,
	PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 ;

-- -----------------------------------------------------
-- Player Characters
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `characters` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `acc_id` bigint NOT NULL,
  `ckey` varchar(32) NOT NULL,
  `name` varchar(100) NOT NULL,
  `gender` varchar(11) NOT NULL,
  `birth_date` varchar(100) NOT NULL,
  `underwear` tinyint UNSIGNED NOT NULL DEFAULT '1',
  `undershirt` tinyint UNSIGNED NOT NULL DEFAULT '1',
  `backpack` tinyint UNSIGNED NOT NULL DEFAULT '2', -- Different
  `hair_style` varchar(50) NOT NULL DEFAULT "Bald",
  `hair_face_style` varchar(50) NOT NULL DEFAULT "Shaved",
  `hair_color` varchar(7) NOT NULL DEFAULT "#FFFFFF",
  `hair_face_color` varchar(7) NOT NULL DEFAULT "#FFFFFF",
  `skin_tone` smallint NOT NULL DEFAULT '35',
  `skin_color` varchar(7) NOT NULL DEFAULT "#FFFFFF",
  `eye_color` varchar(7) NOT NULL DEFAULT "#FFFFFF",
  `species` varchar(100) NOT NULL DEFAULT "Human",
  `additional_language` varchar(100),
  `gear` text,
  `organ_data` text,
  `flavor_texts_human` text,
  `flavor_texts_robot` text, -- Different
  `disabilities` int UNSIGNED NOT NULL DEFAULT '0',
  `DNA` varchar(32) NOT NULL,
  `fingerprints` varchar(32) NOT NULL,
  `blood_type` varchar(10) NOT NULL,
  FOREIGN KEY (`acc_id`) REFERENCES accounts(`id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 ;

-- -----------------------------------------------------
-- Poll Options
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `poll_option` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pollid` int(11) NOT NULL,
  `text` varchar(255) NOT NULL,
  `percentagecalc` tinyint(1) NOT NULL DEFAULT '1',
  `minval` int(3) DEFAULT NULL,
  `maxval` int(3) DEFAULT NULL,
  `descmin` varchar(32) DEFAULT NULL,
  `descmid` varchar(32) DEFAULT NULL,
  `descmax` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 ;

-- -----------------------------------------------------
-- Poll Question
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `poll_question` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `polltype` varchar(16) NOT NULL DEFAULT 'OPTION',
  `starttime` datetime NOT NULL,
  `endtime` datetime NOT NULL,
  `question` varchar(255) NOT NULL,
  `adminonly` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 ;

-- -----------------------------------------------------
-- Poll Replies Text
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `poll_textreply` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `pollid` int(11) NOT NULL,
  `ckey` varchar(32) NOT NULL,
  `ip` varchar(18) NOT NULL,
  `replytext` text NOT NULL,
  `adminrank` varchar(32) NOT NULL DEFAULT 'Player',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 ;

-- -----------------------------------------------------
-- Poll Replies Vote
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `poll_vote` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `pollid` int(11) NOT NULL,
  `optionid` int(11) NOT NULL,
  `ckey` varchar(255) NOT NULL,
  `ip` varchar(16) NOT NULL,
  `adminrank` varchar(32) NOT NULL,
  `rating` int(2) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 ;

-- -----------------------------------------------------
-- End Round Stats
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `round_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `game_mode` varchar(50) NOT NULL,
  `end_time` datetime NOT NULL,
  `duration` int(11) NOT NULL,

  -- End round stats shown in game
  `productivity` int(11) NOT NULL,
  `deaths` int(11) NOT NULL,
  `clones` int(11) NOT NULL,
  `dispense_volume` int(11) NOT NULL,
  `bombs_exploded` int(11) NOT NULL,
  `vended` int(11) NOT NULL,
  `run_distance` int(11) NOT NULL,
  `blood_mopped` int(11) NOT NULL,
  `damage_cost` int(11) NOT NULL,
  `break_time` int(11) NOT NULL,
  `monkey_deaths` int(11) NOT NULL,
  `spam_blocked` int(11) NOT NULL,
  `people_slipped` int(11) NOT NULL,
  `doors_opened` int(11) NOT NULL,
  `guns_fired` int(11) NOT NULL,
  `beepsky_beatings` int(11) NOT NULL,
  `doors_welded` int(11) NOT NULL,
  `total_kwh` int(11) NOT NULL,
  `artifacts` int(11) NOT NULL,
  `cargo_profit` int(11) NOT NULL,
  `trash_vented` int(11) NOT NULL,
  `ai_follow` int(11) NOT NULL,
  `banned` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 ;

CREATE TABLE IF NOT EXISTS `round_antags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `round_id` int(11) NOT NULL,
  `ckey` TEXT NOT NULL,
  `name` TEXT NOT NULL,
  `job` TEXT NOT NULL,
  `role` TEXT NOT NULL,
  `success` BOOL NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 ;

CREATE TABLE IF NOT EXISTS `round_ai_laws` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `round_id` int(11) NOT NULL,
  `law` TEXT NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 ;

-- -----------------------------------------------------
-- Population Tracking
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `population` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `playercount` INT(11) NULL DEFAULT NULL ,
  `admincount` INT(11) NULL DEFAULT NULL ,
  `time` DATETIME NOT NULL ,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 ;

-- -----------------------------------------------------
-- Death Tracking
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `deaths` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `round_id` INT(11) NOT NULL,
  `pod` TEXT NOT NULL COMMENT 'Place of death' ,
  `coord` TEXT NOT NULL COMMENT 'X, Y, Z POD' ,
  `tod` DATETIME NOT NULL COMMENT 'Time of death' ,
  `job` TEXT NOT NULL ,
  `special` TEXT NOT NULL ,
  `name` TEXT NOT NULL ,
  `byondkey` TEXT NOT NULL ,
  `laname` TEXT NOT NULL COMMENT 'Last attacker name' ,
  `lakey` TEXT NOT NULL COMMENT 'Last attacker key' ,
  `gender` TEXT NOT NULL ,
  `bruteloss` INT(11) NOT NULL ,
  `brainloss` INT(11) NOT NULL ,
  `fireloss` INT(11) NOT NULL ,
  `oxyloss` INT(11) NOT NULL ,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 ;
