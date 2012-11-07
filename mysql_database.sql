--
-- Database: `authkeys`
--

-- --------------------------------------------------------

--
-- Table structure for table `authkeys_hashes`
--

CREATE TABLE IF NOT EXISTS `authkeys_hashes` (
  `user` varchar(32) NOT NULL,
  `md5` varchar(32) NOT NULL,
  `sha1` varchar(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `authusers`
--

CREATE TABLE IF NOT EXISTS `authusers` (
  `username` varchar(32) NOT NULL,
  `authusers` varchar(32) NOT NULL,
  KEY `authusers` (`authusers`),
  KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `usercerts`
--

CREATE TABLE IF NOT EXISTS `usercerts` (
  `user` varchar(32) NOT NULL,
  `cert` text NOT NULL,
  UNIQUE KEY `user_1` (`user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `authusers`
--
ALTER TABLE `authusers`
  ADD CONSTRAINT `authusers_ibfk_1` FOREIGN KEY (`authusers`) REFERENCES `usercerts` (`user`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `authusers_ibfk_2` FOREIGN KEY (`username`) REFERENCES `usercerts` (`user`) ON DELETE CASCADE ON UPDATE CASCADE;

