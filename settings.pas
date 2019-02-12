unit Settings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, MaskEdit, Buttons, ExtCtrls, CreateTree;

type

  { TfrmSettings }

  TfrmSettings = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    MaskEdit1: TMaskEdit;
    MaskEdit2: TMaskEdit;
    MaskEdit3: TMaskEdit;
    Shape_color_BackGround: TShape;
    Shape_color_Caption_Node: TShape;
    Shape_color_Foto: TShape;
    Shape_color_Bevel_Foto: TShape;
    Shape_color_frm: TShape;
    Shape_color_ligth_Edge: TShape;
    Shape_color_Edge: TShape;
    UpDown1: TUpDown;
    UpDown2: TUpDown;
    UpDown3: TUpDown;
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure CheckBox2Change(Sender: TObject);
    procedure CheckBox3Change(Sender: TObject);
    procedure CheckBox4Change(Sender: TObject);
    procedure CheckBox5Change(Sender: TObject);
    procedure CheckBox6Change(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MaskEdit1Change(Sender: TObject);
    procedure MaskEdit2Change(Sender: TObject);
    procedure MaskEdit3Change(Sender: TObject);
    procedure Shape_color_frmMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    Ftree: TCreateTree;

  public
    property tree:TCreateTree read Ftree write Ftree;
  end;

var
  frmSettings: TfrmSettings;

implementation

{$R *.lfm}

{ TfrmSettings }

procedure TfrmSettings.CheckBox2Change(Sender: TObject);
begin
  tree.view_potomk:=CheckBox2.Checked;
  MaskEdit1.Enabled:=CheckBox2.Checked;
end;

procedure TfrmSettings.Button2Click(Sender: TObject);
begin
  Shape_color_frm.Brush.Color:=tree.DefaultColor_frm;
end;

procedure TfrmSettings.Button3Click(Sender: TObject);
begin
  Shape_color_ligth_Edge.Brush.Color:=tree.Defaultcolor_ligth_Edge;
end;

procedure TfrmSettings.Button4Click(Sender: TObject);
begin
  Shape_color_Edge.Brush.Color:=tree.Defaultcolor_Edge;
end;

procedure TfrmSettings.Button5Click(Sender: TObject);
begin
  Shape_color_BackGround.Brush.Color:=tree.Defaultcolor_BackGround;
end;

procedure TfrmSettings.Button6Click(Sender: TObject);
begin
  Shape_color_Foto.Brush.Color:=tree.Defaultcolor_Foto;
end;

procedure TfrmSettings.Button7Click(Sender: TObject);
begin
  Shape_color_Bevel_Foto.Brush.Color:=tree.Defaultcolor_Bevel_Foto;
end;

procedure TfrmSettings.Button8Click(Sender: TObject);
begin
  Shape_color_Caption_Node.Brush.Color:=tree.Defaultcolor_Caption_Node;
end;

procedure TfrmSettings.CheckBox3Change(Sender: TObject);
begin
  tree.view_predk:=CheckBox3.Checked;
  MaskEdit2.Enabled:=CheckBox3.Checked;
end;

procedure TfrmSettings.CheckBox4Change(Sender: TObject);
begin
  tree.view_birthday:=CheckBox4.Checked;
  CheckBox5.Enabled:=CheckBox4.Checked;
end;

procedure TfrmSettings.CheckBox5Change(Sender: TObject);
begin
  tree.view_birthday_skoro:=CheckBox5.Checked;
  MaskEdit3.Enabled:=CheckBox5.Checked;
end;

procedure TfrmSettings.CheckBox6Change(Sender: TObject);
begin
  tree.beautiful_tree:=CheckBox6.Checked;
end;

procedure TfrmSettings.FormShow(Sender: TObject);
begin
  if tree=nil then
  begin
    close;
    exit;
  end;
  CheckBox2.Checked:=tree.view_potomk;
  CheckBox3.Checked:=tree.view_predk;
  CheckBox4.Checked:=tree.view_birthday;
  CheckBox5.Checked:=tree.view_birthday_skoro;
  CheckBox6.Checked:=tree.beautiful_tree;
  MaskEdit1.Text:=inttostr(tree.count_view_potomk);
  MaskEdit2.Text:=inttostr(tree.count_view_predk);
  MaskEdit3.Text:=inttostr(tree.count_view_birthday_skoro);
  Shape_color_frm.Brush.Color:=tree.Color_frm;
  Shape_color_ligth_Edge.Brush.Color:=tree.color_ligth_Edge;
  Shape_color_Edge.Brush.Color:=tree.color_Edge;
  Shape_color_BackGround.Brush.Color:=tree.color_BackGround;
  Shape_color_Foto.Brush.Color:=tree.color_Foto;
  Shape_color_Bevel_Foto.Brush.Color:=tree.color_Bevel_Foto;
  Shape_color_Caption_Node.Brush.Color:=tree.color_CaptionNode;
end;

procedure TfrmSettings.MaskEdit1Change(Sender: TObject);
begin
  tree.count_view_potomk:=UpDown1.Position;
end;

procedure TfrmSettings.MaskEdit2Change(Sender: TObject);
begin
  tree.count_view_predk:=UpDown2.Position;
end;

procedure TfrmSettings.MaskEdit3Change(Sender: TObject);
begin
  tree.count_view_birthday_skoro:=UpDown3.Position;
end;

procedure TfrmSettings.Shape_color_frmMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
   cd:TColorDialog;
begin
  cd:=TColorDialog.Create(self);
  case (Sender as TShape).Name of
  'Shape_color_frm':
    begin
      if cd.Execute then
         Shape_color_frm.Brush.Color:=cd.Color;
         tree.Color_frm:=Shape_color_frm.Brush.Color;
    end;
    'Shape_color_ligth_Edge':
    begin
      if cd.Execute then
         Shape_color_ligth_Edge.Brush.Color:=cd.Color;
         tree.color_ligth_Edge:=Shape_color_ligth_Edge.Brush.Color;
    end;
    'Shape_color_Edge':
    begin
      if cd.Execute then
         Shape_color_Edge.Brush.Color:=cd.Color;
         tree.color_Edge:=Shape_color_Edge.Brush.Color;
    end;
    'Shape_color_BackGround':
    begin
      if cd.Execute then
         Shape_color_BackGround.Brush.Color:=cd.Color;
         tree.color_BackGround:=Shape_color_BackGround.Brush.Color;
    end;
    'Shape_color_Foto':
    begin
      if cd.Execute then
         Shape_color_Foto.Brush.Color:=cd.Color;
         tree.color_Foto:=Shape_color_Foto.Brush.Color;
    end;
    'Shape_color_Bevel_Foto':
    begin
      if cd.Execute then
         Shape_color_Bevel_Foto.Brush.Color:=cd.Color;
         tree.color_Bevel_Foto:=Shape_color_Bevel_Foto.Brush.Color;
    end;
    'Shape_color_Caption_Node':
    begin
      if cd.Execute then
         if (cd.Color=clBlack)or(cd.Color=TColor($010101)) then
            cd.Color:=TCOlor($020202);
         Shape_color_Caption_Node.Brush.Color:=cd.Color;
         tree.color_CaptionNode:=Shape_color_Caption_Node.Brush.Color;
    end;
  end;
  FreeAndNil(cd);
end;

end.

