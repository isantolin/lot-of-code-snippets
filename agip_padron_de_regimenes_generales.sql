-- phpMyAdmin SQL Dump
-- version 4.6.6deb5
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Oct 30, 2018 at 11:15 PM
-- Server version: 5.7.24-0ubuntu0.18.10.1
-- PHP Version: 7.2.10-0ubuntu1

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
-- Table structure for table `AgipRegistro`
--

CREATE TABLE `AgipRegistro` (
  `CUIT` bigint(255) NOT NULL,
  `RazonSocial` varchar(170) DEFAULT NULL,
  `FechaDePublicacion` date NOT NULL,
  `FechaVigenciaDesde` date NOT NULL,
  `FechaVigenciaHasta` date NOT NULL,
  `TipoConstanciaInscripcion` char(1) NOT NULL,
  `MarcaAltaSujeto` char(1) NOT NULL,
  `MarcaAlicuota` char(1) NOT NULL,
  `AlicuotaPercepcion` float NOT NULL,
  `AlicuotaRetencion` float NOT NULL,
  `NroGrupoPercepcion` int(2) NOT NULL,
  `NroGrupoRetencion` int(2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `AgipRegistro`
--
ALTER TABLE `AgipRegistro`
  ADD PRIMARY KEY (`CUIT`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
