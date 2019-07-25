CREATE TABLE IF NOT EXISTS `LogBookInfo` (
  `_id` INTEGER PRIMARY KEY AUTOINCREMENT,
  `LogTable` varchar(100) NOT NULL,
  `CallName` varchar(15) NOT NULL,
  `Name` varchar(100) NOT NULL,
  `QTH` varchar(100) NOT NULL,
  `ITU` int(11) NOT NULL,
  `CQ` int(11) NOT NULL,
  `Loc` varchar(32) NOT NULL,
  `Lat` varchar(20) NOT NULL,
  `Lon` varchar(20) NOT NULL,
  `Discription` varchar(150) NOT NULL,
  `QSLInfo` varchar(200) NOT NULL DEFAULT 'TNX For QSO TU 73!',
  `EQSLLogin` varchar(200) DEFAULT NULL,
  `EQSLPassword` varchar(200) DEFAULT NULL,
  `AutoEQSLcc` tinyint(1) DEFAULT NULL,
  `HRDLogLogin` varchar(200) DEFAULT NULL,
  `HRDLogPassword` varchar(200) DEFAULT NULL,
  `AutoHRDLog` tinyint(1) DEFAULT NULL
);


