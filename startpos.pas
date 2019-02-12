unit startpos;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  DBGrids, Grids, ExtCtrls, Menus, sqldb, db, lazutf8, workdb;

type
  TVibor=(ViborTreePotomk,ViborTreePredki,ViborTreeNew,ViborTreeAny);
  { Tfrmstartpos }

  Tfrmstartpos = class(TForm)
    Button1: TButton;
    CheckBox1: TCheckBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    Panel1: TPanel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    StringGridPeople: TStringGrid;
    procedure Button1Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure RadioButton1Change(Sender: TObject);
    procedure StringGridPeopleDblClick(Sender: TObject);
    procedure StringGridPeopleHeaderSized(Sender: TObject; IsColumn: Boolean;
      Index: Integer);
  private
    Fwdb:Tworkdb;
    Fflag:boolean;
    FSQLQueryPeople: TSQLQuery;
    FSQLQueryPotomk:TSQLQuery;
    FSQLQueryPredki:TSQLQuery;
    //DS:TDataSource;
    FVibor: TVibor;
    function GetID: integer;
    procedure SetSQLQueryPeople(AValue: TSQLQuery);
    procedure SetSQLQueryPotomk(AValue: TSQLQuery);
    procedure SetSQLQueryPredki(AValue: TSQLQuery);
    procedure MyFilterPeople (DataSet: TDataSet;  var Accept: Boolean);
    procedure MyFilterPotomk (DataSet: TDataSet;  var Accept: Boolean);
    procedure MyFilterPredki (DataSet: TDataSet;  var Accept: Boolean);
  public
    property SQLQueryPotomk:TSQLQuery read FSQLQueryPotomk write SetSQLQueryPotomk;
    property SQLQueryPredki:TSQLQuery read FSQLQueryPredki write SetSQLQueryPredki;
    property SQLQueryPeople:TSQLQuery read FSQLQueryPeople write SetSQLQueryPeople;
    property ID:integer read GetID;
    property Vibor:TVibor read FVibor;
    property workdb:Tworkdb read Fwdb write fwdb;
  end;

var
  frmstartpos: Tfrmstartpos;

implementation

{$R *.lfm}

{ Tfrmstartpos }

procedure Tfrmstartpos.FormCreate(Sender: TObject);
begin
  Fflag:=false;
end;

procedure Tfrmstartpos.Button1Click(Sender: TObject);
begin

end;

procedure Tfrmstartpos.CheckBox1Change(Sender: TObject);
var
  tmp_int:integer;
begin
   RadioButton1.Enabled:=not (Sender as TCheckBox).Checked;
   RadioButton2.Enabled:=not (Sender as TCheckBox).Checked;
   RadioButton3.Enabled:=not (Sender as TCheckBox).Checked;
   if (Sender as TCheckBox).Checked then
   begin
     StringGridPeople.Clear;
     StringGridPeople.Visible:=true;
     StringGridPeople.RowCount:=1;
     if FSQLQueryPeople.IsEmpty then
     begin
       //пишем что нет объектов для выбора
       exit;
     end;
     FSQLQueryPeople.First;
     while not FSQLQueryPeople.EOF do
       begin
         StringGridPeople.RowCount:=StringGridPeople.RowCount+1;
         StringGridPeople.Cells[0,StringGridPeople.RowCount-1]:=FSQLQueryPeople.FieldByName('id').AsString;
         StringGridPeople.Cells[1,StringGridPeople.RowCount-1]:=FSQLQueryPeople.FieldByName('fam').AsString;
         StringGridPeople.Cells[2,StringGridPeople.RowCount-1]:=FSQLQueryPeople.FieldByName('nam').AsString;
         if FSQLQueryPeople.FieldByName('otch').AsString='UNKNOWN' then StringGridPeople.Cells[3,StringGridPeople.RowCount-1]:='' else
         StringGridPeople.Cells[3,StringGridPeople.RowCount-1]:=FSQLQueryPeople.FieldByName('otch').AsString;
         tmp_int:=strtoint(FSQLQueryPeople.FieldByName('flag').AsString);
          if (tmp_int and 1)=1 then
             StringGridPeople.Cells[4,StringGridPeople.RowCount-1]:='данные требуют уточнения'
             else
                 StringGridPeople.Cells[4,StringGridPeople.RowCount-1]:='';
         FSQLQueryPeople.Next;
       end;
     FVibor:=ViborTreeAny;
   end else
   begin
     RadioButton1Change(RadioButton1);
     RadioButton1Change(RadioButton2);
     RadioButton1Change(RadioButton3);
   end;
