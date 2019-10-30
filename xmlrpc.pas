unit xmlrpc;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, XMLRead, DOM, XMLUtils, synautil;

type
  bytestring = string;

function RequestStrN( address, command: string): string;
function RequestStr( address, command: string): string;
function RequestStr( address, command, value: string; asbytestring: boolean): string;
function RequestStr( address, command, value1, value2: string; asbytestring: boolean): string;
function RequestStr( address, command: string; value: integer): string;
function RequestStr( address, command: string; value1, value2: integer): string;
function RequestStr( address, command: string; value: double): string;
function RequestStr( address, command: string; value: boolean): string;

function RequestInt( address, command: string): integer;
function RequestInt( address, command, value: string): integer;
function RequestInt( address, command, value1, value2: string): integer;
function RequestInt( address, command: string; value: integer): integer;

function RequestFloat( address, command: string): double;
function RequestFloat( address, command, value: string): double;
function RequestFloat( address, command, value1, value2: string): double;

function RequestBool( address, command: string): boolean;
function RequestBool( address, command, value: string): boolean;
function RequestBool( address, command, value1, value2: string): boolean;


function RequestError: boolean;
function GetLastError: string;
function GetLastResponse: string;

implementation

uses
  HTTPSend, Base64;

const
  sRequest = '<?xml version="1.0"?><methodCall>'+
    '<methodName>%m</methodName>'+
    '%p'+
    '</methodCall>';
  sParams = '<params>'+
    '%q'+
    '</params>';
  sValue = '<param><value>%v</value></param>';
  sType = '<%t>%v</%t>';

var
  error: boolean;
  errcode: integer;
  response, errstr: string;

function Base64EncodeStr(Input: string): string;
var
  str, res: TStringStream;
begin
  str := TStringStream.Create(Input);
  try
    str.Position := 0;
    res := TStringStream.Create('');
    try
      with TBase64EncodingStream.Create(res)do
        try
          CopyFrom(str,str.Size);
        finally
          Free;
        end;
      Result := Res.DataString;
    finally
      res.Free;
    end;
  finally
   str.Free;
  end;
end;

function Base64DecodeStr(Input: string): string;
var
  str: TStringStream;
  res: TBase64DecodingStream;
begin
  str := TStringStream.Create(Input);
  try
    res := TBase64DecodingStream.Create(str);
    str.Position := 0;
    try
      SetLength(Result,res.Size);
      res.Read(Result[1],res.Size);
    finally
      res.Free;
    end;
  finally
   str.Free;
  end;
end;

function XMLEncodeStr(Input: string): string;
var
  p: integer;
begin
  Result := Input;
  if Length(Result) = 0 then Exit;
  p := 1;
  repeat
    case Result[p] of
    '&':  begin
            Delete(Result,p,1);
            Insert('&amp;',Result,p);
            Inc(p,4);
          end;
    '<':  begin
            Delete(Result,p,1);
            Insert('&lt;',Result,p);
            Inc(p,3);
          end;
    '>':  begin
            Delete(Result,p,1);
            Insert('&gt;',Result,p);
            Inc(p,3);
          end;
    '''': begin
            Delete(Result,p,1);
            Insert('&apos;',Result,p);
            Inc(p,5);
          end;
    '"':  begin
            Delete(Result,p,1);
            Insert('&quot;',Result,p);
            Inc(p,5);
          end;
    end;
    Inc(p);
  until p > Length(Result);
end;

function XMLDecodeStr(Input: string): string;

  procedure Replace( find, repl: string; var s: string);
  var
    p: integer;
  begin
    repeat
      p := Pos(find,s);
      if p > 0 then
      begin
        Delete(s,p,Length(find));
        Insert(repl,s,p);
      end;
    until p = 0;
  end;

begin
  Result := Input;
  if Length(Result) = 0 then Exit;
  Replace('&amp;','&',Result);
  Replace('&lt;','<',Result);
  Replace('&gt;','>',Result);
  Replace('&apos;','''',Result);
  Replace('&quot;','"',Result);
end;

function HttpPostXML(const URL: string; const Data: TStream): Boolean;
var
  HTTP: THTTPSend;
begin
  HTTP := THTTPSend.Create;
  try
    HTTP.Document.CopyFrom(Data, 0);
    HTTP.MimeType := 'text/xml';
    Result := HTTP.HTTPMethod('POST', URL);
    Data.Size := 0;
    if Result then
    begin
      Data.Seek(0, soFromBeginning);
      Data.CopyFrom(HTTP.Document, 0);
    end;
  finally
    HTTP.Free;
  end;
