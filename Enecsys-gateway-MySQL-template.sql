-- phpMyAdmin SQL Dump
-- version 4.0.10deb1
-- http://www.phpmyadmin.net
--
-- Machine: localhost
-- Genereertijd: 09 okt 2015 om 21:05
-- Serverversie: 5.5.41-0ubuntu0.14.04.1
-- PHP-versie: 5.5.9-1ubuntu4.6

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Databank: `enecsys`
--
CREATE DATABASE IF NOT EXISTS `enecsys` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `enecsys`;

-- --------------------------------------------------------

--
-- Tabelstructuur voor tabel `inverters`
--

CREATE TABLE IF NOT EXISTS `inverters` (
  `inverter_id` int(10) NOT NULL,
  `user_id` int(5) NOT NULL,
  `pvo_system_id` int(11) NOT NULL,
  PRIMARY KEY (`inverter_id`),
  KEY `pvo_system_id` (`pvo_system_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabelstructuur voor tabel `logging`
--

CREATE TABLE IF NOT EXISTS `logging` (
  `log_id` int(5) NOT NULL AUTO_INCREMENT,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `inverter_id` int(11) NOT NULL,
  `payload` text NOT NULL,
  PRIMARY KEY (`log_id`),
  KEY `inverter_id` (`inverter_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=8883 ;

-- --------------------------------------------------------

--
-- Tabelstructuur voor tabel `users`
--

CREATE TABLE IF NOT EXISTS `users` (
  `user_id` int(5) NOT NULL AUTO_INCREMENT,
  `apikey` text NOT NULL,
  `ajax_url` text NOT NULL,
  `last_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=2 ;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
