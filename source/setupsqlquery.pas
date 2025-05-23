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
    '`id` INTEGER UNIQUE PRIMARY KEY, `LogTable` TEXT NOT NULL, ' +
    '`Description` TEXT NOT NULL UNIQUE, ' +
    '`CallName` TEXT NOT NULL, `Name` TEXT NOT NULL, ' +
    '`QTH` TEXT NOT NULL, `ITU` INTEGER NOT NULL, ' +
    '`CQ` INTEGER NOT NULL, `Loc` TEXT NOT NULL, ' +
    '`Lat` TEXT NOT NULL, `Lon` TEXT NOT NULL, ' +
    '`QSLInfo` TEXT NOT NULL DEFAULT "TNX For QSO TU 73!", ' +
    '`EQSLLogin` TEXT DEFAULT NULL, ' +
    '`EQSLPassword` TEXT DEFAULT NULL, ' +
    '`AutoEQSLcc` INTEGER DEFAULT NULL, ' +
    '`HamQTHLogin` TEXT DEFAULT NULL, ' +
    '`HamQTHPassword` TEXT DEFAULT NULL, ' +
    '`AutoHamQTH` INTEGER DEFAULT NULL, ' +
    '`HRDLogLogin` TEXT DEFAULT NULL, ' +
    '`HRDLogPassword` TEXT DEFAULT NULL, ' +
    '`AutoHRDLog` INTEGER DEFAULT NULL, ' +
    '`LoTW_User` TEXT, `LoTW_Password` TEXT, ' +
    '`ClubLog_User` TEXT, `ClubLog_Password` TEXT, ' +
    '`AutoClubLog` INTEGER DEFAULT NULL, ' +
    '`QRZCOM_User` TEXT, `QRZCOM_Password` TEXT, `AutoQRZCom` INTEGER DEFAULT NULL, ' +
    '`HAMLogOnline_API` TEXT, `AutoHAMLogOnline` INTEGER DEFAULT NULL, `Table_version` TEXT);';


  Insert_Table_LogBookInfo = 'INSERT INTO LogBookInfo ' +
    '(LogTable,CallName,Name,QTH,ITU,CQ,Loc,Lat,Lon,Description,QSLInfo, Table_version) '
    +
    'VALUES (:LogTable,:CallName,:Name,:QTH,:ITU,:CQ,:Loc,:Lat,:Lon,:Description,:QSLInfo, :Table_version)';

  Table_MacroTable = 'CREATE TABLE IF NOT EXISTS ' +
      '`MacroTable` (`ButtonID` integer UNIQUE PRIMARY KEY NOT NULL,' +
      '`ButtonName` TEXT DEFAULT NULL, `Macro` TEXT DEFAULT NULL)';

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
    ' `CallSign` TEXT DEFAULT NULL, `QSODateTime` datetime DEFAULT NULL,' +
    ' `QSODate` datetime DEFAULT NULL, `QSOTime` TEXT DEFAULT NULL,' +
    ' `QSOBand` TEXT DEFAULT NULL,' +
    ' `FREQ_RX` TEXT DEFAULT NULL,' +
    ' `BAND_RX` TEXT DEFAULT NULL,' +
    ' `QSOMode` TEXT DEFAULT NULL,' +
    ' `QSOSubMode` TEXT DEFAULT NULL,' +
    ' `QSOReportSent` TEXT DEFAULT NULL,' +
    ' `QSOReportRecived` TEXT DEFAULT NULL,' +
    ' `OMName` TEXT DEFAULT NULL, `OMQTH` TEXT DEFAULT NULL,' +
    ' `State` TEXT DEFAULT NULL, `Grid` TEXT DEFAULT NULL,' +
    ' `IOTA` TEXT DEFAULT NULL, `QSLManager` TEXT DEFAULT NULL,' +
    ' `QSLSent` INTEGER DEFAULT NULL, `QSLSentAdv` TEXT DEFAULT NULL,' +
    ' `QSLSentDate` datetime DEFAULT NULL, `QSLRec` INTEGER DEFAULT NULL,' +
    ' `QSLRecDate` datetime DEFAULT NULL, `MainPrefix` TEXT DEFAULT NULL,' +
    ' `DXCCPrefix` TEXT DEFAULT NULL, `CQZone` TEXT DEFAULT NULL,' +
    ' `ITUZone` TEXT DEFAULT NULL, `QSOAddInfo` TEXT,' +
    ' `Marker` INTEGER DEFAULT NULL, `ManualSet` INTEGER DEFAULT NULL,' +
    ' `DigiBand` REAL DEFAULT NULL, `Continent` TEXT DEFAULT NULL,' +
    ' `ShortNote` TEXT DEFAULT NULL,' +
    ' `QSLReceQSLcc` INTEGER DEFAULT NULL,' +
    ' `LoTWRec` INTEGER DEFAULT 0, `LoTWRecDate` datetime DEFAULT NULL,' +
    ' `QSLInfo` TEXT DEFAULT NULL, `Call` TEXT DEFAULT NULL,' +
    ' `State1` TEXT DEFAULT NULL, `State2` TEXT DEFAULT NULL,' +
    ' `State3` TEXT DEFAULT NULL, `State4` TEXT DEFAULT NULL,' +
    ' `WPX` TEXT DEFAULT NULL, `AwardsEx` TEXT,' +
    ' `ValidDX` INTEGER DEFAULT 1, `SRX` INTEGER DEFAULT NULL,' +
    ' `SRX_STRING` TEXT DEFAULT NULL, `STX` INTEGER DEFAULT NULL,' +
    ' `STX_STRING` TEXT DEFAULT NULL,' +
    ' `SAT_NAME` TEXT DEFAULT NULL,' +
    ' `SAT_MODE` TEXT DEFAULT NULL,' +
    ' `PROP_MODE` TEXT DEFAULT NULL, `LoTWSent` INTEGER DEFAULT 0,' +
    ' `QSL_RCVD_VIA` TEXT DEFAULT NULL,' +
    ' `QSL_SENT_VIA` TEXT DEFAULT NULL,' +
    ' `DXCC` TEXT DEFAULT NULL, `USERS` TEXT DEFAULT NULL,' +
    ' `NoCalcDXCC` INTEGER DEFAULT 0, `MY_STATE` TEXT, ' +
    ' `MY_GRIDSQUARE` TEXT, `MY_LAT` TEXT,`MY_LON` TEXT, `SYNC` INTEGER DEFAULT 0,'+
    ' `SOTA_REF` TEXT DEFAULT NULL, `MY_SOTA_REF` TEXT DEFAULT NULL,'+
    ' `ContestSession` TEXT DEFAULT NULL, `ContestName` TEXT DEFAULT NULL,'+
    ' `EQSL_QSL_SENT` TEXT DEFAULT ''N'', `HAMLOGRec` INTEGER DEFAULT 0, '+
    ' `CLUBLOG_QSO_UPLOAD_DATE` datetime DEFAULT NULL, `CLUBLOG_QSO_UPLOAD_STATUS` INTEGER DEFAULT NULL,'+
    ' `HRDLOG_QSO_UPLOAD_DATE` datetime DEFAULT NULL, `HRDLOG_QSO_UPLOAD_STATUS` INTEGER DEFAULT NULL,'+
    ' `QRZCOM_QSO_UPLOAD_DATE` datetime DEFAULT NULL, `QRZCOM_QSO_UPLOAD_STATUS` INTEGER DEFAULT NULL,'+
    ' `HAMLOGONLINE_QSO_UPLOAD_DATE` datetime DEFAULT NULL, `HAMLOGONLINE_QSO_UPLOAD_STATUS` INTEGER DEFAULT NULL,' +
    ' `HAMLOGEU_QSO_UPLOAD_DATE` datetime DEFAULT NULL, `HAMLOGEU_QSO_UPLOAD_STATUS` INTEGER DEFAULT NULL,' +
    ' `HAMQTH_QSO_UPLOAD_DATE` datetime DEFAULT NULL, `HAMQTH_QSO_UPLOAD_STATUS` INTEGER DEFAULT NULL';
    Result := TempResult +
      ', CONSTRAINT `Dupe_index` UNIQUE (`CallSign`, `QSODate`, `QSOTime`, `QSOBand`))';
end;

function TdmSQL.CreateIndex(LOG_PREFIX: string): string;
begin
    Result := 'CREATE INDEX `Call_index' + LOG_PREFIX + '` ON `Log_TABLE_' +
      LOG_PREFIX + '` (`Call`);';
end;

end.
