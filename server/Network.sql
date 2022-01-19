-- MariaDB dump 10.19  Distrib 10.6.5-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: Network
-- ------------------------------------------------------
-- Server version	8.0.27

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `Network`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `Network` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `Network`;

--
-- Table structure for table `files`
--

DROP TABLE IF EXISTS `files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `files` (
  `fIndex` int unsigned NOT NULL AUTO_INCREMENT,
  `fid` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `fname` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'File name',
  `motherFolder` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'id of mother folder',
  `fType` enum('DIR','FILE','GDIR') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `uid` varchar(8) NOT NULL,
  PRIMARY KEY (`fid`),
  UNIQUE KEY `fIndex` (`fIndex`),
  UNIQUE KEY `uniqueNameIn1Folder` (`fname`,`motherFolder`,`fType`),
  KEY `File owner` (`uid`),
  KEY `Mother folder` (`motherFolder`),
  CONSTRAINT `File owner` FOREIGN KEY (`uid`) REFERENCES `users` (`uid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `Mother folder` FOREIGN KEY (`motherFolder`) REFERENCES `files` (`fid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=219 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `files`
--

LOCK TABLES `files` WRITE;
/*!40000 ALTER TABLE `files` DISABLE KEYS */;
/*!40000 ALTER TABLE `files` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `createFID` BEFORE INSERT ON `files` FOR EACH ROW proc_label:BEGIN 
  
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `groups`
--

DROP TABLE IF EXISTS `groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `groups` (
  `gid` varchar(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `gname` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `uid` varchar(8) NOT NULL,
  `gFolderID` varchar(10) NOT NULL,
  PRIMARY KEY (`gid`),
  KEY `Group's creator-admin` (`uid`),
  KEY `Group's folder` (`gFolderID`),
  CONSTRAINT `Group's creator-admin` FOREIGN KEY (`uid`) REFERENCES `users` (`uid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `Group's folder` FOREIGN KEY (`gFolderID`) REFERENCES `files` (`fid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `groups`
--

LOCK TABLES `groups` WRITE;
/*!40000 ALTER TABLE `groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `groups` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `createGID` BEFORE INSERT ON `groups` FOR EACH ROW BEGIN 
  DECLARE ID VARCHAR(5);
  DECLARE count int;
  
  SET ID = LEFT(MD5(RAND()), 5);
  SELECT COUNT(*) INTO count FROM `groups` WHERE gid = `ID`;
  
  WHILE count > 0 DO
	SET ID = LEFT(MD5(RAND()), 5);
	SELECT COUNT(*) INTO count FROM `groups` WHERE gid = `ID`;
  END WHILE;
  SET NEW.gid = ID; 
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `addFolder` BEFORE INSERT ON `groups` FOR EACH ROW BEGIN
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `addAdmin` AFTER INSERT ON `groups` FOR EACH ROW BEGIN
-- This trigger add a new row to userInGroup table when a new group being created
INSERT INTO userInGroup (gid, uid)
VALUES
(NEW.gid, NEW.uid);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `userInGroup`
--

DROP TABLE IF EXISTS `userInGroup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userInGroup` (
  `u_gIndex` int NOT NULL AUTO_INCREMENT,
  `gid` varchar(5) NOT NULL COMMENT 'group unique id',
  `uid` varchar(8) NOT NULL COMMENT 'user unique id',
  PRIMARY KEY (`u_gIndex`),
  KEY `userInGroup` (`uid`),
  KEY `groupOfUser` (`gid`),
  CONSTRAINT `groupOfUser` FOREIGN KEY (`gid`) REFERENCES `groups` (`gid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `userInGroup` FOREIGN KEY (`uid`) REFERENCES `users` (`uid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=60 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userInGroup`
--

LOCK TABLES `userInGroup` WRITE;
/*!40000 ALTER TABLE `userInGroup` DISABLE KEYS */;
/*!40000 ALTER TABLE `userInGroup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `createUID` BEFORE INSERT ON `users` FOR EACH ROW BEGIN 
  DECLARE ID VARCHAR(8);
  DECLARE count int;
  
  SET ID = LEFT(MD5(RAND()), 8);
  SELECT COUNT(*) INTO count FROM `users` WHERE uid = `ID`;
  
  WHILE count > 0 DO
	SET ID = LEFT(MD5(RAND()), 8);
	SELECT COUNT(*) INTO count FROM `users` WHERE uid = `ID`;
  END WHILE;
  SET NEW.uid = ID; 
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Dumping routines for database 'Network'
--
/*!50003 DROP FUNCTION IF EXISTS `createFile` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `createFile`(`fNameIN` VARCHAR(256), `motherFolderIn` VARCHAR(50), `uidIn` VARCHAR(8)) RETURNS varchar(10) CHARSET utf8mb4
    DETERMINISTIC
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `createFolder` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `createFolder`(`folderNameIn` VARCHAR(256), `motherFolderIn` VARCHAR(10), `uIDIn` VARCHAR(8), `prepend` VARCHAR(100)) RETURNS varchar(255) CHARSET utf8mb4
    DETERMINISTIC
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `getGroupFolder` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `getGroupFolder`(`fIDin` VARCHAR(10)) RETURNS varchar(10) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `getPath` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `getPath`(`fIDin` VARCHAR(10), `uIDin` VARCHAR(8), `prepend` VARCHAR(100)) RETURNS varchar(200) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `getPermision` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `getPermision`(`fIDin` VARCHAR(10), `uIDin` VARCHAR(8)) RETURNS int
    DETERMINISTIC
BEGIN
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `signin` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `signin`(`usernameIn` VARCHAR(50), `passwordIn` VARCHAR(50)) RETURNS varchar(8) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `signup` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `signup`(`firstNameIn` VARCHAR(25), `lastNameIn` VARCHAR(25), `emailIn` VARCHAR(50), `usernameIn` VARCHAR(50), `passwordIn` VARCHAR(50)) RETURNS int
    DETERMINISTIC
BEGIN
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `checkDuplicate` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `checkDuplicate`(IN `tableName` VARCHAR(20), IN `fieldName` VARCHAR(20), IN `valueIn` VARCHAR(50), OUT `returnValue` INT)
BEGIN
  SET @s = CONCAT('select count(*) INTO @r from ', `tableName`, ' where ', `fieldName`, ' = ', "'",`valueIn`,"'"); 
  PREPARE stmt1 FROM @s; 
  EXECUTE stmt1; 
  SET `returnValue` = @r;
  DEALLOCATE PREPARE stmt1; 
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `createGroup` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `createGroup`(IN `groupNameIn` VARCHAR(50), IN `uIDin` VARCHAR(8))
    DETERMINISTIC
BEGIN

  DECLARE groupID VARCHAR(5);
  DECLARE groupFolderID VARCHAR(10);
  INSERT INTO `groups` (`gname`, `uid`) VALUES (`groupNameIn`, `uIDin`);
  SELECT `gid` INTO `groupID` FROM `userInGroup` WHERE `u_gIndex` = (SELECT MAX(u_gIndex) FROM `userInGroup`);
  SELECT `gFolderID` INTO groupFolderID FROM `groups` WHERE `gid` = groupID;
  SELECT groupID, groupFolderID;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `listFolder` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `listFolder`(IN `fIDIn` VARCHAR(10), IN `uIDIn` VARCHAR(8))
BEGIN
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
  
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `listGroup` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `listGroup`(IN `uIDIn` VARCHAR(8))
    DETERMINISTIC
BEGIN
  SELECT * FROM `groups` WHERE `uid` = `uIDIn`;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2022-01-19 13:41:36