end;

procedure Tfrmstartpos.Edit1Change(Sender: TObject);
begin
   FSQLQueryPeople.Filtered:=false;
   FSQLQueryPotomk.Filtered:=false;
   FSQLQueryPredki.Filtered:=false;
   FSQLQueryPeople.Filtered:=(CheckBox1.Checked)and
   ((utf8length(trim(Edit1.Text))>0){or(utf8length(trim(Edit2.Text))>0)or(utf8length(trim(Edit3.Text))>0)});
   FSQLQueryPotomk.Filtered:=(not CheckBox1.Checked)and(RadioButton1.Checked)and
   ((utf8length(trim(Edit1.Text))>0){or(utf8length(trim(Edit2.Text))>0)or(utf8length(trim(Edit3.Text))>0)});
   FSQLQueryPredki.Filtered:=(not CheckBox1.Checked)and(RadioButton2.Checked)and
   ((utf8length(trim(Edit1.Text))>0){or(utf8length(trim(Edit2.Text))>0)or(utf8length(trim(Edit3.Text))>0)});
   if Fflag then exit;
   if (not CheckBox1.Checked)and(RadioButton1.Checked) then
      RadioButton1Change(RadioButton1);
   if (not CheckBox1.Checked)and(RadioButton2.Checked) then
      RadioButton1Change(RadioButton2);
   if (CheckBox1.Checked) then
      CheckBox1Change(CheckBox1);
   Edit2.Enabled:=utf8length(trim(Edit1.Text))>0;
   if not Edit2.Enabled then edit2.Text:='';
end;

procedure Tfrmstartpos.FormShow(Sender: TObject);
begin
   if SQLQueryPotomk.IsEmpty then
   begin
     RadioButton1.Enabled:=false;
     RadioButton2.Checked:=true;
   end;
   if SQLQueryPredki.IsEmpty then
   begin
     RadioButton2.Enabled:=false;
     RadioButton3.Checked:=true;
   end;
   CheckBox1.Enabled:=RadioButton2.Enabled or RadioButton1.Enabled;
   StringGridPeople.Visible:=RadioButton2.Enabled or RadioButton1.Enabled;
   if StringGridPeople.Visible then StringGridPeople.SetFocus;
end;

procedure Tfrmstartpos.MenuItem2Click(Sender: TObject);
begin
  fwdb.ExportGEDCOM;
end;

procedure Tfrmstartpos.RadioButton1Change(Sender: TObject);
var
  tmp_int:integer;
