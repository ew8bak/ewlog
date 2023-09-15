(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit SetupSQLquery;

{$mode objfpc}{$H+}


interface

uses
  Classes, SysUtils;

const
  Table_LogBookInfo = 'CREATE TABLE IF NOT EXISTS `LogBookInfo` ( ' +
    '`id` integer UNIQUE PRIMARY KEY, `LogTable` varchar(100) NOT NULL, ' +
    '`Description` TEXT NOT NULL UNIQUE, ' +
    '`CallName` varchar(15) NOT NULL, `Name` varchar(100) NOT NULL, ' +
    '`QTH` varchar(100) NOT NULL, `ITU` int(11) NOT NULL, ' +
    '`CQ` int(11) NOT NULL, `Loc` varchar(32) NOT NULL, ' +
    '`Lat` varchar(20) NOT NULL, `Lon` varchar(20) NOT NULL, ' +
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
    + '`QRZCOM_User` varchar(20), `QRZCOM_Password` varchar(50), `AutoQRZCom` tinyint(1) DEFAULT NULL, `Table_version` varchar(10));';


  Insert_Table_LogBookInfo = 'INSERT INTO LogBookInfo ' +
    '(LogTable,CallName,Name,QTH,ITU,CQ,Loc,Lat,Lon,Description,QSLInfo, Table_version) '
    +
    'VALUES (:LogTable,:CallName,:Name,:QTH,:ITU,:CQ,:Loc,:Lat,:Lon,:Description,:QSLInfo, :Table_version)';

  Table_MacroTable = 'CREATE TABLE IF NOT EXISTS ' +
      '`MacroTable` (`ButtonID` integer UNIQUE PRIMARY KEY NOT NULL,' +
      '`ButtonName` varchar(20) DEFAULT NULL, `Macro` TEXT DEFAULT NULL)';

type
  TdmSQL = class(TDataModule)
  private

  public
    function Table_Log_Table(LOG_PREFIX: string): string;
    function CreateIndex(LOG_PREFIX: string): string;
  end;

var
  dmSQL: TdmSQL;

implementation

function TdmSQL.Table_Log_Table(LOG_PREFIX: string): string;
var
  TempResult: string;
begin
  Result := '';
  TempResult := 'CREATE TABLE IF NOT EXISTS `Log_TABLE_' + LOG_PREFIX +
    '` ( `UnUsedIndex` integer UNIQUE PRIMARY KEY,' +
    ' `CallSign` varchar(20) DEFAULT NULL, `QSODateTime` datetime DEFAULT NULL,' +
    ' `QSODate` datetime DEFAULT NULL, `QSOTime` varchar(5) DEFAULT NULL,' +
    ' `QSOBand` varchar(20) DEFAULT NULL,' +
    ' `QSOMode` varchar(15) DEFAULT NULL,' +
    ' `QSOSubMode` varchar(15) DEFAULT NULL,' +
    ' `QSOReportSent` varchar(15) DEFAULT NULL,' +
    ' `QSOReportRecived` varchar(15) DEFAULT NULL,' +
    ' `OMName` varchar(30) DEFAULT NULL, `OMQTH` varchar(50) DEFAULT NULL,' +
    ' `State` varchar(25) DEFAULT NULL, `Grid` varchar(8) DEFAULT NULL,' +
    ' `IOTA` varchar(6) DEFAULT NULL, `QSLManager` varchar(9) DEFAULT NULL,' +
    ' `QSLSent` tinyint(1) DEFAULT NULL, `QSLSentAdv` varchar(1) DEFAULT NULL,' +
    ' `QSLSentDate` datetime DEFAULT NULL, `QSLRec` tinyint(1) DEFAULT NULL,' +
    ' `QSLRecDate` datetime DEFAULT NULL, `MainPrefix` varchar(5) DEFAULT NULL,' +
    ' `DXCCPrefix` varchar(5) DEFAULT NULL, `CQZone` varchar(2) DEFAULT NULL,' +
    ' `ITUZone` varchar(2) DEFAULT NULL, `QSOAddInfo` longtext,' +
    ' `Marker` int(11) DEFAULT NULL, `ManualSet` tinyint(1) DEFAULT NULL,' +
    ' `DigiBand` double DEFAULT NULL, `Continent` varchar(2) DEFAULT NULL,' +
    ' `ShortNote` varchar(200) DEFAULT NULL,' +
    ' `QSLReceQSLcc` tinyint(1) DEFAULT NULL,' +
    ' `LoTWRec` tinyint(1) DEFAULT 0, `LoTWRecDate` datetime DEFAULT NULL,' +
    ' `QSLInfo` varchar(200) DEFAULT NULL, `Call` varchar(20) DEFAULT NULL,' +
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
    ' `MY_GRIDSQUARE` varchar(15), `MY_LAT` varchar(15),`MY_LON` varchar(15), `SYNC` tinyint(1) DEFAULT 0,'+
    ' `SOTA_REF` varchar(15) DEFAULT NULL, `MY_SOTA_REF` varchar(15) DEFAULT NULL,'+
    ' `ContestSession` varchar(255) DEFAULT NULL, `ContestName` varchar(255) DEFAULT NULL,'+
    ' `EQSL_QSL_SENT` varchar(2) DEFAULT ''N'', `HAMLOGRec` tinyint(1) DEFAULT 0, '+
    ' `CLUBLOG_QSO_UPLOAD_DATE` datetime DEFAULT NULL, `CLUBLOG_QSO_UPLOAD_STATUS` tinyint(1) DEFAULT NULL,'+
    ' `HRDLOG_QSO_UPLOAD_DATE` datetime DEFAULT NULL, `HRDLOG_QSO_UPLOAD_STATUS` tinyint(1) DEFAULT NULL,'+
    ' `QRZCOM_QSO_UPLOAD_DATE` datetime DEFAULT NULL, `QRZCOM_QSO_UPLOAD_STATUS` tinyint(1) DEFAULT NULL,'+
    ' `HAMLOG_QSO_UPLOAD_DATE` datetime DEFAULT NULL, `HAMLOG_QSO_UPLOAD_STATUS` tinyint(1) DEFAULT NULL,' +
    ' `FREQ_RX` varchar(20) DEFAULT NULL,' +
    ' `BAND_RX` varchar(20) DEFAULT NULL';
    Result := TempResult +
      ', CONSTRAINT `Dupe_index` UNIQUE (`CallSign`, `QSODate`, `QSOTime`, `QSOBand`))';
end;

function TdmSQL.CreateIndex(LOG_PREFIX: string): string;
begin
    Result := 'CREATE INDEX `Call_index' + LOG_PREFIX + '` ON `Log_TABLE_' +
      LOG_PREFIX + '` (`Call`);';
end;

end.
