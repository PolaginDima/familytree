unit startmodul;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Menus, EditBtn, Buttons, ComCtrls, CreateTree, sqldb,
  mysqlite3conn, lazutf8;

type

  { TForm1 }


  TForm1 = class(TForm)
    ComboBox1: TComboBox;
    Label1: TLabel;
    Panel2: TPanel;
    ProgressBar1: TProgressBar;
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    const helptxt1='разработчик: Полагин Д.А.'+lineending+
          'ЯП:Lazarus'+lineending+
          'БД:SQLite'+lineending+
          'версия БД: ';
    const helptxt2=lineending+'лиценция: FreeWare';
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ProgressBar(value:integer;capt:string);
    procedure Timer1Timer(Sender: TObject);
  private
    rodTree:TCreateTree;
    pathdb:string;
    procedure Closefrm;
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  i:integer;
begin
  pathdb:=ExtractFilePath(Application.ExeName)+directoryseparator+'rod.db3';
  ComboBox1.Clear;
  for i:=7 to 30 do ComboBox1.Items.Add(inttostr(i*5)+'%');
  ComboBox1.ItemIndex:=13;
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
var
  t:string;
begin
  t:=TComboBox(Sender).Items.Strings[TComboBox(Sender).ItemIndex];
  t:=utf8copy(t,1,utf8pos('%',t)-1);
  rodTree.PercentM:=strtoint(t);
end;

procedure TForm1.ComboBox1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=112 then
     messagedlg('справка',helptxt1+rodtree.versionBD+helptxt2,mtInformation,[mbOK],'');
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  rodtree.Free;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  {try
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
  //Выведем список деревьев или предложим начать новое дерево
  rodtree.Execute;
  if rodtree.Closefrm then
  begin
    close;
    exit;
  end;
  rodTree.Parent:=self;
  rodTree.Align:=alClient;
  rodtree.AutoSize:=true;}
  //rodtree.CaptionTree:='Древо жизни';
  //rodtree.DrawTree;
  Timer1.Enabled:=true;
end;

procedure TForm1.ProgressBar(value: integer; capt: string);
begin
  ProgressBar1.Position:=value;
  if value mod 5 =0 then  application.ProcessMessages;
  if capt=StatusBar1.Panels.Items[0].Text then exit;
  if (value=0) then StatusBar1.Panels.Items[0].Text:='' else StatusBar1.Panels.Items[0].Text:=capt;
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
  //Выведем список деревьев или предложим начать новое дерево
  rodtree.Execute;
  if rodtree.Closefrm then
  begin
    close;
    exit;
  end;
  rodTree.Parent:=self;
  rodTree.Align:=alClient;
  rodtree.AutoSize:=true;

end;

procedure TForm1.Closefrm;
begin
  Close;
end;

end.