begin
   //Edit1.Enabled:=not RadioButton3.Checked;
   edit1.Visible:=not RadioButton3.Checked;
   edit2.Visible:=not RadioButton3.Checked;
   label1.Visible:=not RadioButton3.Checked;
   //Edit1.ReadOnly:=RadioButton3.Checked;
   Fflag:=true;
   Edit1Change(Edit1);
   Fflag:=false;
  if  TRadioButton(Sender).Checked then
  case TRadioButton(Sender).Name of
  'RadioButton1':
    begin
      StringGridPeople.Clear;
      StringGridPeople.Visible:=true;
      StringGridPeople.RowCount:=1;
      if FSQLQueryPotomk.IsEmpty then
      begin
        //пишем что нет объектов для выбора
        exit;
      end;
      FSQLQueryPotomk.First;
      while not FSQLQueryPotomk.EOF do
        begin
          StringGridPeople.RowCount:=StringGridPeople.RowCount+1;
          StringGridPeople.Cells[0,StringGridPeople.RowCount-1]:=FSQLQueryPotomk.FieldByName('id').AsString;
          StringGridPeople.Cells[1,StringGridPeople.RowCount-1]:=FSQLQueryPotomk.FieldByName('fam').AsString;
          StringGridPeople.Cells[2,StringGridPeople.RowCount-1]:=FSQLQueryPotomk.FieldByName('nam').AsString;
          if FSQLQueryPotomk.FieldByName('otch').AsString='UNKNOWN' then StringGridPeople.Cells[3,StringGridPeople.RowCount-1]:='' else
          StringGridPeople.Cells[3,StringGridPeople.RowCount-1]:=FSQLQueryPotomk.FieldByName('otch').AsString;
          tmp_int:=strtoint(FSQLQueryPotomk.FieldByName('flag').AsString);
          if (tmp_int and 1)=1 then
             StringGridPeople.Cells[4,StringGridPeople.RowCount-1]:='данные требуют уточнения'
             else
                 StringGridPeople.Cells[4,StringGridPeople.RowCount-1]:='';
          FSQLQueryPotomk.Next;
        end;
      FVibor:=ViborTreePotomk;
    end;
  'RadioButton2':
    begin
      StringGridPeople.Clear;
      self.StringGridPeople.Visible:=true;
      self.StringGridPeople.RowCount:=1;
      if FSQLQueryPredki.IsEmpty then
      begin
        //пишем что нет объектов для выбора
        exit;
      end;
      FSQLQueryPredki.First;
      while not FSQLQueryPredki.EOF do
        begin
          StringGridPeople.RowCount:=StringGridPeople.RowCount+1;
          StringGridPeople.Cells[0,StringGridPeople.RowCount-1]:=FSQLQueryPredki.FieldByName('id').AsString;
          StringGridPeople.Cells[1,StringGridPeople.RowCount-1]:=FSQLQueryPredki.FieldByName('fam').AsString;
          StringGridPeople.Cells[2,StringGridPeople.RowCount-1]:=FSQLQueryPredki.FieldByName('nam').AsString;
          if FSQLQueryPredki.FieldByName('otch').AsString='UNKNOWN' then StringGridPeople.Cells[3,StringGridPeople.RowCount-1]:='' else
          StringGridPeople.Cells[3,StringGridPeople.RowCount-1]:=FSQLQueryPredki.FieldByName('otch').AsString;
          tmp_int:=strtoint(FSQLQueryPredki.FieldByName('flag').AsString);
          if (tmp_int and 1)=1 then
             StringGridPeople.Cells[4,StringGridPeople.RowCount-1]:='данные требуют уточнения'
             else
                 StringGridPeople.Cells[4,StringGridPeople.RowCount-1]:='';
          FSQLQueryPredki.Next;
        end;
      FVibor:=ViborTreePredki;
    end;
  'RadioButton3':
    begin
      StringGridPeople.Clear;
      StringGridPeople.RowCount:=1;
      StringGridPeople.Visible:=false;
      FVibor:=ViborTreeNew;
    end;
  end;
end;

procedure Tfrmstartpos.StringGridPeopleDblClick(Sender: TObject);
begin
  if StringGridPeople.RowCount>1 then Button1.Click;//Button1Click(Button1);
end;

procedure Tfrmstartpos.StringGridPeopleHeaderSized(Sender: TObject;
  IsColumn: Boolean; Index: Integer);
begin
      if Index=1 then
      begin
        Edit1.Width:=StringGridPeople.Columns.Items[1].Width;
        Edit2.Left:=Edit1.Left+Edit1.Width;
        Edit3.Left:=Edit2.Left+Edit2.Width;
        exit;
      end;
      if Index=2 then
      begin
        Edit2.Width:=StringGridPeople.Columns.Items[2].Width;
        Edit3.Left:=Edit2.Left+Edit2.Width;
        exit;
      end;
      Edit3.Width:=StringGridPeople.Columns.Items[3].Width;
