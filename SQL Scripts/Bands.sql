CREATE TABLE IF NOT EXISTS `Bands` (
  `_id` INTEGER PRIMARY KEY AUTOINCREMENT,
  `Band` varchar(15) NOT NULL,
  `StartFreq` varchar(15) NOT NULL,
  `StopFreq` varchar(15) NOT NULL
);

INSERT INTO `Bands` (`Band`, `StartFreq`, `StopFreq`) VALUES
('160M', '1810', '2000'),
('80M', '3500', '3800'),
('40M', '7000', '7200'),
('30M', '10000', '10150'),
('20M', '14000', '14350'),
('17M', '18068', '18318'),
('15M', '21000', '21450'),
('12M', '24890', '24930'),
('10M', '28000', '29700'),
('2M', '144000', '146000'),
('70CM', '430000', '440000'),
('23CM', '1260000', '1300000');