end;

function PrepareValue( value, vtype: string ): string;
var
  p: integer;
  s,t: string;
begin
  s := sValue;
  if vtype = '' then
    t := value
  else
  begin
    t := sType;
    repeat
      p := Pos('%t',t);
      if p > 0 then
      begin
        Delete(t,p,2);
        Insert(vtype,t,p);
      end;
    until p = 0;
    p := Pos('%v',t);
    Delete(t,p,2);
    Insert(value,t,p);
  end;
  p := Pos('%v',s);
  Delete(s,p,2);
  Insert(t,s,p);
  Result := s;
end;

function PrepareStringValue( value: string; bytestring: boolean ): string;
begin
  if bytestring then
    Result := PrepareValue(Base64EncodeStr(value),'base64')
  else
    Result := PrepareValue(XMLEncodeStr(value),'string');
end;

function GetStringResult( response: string ): string;
var
  p, q: integer;
begin
  Result := '';
  p := Pos('<string>',response);
  if p > 0 then
  begin
    q := Pos('</string>',response);
    if q > p+8 then
      Result := XMLDecodeStr(Copy(response,p+8,q-(p+8)));
  end
  else
  begin
    p := Pos('<base64>',response);
    if p > 0 then
    begin
      q := Pos('</base64>',response);
      if q > p+8 then
        Result := Base64DecodeStr(Copy(response,p+8,q-(p+8)));
    end;
  end;
end;

function GetIntegerResult( response: string ): integer;
var
  p, q: integer;
begin
  Result := MAXINT;
  p := Pos('<i4>',response);
  if p > 0 then
  begin
    q := Pos('</i4>',response);
    if q > p+4 then
      Result := StrToIntDef(Copy(response,p+4,q-(p+4)),0);
  end;
end;

function GetFloatResult( response: string ): double;
var
  p, q: integer;
  r: string;
begin
  Result := 0.0;
  p := Pos('<double>',response);
  if p > 0 then
  begin
    q := Pos('</double>',response);
    if q > p+8 then
    begin
      // get floating point value
      r := Copy(response,p+8,q-(p+8));
      // convert to correct regional format
      p := Pos('.',r);
      if p > 0 then r[p] := DefaultFormatSettings.DecimalSeparator;
      Result := StrToFloatDef(r,0.0);
    end;
  end;
end;

function GetBooleanResult( response: string ): boolean;
var
  p, q: integer;
begin
  Result := false;
  p := Pos('<boolean>',response);
  if p > 0 then
  begin
    q := Pos('</boolean>',response);
    if q > p+9 then
      Result := Copy(response,p+9,q-(p+9)) = '1';
  end;
end;

function RawRequest( address, command, value1, value2: string): string;
var
  p: integer;
  s: string;
  ss: TStringStream;
begin
  errcode := 0;
  errstr := '';
  s := sRequest;
  // insert command
  p := Pos('%m',s);
  Delete(s,p,2);
  Insert(command,s,p);
  // insert params
  p := Pos('%p',s);
  Delete(s,p,2);
  if Length(value1) > 0 then
  begin
    // insert params
    Insert(sParams,s,p);
    // insert value1 (created using PrepareValue)
    p := Pos('%q',s);
    Insert(value1,s,p);
    Inc(p,Length(value1));
    if Length(value2) > 0 then
    // insert value2
    begin
      Insert(value2,s,p);
      Inc(p,Length(value2));
    end;
  end;
  // send request
  ss := TStringStream.Create(s);
  if HTTPPostXML(address,ss) then
  begin
    // get result
    Result := ss.DataString;
    error := Pos('<fault>',Result) > 0;
    if error then
    begin
      errcode := GetIntegerResult(Result);
      errstr := GetStringResult(Result);
    end;
  end
  else
  begin
    error := true;
    errcode := 999;
    errstr := 'Post request failed';
  end;
  ss.Destroy;
end;

function RequestStr( address, command: string): string;
begin
  Result := RequestStr( address, command, '', '', false);
end;

function RequestStrN( address, command: string): string;
var
aHTTP: THTTPSend;
Doc: TXMLDocument;
begin
 aHTTP := THTTPSend.Create;
 Doc := TXMLDocument.Create;
  try
    WriteStrToStream(aHTTP.Document, '<methodCall>'+
    '<methodName>'+command+'</methodName>'+
    '</methodCall>');
    aHTTP.MimeType := 'application/xml';