end;

procedure Tfrmstartpos.SetSQLQueryPotomk(AValue: TSQLQuery);
var
  tmp_int:integer;
begin
   if AValue=nil then exit;
   FSQLQueryPotomk:=AValue;
   //DS:=TDataSource.Create(self);
   FSQLQueryPotomk.Open;
   if FSQLQueryPotomk.IsEmpty then
   begin
    //пишем что нет объектов для выбора
     //RadioButton1.Enabled:=FSQLQueryPotomk.IsEmpty;
     exit;
   end;  
   //Свяжем событие фильтрации с процедурой
   FSQLQueryPotomk.OnFilterRecord:=@MyFilterPotomk;
   FSQLQueryPotomk.First;
   while not FSQLQueryPotomk.EOF do
  begin
    StringGridPeople.RowCount:=StringGridPeople.RowCount+1;
    StringGridPeople.Cells[0,StringGridPeople.RowCount-1]:=FSQLQueryPotomk.FieldByName('id').AsString;
    StringGridPeople.Cells[1,StringGridPeople.RowCount-1]:=FSQLQueryPotomk.FieldByName('fam').AsString;
    StringGridPeople.Cells[2,StringGridPeople.RowCount-1]:=FSQLQueryPotomk.FieldByName('nam').AsString;
    if FSQLQueryPotomk.FieldByName('otch').AsString='UNKNOWN' then StringGridPeople.Cells[3,StringGridPeople.RowCount-1]:='' else
    StringGridPeople.Cells[3,StringGridPeople.RowCount-1]:=FSQLQueryPotomk.FieldByName('otch').AsString;
    tmp_int:=strtoint(FSQLQueryPotomk.FieldByName('flag').AsString);
          if (tmp_int and 1)=1 then
             StringGridPeople.Cells[4,StringGridPeople.RowCount-1]:='данные требуют уточнения'
             else
                 StringGridPeople.Cells[4,StringGridPeople.RowCount-1]:='';
    FSQLQueryPotomk.Next;
  end;
end;

function Tfrmstartpos.GetID: integer;
begin
   result:=-1;
   if not RadioButton3.Checked then
      result:=strtoint(StringGridPeople.Cells[0,StringGridPeople.Row]);
end;

procedure Tfrmstartpos.SetSQLQueryPeople(AValue: TSQLQuery);
begin
  if FSQLQueryPeople=AValue then Exit;
  FSQLQueryPeople:=AValue;
  //DS:=TDataSource.Create(self);
   FSQLQueryPeople.Open;
   if FSQLQueryPeople.IsEmpty then
   begin
    //пишем что нет объектов для выбора
     exit;
   end;
   //Свяжем событие фильтрации с процедурой
   FSQLQueryPeople.OnFilterRecord:=@MyFilterPeople;
end;

procedure Tfrmstartpos.SetSQLQueryPredki(AValue: TSQLQuery);
begin
   if AValue=nil then exit;
   FSQLQueryPredki:=AValue;
   //DS:=TDataSource.Create(self);
   FSQLQueryPredki.Open;
   if FSQLQueryPredki.IsEmpty then
   begin
    //пишем что нет объектов для выбора
     exit;
   end;
   //Свяжем событие фильтрации с процедурой
   FSQLQueryPredki.OnFilterRecord:=@MyFilterPredki;
end;

