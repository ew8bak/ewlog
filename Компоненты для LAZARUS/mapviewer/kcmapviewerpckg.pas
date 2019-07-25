{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit kcMapViewerPckg; 

interface

uses
  kcMapViewerInstall, LazarusPackageIntf;

implementation

procedure Register; 
begin
  RegisterUnit('kcMapViewerInstall', @kcMapViewerInstall.Register); 
end; 

initialization
  RegisterPackage('kcMapViewerPckg', @Register); 
end.
