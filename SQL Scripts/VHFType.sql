CREATE TABLE IF NOT EXISTS `VHFType` (
  `_id` INTEGER PRIMARY KEY AUTOINCREMENT,
  `Type` varchar(50) NOT NULL
);

INSERT INTO `VHFType` (`Type`) VALUES
('EME'),
('EchoLink'),
('AUR'),
('AUE'),
('BS'),
('ECH'),
('ES'),
('FAI'),
('F2'),
('ION'),
('IRL'),
('MS'),
('RPT'),
('SAT'),
('RS'),
('TEP');
