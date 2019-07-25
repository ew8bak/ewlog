{===============================================================================

   Set of routines extending usability of SimpleXML library.
   Provide additional sanity checks, keeping all "Assigned()" and "<> nil"
   constructs in one place, thus making original code more clean
   and comprehensible.
   Implemented as a set of regular functions to improve nil handling.

   (c) 2008 Vladimir Zhirov <vvzh.home@gmail.com>
   All rights reserved.
   
   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are met:
       * Redistributions of source code must retain the above copyright
         notice, this list of conditions and the following disclaimer.
       * Neither the name of the copyright holder nor the
         names of contributors may be used to endorse or promote products
         derived from this software without specific prior written permission.
   
   THIS SOFTWARE IS PROVIDED BY COPYRIGHT HOLDER "AS IS" AND ANY
   EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
   WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
   DISCLAIMED. IN NO EVENT SHALL COPYRIGHT HOLDER BE LIABLE FOR ANY
   DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
   (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
   ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
   
===============================================================================}

unit SmpXMLUtils;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, SimpleXML, strutils;
                                        
function InsertElementWithAlphaSort(AParentNode: IXmlNode;
  const ANewElementName, ASortByAttr, ANewElementAttrValue: string): IXmlElement;
{procedure SortChildNodesByAttr(AParentNode: IXmlNode; const AnAttrName: string;
  AStringSort, AnAscendingSort: Boolean);}
function EnsureElementWithAttr(AParentNode: IXmlNode;
  const AnElementName, AnAttrName: string; AnAttrValue: Variant): IXmlElement;
function FindElementDeep(AParentNode: IXmlNode;
  const AnElementName, AnAttrName: string; AnAttrValue: Variant): IXmlElement;
function CreateXMLDocumentFromNode(ANode: IXmlNode): IXmlDocument;
procedure SetDocumentElement(const ADocument: IXmlDocument;
  const AnElement: IXmlNode); inline;
function EnsureFirstChild(const AParentNode: IXmlNode;
  const ANodeName: string): IXmlNode;

// expression-based routines for node and attribute retrieval
function GetNodeByExpr(AContextNode: IXmlNode;
  const AnExpression: string): IXmlNode;
function GetNodeListByExpr(AContextNode: IXmlNode;
  const AnExpression: string): IXmlNodeList;
function GetVarAttrByExpr(AContextNode: IXmlNode;
  const AnExpression, AnAttrName: string; const ADefault: Variant): Variant;
function GetAttrByExpr(AContextNode: IXmlNode;
  const AnExpression, AnAttrName: string; const ADefault: string = ''): string;
function GetBoolAttrByExpr(AContextNode: IXmlNode;
  const AnExpression, AnAttrName: string; ADefault: Boolean = False): boolean;
function GetIntAttrByExpr(AContextNode: IXmlNode;
  const AnExpression, AnAttrName: string; ADefault: Integer = 0): integer;
function GetDateTimeAttrByExpr(AContextNode: IXmlNode;
  const AnExpression, AnAttrName: string; ADefault: TDateTime = 0): TDateTime;
function GetFloatAttrByExpr(AContextNode: IXmlNode;
  const AnExpression, AnAttrName: string; ADefault: Double = 0): Double;
function GetHexAttrByExpr(AContextNode: IXmlNode;
  const AnExpression, AnAttrName: string; ADefault: Integer = 0): Integer;

implementation

function ParseNodeToken(ANode: IXmlNode; AToken: string): IXmlNode;
begin
  // (some location path shortcuts)
  if AToken = '.'  then Result := ANode else
  if AToken = '..' then Result := ANode.ParentNode else
  if AToken = '*'  then Result := ANode.ChildNodes[0] else
  // (child nodes)
  Result := ANode.SelectSingleNode(AToken);
  // node axes, typed nodes, id() and predicates are not supported
end;

function ParseListToken(ANode: IXmlNode; AToken: string): IXmlNodeList;
var
  i: Integer;
  DetachedChildNodes: array of IXmlNode;
begin
  if AToken = '*'  then
  begin
    { We cannot return ChildNodes here because all operations on the
      resulting list will cause changes in the original set of child nodes
      in this case. That is why we create a separate node list containing
      all child nodes. One should keep in mind though, that the nodes
      of the list still are pointers to the actual child nodes,
      so they will change as soon as original child nodes change. }
    SetLength(DetachedChildNodes, ANode.ChildNodes.Count);
    for i := 0 to High(DetachedChildNodes) do
      DetachedChildNodes[i] := ANode.ChildNodes[i];
    Result := CreateXmlNodeList(DetachedChildNodes);
  end else
  // (child nodes)
  Result := ANode.SelectNodes(AToken);
  // node axes, typed nodes, id() and predicates are not supported
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function InsertElementWithAlphaSort(AParentNode: IXmlNode;
  const ANewElementName, ASortByAttr, ANewElementAttrValue: string): IXmlElement;
var
  i: integer;
begin
  // search for an insert position
  i := 0;
  while (i < AParentNode.ChildNodes.Count)
    and (ANewElementAttrValue >= AParentNode.ChildNodes[i].GetAttr(ASortByAttr))
    do Inc(i);
  // make an insertion
  if i < AParentNode.ChildNodes.Count then
  begin  
    Result := AParentNode.OwnerDocument.CreateElement(ANewElementName);
    AParentNode.InsertBefore(Result, AParentNode.ChildNodes[i]) ;
  end else
    Result := AParentNode.AppendElement(ANewElementName);
end;

function EnsureElementWithAttr(AParentNode: IXmlNode; const AnElementName,
  AnAttrName: string; AnAttrValue: Variant): IXmlElement;
begin
  if AParentNode = nil then
    raise Exception.Create('{B4E71FF7-3EF7-4921-BAE1-336C89D30DA2}');
  Result := AParentNode.FindElement(AnElementName, AnAttrName, AnAttrValue);
  if Result = nil then
  begin
    Result := AParentNode.AppendElement(AnElementName);
    Result.SetVarAttr(AnAttrName, AnAttrValue);
  end;
end;

function FindElementDeep(AParentNode: IXmlNode; const AnElementName,
  AnAttrName: string; AnAttrValue: Variant): IXmlElement;
var
  i: Integer;
begin
  if AParentNode = nil then
  begin
    Result := nil;
    Exit; //==>
  end;

  with AParentNode do
  begin
    Result := FindElement(AnElementName, AnAttrName, AnAttrValue);
    if Result = nil then
      for i := 0 to ChildNodes.Count - 1 do
      begin
        Result := FindElementDeep(ChildNodes.Item[i], AnElementName,
          AnAttrName, AnAttrValue);
        if Assigned(Result) then
          Exit; //==>
      end;
  end;
end;

function CreateXMLDocumentFromNode(ANode: IXmlNode): IXmlDocument;
begin
  if Assigned(ANode) then
  begin
    Result := CreateXmlDocument('root');
    with Result do
      ReplaceChild(ANode.CloneNode(True), DocumentElement);
  end else
    Result := nil;
end;

procedure SetDocumentElement(const ADocument: IXmlDocument;
  const AnElement: IXmlNode); inline;
begin
  ADocument.ReplaceChild(AnElement, ADocument.DocumentElement);
end;

function EnsureFirstChild(const AParentNode: IXmlNode; const ANodeName: string
  ): IXmlNode;
var
  NewNodeNameID: Integer;
begin
  NewNodeNameID := AParentNode.OwnerDocument.NameTable.GetID(ANodeName);
  if AParentNode.ChildNodes.Count > 0 then
  begin
    if AParentNode.ChildNodes[0].NodeNameID <> NewNodeNameID then
    begin
      Result := AParentNode.OwnerDocument.CreateElement(NewNodeNameID);
      AParentNode.InsertBefore(Result, AParentNode.ChildNodes[0]);
    end else
      Result := AParentNode.ChildNodes[0]
  end else
    Result := AParentNode.AppendElement(NewNodeNameID);
end;

function GetNodeByExpr(AContextNode: IXmlNode;
  const AnExpression: string): IXmlNode;
var
  Token, RestExpr: string;
  XNode: IXmlNode;
begin
  if AContextNode = nil then
  begin
    Result := nil;
    Exit; //==>
  end;
  if AnExpression = '' then
  begin
    Result := AContextNode;
    Exit; //==>
  end;

  RestExpr := AnExpression;
  if RestExpr[1] = '/' then // absolute path
  begin
    Delete(RestExpr, 1, 1);
    XNode := AContextNode.OwnerDocument;
  end else
    XNode := AContextNode;

  if RestExpr > '' then
    repeat
      Token := Copy2SymbDel(RestExpr, '/');
      XNode := ParseNodeToken(XNode, Token);
      if XNode = nil then break;
    until RestExpr = '';

  Result := XNode;
end;

function GetNodeListByExpr(AContextNode: IXmlNode;
  const AnExpression: string): IXmlNodeList;
var
  Token, RestExpr: string;
  XNode: IXmlNode;
  XList: IXmlNodeList;
begin
  if AContextNode = nil then
  begin
    Result := nil;
    Exit; //==>
  end;
  if AnExpression = '' then
  begin
    Result := CreateXmlNodeList([AContextNode]);
    Exit; //==>
  end;

  RestExpr := AnExpression;
  if RestExpr[1] = '/' then // absolute path
  begin
    Delete(RestExpr, 1, 1);
    XNode := AContextNode.OwnerDocument;
  end else
    XNode := AContextNode;

  if RestExpr > '' then
    repeat
      Token := Copy2SymbDel(RestExpr, '/');
      if RestExpr = '' then
        XList := ParseListToken(XNode, Token)
      else
        XNode := ParseNodeToken(XNode, Token);
      if XNode = nil then break;
    until RestExpr = '';

  if XList = nil then
  begin
    if XNode = nil then
      Result := nil
    else
      Result := CreateXmlNodeList([XNode]);
  end else
    Result := XList;
end;

function GetVarAttrByExpr(AContextNode: IXmlNode;
  const AnExpression, AnAttrName: string; const ADefault: Variant): Variant;
var
  XNode: IXmlNode;
begin
  XNode := GetNodeByExpr(AContextNode, AnExpression);
  if XNode = nil
    then Result := ADefault
    else Result := XNode.GetVarAttr(AnAttrName, ADefault);
end; 

function GetAttrByExpr(AContextNode: IXmlNode;
  const AnExpression, AnAttrName: string; const ADefault: string = ''): string;
var
  XNode: IXmlNode;
begin
  XNode := GetNodeByExpr(AContextNode, AnExpression);
  if XNode = nil
    then Result := ADefault
    else Result := XNode.GetAttr(AnAttrName, ADefault);
end;

function GetBoolAttrByExpr(AContextNode: IXmlNode;
  const AnExpression, AnAttrName: string; ADefault: Boolean = False): boolean;
var
  XNode: IXmlNode;
begin
  XNode := GetNodeByExpr(AContextNode, AnExpression);
  if XNode = nil
    then Result := ADefault
    else Result := XNode.GetBoolAttr(AnAttrName, ADefault);
end;

function GetIntAttrByExpr(AContextNode: IXmlNode;
  const AnExpression, AnAttrName: string; ADefault: Integer = 0): integer;
var
  XNode: IXmlNode;
begin
  XNode := GetNodeByExpr(AContextNode, AnExpression);
  if XNode = nil
    then Result := ADefault
    else Result := XNode.GetIntAttr(AnAttrName, ADefault);
end;

function GetDateTimeAttrByExpr(AContextNode: IXmlNode;
  const AnExpression, AnAttrName: string; ADefault: TDateTime = 0): TDateTime;
var
  XNode: IXmlNode;
begin
  XNode := GetNodeByExpr(AContextNode, AnExpression);
  if XNode = nil
    then Result := ADefault
    else Result := XNode.GetDateTimeAttr(AnAttrName, ADefault);
end;

function GetFloatAttrByExpr(AContextNode: IXmlNode;
  const AnExpression, AnAttrName: string; ADefault: Double = 0): Double;
var
  XNode: IXmlNode;
begin
  XNode := GetNodeByExpr(AContextNode, AnExpression);
  if XNode = nil
    then Result := ADefault
    else Result := XNode.GetFloatAttr(AnAttrName, ADefault);
end;

function GetHexAttrByExpr(AContextNode: IXmlNode;
  const AnExpression, AnAttrName: string; ADefault: Integer = 0): Integer;
var
  XNode: IXmlNode;
begin
  XNode := GetNodeByExpr(AContextNode, AnExpression);
  if XNode = nil
    then Result := ADefault
    else Result := XNode.GetHexAttr(AnAttrName, ADefault);
end;

end.
