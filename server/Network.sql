-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: db
-- Generation Time: Jan 19, 2022 at 04:35 AM
-- Server version: 8.0.27
-- PHP Version: 7.4.27

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `Network`
--
CREATE DATABASE IF NOT EXISTS `Network` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `Network`;

DELIMITER $$
--
-- Procedures
--
DROP PROCEDURE IF EXISTS `checkDuplicate`$$
CREATE DEFINER=`root`@`%` PROCEDURE `checkDuplicate` (IN `tableName` VARCHAR(20), IN `fieldName` VARCHAR(20), IN `valueIn` VARCHAR(50), OUT `returnValue` INT)  BEGIN
  SET @s = CONCAT('select count(*) INTO @r from ', `tableName`, ' where ', `fieldName`, ' = ', "'",`valueIn`,"'"); 
  PREPARE stmt1 FROM @s; 
  EXECUTE stmt1; 
  SET `returnValue` = @r;
  DEALLOCATE PREPARE stmt1; 
END$$

DROP PROCEDURE IF EXISTS `createGroup`$$
CREATE DEFINER=`root`@`%` PROCEDURE `createGroup` (IN `groupNameIn` VARCHAR(50), IN `uIDin` VARCHAR(8))  BEGIN

  DECLARE groupID VARCHAR(5);
  DECLARE groupFolderID VARCHAR(10);
  INSERT INTO `groups` (`gname`, `uid`) VALUES (`groupNameIn`, `uIDin`);
  SELECT `gid` INTO `groupID` FROM `userInGroup` WHERE `u_gIndex` = (SELECT MAX(u_gIndex) FROM `userInGroup`);
  SELECT `gFolderID` INTO groupFolderID FROM `groups` WHERE `gid` = groupID;
  SELECT groupID, groupFolderID;
END$$

DROP PROCEDURE IF EXISTS `listFolder`$$
CREATE DEFINER=`root`@`%` PROCEDURE `listFolder` (IN `fIDIn` VARCHAR(10), IN `uIDIn` VARCHAR(8))  BEGIN
  DECLARE permision INT DEFAULT 0;
  DECLARE fileType VARCHAR(5);
  
  SET permision = getPermision(fIDIn, uIDIn);
  SELECT fType INTO fileType FROM files WHERE fid = fIDIn;
  
  IF fileType != 'DIR' AND fileType != 'GDIR' THEN
    SET permision =0;
  END IF;
  
  IF permision > 0 THEN
    SELECT * FROM files WHERE motherFolder = fIDIn;
  END IF;
  
END$$

DROP PROCEDURE IF EXISTS `listGroup`$$
CREATE DEFINER=`root`@`%` PROCEDURE `listGroup` (IN `uIDIn` VARCHAR(8))  BEGIN
  SELECT * FROM `groups` WHERE `uid` = `uIDIn`;
END$$

--
-- Functions
--
DROP FUNCTION IF EXISTS `createFile`$$
CREATE DEFINER=`root`@`%` FUNCTION `createFile` (`fNameIN` VARCHAR(256), `motherFolderIn` VARCHAR(50), `uidIn` VARCHAR(8)) RETURNS VARCHAR(10) CHARSET utf8mb4 BEGIN

DECLARE permision INT DEFAULT 0;
DECLARE fileType VARCHAR(5);
DECLARE fidOut VARCHAR(10);
SET permision = getPermision(`motherFolderIn`, `uIDIn`);

SELECT fType INTO fileType FROM files WHERE fid = motherFolderIn;
IF fileType != 'GDIR' AND fileType != 'DIR' THEN
  SET permision = -1;
END IF;

IF permision > 0 THEN
  INSERT INTO `files` (`fname`, `motherFolder`, `fType`, `uid`) VALUES (`fNameIN`, `motherFolderIn`, 'FILE', `uidIn`);
  SELECT `fid` INTO `fidOut` FROM `files` WHERE `fIndex` = (SELECT MAX(findex) FROM `files`);
END IF;

RETURN `fidOut`;

END$$

DROP FUNCTION IF EXISTS `createFolder`$$
CREATE DEFINER=`root`@`%` FUNCTION `createFolder` (`folderNameIn` VARCHAR(256), `motherFolderIn` VARCHAR(10), `uIDIn` VARCHAR(8), `prepend` VARCHAR(100)) RETURNS VARCHAR(255) CHARSET utf8mb4 BEGIN