if aHTTP.HTTPMethod('POST', address) then
begin
aHTTP.Document.Position := 0;
ReadXMLFile(Doc, aHTTP.Document);
Result:=Doc.DocumentElement.TextContent;
end
else exit;
finally
aHTTP.Free;
Doc.Free;
end;
end;

function RequestStr( address, command, value: string; asbytestring: boolean): string;
begin
  Result := RequestStr( address, command, value, '', asbytestring);
end;

function RequestStr( address, command, value1, value2: string; asbytestring: boolean): string;
var
  v1, v2: string;
begin
  Result := ''; v1 := ''; v2 := '';
  if Length(value1) > 0 then
    v1 := PrepareStringValue(value1,asbytestring);
  if Length(value2) > 0 then
    v2 := PrepareStringValue(value2,asbytestring);
  response := RawRequest( address, command, v1, v2 );
  if not error then
    Result := GetStringResult( response );
end;

function RequestStr( address, command: string; value: integer): string;
var
  v: string;
begin
  v := PrepareValue(IntToStr(value),'i4');
  response := RawRequest( address, command, v, '' );
  if not error then
    Result := GetStringResult( response );
end;

function RequestStr( address, command: string; value1, value2: integer): string;
var
  v1, v2: string;
begin
  v1 := PrepareValue(IntToStr(value1),'i4');
  v2 := PrepareValue(IntToStr(value2),'i4');
  response := RawRequest( address, command, v1, v2 );
  if not error then
    Result := GetStringResult( response );
end;

function RequestStr( address, command: string; value: double): string;
var
  v: string;
begin
  v := PrepareValue(FloatToStr(value),'double');
  response := RawRequest( address, command, v, '' );
  if not error then
    Result := GetStringResult( response );
end;

function RequestStr( address, command: string; value: boolean): string;
var
  v: string;
begin
  v := PrepareValue(IntToStr(Ord(value)),'boolean');
  response := RawRequest( address, command, v, '' );
  if not error then
    Result := GetStringResult( response );
end;

function RequestInt( address, command: string): integer;
begin
  Result := RequestInt( address, command, '', '');
end;

function RequestInt( address, command, value: string): integer;
begin
  Result := RequestInt( address, command, value, '');
end;

function RequestInt( address, command, value1, value2: string): integer;
var
  v1, v2: string;
begin
  Result := -1; v1 := ''; v2 := '';
  if Length(value1) > 0 then
    v1 := PrepareStringValue(value1,false);
  if Length(value2) > 0 then
    v2 := PrepareStringValue(value2,false);
  response := RawRequest( address, command, v1, v2);
  if not error then
    Result := GetIntegerResult( response );
end;

function RequestInt( address, command: string; value: integer): integer;
var
  v: string;
begin
  v := PrepareValue(IntToStr(value),'i4');
  response := RawRequest( address, command, v, '' );
  if not error then
    Result := GetIntegerResult( response );
end;

function RequestError: boolean;
begin
  Result := error;
end;

function RequestFloat( address, command: string): double;
begin
  Result := RequestFloat( address, command, '', '');
end;

function RequestFloat( address, command, value: string): double;
begin
  Result := RequestFloat( address, command, value, '');
end;

function RequestFloat( address, command, value1, value2: string): double;
var
  v1, v2: string;
begin
  Result := -1; v1 := ''; v2 := '';
  if Length(value1) > 0 then
    v1 := PrepareStringValue(value1,false);
  if Length(value2) > 0 then
    v2 := PrepareStringValue(value2,false);
  response := RawRequest( address, command, v1, v2);
  if not error then
    Result := GetFloatResult( response );
end;

function RequestBool( address, command: string): boolean;
begin
  Result := RequestBool( address, command, '', '');
end;

function RequestBool( address, command, value: string): boolean;
begin
  Result := RequestBool( address, command, value, '');
end;

function RequestBool( address, command, value1, value2: string): boolean;
var
  v1, v2: string;
begin
  Result := false; v1 := ''; v2 := '';
  if Length(value1) > 0 then
    v1 := PrepareStringValue(value1,false);
  if Length(value2) > 0 then
    v2 := PrepareStringValue(value2,false);
  response := RawRequest( address, command, v1, v2);
  if not error then
    Result := GetBooleanResult( response );
end;

function GetLastError: string;
begin
  Result := errstr;
end;

function GetLastResponse: string;
begin
  Result := response;
end;

end.