procedure Tfrmstartpos.MyFilterPeople(DataSet: TDataSet; var Accept: Boolean);
begin
  Accept:=((utf8pos(utf8lowercase(trim(Edit1.Text)),utf8lowercase(trim(dataset.FieldByName('fam').AsString)))>0)or
  (utf8pos(utf8lowercase(trim(Edit1.Text)),utf8lowercase(trim(dataset.FieldByName('nam').AsString)))>0)or
  (utf8pos(utf8lowercase(trim(Edit1.Text)),utf8lowercase(trim(dataset.FieldByName('otch').AsString)))>0)or
  ((utf8pos(utf8lowercase(trim(Edit1.Text)),'данные требуют уточнения')>0)and((strtoint(dataset.FieldByName('flag').AsString) and 1)=1)))and
  (((utf8pos(utf8lowercase(trim(Edit2.Text)),utf8lowercase(trim(dataset.FieldByName('fam').AsString)))>0)or
  (utf8pos(utf8lowercase(trim(Edit2.Text)),utf8lowercase(trim(dataset.FieldByName('nam').AsString)))>0)or
  (utf8pos(utf8lowercase(trim(Edit2.Text)),utf8lowercase(trim(dataset.FieldByName('otch').AsString)))>0))or
  (utf8length(trim(Edit2.Text))=0)or
  ((utf8pos(utf8lowercase(trim(Edit2.Text)),'данные требуют уточнения')>0)and((strtoint(dataset.FieldByName('flag').AsString) and 1)=1)));
end;

procedure Tfrmstartpos.MyFilterPotomk(DataSet: TDataSet; var Accept: Boolean);
begin
  Accept:=((utf8pos(utf8lowercase(trim(Edit1.Text)),utf8lowercase(trim(dataset.FieldByName('fam').AsString)))>0)or
  (utf8pos(utf8lowercase(trim(Edit1.Text)),utf8lowercase(trim(dataset.FieldByName('nam').AsString)))>0)or
  (utf8pos(utf8lowercase(trim(Edit1.Text)),utf8lowercase(trim(dataset.FieldByName('otch').AsString)))>0)or
  ((utf8pos(utf8lowercase(trim(Edit1.Text)),'данные требуют уточнения')>0)and((strtoint(dataset.FieldByName('flag').AsString) and 1)=1)))and
  (((utf8pos(utf8lowercase(trim(Edit2.Text)),utf8lowercase(trim(dataset.FieldByName('fam').AsString)))>0)or
  (utf8pos(utf8lowercase(trim(Edit2.Text)),utf8lowercase(trim(dataset.FieldByName('nam').AsString)))>0)or
  (utf8pos(utf8lowercase(trim(Edit2.Text)),utf8lowercase(trim(dataset.FieldByName('otch').AsString)))>0))or
  (utf8length(trim(Edit2.Text))=0)or
  ((utf8pos(utf8lowercase(trim(Edit2.Text)),'данные требуют уточнения')>0)and((strtoint(dataset.FieldByName('flag').AsString) and 1)=1)));
end;

procedure Tfrmstartpos.MyFilterPredki(DataSet: TDataSet; var Accept: Boolean);
begin
  Accept:=((utf8pos(utf8lowercase(trim(Edit1.Text)),utf8lowercase(trim(dataset.FieldByName('fam').AsString)))>0)or
  (utf8pos(utf8lowercase(trim(Edit1.Text)),utf8lowercase(trim(dataset.FieldByName('nam').AsString)))>0)or
  (utf8pos(utf8lowercase(trim(Edit1.Text)),utf8lowercase(trim(dataset.FieldByName('otch').AsString)))>0)or
  ((utf8pos(utf8lowercase(trim(Edit1.Text)),'данные требуют уточнения')>0)and((strtoint(dataset.FieldByName('flag').AsString) and 1)=1)))and
  (((utf8pos(utf8lowercase(trim(Edit2.Text)),utf8lowercase(trim(dataset.FieldByName('fam').AsString)))>0)or
  (utf8pos(utf8lowercase(trim(Edit2.Text)),utf8lowercase(trim(dataset.FieldByName('nam').AsString)))>0)or
  (utf8pos(utf8lowercase(trim(Edit2.Text)),utf8lowercase(trim(dataset.FieldByName('otch').AsString)))>0))or
  (utf8length(trim(Edit2.Text))=0)or
  ((utf8pos(utf8lowercase(trim(Edit2.Text)),'данные требуют уточнения')>0)and((strtoint(dataset.FieldByName('flag').AsString) and 1)=1)));
end;

end.

