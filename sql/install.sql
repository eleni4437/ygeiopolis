CREATE DATABASE  IF NOT EXISTS `ygeiopolis` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;
USE `ygeiopolis`;
-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: ygeiopolis
-- ------------------------------------------------------
-- Server version	5.5.5-10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `active_substance`
--

DROP TABLE IF EXISTS `active_substance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `active_substance` (
  `substance_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(500) NOT NULL,
  PRIMARY KEY (`substance_id`),
  UNIQUE KEY `name_UNIQUE` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=167307 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `allergy`
--

DROP TABLE IF EXISTS `allergy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `allergy` (
  `patient_amka` char(11) NOT NULL,
  `substance_id` int(11) NOT NULL,
  PRIMARY KEY (`patient_amka`,`substance_id`),
  KEY `fk_allergy_substance_idx` (`substance_id`),
  CONSTRAINT `fk_allergy_patient` FOREIGN KEY (`patient_amka`) REFERENCES `patient` (`amka`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_allergy_substance` FOREIGN KEY (`substance_id`) REFERENCES `active_substance` (`substance_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `department`
--

DROP TABLE IF EXISTS `department`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `department` (
  `dept_name` varchar(45) NOT NULL,
  `description` mediumtext NOT NULL,
  `amount_of_rooms` int(11) DEFAULT 0,
  `floor` int(11) NOT NULL,
  `image_url` tinytext DEFAULT NULL,
  `image_descriptor` tinytext DEFAULT NULL,
  `dept_manager` char(11) NOT NULL,
  PRIMARY KEY (`dept_name`),
  UNIQUE KEY `dept_manager_UNIQUE` (`dept_manager`),
  KEY `fk_department_doctor_idx` (`dept_manager`),
  CONSTRAINT `fk_department_doctor` FOREIGN KEY (`dept_manager`) REFERENCES `doctor` (`amka`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `department_doctor`
--

DROP TABLE IF EXISTS `department_doctor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `department_doctor` (
  `doc_amka` char(11) NOT NULL,
  `dept_name` varchar(45) NOT NULL,
  PRIMARY KEY (`doc_amka`,`dept_name`),
  KEY `fk_dept_doc_department_idx` (`dept_name`),
  CONSTRAINT `fk_dept_doc_department` FOREIGN KEY (`dept_name`) REFERENCES `department` (`dept_name`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_dept_doc_doctor` FOREIGN KEY (`doc_amka`) REFERENCES `doctor` (`amka`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `diagnosis`
--

DROP TABLE IF EXISTS `diagnosis`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `diagnosis` (
  `ICD` varchar(10) NOT NULL,
  `description` text NOT NULL,
  PRIMARY KEY (`ICD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `doctor`
--

DROP TABLE IF EXISTS `doctor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `doctor` (
  `amka` char(11) NOT NULL,
  `license_number` varchar(20) NOT NULL,
  `speciality` varchar(50) NOT NULL,
  `supervisor_amka` char(11) DEFAULT NULL,
  `doc_rank` varchar(50) NOT NULL,
  PRIMARY KEY (`amka`),
  UNIQUE KEY `license_number_UNIQUE` (`license_number`),
  KEY `fk_doctor_supervisor_idx` (`supervisor_amka`),
  CONSTRAINT `fk_doctor_staff` FOREIGN KEY (`amka`) REFERENCES `staff` (`amka`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_doctor_supervisor` FOREIGN KEY (`supervisor_amka`) REFERENCES `doctor` (`amka`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_doctor_rank` CHECK (`doc_rank` in ('ΕΙΔΙΚΕΥΟΜΕΝΟΣ','ΕΠΙΜΕΛΗΤΗΣ Β','ΕΠΙΜΕΛΗΤΗΣ Α','ΔΙΕΥΘΥΝΤΗΣ'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `drug`
--

DROP TABLE IF EXISTS `drug`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `drug` (
  `drug_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` text NOT NULL,
  `route_of_administration` text DEFAULT NULL,
  PRIMARY KEY (`drug_id`)
) ENGINE=InnoDB AUTO_INCREMENT=99720 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `drug_substance`
--

DROP TABLE IF EXISTS `drug_substance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `drug_substance` (
  `drug_id` int(11) NOT NULL,
  `substance_id` int(11) NOT NULL,
  PRIMARY KEY (`drug_id`,`substance_id`),
  KEY `fk_ds_drug_idx` (`drug_id`),
  KEY `fk_ds_substance_idx` (`substance_id`),
  CONSTRAINT `fk_ds_drug` FOREIGN KEY (`drug_id`) REFERENCES `drug` (`drug_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_ds_substance` FOREIGN KEY (`substance_id`) REFERENCES `active_substance` (`substance_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `evaluation_doctor`
--

DROP TABLE IF EXISTS `evaluation_doctor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `evaluation_doctor` (
  `patient_amka` char(11) NOT NULL,
  `entry_date` datetime NOT NULL,
  `doctor_amka` char(11) NOT NULL,
  `eval_date` datetime NOT NULL,
  `medical_care` tinyint(4) NOT NULL CHECK (`medical_care` between 1 and 5),
  PRIMARY KEY (`patient_amka`,`entry_date`,`doctor_amka`),
  KEY `fk_eval_doc_doctor` (`doctor_amka`),
  KEY `idx_eval_doc_amka` (`doctor_amka`),
  CONSTRAINT `fk_eval_doc_doctor` FOREIGN KEY (`doctor_amka`) REFERENCES `doctor` (`amka`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_eval_doc_hosp` FOREIGN KEY (`patient_amka`, `entry_date`) REFERENCES `hospitalization` (`patient_amka`, `entry_date`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_medical_care` CHECK (`medical_care` between 1 and 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `evaluation_hospital`
--

DROP TABLE IF EXISTS `evaluation_hospital`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `evaluation_hospital` (
  `patient_amka` char(11) NOT NULL,
  `entry_date` datetime NOT NULL,
  `evaluation_date` datetime NOT NULL,
  `nursing_care` tinyint(4) NOT NULL CHECK (`nursing_care` between 1 and 5),
  `cleanliness` tinyint(4) NOT NULL CHECK (`cleanliness` between 1 and 5),
  `food` tinyint(4) NOT NULL CHECK (`food` between 1 and 5),
  `overall_experience` tinyint(4) NOT NULL CHECK (`overall_experience` between 1 and 5),
  PRIMARY KEY (`patient_amka`,`entry_date`),
  KEY `idx_eval_hosp_patient` (`patient_amka`,`entry_date`),
  CONSTRAINT `fk_eval_hosp_hosp` FOREIGN KEY (`patient_amka`, `entry_date`) REFERENCES `hospitalization` (`patient_amka`, `entry_date`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hospitalization`
--

DROP TABLE IF EXISTS `hospitalization`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hospitalization` (
  `patient_amka` char(11) NOT NULL,
  `entry_date` datetime NOT NULL,
  `exit_date` datetime DEFAULT NULL,
  `cost` decimal(10,2) DEFAULT NULL,
  `dept_name` varchar(45) NOT NULL,
  `room_number` int(11) NOT NULL,
  `entry_diagnosis` varchar(10) NOT NULL,
  `exit_diagnosis` varchar(10) DEFAULT NULL,
  `ken_code` varchar(10) NOT NULL,
  PRIMARY KEY (`patient_amka`,`entry_date`),
  KEY `fk_hosp_room_idx` (`dept_name`,`room_number`),
  KEY `fk_hosp_entry_diagnosis_idx` (`entry_diagnosis`),
  KEY `fk_hosp_exit_diagnosis_idx` (`exit_diagnosis`),
  KEY `fk_hosp_ken_idx` (`ken_code`),
  KEY `idx_hosp_patient` (`patient_amka`),
  CONSTRAINT `fk_hosp_entry_diagnosis` FOREIGN KEY (`entry_diagnosis`) REFERENCES `diagnosis` (`ICD`) ON UPDATE CASCADE,
  CONSTRAINT `fk_hosp_exit_diagnosis` FOREIGN KEY (`exit_diagnosis`) REFERENCES `diagnosis` (`ICD`) ON UPDATE CASCADE,
  CONSTRAINT `fk_hosp_ken` FOREIGN KEY (`ken_code`) REFERENCES `ken` (`ken_code`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `fk_hosp_room` FOREIGN KEY (`dept_name`, `room_number`) REFERENCES `room` (`dept_name`, `room_number`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_hosp_triage` FOREIGN KEY (`patient_amka`) REFERENCES `triage` (`patient_amka`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ken`
--

DROP TABLE IF EXISTS `ken`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ken` (
  `ken_code` varchar(10) NOT NULL,
  `description` text NOT NULL,
  `basic_cost` decimal(10,2) NOT NULL,
  `avrg_duration` int(11) NOT NULL,
  PRIMARY KEY (`ken_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lab_test`
--

DROP TABLE IF EXISTS `lab_test`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lab_test` (
  `patient_amka` char(11) NOT NULL,
  `entry_date` datetime NOT NULL,
  `lab_id` varchar(11) NOT NULL,
  `date` datetime NOT NULL,
  `doctor_amka` char(11) NOT NULL,
  `results` text DEFAULT NULL,
  `cost` decimal(10,2) NOT NULL,
  PRIMARY KEY (`patient_amka`,`entry_date`,`lab_id`,`date`),
  KEY `fk_lab_doc` (`doctor_amka`),
  KEY `fk_lab_hosp` (`patient_amka`,`entry_date`),
  KEY `fk_lab_lab_idx` (`lab_id`),
  CONSTRAINT `fk_lab_doc` FOREIGN KEY (`doctor_amka`) REFERENCES `doctor` (`amka`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `fk_lab_hosp` FOREIGN KEY (`patient_amka`, `entry_date`) REFERENCES `hospitalization` (`patient_amka`, `entry_date`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `fk_lab_lab` FOREIGN KEY (`lab_id`) REFERENCES `lab_tests` (`lab_id`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lab_tests`
--

DROP TABLE IF EXISTS `lab_tests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lab_tests` (
  `lab_id` varchar(11) NOT NULL,
  `description` mediumtext NOT NULL,
  `type` varchar(100) NOT NULL,
  PRIMARY KEY (`lab_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nurse`
--

DROP TABLE IF EXISTS `nurse`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nurse` (
  `amka` char(11) NOT NULL,
  `rank` varchar(50) NOT NULL,
  `dept_name` varchar(45) NOT NULL,
  PRIMARY KEY (`amka`),
  KEY `fk_nurse_department_idx` (`dept_name`),
  CONSTRAINT `fk_nurse_department` FOREIGN KEY (`dept_name`) REFERENCES `department` (`dept_name`) ON UPDATE CASCADE,
  CONSTRAINT `fk_nurse_staff` FOREIGN KEY (`amka`) REFERENCES `staff` (`amka`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_nurse_rank` CHECK (`rank` in ('ΒΟΗΘΟΣ ΝΟΣΗΛΕΥΤΗ','ΝΟΣΗΛΕΥΤΗΣ','ΠΡΟΪΣΤΑΜΕΝΟΣ'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `operating_room`
--

DROP TABLE IF EXISTS `operating_room`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `operating_room` (
  `oproom_id` int(11) NOT NULL,
  `type` varchar(50) NOT NULL,
  PRIMARY KEY (`oproom_id`),
  CONSTRAINT `chk_op_room_type` CHECK (`type` in ('ΧΕΙΡΟΥΡΓΕΙΟ','ΑΙΘΟΥΣΑ ΕΠΕΜΒΑΣΗΣ'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patient`
--

DROP TABLE IF EXISTS `patient`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patient` (
  `amka` char(11) NOT NULL,
  `first_name` varchar(45) NOT NULL,
  `last_name` varchar(45) NOT NULL,
  `patronym` varchar(45) NOT NULL,
  `age` tinyint(4) NOT NULL,
  `sex` varchar(45) NOT NULL,
  `weight` decimal(5,2) NOT NULL,
  `height` smallint(6) NOT NULL,
  `address` varchar(45) NOT NULL,
  `phone_number` varchar(45) NOT NULL,
  `email` varchar(45) NOT NULL,
  `job` varchar(45) NOT NULL,
  `citizenship` varchar(45) NOT NULL,
  `emergency_contact` varchar(45) NOT NULL,
  `insurance` varchar(45) NOT NULL,
  PRIMARY KEY (`amka`),
  UNIQUE KEY `email_UNIQUE` (`email`),
  UNIQUE KEY `phone_number_UNIQUE` (`phone_number`),
  CONSTRAINT `chk_patient_insurance` CHECK (`insurance` in ('Ανασφάλιστος','ΕΟΠΥΥ','ΕΦΚΑ','Ιδιωτική Ασφάλεια')),
  CONSTRAINT `chk_patient_amka` CHECK (`amka` regexp '^[0-9]{11}$'),
  CONSTRAINT `chk_patient_phone` CHECK (`phone_number` regexp '^[+][0-9]{8,15}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `personel`
--

DROP TABLE IF EXISTS `personel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `personel` (
  `amka` char(11) NOT NULL,
  `role` varchar(45) NOT NULL,
  `office` varchar(45) NOT NULL,
  `dept_name` varchar(45) NOT NULL,
  PRIMARY KEY (`amka`),
  KEY `fk_personel_department_idx` (`dept_name`),
  CONSTRAINT `fk_personel_department` FOREIGN KEY (`dept_name`) REFERENCES `department` (`dept_name`) ON UPDATE CASCADE,
  CONSTRAINT `fk_personel_staff` FOREIGN KEY (`amka`) REFERENCES `staff` (`amka`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `chk_role` CHECK (`role` in ('ΓΡΑΜΜΑΤΕΑΣ ΤΜΗΜΑΤΟΣ','ΥΠΕΥΘΥΝΟΣ ΑΡΧΕΙΟΥ','ΔΙΑΧΕΙΡΙΣΤΗΣ ΡΑΝΤΕΒΟΥ','ΥΠΕΥΘΥΝΟΣ ΕΙΣΑΓΩΓΩΝ','ΛΟΓΙΣΤΗΣ','ΥΠΕΥΘΥΝΟΣ ΠΡΟΜΗΘΕΙΩΝ','ΔΙΟΙΚΗΤΙΚΟΣ ΣΥΝΤΟΝΙΣΤΗΣ','ΥΠΕΥΘΥΝΟΣ ΑΣΦΑΛΙΣΕΩΝ'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `prescription`
--

DROP TABLE IF EXISTS `prescription`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `prescription` (
  `doc_amka` char(11) NOT NULL,
  `patient_amka` char(11) NOT NULL,
  `drug_id` int(11) NOT NULL,
  `dosage` varchar(45) NOT NULL,
  `frequency` varchar(45) NOT NULL,
  `starting_date` datetime NOT NULL,
  `ending_date` datetime NOT NULL,
  `hosp_entry_date` datetime NOT NULL,
  PRIMARY KEY (`doc_amka`,`patient_amka`,`starting_date`,`drug_id`),
  KEY `fk_prescription_hosp_idx` (`patient_amka`,`hosp_entry_date`),
  KEY `fk_perscription_drug_idx` (`drug_id`),
  CONSTRAINT `fk_perscription_drug` FOREIGN KEY (`drug_id`) REFERENCES `drug` (`drug_id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `fk_prescription_doctor` FOREIGN KEY (`doc_amka`) REFERENCES `doctor` (`amka`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `fk_prescription_hosp` FOREIGN KEY (`patient_amka`, `hosp_entry_date`) REFERENCES `hospitalization` (`patient_amka`, `entry_date`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `procedure`
--

DROP TABLE IF EXISTS `procedure`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `procedure` (
  `patient_amka` char(11) NOT NULL,
  `entry_date` datetime NOT NULL,
  `procedure_id` varchar(11) NOT NULL,
  `starting_time` datetime NOT NULL,
  `main_surgeon_amka` char(11) NOT NULL,
  `duration` time NOT NULL,
  `cost` decimal(10,2) DEFAULT NULL,
  `oproom_id` int(11) NOT NULL,
  PRIMARY KEY (`patient_amka`,`entry_date`,`procedure_id`,`starting_time`),
  KEY `fk_proc_hosp` (`patient_amka`,`entry_date`),
  KEY `fk_proc_doc` (`main_surgeon_amka`),
  KEY `fk_proc_oproom_idx` (`oproom_id`),
  KEY `fk_proc_proc_idx` (`procedure_id`),
  CONSTRAINT `fk_proc_doc` FOREIGN KEY (`main_surgeon_amka`) REFERENCES `doctor` (`amka`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `fk_proc_hosp` FOREIGN KEY (`patient_amka`, `entry_date`) REFERENCES `hospitalization` (`patient_amka`, `entry_date`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_proc_oproom` FOREIGN KEY (`oproom_id`) REFERENCES `operating_room` (`oproom_id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `fk_proce_proce` FOREIGN KEY (`procedure_id`) REFERENCES `procedures` (`procedure_id`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `procedure_staff`
--

DROP TABLE IF EXISTS `procedure_staff`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `procedure_staff` (
  `amka` char(11) NOT NULL,
  `procedure_id` varchar(11) NOT NULL,
  PRIMARY KEY (`amka`,`procedure_id`),
  KEY `fk_proc_proc_idx` (`procedure_id`),
  CONSTRAINT `fk_proc_proc` FOREIGN KEY (`procedure_id`) REFERENCES `procedure` (`procedure_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_proc_staff_staff` FOREIGN KEY (`amka`) REFERENCES `staff` (`amka`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `procedures`
--

DROP TABLE IF EXISTS `procedures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `procedures` (
  `procedure_id` varchar(11) NOT NULL,
  `description` mediumtext NOT NULL,
  `type` varchar(50) NOT NULL,
  PRIMARY KEY (`procedure_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `room`
--

DROP TABLE IF EXISTS `room`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `room` (
  `dept_name` varchar(45) NOT NULL,
  `room_number` int(11) NOT NULL,
  `room_type` varchar(45) NOT NULL,
  `status` varchar(45) NOT NULL,
  PRIMARY KEY (`dept_name`,`room_number`),
  CONSTRAINT `fk_room_department` FOREIGN KEY (`dept_name`) REFERENCES `department` (`dept_name`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_room_type` CHECK (`room_type` in ('ΠΟΛΥΚΛΙΝΟ','ΔΙΚΛΙΝΟ','ΜΟΝΟΚΛΙΝΟ','ΜΕΘ')),
  CONSTRAINT `chk_room_status` CHECK (`status` in ('ΚΑΤΕΙΛΛΗΜΕΝΟ','ΔΙΑΘΕΣΙΜΟ','ΥΠΟ ΣΥΝΤΗΡΗΣΗ'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `shift`
--

DROP TABLE IF EXISTS `shift`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shift` (
  `dept_name` varchar(45) NOT NULL,
  `date` date NOT NULL,
  `type` varchar(50) NOT NULL COMMENT 'πρωινή (07:00-15:00)\nαπογευματινή (15:00-23:00)\nνυχτερινή (23:00-07:00)',
  `status` varchar(20) NOT NULL DEFAULT 'ΜΗ ΕΓΚΥΡΗ',
  PRIMARY KEY (`dept_name`,`date`,`type`),
  CONSTRAINT `fk_shift_department` FOREIGN KEY (`dept_name`) REFERENCES `department` (`dept_name`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_shift_type` CHECK (`type` in ('ΠΡΩΙΝΗ','ΑΠΟΓΕΥΜΑΤΙΝΗ','ΝΥΧΤΕΡΙΝΗ')),
  CONSTRAINT `chk_status` CHECK (`status` in ('ΜΗ ΕΓΚΥΡΗ','ΕΓΚΥΡΗ'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `shift_staff`
--

DROP TABLE IF EXISTS `shift_staff`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shift_staff` (
  `dept_name` varchar(45) NOT NULL,
  `date` date NOT NULL,
  `type` varchar(50) NOT NULL,
  `staff_amka` char(11) NOT NULL,
  PRIMARY KEY (`dept_name`,`date`,`type`,`staff_amka`),
  KEY `fk_shift_staff_staff_idx` (`staff_amka`),
  CONSTRAINT `fk_shift_staff_shift` FOREIGN KEY (`dept_name`, `date`, `type`) REFERENCES `shift` (`dept_name`, `date`, `type`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_shift_staff_staff` FOREIGN KEY (`staff_amka`) REFERENCES `staff` (`amka`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `staff`
--

DROP TABLE IF EXISTS `staff`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `staff` (
  `amka` char(11) NOT NULL,
  `first_name` varchar(45) NOT NULL,
  `last_name` varchar(45) NOT NULL,
  `age` tinyint(4) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone_number` varchar(15) NOT NULL,
  `hiring_date` date NOT NULL,
  `staff_type` varchar(20) NOT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `image_descriptor` text DEFAULT NULL,
  `status` varchar(45) NOT NULL,
  PRIMARY KEY (`amka`),
  UNIQUE KEY `uq_staff_email` (`email`),
  CONSTRAINT `chk_phone_number` CHECK (`phone_number` regexp '^[+][0-9]{8,15}$'),
  CONSTRAINT `staff_amka` CHECK (`amka` regexp '^[0-9]{11}$'),
  CONSTRAINT `chk_staff_type` CHECK (`staff_type` in ('ΙΑΤΡΟΣ','ΝΟΣΗΛΕΥΤΗΣ','ΔΙΟΙΚΗΤΙΚΟ ΠΡΟΣΩΠΙΚΟ')),
  CONSTRAINT `chk_staff_status` CHECK (`status` in ('ΔΙΑΘΕΣΙΜΟΣ','ΑΠΑΣΧΟΛΗΜΕΝΟΣ'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `triage`
--

DROP TABLE IF EXISTS `triage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `triage` (
  `arrival_time` datetime NOT NULL,
  `patient_amka` char(11) NOT NULL,
  `symptoms` text NOT NULL,
  `urgency_level` tinyint(4) NOT NULL,
  `outcome` varchar(50) DEFAULT NULL,
  `nurse_amka` char(11) NOT NULL,
  `status` varchar(45) NOT NULL DEFAULT 'ΑΝΑΜΟΝΗ',
  PRIMARY KEY (`arrival_time`,`patient_amka`),
  KEY `fk_triage_patient_idx` (`patient_amka`),
  KEY `fk_triage_nurse_idx` (`nurse_amka`),
  CONSTRAINT `fk_triage_nurse` FOREIGN KEY (`nurse_amka`) REFERENCES `nurse` (`amka`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `fk_triage_patient` FOREIGN KEY (`patient_amka`) REFERENCES `patient` (`amka`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `chk_urgency_level` CHECK (`urgency_level` in ('1','2','3','4','5')),
  CONSTRAINT `chk_outcome` CHECK (`outcome` in ('ΝΟΣΗΛΕΙΑ','ΑΠΟΧΩΡΗΣΗ')),
  CONSTRAINT `chk_status` CHECK (`status` in ('ΑΝΑΜΟΝΗ','ΕΞΕΤΑΖΕΤΑΙ','ΟΛΟΚΛΗΡΩΘΗΚΕ'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary view structure for view `triage_queue`
--

DROP TABLE IF EXISTS `triage_queue`;
/*!50001 DROP VIEW IF EXISTS `triage_queue`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `triage_queue` AS SELECT 
 1 AS `patient_amka`,
 1 AS `urgency_level`,
 1 AS `arrival_time`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping events for database 'ygeiopolis'
--
/*!50106 SET @save_time_zone= @@TIME_ZONE */ ;
/*!50106 DROP EVENT IF EXISTS `free_all_staff_timer` */;
DELIMITER ;;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;;
/*!50003 SET character_set_client  = utf8mb4 */ ;;
/*!50003 SET character_set_results = utf8mb4 */ ;;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;;
/*!50003 SET @saved_time_zone      = @@time_zone */ ;;
/*!50003 SET time_zone             = 'SYSTEM' */ ;;
/*!50106 CREATE*/ /*!50117 DEFINER=`ygeiopolis_team`@`%`*/ /*!50106 EVENT `free_all_staff_timer` ON SCHEDULE EVERY 1 MINUTE STARTS '2026-05-13 01:55:29' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
    UPDATE `staff`
    SET `status` = 'ΔΙΑΘΕΣΙΜΟΣ'
    WHERE `status` = 'ΑΠΑΣΧΟΛΗΜΕΝΟΣ'
    
    -- 1. ΔΕΝ είναι σε ΕΝΕΡΓΟ χειρουργείο (Έχει ξεκινήσει ΚΑΙ δεν έχει λήξει)
    AND amka NOT IN (
        SELECT main_surgeon_amka 
        FROM `procedure` 
        WHERE starting_time <= now() AND addtime(starting_time, duration) > now()
    )
    
    -- 2. ΔΕΝ είναι Βοηθητικό Προσωπικό σε ΕΝΕΡΓΟ χειρουργείο
    AND amka NOT IN (
        SELECT ps.amka 
        FROM `procedure_staff` ps
        JOIN `procedure` p ON ps.procedure_id = p.procedure_id
        WHERE p.starting_time <= now() AND addtime(p.starting_time, p.duration) > now()
    )
    
    -- 3. ΔΕΝ περιμένει να βγάλει αποτελέσματα σε Lab Test
    AND amka NOT IN (
        SELECT doctor_amka 
        FROM `lab_test` 
        WHERE results IS NULL
    )
    
    -- 4. ΔΕΝ είναι σε ανοιχτή Διαλογή (Triage)
    AND amka NOT IN (
        SELECT nurse_amka 
        FROM `triage` 
        WHERE status != 'ΟΛΟΚΛΗΡΩΘΗΚΕ'
    );

END */ ;;
/*!50003 SET time_zone             = @saved_time_zone */ ;;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;;
/*!50003 SET character_set_client  = @saved_cs_client */ ;;
/*!50003 SET character_set_results = @saved_cs_results */ ;;
/*!50003 SET collation_connection  = @saved_col_connection */ ;;
DELIMITER ;
/*!50106 SET TIME_ZONE= @save_time_zone */ ;

--
-- Dumping routines for database 'ygeiopolis'
--

--
-- Final view structure for view `triage_queue`
--

/*!50001 DROP VIEW IF EXISTS `triage_queue`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ygeiopolis_team`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `triage_queue` AS select `triage`.`patient_amka` AS `patient_amka`,`triage`.`urgency_level` AS `urgency_level`,`triage`.`arrival_time` AS `arrival_time` from `triage` where `triage`.`status` = 'ΑΝΑΜΟΝΗ' order by `triage`.`urgency_level`,`triage`.`arrival_time` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-20  2:33:59