DECLARE permision INT DEFAULT 0;
DECLARE fileType VARCHAR(5);
DECLARE fidOut VARCHAR(10);
DECLARE folderPath VARCHAR(255);

SET permision = getPermision(`motherFolderIn`, `uIDIn`);

SELECT fType INTO fileType FROM files WHERE fid = motherFolderIn;
IF fileType != 'GDIR' AND fileType != 'DIR' THEN
  SET permision = -1;
END IF;

IF permision > 0 THEN
  INSERT INTO `files` (`fname`, `motherFolder`, `fType`, `uid`) VALUES (`folderNameIn`, `motherFolderIn`, 'DIR', `uIDIn`);
  SELECT `fid` INTO `fidOut` FROM `files` WHERE `fIndex` = (SELECT MAX(findex) FROM `files`);
  SET `folderPath` = getPath(fidOut, uIDIn, prepend);
END IF;

RETURN `folderPath`;

END$$

DROP FUNCTION IF EXISTS `getGroupFolder`$$
CREATE DEFINER=`root`@`%` FUNCTION `getGroupFolder` (`fIDin` VARCHAR(10)) RETURNS VARCHAR(10) CHARSET utf8mb4 BEGIN
  DECLARE temp VARCHAR(10); 
  DECLARE result VARCHAR(10); 
  
  SELECT motherFolder INTO temp FROM files WHERE `fid` = `fIDin`;
  IF ISNULL(temp) THEN
    SET result = fIDin;
  END IF;
  
  WHILE ISNULL(temp) != 1 DO
    SET result = temp;
    SELECT motherFolder INTO temp FROM files WHERE `fid` = temp;
  END WHILE;

  RETURN result;
END$$

DROP FUNCTION IF EXISTS `getPath`$$
CREATE DEFINER=`root`@`%` FUNCTION `getPath` (`fIDin` VARCHAR(10), `uIDin` VARCHAR(8), `prepend` VARCHAR(100)) RETURNS VARCHAR(200) CHARSET utf8mb4 BEGIN
  DECLARE temp VARCHAR(10); 
  DECLARE filePath VARCHAR(100);
IF getPermision(fIDin, uIDin) > 0 THEN
  SELECT `motherFolder` INTO `temp` FROM `files` WHERE `fid` = `fIDin`;
  IF ISNULL(temp) THEN
    SET filePath = fIDin;
  ELSE 
    SET filePath = fIDin;
  END IF;
  
  WHILE ISNULL(temp) != 1 DO
    SET filePath = CONCAT(temp, '/', filePath);
    SELECT motherFolder INTO temp FROM files WHERE `fid` = temp;
  END WHILE;
  SET filePath = CONCAT(prepend, '/', filePath);
  
ELSE 
  SET filePath = '';
END IF;

RETURN filePath;
END$$

DROP FUNCTION IF EXISTS `getPermision`$$
CREATE DEFINER=`root`@`%` FUNCTION `getPermision` (`fIDin` VARCHAR(10), `uIDin` VARCHAR(8)) RETURNS INT BEGIN
-- This function take a file's ID and a user's ID and return the permision of user to the file
-- 0 means no permision
-- 1 means have regular permision
-- 2 means have admin permision
  DECLARE userID VARCHAR(8);
  DECLARE groupFolderID VARCHAR(10);
  DECLARE groupID VARCHAR(5);
  DECLARE temp INT;
  DECLARE result INT DEFAULT 0;
  
  SET `groupFolderID` = getGroupFolder(fIDin);
  
SELECT gid, uid INTO `groupID`, `userID` FROM `groups` WHERE gFolderID = `groupFolderID`;
  
  SELECT COUNT(*) INTO temp FROM `userInGroup` WHERE (gid = `groupID` AND uid = `uIDin`);
  
  SET result = 0;

  IF (temp > 0) THEN
    SET result = 1;
  END IF;
  IF `userID` = uIDin THEN
    SET result = 2;
  END IF;
  
RETURN result;
END$$

DROP FUNCTION IF EXISTS `signin`$$
CREATE DEFINER=`root`@`%` FUNCTION `signin` (`usernameIn` VARCHAR(50), `passwordIn` VARCHAR(50)) RETURNS VARCHAR(8) CHARSET utf8mb4 BEGIN
-- signin function
-- return -2 if user not exist
-- return -1 if wrong password
-- return 1 if signin successful

