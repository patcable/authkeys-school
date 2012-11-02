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
  `authusers` varchar(32) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `usercerts`
--

CREATE TABLE IF NOT EXISTS `usercerts` (
  `user` varchar(32) NOT NULL,
  `cert` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

