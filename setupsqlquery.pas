unit SetupSQLquery;

{$mode objfpc}{$H+}


interface

uses
  Classes, SysUtils;

const
  Table_LogBookInfo = 'CREATE TABLE IF NOT EXISTS `LogBookInfo` ( ' +
    '`id` integer UNIQUE PRIMARY KEY, `LogTable` varchar(100) NOT NULL, ' +
    '`CallName` varchar(15) NOT NULL, `Name` varchar(100) NOT NULL, ' +
    '`QTH` varchar(100) NOT NULL, `ITU` int(11) NOT NULL, ' +
    '`CQ` int(11) NOT NULL, `Loc` varchar(32) NOT NULL, ' +
    '`Lat` varchar(20) NOT NULL, `Lon` varchar(20) NOT NULL, ' +
    '`Discription` varchar(150) NOT NULL, ' +
    '`QSLInfo` varchar(200) NOT NULL DEFAULT "TNX For QSO TU 73!", ' +
    '`EQSLLogin` varchar(200) DEFAULT NULL, ' +
    '`EQSLPassword` varchar(200) DEFAULT NULL, ' +
    '`AutoEQSLcc` tinyint(1) DEFAULT NULL, ' +
    '`HamQTHLogin` varchar(200) DEFAULT NULL, ' +
    '`HamQTHPassword` varchar(200) DEFAULT NULL, ' +
    '`AutoHamQTH` tinyint(1) DEFAULT NULL, ' +
    '`HRDLogLogin` varchar(200) DEFAULT NULL, ' +
    '`HRDLogPassword` varchar(200) DEFAULT NULL, ' +
    '`AutoHRDLog` tinyint(1) DEFAULT NULL, `LoTW_User` varchar(20), `LoTW_Password` varchar(50), '
    + '`ClubLog_User` varchar(20), `ClubLog_Password` varchar(50), `AutoClubLog` tinyint(1) DEFAULT NULL, '
    + '`QRZCOM_User` varchar(20), `QRZCOM_Password` varchar(50), `AutoQRZCom` tinyint(1) DEFAULT NULL);';

  Insert_Table_LogBookInfo = 'INSERT INTO LogBookInfo ' +
    '(id,LogTable,CallName,Name,QTH,ITU,CQ,Loc,Lat,Lon,Discription,QSLInfo) ' +
    'VALUES (:id,:LogTable,:CallName,:Name,:QTH,:ITU,:CQ,:Loc,:Lat,:Lon,:Discription,:QSLInfo)';

type
  TdmSQL = class(TDataModule)
  private

  public
    function Table_Log_Table(LOG_PREFIX, Database: string): string;
    function CreateIndex(LOG_PREFIX, Database: string): string;
  end;

var
  dmSQL: TdmSQL;

implementation

function TdmSQL.Table_Log_Table(LOG_PREFIX, Database: string): string;
var
  TempResult: string;
