CREATE DATABASE  IF NOT EXISTS `wso2_engineering_reviews_database` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `wso2_engineering_reviews_database`;
-- MySQL dump 10.13  Distrib 5.7.17, for Linux (x86_64)
--
-- Host: 192.168.56.212    Database: wso2_engineering_reviews_database
-- ------------------------------------------------------
-- Server version	5.6.33-0ubuntu0.14.04.1-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Contributors`
--

DROP TABLE IF EXISTS `Contributors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Contributors` (
  `review_id` int(11) NOT NULL,
  `contributor` varchar(50) NOT NULL,
  PRIMARY KEY (`review_id`,`contributor`),
  CONSTRAINT `Contributors_ibfk_1` FOREIGN KEY (`review_id`) REFERENCES `Reviews` (`review_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Contributors`
--

LOCK TABLES `Contributors` WRITE;

UNLOCK TABLES;

--
-- Table structure for table `Reviews`
--

DROP TABLE IF EXISTS `Reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Reviews` (
  `review_id` int(11) NOT NULL AUTO_INCREMENT,
  `team_name` varchar(50) NOT NULL,
  `product_version` varchar(20) NOT NULL,
  `product_name` varchar(100) NOT NULL,
  `component_name` varchar(200) NOT NULL,
  `component_version` varchar(20) DEFAULT NULL,
  `reporter` varchar(50) NOT NULL,
  `review_note` varchar(1000) NOT NULL,
  `reference` varchar(500) DEFAULT NULL,
  `review_date` varchar(50) NOT NULL,
  `review_type` varchar(80) DEFAULT NULL,
  `participants` varchar(300) NOT NULL,
  PRIMARY KEY (`review_id`),
  KEY `component_id` (`component_version`),
  KEY `review_type` (`review_type`),
  CONSTRAINT `Reviews_ibfk_2` FOREIGN KEY (`review_type`) REFERENCES `Types` (`reviewType`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Reviews`
--

LOCK TABLES `Reviews` WRITE;

UNLOCK TABLES;

--
-- Table structure for table `Types`
--

DROP TABLE IF EXISTS `Types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Types` (
  `reviewType` varchar(80) NOT NULL,
  PRIMARY KEY (`reviewType`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Types`
--

LOCK TABLES `Types` WRITE;
/*!40000 ALTER TABLE `Types` DISABLE KEYS */;
INSERT INTO `Types` VALUES ('Architecture / Design Review'),('Code Review'),('User Story Review'),('UX Review');
/*!40000 ALTER TABLE `Types` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-11-21 13:59:50