DECLARE returnValue VARCHAR(8);
DECLARE ID VARCHAR(8);
DECLARE savePassword VARCHAR(45);DECLARE checkPassword VARCHAR(50);

SELECT `password`, `uid` INTO savePassword, ID FROM `users` WHERE username = `usernameIn` OR  email = `usernameIn`;

IF ISNULL(savePassword) THEN
  SET returnValue = '-2';
ELSE
  SELECT CONCAT(LEFT(savePassword, 5), passwordIn) INTO `checkPassword`;
 SELECT SHA1(checkPassword) INTO `checkPassword`;
 SELECT CONCAT(LEFT(savePassword, 5), checkPassword) INTO `checkPassword`;
 	IF checkPassword = savePassword THEN
      SET returnValue = ID;
    ELSEIF checkPassword != savePassword THEN
      SET returnValue = '-1';
    END IF;
END IF;
RETURN returnValue;

END$$

DROP FUNCTION IF EXISTS `signup`$$
CREATE DEFINER=`root`@`%` FUNCTION `signup` (`firstNameIn` VARCHAR(25), `lastNameIn` VARCHAR(25), `emailIn` VARCHAR(50), `usernameIn` VARCHAR(50), `passwordIn` VARCHAR(50)) RETURNS INT BEGIN
-- Before add a user, create sha1 with salt from password
  DECLARE checkdup INT DEFAULT 0;
  DECLARE temp VARCHAR(100);
  DECLARE salt VARCHAR(5);
  DECLARE savePassword VARCHAR(55);
  
SELECT `email` INTO temp FROM `users` WHERE email = `emailIn`;
IF ISNULL(temp) = 0 THEN
  SET checkdup = -1;
END IF;
SET temp = NULL;
SELECT `username` INTO temp FROM `users` WHERE username = `usernameIn`;
IF ISNULL(temp) = 0 THEN
  SET checkdup = checkdup - 2;
END IF;

IF checkdup = 0 THEN
  SET salt = LEFT(MD5(RAND()), 5);
  
  SELECT CONCAT(salt, passwordIn) INTO `savePassword`;
  SELECT SHA1(savePassword) INTO `savePassword`;
  SELECT CONCAT(salt, savePassword) INTO `savePassword`;

  INSERT INTO `users` (`uid`, `firstName`, `lastName`, `email`, `username`, `password`) VALUES ('', TRIM(firstNameIn), TRIM(lastNameIn), TRIM(emailIn), TRIM(usernameIn), TRIM(savePassword)); 
END IF;
  RETURN `checkdup`;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `files`
--

DROP TABLE IF EXISTS `files`;
CREATE TABLE IF NOT EXISTS `files` (
  `fIndex` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `fid` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `fname` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'File name',
  `motherFolder` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'id of mother folder',
  `fType` enum('DIR','FILE','GDIR') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `uid` varchar(8) NOT NULL,
  PRIMARY KEY (`fid`),
  UNIQUE KEY `fIndex` (`fIndex`),
  UNIQUE KEY `uniqueNameIn1Folder` (`fname`,`motherFolder`,`fType`),
  KEY `File owner` (`uid`),
  KEY `Mother folder` (`motherFolder`)
) ENGINE=InnoDB AUTO_INCREMENT=219 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Triggers `files`
--
DROP TRIGGER IF EXISTS `createFID`;
DELIMITER $$
CREATE TRIGGER `createFID` BEFORE INSERT ON `files` FOR EACH ROW proc_label:BEGIN 
  
  DECLARE ID VARCHAR(10);
  DECLARE count int;
  
  IF NEW.fType = 'GDIR' THEN 
    LEAVE proc_label;
  END IF;
  
  SET ID = LEFT(MD5(RAND()), 10);
  SELECT COUNT(*) INTO count FROM `files` WHERE fid = `ID`;
  
  WHILE count > 0 DO
	SET ID = LEFT(MD5(RAND()), 10);
	SELECT COUNT(*) INTO count FROM `files` WHERE fid = `ID`;
  END WHILE;
  SET NEW.fid = ID; 
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `groups`
--

