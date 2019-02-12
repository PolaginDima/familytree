unit UnitNodeFromBD;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, DBGrids,
  Grids, StdCtrls, sqldb, db;

type

  { TfrmNodeFromBD }

  TfrmNodeFromBD = class(TForm)
    Button1: TButton;
    StringGridPeople: TStringGrid;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure StringGridPeopleDblClick(Sender: TObject);
  private
    FfrmCaption:string;
    FbtnCaption:string;
    FID_Select: cardinal;
    FSQLQuery:TSQLQuery;
    DS:TDataSource;
    procedure SetbtnCaption(AValue: string);
    procedure SetfrmCaption(AValue: string);
    procedure SetSQLQuery(AValue: TSQLQuery);
    function changedate(dt:string):string;
  public
    property frmCaption:string write SetfrmCaption;
    property SQLQuery:TSQLQuery write SetSQLQuery;
    property ID_Select:cardinal read FID_Select;
    property btnCaption:string write SetbtnCaption;
  end;

var
  frmNodeFromBD: TfrmNodeFromBD;

implementation

{$R *.lfm}

{ TfrmNodeFromBD }

procedure TfrmNodeFromBD.Button1Click(Sender: TObject);
begin
  //showmessage(StringGridPeople.Cells[0,StringGridPeople.Row]);
  FID_Select:=strtoint(StringGridPeople.Cells[0,StringGridPeople.Row]);
end;

procedure TfrmNodeFromBD.FormCreate(Sender: TObject);
begin
  FID_Select:=-1;
end;

procedure TfrmNodeFromBD.StringGridPeopleDblClick(Sender: TObject);
begin
  FID_Select:=strtoint(StringGridPeople.Cells[0,StringGridPeople.Row]);
end;

procedure TfrmNodeFromBD.SetfrmCaption(AValue: string);
begin
  if AValue=FfrmCaption then exit;
  FfrmCaption:=AValue;
  self.Caption:=FfrmCaption;
end;

procedure TfrmNodeFromBD.SetbtnCaption(AValue: string);
begin
   if AValue=FfrmCaption then exit;
  FbtnCaption:=AValue;
  self.Caption:=FbtnCaption;
end;

procedure TfrmNodeFromBD.SetSQLQuery(AValue: TSQLQuery);
begin
  if AValue=nil then exit;
  FSQLQuery:=AValue;
  DS:=TDataSource.Create(self);
  FSQLQuery.Open;
  if FSQLQuery.IsEmpty then
  begin
    //пишем что нет объектов для выбора
    self.Button1.Enabled:=false;
    exit;
  end;
  FSQLQuery.First;
  while not FSQLQuery.EOF do
  begin
    StringGridPeople.RowCount:=StringGridPeople.RowCount+1;
    StringGridPeople.Cells[0,StringGridPeople.RowCount-1]:=FSQLQuery.FieldByName('id').AsString;
    StringGridPeople.Cells[1,StringGridPeople.RowCount-1]:=FSQLQuery.FieldByName('fam').AsString;
    StringGridPeople.Cells[2,StringGridPeople.RowCount-1]:=FSQLQuery.FieldByName('nam').AsString;
    StringGridPeople.Cells[3,StringGridPeople.RowCount-1]:=FSQLQuery.FieldByName('otch').AsString;
    if FSQLQuery.FieldByName('sex').AsInteger=0 then
    StringGridPeople.Cells[4,StringGridPeople.RowCount-1]:='муж' else
      StringGridPeople.Cells[4,StringGridPeople.RowCount-1]:='жен';
    if FSQLQuery.FieldByName('dtb').AsString='UNKNOWN' then
    StringGridPeople.Cells[5,StringGridPeople.RowCount-1]:='' else
      StringGridPeople.Cells[5,StringGridPeople.RowCount-1]:=changedate(FSQLQuery.FieldByName('dtb').AsString);
    FSQLQuery.Next;
  end;
end;

function TfrmNodeFromBD.changedate(dt: string): string;
begin
  result:=copy(dt,9,2)+'.'+copy(dt,6,2)+'.'+copy(dt,0,4);
end;

end.

