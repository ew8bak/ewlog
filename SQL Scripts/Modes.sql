CREATE TABLE IF NOT EXISTS `Modes` (
  `_id` INTEGER PRIMARY KEY AUTOINCREMENT,
  `mode` varchar(15) NOT NULL,
  `report` varchar(5) NOT NULL
);


INSERT INTO `Modes` (`mode`, `report`) VALUES
('SSB', '59'),
('BPSK31', '599'),
('BPSK63', '599'),
('BPSK125', '599'),
('RTTY', '599'),
('SSTV', '599'),
('MFSK16', '599'),
('OLIVIA', '599'),
('FM', '59'),
('WSPR', 'S1'),
('JT65', '-10'),
('ROS', '-10'),
('CW', '599'),
('AM', '59'),
('MFSK8', '599'),
('QPSK63', '599'),
('QPSK125', '599'),
('JT9-1', '-10'),
('JT9-2', '-10'),
('QPSK31', '599');