DROP TABLE IF EXISTS `groups`;
CREATE TABLE IF NOT EXISTS `groups` (
  `gid` varchar(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `gname` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `uid` varchar(8) NOT NULL,
  `gFolderID` varchar(10) NOT NULL,
  PRIMARY KEY (`gid`),
  KEY `Group's creator-admin` (`uid`),
  KEY `Group's folder` (`gFolderID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Triggers `groups`
--
DROP TRIGGER IF EXISTS `addAdmin`;
DELIMITER $$
CREATE TRIGGER `addAdmin` AFTER INSERT ON `groups` FOR EACH ROW BEGIN
-- This trigger add a new row to userInGroup table when a new group being created
INSERT INTO userInGroup (gid, uid)
VALUES
(NEW.gid, NEW.uid);
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `addFolder`;
DELIMITER $$
CREATE TRIGGER `addFolder` BEFORE INSERT ON `groups` FOR EACH ROW BEGIN
  DECLARE ID VARCHAR(10);
  DECLARE count int;
  
  SET ID = LEFT(MD5(RAND()), 10);
  SELECT COUNT(*) INTO count FROM `files` WHERE fid = `ID`;
  
  WHILE count > 0 DO
	SET ID = LEFT(MD5(RAND()), 10);
	SELECT COUNT(*) INTO count FROM `files` WHERE fid = `ID`;
  END WHILE;
  
  INSERT INTO files (fid,fname,uid,fType) VALUES (`ID`,NEW.gname, NEW.uid ,"GDIR");

  SET NEW.gFolderID = `ID`;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `createGID`;
DELIMITER $$
CREATE TRIGGER `createGID` BEFORE INSERT ON `groups` FOR EACH ROW BEGIN 
  DECLARE ID VARCHAR(5);
  DECLARE count int;
  
  SET ID = LEFT(MD5(RAND()), 5);
  SELECT COUNT(*) INTO count FROM `groups` WHERE gid = `ID`;
  
  WHILE count > 0 DO
	SET ID = LEFT(MD5(RAND()), 5);
	SELECT COUNT(*) INTO count FROM `groups` WHERE gid = `ID`;
  END WHILE;
  SET NEW.gid = ID; 
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `userInGroup`
--

DROP TABLE IF EXISTS `userInGroup`;
CREATE TABLE IF NOT EXISTS `userInGroup` (
  `u_gIndex` int NOT NULL AUTO_INCREMENT,
  `gid` varchar(5) NOT NULL COMMENT 'group unique id',
  `uid` varchar(8) NOT NULL COMMENT 'user unique id',
  PRIMARY KEY (`u_gIndex`),
  KEY `userInGroup` (`uid`),
  KEY `groupOfUser` (`gid`)
) ENGINE=InnoDB AUTO_INCREMENT=60 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `uid` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'user unique id',
  `firstName` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'Ten',
  `lastName` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'Ho',
  `fullName` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci GENERATED ALWAYS AS (concat(trim(`firstName`),_utf8mb4' ',trim(`lastName`))) VIRTUAL NOT NULL,
  `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `password` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`uid`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Triggers `users`
--
DROP TRIGGER IF EXISTS `createUID`;
DELIMITER $$
CREATE TRIGGER `createUID` BEFORE INSERT ON `users` FOR EACH ROW BEGIN 
  DECLARE ID VARCHAR(8);
  DECLARE count int;
  
  SET ID = LEFT(MD5(RAND()), 8);
  SELECT COUNT(*) INTO count FROM `users` WHERE uid = `ID`;
  
  WHILE count > 0 DO
	SET ID = LEFT(MD5(RAND()), 8);
	SELECT COUNT(*) INTO count FROM `users` WHERE uid = `ID`;
  END WHILE;
  SET NEW.uid = ID; 
END
$$
DELIMITER ;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `files`
--
ALTER TABLE `files`
  ADD CONSTRAINT `File owner` FOREIGN KEY (`uid`) REFERENCES `users` (`uid`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `Mother folder` FOREIGN KEY (`motherFolder`) REFERENCES `files` (`fid`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `groups`
--
ALTER TABLE `groups`
  ADD CONSTRAINT `Group's creator-admin` FOREIGN KEY (`uid`) REFERENCES `users` (`uid`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `Group's folder` FOREIGN KEY (`gFolderID`) REFERENCES `files` (`fid`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `userInGroup`
--
ALTER TABLE `userInGroup`
  ADD CONSTRAINT `groupOfUser` FOREIGN KEY (`gid`) REFERENCES `groups` (`gid`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `userInGroup` FOREIGN KEY (`uid`) REFERENCES `users` (`uid`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