begin
  Result := '';
  TempResult:='CREATE TABLE IF NOT EXISTS `Log_TABLE_' + LOG_PREFIX +
    '` ( `UnUsedIndex` integer UNIQUE PRIMARY KEY,' +
    ' `CallSign` varchar(20) DEFAULT NULL, `QSODate` datetime DEFAULT NULL,' +
    ' `QSOTime` varchar(5) DEFAULT NULL, `QSOBand` varchar(20) DEFAULT NULL,' +
    ' `QSOMode` varchar(7) DEFAULT NULL,' +
    ' `QSOSubMode` varchar(15) DEFAULT NULL,' +
    ' `QSOReportSent` varchar(15) DEFAULT NULL,' +
    ' `QSOReportRecived` varchar(15) DEFAULT NULL,' +
    ' `OMName` varchar(30) DEFAULT NULL, `OMQTH` varchar(50) DEFAULT NULL,' +
    ' `State` varchar(25) DEFAULT NULL, `Grid` varchar(6) DEFAULT NULL,' +
    ' `IOTA` varchar(6) DEFAULT NULL, `QSLManager` varchar(9) DEFAULT NULL,' +
    ' `QSLSent` tinyint(1) DEFAULT NULL,' + ' `QSLSentAdv` varchar(1) DEFAULT NULL,' +
    ' `QSLSentDate` datetime DEFAULT NULL, `QSLRec` tinyint(1) DEFAULT NULL,' +
    ' `QSLRecDate` datetime DEFAULT NULL,' +
    ' `MainPrefix` varchar(5) DEFAULT NULL,' +
    ' `DXCCPrefix` varchar(5) DEFAULT NULL, `CQZone` varchar(2) DEFAULT NULL,' +
    ' `ITUZone` varchar(2) DEFAULT NULL, `QSOAddInfo` longtext,' +
    ' `Marker` int(11) DEFAULT NULL, `ManualSet` tinyint(1) DEFAULT NULL,' +
    ' `DigiBand` double DEFAULT NULL, `Continent` varchar(2) DEFAULT NULL,' +
    ' `ShortNote` varchar(200) DEFAULT NULL,' +
    ' `QSLReceQSLcc` tinyint(1) DEFAULT NULL,' +
    ' `LoTWRec` tinyint(1) DEFAULT 0, `LoTWRecDate` datetime DEFAULT NULL,' +
    ' `QSLInfo` varchar(100) DEFAULT NULL, `Call` varchar(20) DEFAULT NULL,' +
    ' `State1` varchar(25) DEFAULT NULL, `State2` varchar(25) DEFAULT NULL,' +
    ' `State3` varchar(25) DEFAULT NULL, `State4` varchar(25) DEFAULT NULL,' +
    ' `WPX` varchar(10) DEFAULT NULL, `AwardsEx` longtext,' +
    ' `ValidDX` tinyint(1) DEFAULT 1, `SRX` int(11) DEFAULT NULL,' +
    ' `SRX_STRING` varchar(15) DEFAULT NULL, `STX` int(11) DEFAULT NULL,' +
    ' `STX_STRING` varchar(15) DEFAULT NULL,' +
    ' `SAT_NAME` varchar(20) DEFAULT NULL,' +
    ' `SAT_MODE` varchar(20) DEFAULT NULL,' +
    ' `PROP_MODE` varchar(20) DEFAULT NULL, `LoTWSent` tinyint(1) DEFAULT 0,' +
    ' `QSL_RCVD_VIA` varchar(1) DEFAULT NULL,' +
    ' `QSL_SENT_VIA` varchar(1) DEFAULT NULL,' +
    ' `DXCC` varchar(5) DEFAULT NULL, `USERS` varchar(5) DEFAULT NULL,' +
    ' `NoCalcDXCC` tinyint(1) DEFAULT 0, `MY_STATE` varchar(15), ' +
    ' `MY_GRIDSQUARE` varchar(15), `MY_LAT` varchar(15),`MY_LON` varchar(15) ';
  if Database = 'MySQL' then
  Result := TempResult + ')';
  if Database = 'SQLite' then
  Result := TempResult + ', CONSTRAINT `Dupe_index` UNIQUE (`CallSign`, `QSODate`, `QSOTime`, `QSOBand`))';
end;

function TdmSQL.CreateIndex(LOG_PREFIX, Database: string): string;
begin
  Result := '';
  if Database = 'MySQL' then
    Result := 'ALTER TABLE `Log_TABLE_'+LOG_PREFIX+'`'+
       'ADD KEY `CallSign` (`CallSign`),'+
       'ADD KEY `QSODate` (`QSODate`,`QSOTime`),'+
       'ADD KEY `DigiBand` (`DigiBand`), ADD KEY `DXCC` (`DXCC`),'+
       'ADD KEY `DXCCPrefix` (`DXCCPrefix`), ADD KEY `IOTA` (`IOTA`),'+
       'ADD KEY `MainPrefix` (`MainPrefix`), ADD KEY `QSOMode` (`QSOMode`),'+
       'ADD KEY `State` (`State`), ADD KEY `State1` (`State1`),'+
       'ADD KEY `State2` (`State2`), ADD KEY `State3` (`State3`),'+
       'ADD KEY `State4` (`State4`), ADD KEY `WPX` (`WPX`),'+
       'MODIFY `UnUsedIndex` integer NOT NULL AUTO_INCREMENT,'+
       'ADD INDEX `Call` (`Call`),'+
       'ADD UNIQUE `Dupe_index` (`CallSign`, `QSODate`, `QSOTime`, `QSOBand`)';

  if Database = 'SQLite' then
    Result := 'CREATE INDEX `Call_index` ON `Log_TABLE_'+LOG_PREFIX+'` (`Call`);';

end;

end.
