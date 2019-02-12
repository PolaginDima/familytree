unit startmodule;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Menus, ComCtrls, CreateTree,
  mysqlite3conn, lazutf8, Types;

type

  { TForm1 }


  TForm1 = class(TForm)
    ComboBox1: TComboBox;
    Label1: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    Panel2: TPanel;
    ProgressBar1: TProgressBar;
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    const helptxt1='разработчик: Полагин Д.А.'+lineending+
          'ЯП:Lazarus'+lineending+
          'БД:SQLite'+lineending+
          'версия программы: ';
    const helptxt2=lineending+'лиценция: FreeWare'{+lineending+'F9 - настройки программы'};
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseLeave(Sender: TObject);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormShow(Sender: TObject);

    procedure Timer1Timer(Sender: TObject);
  private
    Fflag:boolean;
    rodTree:TCreateTree;
    pathdb:string;
    procedure ProgressBar(value:integer;capt:string);
    procedure SetColorFrm(ColorFrm:TColor);
    procedure Closefrm;
    procedure ChangePercent(inc:byte);
  public
  end;

var
  Form1: TForm1;

implementation
uses Settings;
{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  i:integer;
begin
  pathdb:=ExtractFilePath(Application.ExeName)+{directoryseparator+}'rod.db3';
  ComboBox1.Clear;
  //ComboBox1.Items.Add(inttostr(4*5)+'%');
  for i:=1 to 30 do ComboBox1.Items.Add(inttostr(i*5)+'%');
  ComboBox1.ItemIndex:=19;
  //Color:=TColor($00DD00);
  Fflag:=true;
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
var
  t:string;
begin
  if Fflag then
  begin
    Fflag:=false;
    t:=TComboBox(Sender).Text;//TComboBox(Sender).Items.Strings[TComboBox(Sender).ItemIndex];
    t:=utf8copy(t,1,utf8pos('%',t)-1);
    rodTree.PercentM:=strtoint(t);
    Fflag:=true;
  end;
end;

{procedure TForm1.Button1Click(Sender: TObject);
begin
  rodtree.VertScrollBar.Position:=3000;
  rodtree.VertScrollBar.Position:=rodtree.VertScrollBar.Position div 2;
end; }

procedure TForm1.ComboBox1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=112 then//F1
     messagedlg('справка',helptxt1+rodtree.versionBD+helptxt2+lineending+
     'в базе человек: '+inttostr(rodtree.countPeople) ,mtInformation,[mbOK],'');
  if key=123 then//F12
     messagedlg('настройки базы',rodTree.getparametrbase ,mtInformation,[mbOK],'');
  if key=120 then//F9
     begin
       rodtree.ClearSelection;
       frmSettings:=TfrmSettings.Create(self);
       frmSettings.tree:=rodtree;
       frmSettings.ShowModal;
       FreeAndNil(frmSettings);
     end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  rodtree.Free;
end;

procedure TForm1.FormMouseLeave(Sender: TObject);
begin

end;

procedure TForm1.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  {if ssCtrl in Shift then
     begin
       if ComboBox1.ItemIndex=0 then exit;
       Combobox1.ItemIndex:=Combobox1.ItemIndex-1;
       ComboBox1Change(Combobox1);
     end; }
end;

procedure TForm1.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TForm1.FormShow(Sender: TObject);
begin
  Timer1.Enabled:=true;
  //showmessage(floattostr(strtodate('01.01.1700')));
end;

procedure TForm1.ProgressBar(value: integer; capt: string);
begin
  ProgressBar1.Position:=value;
  if value mod 5 =0 then  application.ProcessMessages;
  if capt=StatusBar1.Panels.Items[0].Text then exit;
  if (value=0)and(utf8length(capt)=0) then
     StatusBar1.Panels.Items[0].Text:=''
     else
       StatusBar1.Panels.Items[0].Text:=capt;
end;

procedure TForm1.SetColorFrm(ColorFrm: TColor);
begin
  Color:=ColorFrm;
  ComboBox1.Color:=ColorFrm;
  StatusBar1.Color:=ColorFrm;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled:=false;
  try
    rodtree:=TCreateTree.Create(pathdb,self);
  except
     on E: Exception do
               begin
                 messagedlg('ошибка',e.Message,mtError,[mbok],0);
                 exit;
               end;
  end;

  rodtree.onFrmClose:=@Closefrm;
  rodtree.OnProgressEvent:=@ProgressBar;
  rodtree.OnColorFrmEvent:=@SetColorFrm;
  rodtree.OnKeyUp:=@ComboBox1KeyUp;
  rodtree.onChangePercent:=@ChangePercent;
  rodTree.Parent:=self;
  rodTree.Align:=alClient;
  rodtree.AutoSize:=true;
  //Выведем список деревьев или предложим начать новое дерево
  rodtree.Execute;
  if rodtree.Closefrm then
  begin
    close;
    exit;
  end;
  rodtree.HorzScrollBar.Position:=10000000;
  rodtree.VertScrollBar.Position:=10000000;
  rodtree.HorzScrollBar.Position:=round(rodtree.HorzScrollBar.Position*rodtree.PositionX);
  rodtree.VertScrollBar.Position:=round(rodtree.VertScrollBar.Position*rodtree.PositionY);
end;

{procedure TForm1.Timer2Timer(Sender: TObject);
var
  t:string;
begin
  Timer2.Enabled:=false;
  t:=ComboBox1.Text;
  //t:=TComboBox(Sender).Items.Strings[TComboBox(Sender).ItemIndex];
  t:=utf8copy(t,1,utf8pos('%',t)-1);
  rodTree.PercentM:=strtoint(t);
end;    }

procedure TForm1.Closefrm;
begin
  Close;
end;

procedure TForm1.ChangePercent(inc: byte);
begin
  if inc>1 then
  begin
       if ComboBox1.ItemIndex=Combobox1.Items.Count-1 then exit;
       Combobox1.ItemIndex:=Combobox1.ItemIndex+1;
       ComboBox1Change(Combobox1);
  end else
  begin
    if ComboBox1.ItemIndex=0 then exit;
    Combobox1.ItemIndex:=Combobox1.ItemIndex-1;
    ComboBox1Change(Combobox1);
  end;
end;

end.

