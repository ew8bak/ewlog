(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit flDigiModem;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

const
  ModemNames: array [1..158] of string =
    ('CW', 'CONTESTIA', 'Cont-4/125', 'Cont-4/250', 'Cont-4/500', 'Cont-4/1K',
    'Cont-4/2K', 'Cont-8/125', 'Cont-8/250', 'Cont-8/500', 'Cont-8/1K', 'Cont-8/2K',
    'Cont-16/250', 'Cont-16/500', 'Cont-16/1K', 'Cont-16/2K', 'Cont-32/1K', 'Cont-32/2K',
    'Cont-64/500', 'Cont-64/1K', 'Cont-64/2K',
    'DOMEX Micro', 'DOMEX4', 'DOMEX5', 'DOMEX8', 'DOMX11', 'DOMX16',
    'DOMX22', 'DOMX44', 'DOMX88',
    'FELDHELL', 'SLOWHELL', 'HELLX5', 'HELLX9', 'FSKH245', 'FSKH105', 'HELL80',
    'MFSK8', 'MFSK16', 'MFSK32', 'MFSK4', 'MFSK11', 'MFSK22', 'MFSK31', 'MFSK64',
    'MFSK128', 'MFSK64L', 'MFSK128L',
    'WEFAX576', 'WEFAX288',
    'NAVTEX', 'SITORB',
    'MT63-500S', 'MT63-500L', 'MT63-1KS', 'MT63-1KL', 'MT63-2KS', 'MT63-2KL',
    'BPSK31', 'BPSK63', 'BPSK63F', 'BPSK125', 'BPSK250', 'BPSK500', 'BPSK1000',
    'PSK125C12', 'PSK250C6', 'PSK500C2', 'PSK500C4', 'PSK800C2', 'PSK1000C2',
    'QPSK31', 'QPSK63', 'QPSK125', 'QPSK250', 'QPSK500',
    '8PSK125', '8PSK125FL', '8PSK125F', '8PSK250', '8PSK250FL', '8PSK250F', '8PSK500',
    '8PSK500F', '8PSK1000', '8PSK1000F', '8PSK1200F',
    'OFDM500F', 'OFDM750F', 'OFDM2000F', 'OFDM2000', 'OFDM3500',
    'OLIVIA', 'OLIVIA-4/125', 'OLIVIA-4/250', 'OLIVIA-4/500',
    'OLIVIA-4/1K', 'OLIVIA-4/2K',
    'OLIVIA-8/125', 'OLIVIA-8/250', 'OLIVIA-8/500', 'OLIVIA-8/1K', 'OLIVIA-8/2K',
    'OLIVIA-16/500', 'OLIVIA-16/1K', 'OLIVIA-16/2K', 'OLIVIA-32/1K', 'OLIVIA-32/2K',
    'OLIVIA-64/500', 'OLIVIA-64/1K', 'OLIVIA-64/2K', 'RTTY',
    'THOR Micro', 'THOR4', 'THOR5', 'THOR8', 'THOR11', 'THOR16', 'THOR22', 'THOR25x4',
    'THOR50x1', 'THOR50x2', 'THOR100',
    'THROB1', 'THROB2', 'THROB4', 'THRBX1', 'THRBX2', 'THRBX4',
    'PSK125R', 'PSK250R', 'PSK500R', 'PSK1000R',
    'PSK63RC4', 'PSK63RC5', 'PSK63RC10', 'PSK63RC20', 'PSK63RC32',
    'PSK125RC4', 'PSK125RC5', 'PSK125RC10', 'PSK125RC12', 'PSK125RC16',
    'PSK250RC2', 'PSK250RC3', 'PSK250RC5', 'PSK250RC6', 'PSK250RC7',
    'PSK500RC2', 'PSK500RC3', 'PSK500RC4', 'PSK800RC2', 'PSK1000RC2',
    'FSQ', 'IFKP', 'SSB', 'WWV', 'ANALYSIS');

type
  TModem = record
    ModeNames: string[20];
    ModeSubNames: string[15];
  end;

const
  Modem: array[1..160] of TModem = (
    //(ModeNames: ''; ModeSubNames: ''),
    (ModeNames: 'CW'; ModeSubNames: ''),
    (ModeNames: ''; ModeSubNames: 'CT'),
    (ModeNames: 'CONTESTI'; ModeSubNames: ''),
    (ModeNames: 'CONTESTI'; ModeSubNames: ''),
    (ModeNames: 'CONTESTI'; ModeSubNames: ''),
    (ModeNames: 'CONTESTI'; ModeSubNames: ''),
    (ModeNames: 'CONTESTI'; ModeSubNames: ''),
    (ModeNames: 'CONTESTI'; ModeSubNames: ''),
    (ModeNames: 'CONTESTI'; ModeSubNames: ''),
    (ModeNames: 'CONTESTI'; ModeSubNames: ''),
    (ModeNames: 'CONTESTI'; ModeSubNames: ''),
    (ModeNames: 'CONTESTI'; ModeSubNames: ''),
    (ModeNames: 'CONTESTI'; ModeSubNames: ''),
    (ModeNames: 'CONTESTI'; ModeSubNames: ''),
    (ModeNames: 'CONTESTI'; ModeSubNames: ''),
    (ModeNames: 'CONTESTI'; ModeSubNames: ''),
    (ModeNames: 'CONTESTI'; ModeSubNames: ''),
    (ModeNames: 'CONTESTI'; ModeSubNames: ''),
    (ModeNames: 'CONTESTI'; ModeSubNames: ''),
    (ModeNames: 'CONTESTI'; ModeSubNames: ''),
    (ModeNames: 'CONTESTI'; ModeSubNames: ''),
    (ModeNames: 'DOMINO'; ModeSubNames: ''),
    (ModeNames: 'DOMINO'; ModeSubNames: ''),
    (ModeNames: 'DOMINO'; ModeSubNames: ''),
    (ModeNames: 'DOMINO'; ModeSubNames: ''),
    (ModeNames: 'DOMINO'; ModeSubNames: ''),
    (ModeNames: 'DOMINO'; ModeSubNames: ''),
    (ModeNames: 'DOMINO'; ModeSubNames: ''),
    (ModeNames: 'DOMINO'; ModeSubNames: ''),
    (ModeNames: 'DOMINO'; ModeSubNames: ''),
    (ModeNames: 'HELL'; ModeSubNames: ''),
    (ModeNames: 'HELL'; ModeSubNames: ''),
    (ModeNames: 'HELL'; ModeSubNames: ''),
    (ModeNames: 'HELL'; ModeSubNames: ''),
    (ModeNames: 'HELL'; ModeSubNames: 'FSKH245'),
    (ModeNames: 'HELL'; ModeSubNames: 'FSKH105'),
    (ModeNames: 'HELL'; ModeSubNames: 'HELL80'),
    (ModeNames: 'MFSK'; ModeSubNames: 'MFSK8'),
    (ModeNames: 'MFSK'; ModeSubNames: 'MFSK16'),
    (ModeNames: 'MFSK'; ModeSubNames: 'MFSK32'),
    (ModeNames: 'MFSK'; ModeSubNames: 'MFSK4'),
    (ModeNames: 'MFSK'; ModeSubNames: 'MFSK11'),
    (ModeNames: 'MFSK'; ModeSubNames: 'MFSK22'),
    (ModeNames: 'MFSK'; ModeSubNames: 'MFSK31'),
    (ModeNames: 'MFSK'; ModeSubNames: 'MFSK64'),
    (ModeNames: 'MFSK'; ModeSubNames: 'MFSK128'),
    (ModeNames: 'MFSK'; ModeSubNames: 'MFSK64'),
    (ModeNames: 'MFSK'; ModeSubNames: 'MFSK128'),
    (ModeNames: 'FAX'; ModeSubNames: ''),
    (ModeNames: 'FAX'; ModeSubNames: ''),
    (ModeNames: 'NAVTEX'; ModeSubNames: ''),
    (ModeNames: 'SITORB'; ModeSubNames: ''),
    (ModeNames: 'MT63'; ModeSubNames: ''),
    (ModeNames: 'MT63'; ModeSubNames: ''),
    (ModeNames: 'MT63'; ModeSubNames: ''),
    (ModeNames: 'MT63'; ModeSubNames: ''),
    (ModeNames: 'MT63'; ModeSubNames: ''),
    (ModeNames: 'MT63'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: 'PSK31'),
    (ModeNames: 'PSK'; ModeSubNames: 'PSK63'),
    (ModeNames: 'PSK'; ModeSubNames: 'PSK63F'),
    (ModeNames: 'PSK'; ModeSubNames: 'PSK125'),
    (ModeNames: 'PSK'; ModeSubNames: 'PSK250'),
    (ModeNames: 'PSK'; ModeSubNames: 'PSK500'),
    (ModeNames: 'PSK'; ModeSubNames: 'PSK1000'),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: 'QPSK31'),
    (ModeNames: 'PSK'; ModeSubNames: 'QPSK63'),
    (ModeNames: 'PSK'; ModeSubNames: 'QPSK125'),
    (ModeNames: 'PSK'; ModeSubNames: 'QPSK250'),
    (ModeNames: 'PSK'; ModeSubNames: 'QPSK500'),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'OFDM'; ModeSubNames: ''),
    (ModeNames: 'OFDM'; ModeSubNames: ''),
    (ModeNames: 'OFDM'; ModeSubNames: ''),
    (ModeNames: 'OFDM'; ModeSubNames: ''),
    (ModeNames: 'OFDM'; ModeSubNames: ''),
    (ModeNames: 'OLIVIA'; ModeSubNames: ''),
    (ModeNames: 'OLIVIA'; ModeSubNames: 'OLIVIA 4/125'),
    (ModeNames: 'OLIVIA'; ModeSubNames: 'OLIVIA 4/250'),
    (ModeNames: 'OLIVIA'; ModeSubNames: 'OLIVIA 4/500'),
    (ModeNames: 'OLIVIA'; ModeSubNames: 'OLIVIA 4/1K'),
    (ModeNames: 'OLIVIA'; ModeSubNames: 'OLIVIA 4/2K'),
    (ModeNames: 'OLIVIA'; ModeSubNames: 'OLIVIA 8/125'),
    (ModeNames: 'OLIVIA'; ModeSubNames: 'OLIVIA 8/250'),
    (ModeNames: 'OLIVIA'; ModeSubNames: 'OLIVIA 8/500'),
    (ModeNames: 'OLIVIA'; ModeSubNames: 'OLIVIA 8/1K'),
    (ModeNames: 'OLIVIA'; ModeSubNames: 'OLIVIA 8/2K'),
    (ModeNames: 'OLIVIA'; ModeSubNames: 'OLIVIA 16/500'),
    (ModeNames: 'OLIVIA'; ModeSubNames: 'OLIVIA 16/1K'),
    (ModeNames: 'OLIVIA'; ModeSubNames: 'OLIVIA 16/2K'),
    (ModeNames: 'OLIVIA'; ModeSubNames: 'OLIVIA 32/1K'),
    (ModeNames: 'OLIVIA'; ModeSubNames: 'OLIVIA 32/2K'),
    (ModeNames: 'OLIVIA'; ModeSubNames: ''),
    (ModeNames: 'OLIVIA'; ModeSubNames: ''),
    (ModeNames: 'OLIVIA'; ModeSubNames: ''),
    (ModeNames: 'RTTY'; ModeSubNames: ''),
    (ModeNames: 'THOR'; ModeSubNames: ''),
    (ModeNames: 'THOR'; ModeSubNames: ''),
    (ModeNames: 'THOR'; ModeSubNames: ''),
    (ModeNames: 'THOR'; ModeSubNames: ''),
    (ModeNames: 'THOR'; ModeSubNames: ''),
    (ModeNames: 'THOR'; ModeSubNames: ''),
    (ModeNames: 'THOR'; ModeSubNames: ''),
    (ModeNames: 'THOR'; ModeSubNames: ''),
    (ModeNames: 'THOR'; ModeSubNames: ''),
    (ModeNames: 'THOR'; ModeSubNames: ''),
    (ModeNames: 'THOR'; ModeSubNames: ''),
    (ModeNames: 'THRB'; ModeSubNames: ''),
    (ModeNames: 'THRB'; ModeSubNames: ''),
    (ModeNames: 'THRB'; ModeSubNames: ''),
    (ModeNames: 'THRB'; ModeSubNames: 'THRBX'),
    (ModeNames: 'THRB'; ModeSubNames: 'THRBX'),
    (ModeNames: 'THRB'; ModeSubNames: 'THRBX'),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'PSK'; ModeSubNames: ''),
    (ModeNames: 'FSQ'; ModeSubNames: ''),
    (ModeNames: 'IFKP'; ModeSubNames: ''),
    (ModeNames: 'SSB'; ModeSubNames: ''),
    (ModeNames: ''; ModeSubNames: ''),
    (ModeNames: ''; ModeSubNames: ''),
    (ModeNames: ''; ModeSubNames: ''),
    (ModeNames: ''; ModeSubNames: ''));

type
  TdmFlModem = class(TDataModule)
  private

  public
    procedure GetModemName(id: integer; var mode, submode: string);
  end;

var
  dmFlModem: TdmFlModem;

implementation

procedure TdmFlModem.GetModemName(id: integer; var mode, submode: string);
begin
  mode := Modem[id].ModeNames;
  submode := Modem[id].ModeSubNames;
end;

end.
