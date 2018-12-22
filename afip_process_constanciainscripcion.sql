-- phpMyAdmin SQL Dump
-- version 4.6.6deb5
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Oct 10, 2018 at 09:45 PM
-- Server version: 5.7.23-0ubuntu0.18.04.1
-- PHP Version: 7.2.10-0ubuntu0.18.04.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `AFIP`
--

-- --------------------------------------------------------

--
-- Table structure for table `ConstanciasInscripcion`
--

CREATE TABLE `ConstanciasInscripcion` (
  `CUIT` int(11) UNSIGNED NOT NULL,
  `Denominacion` varchar(30) NOT NULL,
  `ImpuestoGanancias` varchar(2) NOT NULL,
  `ImpuestoIVA` varchar(2) NOT NULL,
  `Monotributo` varchar(2) DEFAULT NULL,
  `IntegraSociedades` varchar(1) NOT NULL,
  `Empleador` varchar(1) NOT NULL,
  `ActividadMonotributo` int(2) UNSIGNED DEFAULT NULL,
  `DateAdded` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `ConstanciasInscripcion`
--
ALTER TABLE `ConstanciasInscripcion`
  ADD PRIMARY KEY (`CUIT`),
  ADD UNIQUE KEY `CUIT` (`CUIT`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
