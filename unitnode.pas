unit unitNode;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqlite3conn, sqldb, FileUtil, Forms, Controls,
  Graphics, Dialogs, StdCtrls, Buttons, DbCtrls, ExtCtrls, lazutf8,
  DateTimePicker, workdb, menus, ComCtrls, ActnList, dateutils, FPReadJPEG;

type

  { TmyPanet }

  TmyPanel=class(TPanel)
    private
      FdopInf: string;
    public
      property dopInf:string read FdopInf write FdopInf;
  end;

  { TfrmNode }

  TfrmNode = class(TForm)
    Aadding: TAction;
    AShow: TAction;
    ActionList1: TActionList;
    ADeleting: TAction;
    AEditing: TAction;
    AExit: TAction;
    AOpen: TAction;
    APrinting: TAction;
    ARole: TAction;
    ASave: TAction;
    AShowpwd: TAction;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    CheckBoxUtochn: TCheckBox;
    dtp_dtb: TDateTimePicker;
    dtp_dtd: TDateTimePicker;
    EditdevFam: TEdit;
    EditFam: TEdit;
    EditNam: TEdit;
    EditOtch: TEdit;
    GroupBox1: TGroupBox;
    ImageFoto: TImage;
    ImageList1: TImageList;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    LabeldevFam: TLabel;
    Memo1: TMemo;
    Memodopinfo: TMemo;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    RadioButtonMen: TRadioButton;
    RadioButtonWomen: TRadioButton;
    ScrollBox1: TScrollBox;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    procedure AaddingExecute(Sender: TObject);
    procedure ADeletingExecute(Sender: TObject);
    procedure AShowExecute(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure dtp_dtbChange(Sender: TObject);
    procedure EditFamKeyPress(Sender: TObject; var Key: char);
    procedure EditNamKeyPress(Sender: TObject; var Key: char);
    procedure EditOtchKeyPress(Sender: TObject; var Key: char);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure ImageFotoDblClick(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
    procedure RadioButtonWomenChange(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
  private
    FSelectingFoto:integer;
    FFotos:TList;
    Fexit:boolean;
    FPicIsModified:boolean;
    FIsModified:boolean;
    FDelPic:Boolean;
    FIDPeople: integer;
    Fnew: boolean;
    FPredok_Potomok: integer;
    FPeople:TPeople;
    PopupMenu1: TPopupMenu;
    function GetIsModified: boolean;
    function LoadFoto:TJpegImage;
    function CheckModifiedTextFoto:boolean;
    procedure Setnew(AValue: boolean);
    procedure SetPredok_Potomok(AValue: integer);
    procedure MenuItemClick(Sender: TObject);
    procedure addFOTO(MemoryStream:TmyMemoryStream;Index:integer;select:boolean=false);
    procedure LigthSelect(Index:integer);
    const leftwidth = 10;
    const widthFotos = 250;
    const heightFotos = 250;
    const beetweenFotos = 5;
    const topheight = 10;
    const ColorSelect = clHighLight;{clBlue}//Цвет выделения
    const CaptionMainSheet = 'Основное';
  public
    { public declarations }
    //property people:Tpeople read Fpeople write Fpeople;
    //constructor Create(TheOwner: TComponent;); override;
    property IDPeople:integer {read GetIDPeople} write FIDPeople default -1;
    property new:boolean read Fnew write Setnew default false;
    property Predok_Potomok:integer read FPredok_Potomok write SetPredok_Potomok default -1;
    property People:TPeople read FPeople write FPeople;
    property IsModified:boolean read FIsModified;
  end;

var
  frmNode: TfrmNode;

implementation
 //uses workdb;
{$R *.lfm}
uses viewfoto;
{ TfrmNode }

procedure TfrmNode.FormCreate(Sender: TObject);
var
  mi:TMenuItem;
begin
  Fexit:=true;
  FIsModified:=false;
  FPicIsModified:=false;
  FDelPic:=false;

  Memo1.Enabled:=False;

  FFotos:=TList.Create;
  //GroupBox1.Color:=Color;
  PopupMenu1:=TPopupmenu.Create(self);

  mi:=TMenuItem.Create(PopupMenu1);
  Popupmenu1.Items.Add(mi);
  mi.Caption:='Загрузить изображение';
  mi.Name:='loadjpg';
  mi.OnClick:=@self.MenuItemClick;

  mi:=TMenuItem.Create(PopupMenu1);
  Popupmenu1.Items.Add(mi);
  mi.Caption:='Сохранить изображение';
  mi.Name:='savejpg';
  mi.OnClick:=@self.MenuItemClick;

  mi:=TMenuItem.Create(PopupMenu1);
  Popupmenu1.Items.Add(mi);
  mi.Caption:='Удалить изображение';
  mi.Name:='deletejpg';
  mi.OnClick:=@self.MenuItemClick;
  self.ImageFoto.PopupMenu:=Popupmenu1;

  PopupMenu1.Items.Items[1].Visible:=false;
  PopupMenu1.Items.Items[2].Visible:=false;

  PageControl1.Pages[0].Caption:=CaptionMainSheet;
end;

procedure TfrmNode.FormDestroy(Sender: TObject);
var
  i,ii:integer;
begin
  if FPeople<>nil then FPeople.Free;
  if PopupMenu1<>nil then Popupmenu1.Free;
  //Удалим созданное нами - вкладка фото
  for i:=0 to FFotos.Count-1 do
  begin
       for ii:=0 to TmyPanel(FFotos.Items[i]).ControlCount-1 do
           if (TmyPanel(FFotos.Items[i]).Controls[ii] is TImage) then
               (TmyPanel(FFotos.Items[i]).Controls[ii] as TImage).Free;
       TmyPanel(FFotos.Items[i]).Free;
  end;
  FreeAndNil(FFotos);
end;

procedure TfrmNode.FormShow(Sender: TObject);
var
  jpg:TJpegImage;
  i:integer;
  //fotos:TFotos;
  //ms:TMemoryStream;
begin
  if not new then
  begin
       Caption:='редактирование листа дерева';
       BitBtn1.Enabled:=true;
       EditFam.Text:=people.fam;
       EditNam.Text:=people.nam;
       EditOtch.Text:=people.otch;
       Memodopinfo.Text:=people.dopinfo;
       //showmessage(people.dopinfo);
       if (people.flag and 1)=1 then
          CheckBoxUtochn.Checked:=true
          else
            CheckBoxUtochn.Checked:=false;
       RadioButtonWomen.Checked:=boolean(people.sex);
       RadioButtonMen.Checked:=not RadioButtonWomen.Checked;
       if radiobuttonwomen.Checked then EditdevFam.Text:=people.firstFam;
       dtp_dtb.Date:=people.dateBorn;
       dtp_dtd.Date:=people.dateDeath;
       //showmessage(datetostr(people.dateDeath)+lineending+       datetostr(dtp_dtd.Date));
       if (not (dtp_dtb.Date>1.7E307))
       then
       begin
            //посчитаем возраст
            if (dtp_dtd.Date>1.7E307) then
               Label9.Caption:='возраст(лет) '+inttostr(yearsBetween(now(),dtp_dtb.Date))
            else
              Label9.Caption:='сейчас было бы (лет) '+inttostr(yearsBetween(now(),dtp_dtb.Date));
       end;
       if (not (dtp_dtd.Date>1.7E307))and
       (not (dtp_dtb.Date>1.7E307))
       then
       begin
            if dtp_dtd.Date>dtp_dtb.Date then
               //посчитаем в каком возрасте наступила смерть
               Label10.Caption:='умер(ла) в возраст(лет) '+inttostr(yearsBetween(dtp_dtd.Date,dtp_dtb.Date));
       end;
       //Если есть фото-аватар, то выведем на экран
       if people.foto<>nil then
       begin
            jpg:=TJpegImage.Create;
            {ms:=TMemoryStream.Create;
            ms:=people.foto; }
            people.foto.Seek(0, soBeginning);
            jpg.LoadFromStream(people.foto);
            //ms.Free;
            ImageFoto.Picture.Jpeg.Assign(jpg);
            jpg.Free;
            PopupMenu1.Items.Items[1].Visible:=true;
            PopupMenu1.Items.Items[2].Visible:=true;
            Panel1.Caption:='';
            ImageFoto.Hint:='щелкните правой кнопкой мыши для добавления/сохранения/удаления фото';
       end;
       //Если есть фотки, то добавим их в scrollbox
       if people.FotoInPeople.Count>0 then
       begin
            for i:=0 to people.FotoInPeople.Count-1 do
            begin
                 if i=0 then
                    addFOTO(people.FotoInPeople.Items[i],i,true)
                 else
                     addFOTO(people.FotoInPeople.Items[i],i);
            end;
       end;
  end else
  begin
       EditFam.Text:=FPeople.fam;
       RadioButtonWomen.Checked:=true;
       EditdevFam.Text:=FPeople.fam;
  end;
end;

procedure TfrmNode.Image1Click(Sender: TObject);
begin
  LigthSelect(TmyPanel(FFotos.Items[FFotos.IndexOf((Sender as TImage).Parent)]).Tag);
end;

procedure TfrmNode.ImageFotoDblClick(Sender: TObject);
var
//  od:topendialog;
  jpg:TJpegImage;
{  pct:TPicture;
  w,h:longint;
  //r:TRect;
const
  maxWidth = 1024;//1280;//1024;800;
  maxHeight = 768;//720;//768;600  }
begin
  {
  //окно выбора фото
  od:=topendialog.Create(self.Owner);
  od.Filter:='изображение|*.jpg;*.gif;*.jpeg;*.bmp;*.png;*.JPG;*.JPEG;*.BMP;*.PNG';
  if not  od.Execute then exit;
  //fname:=ExtractFileName(od.FileName);
  //загрузим выбранное фото
  pct:=TPicture.Create;
  pct.LoadFromFile(od.FileName);
  od.Free;

  //преобразуем и сожмем выбранное фото
  w:=pct.Graphic.Width;
  h:=pct.Graphic.Height;
  jpg:=TJpegImage.Create;
  if w>h then
  begin
  if (w/h)<=maxWidth/maxHeight then
  begin
       if h>maxHeight then
       begin
            w:=round(maxHeight*(w/h));
            h:=maxHeight;
       end;
  end else
  begin
     if w>maxWidth then
     begin
          h:=round(maxWidth*(h/w));
          w:=maxWidth;
     end;
  end;
  end else
  begin
     if (h/w)<=maxWidth/maxHeight then
  begin
       if w>maxHeight then
       begin
            h:=round(maxWidth*(h/w));
            w:=maxWidth;
       end;
  end else
  begin
     if h>maxWidth then
     begin
          w:=round(maxHeight*(w/h));
          h:=maxHeight;
     end;
  end;
  end;
  jpg.Width:=w;
  jpg.Height:=h;
  jpg.CompressionQuality:=100;
  jpg.Performance:=jpBestQuality;
  jpg.Canvas.StretchDraw(rect(0,0,jpg.Width,jpg.Height),pct.Graphic);
  //сохраним в нужное место сжатое фото
  //jpg.SaveToFile('???');
  }
  jpg:=LoadFoto;
  if jpg=nil then exit;
  ImageFoto.Picture.Jpeg.Assign(jpg);
  //FreeAndNil(pct);
  FreeAndNil(jpg);
  FPicIsModified:=true;
  FDelPic:=false;
  PopupMenu1.Items.Items[1].Visible:=true;
  PopupMenu1.Items.Items[2].Visible:=true;
  Panel1.Caption:='';
  ImageFoto.Hint:='щелкните правой кнопкой мыши для добавления/сохранения/удаления фото';
end;

procedure TfrmNode.Memo1Change(Sender: TObject);
begin
  TmyPanel(FFotos.Items[FSelectingFoto]).dopInf:=Memo1.Text;
end;

procedure TfrmNode.RadioButtonWomenChange(Sender: TObject);
begin
  if TRadioButton(Sender).Checked then
  begin
    LabeldevFam.Visible:=true;
    EditdevFam.Visible:=true;
  end else
  begin
    LabeldevFam.Visible:=false;
    EditdevFam.Visible:=false;
  end;
end;

procedure TfrmNode.SpeedButton1Click(Sender: TObject);
begin
  dtp_dtb.Date:=1.7E308;
end;

procedure TfrmNode.SpeedButton2Click(Sender: TObject);
begin
  dtp_dtd.Date:=1.7E308;
end;

procedure TfrmNode.BitBtn1Click(Sender: TObject);
var
  ms:TMemoryStream;
begin
  //Проверим на корректность введенные данные и сохраним
  if (not new)and(not GetIsModified) then exit; //Если редиктирование и ничего не менялось, то выход
  //сохраняем
  if FPeople=nil then
     begin
          FPeople:=TPeople.Create;
          FPeople.flag:=0;
     end;
  try
                 if utf8copy(EditFam.Text,1,1)<>utf8uppercase(utf8copy(EditFam.Text,1,1)) then
                 EditFam.Text:=utf8uppercase(utf8copy(EditFam.Text,1,1))+utf8copy(EditFam.Text,2,utf8length(EditFam.Text)-1);
                 if utf8copy(EditNam.Text,1,1)<>utf8uppercase(utf8copy(EditNam.Text,1,1)) then
                 EditNam.Text:=utf8uppercase(utf8copy(EditNam.Text,1,1))+utf8copy(EditNam.Text,2,utf8length(EditNam.Text)-1);
                 if (utf8length(EditOtch.Text)>1) and (utf8copy(EditOtch.Text,1,1)<>utf8uppercase(utf8copy(EditOtch.Text,1,1))) then
                 EditOtch.Text:=utf8uppercase(utf8copy(EditOtch.Text,1,1))+utf8copy(EditOtch.Text,2,utf8length(EditOtch.Text)-1);
                 if utf8copy(EditdevFam.Text,1,1)<>utf8uppercase(utf8copy(EditdevFam.Text,1,1)) then
                 EditdevFam.Text:=utf8uppercase(utf8copy(EditdevFam.Text,1,1))+utf8copy(EditdevFam.Text,2,utf8length(EditdevFam.Text)-1);
                 FPeople.fam:=EditFam.Text;
                 FPeople.nam:=EditNam.Text;
                 if RadioButtonWomen.Checked then FPeople.firstFam:=EditdevFam.Text else FPeople.firstFam:='';
                 FPeople.otch:=EditOtch.Text;
                 if dtp_dtb.Date>1.7E307 then
                    FPeople.dateBorn:=1.7E308 else
                      FPeople.dateBorn:=dtp_dtb.Date;
                 if dtp_dtd.Date>1.7E307 then
                    FPeople.dateDeath:=1.7E308 else
                      FPeople.dateDeath:=dtp_dtd.Date;
                 //showmessage(datetostr(people.dateDeath));
                 FPeople.Death:=not (dtp_dtd.Date>1.7E307);
                 FPeople.sex:=integer(not RadioButtonMen.Checked);
                 FPeople.flag:={FPeople.flag or }integer(CheckBoxUtochn.Checked);
                 FPeople.predok_potomok:=Predok_Potomok;
                 if (not FDelPic) and FPicIsModified then
                 begin
                   ms:=TMemoryStream.Create;
                   ImageFoto.Picture.Jpeg.SaveToStream(ms);
                   FPeople.foto:=ms;
                   //ms.Free;
                 end;
                 FPeople.dopinfo:=Memodopinfo.Text;
  except
    on E: Exception do
               begin
                 //Выводим сообщение и устанавливаем флаг запрещающий закрытие окна
                 messagedlg('ошибка создания',E.Message,mtError,[mbOK],0);
                 Fexit:=false;
               end;
  end;
end;

procedure TfrmNode.AaddingExecute(Sender: TObject);
var
  jpg:TJpegImage;
  msf:TmyMemoryStream;
  Index:integer;
begin
  jpg:=LoadFoto;
  if jpg=nil then exit;
  msf:=TmyMemoryStream.Create;
  jpg.SaveToStream(msf);
  Index:=FPeople.FotoInPeople.Add(msf);
  addFOTO(msf,Index);
  FPeople.fotosIsModified:=true;
  LigthSelect(TmyPanel(FFotos.Items[FFotos.Count-1]).Tag);
  //freeAndNil(jpg);
end;

procedure TfrmNode.ADeletingExecute(Sender: TObject);
var
  i,ii:integer;
  FSelectIndex:integer;
begin
  if FFotos.Count<=0 then exit;

  //FPeople.FotoInPeople.Items[FSelectIndex].Deleting:=true;
  for i:=0 to FFotos.Count-1 do
  begin
    if TmyPanel(FFotos.Items[i]).Color=ColorSelect then
    begin
       FSelectIndex:=TmyPanel(FFotos.Items[i]).Tag;
       if FPeople.ID_Avatar=FPeople.FotoInPeople.Items[FselectIndex].ID_Foto then
       begin
            QuestionDlg('Предупреждение', 'Эту фотографию нельзя удалить пока она используется как аватар.'+lineending
            +'На вкладке '+CaptionMainSheet+' удалите аватар.'+lineending+
            'После этого можно удалить фотографию.', mtInformation, [mrOK,'Ок','isdefault'],'');
            exit;
       end;
       FPeople.FotoInPeople.Items[TmyPanel(FFotos.Items[i]).Tag].Deleting:=true;
       for ii:=0 to TmyPanel(FFotos.Items[i]).ComponentCount-1 do
       begin
            TmyPanel(FFotos.Items[i]).Components[ii].Free;
       end;
       TmyPanel(FFotos.Items[i]).Free;
       FFotos.Delete(i);
       FPeople.fotosIsModified:=true;
       break;
    end;
  end;

  //Пересчитаем положение фоток
  for i:=0 to FFotos.Count-1 do
  begin
    TmyPanel(FFotos.Items[i]).Left:=leftwidth+(i)*(WidthFotos+beetweenFotos);
  end;
  if FFotos.Count<>0 then
  begin
     if FSelectIndex>(TmyPanel(FFOtos.Items[FFotos.Count-1]).Tag) then FSelectIndex:=TmyPanel(FFOtos.Items[FFotos.Count-1]).Tag;
     LigthSelect(FSelectIndex);
  end else
      Memo1.Enabled:=False;

end;

procedure TfrmNode.AShowExecute(Sender: TObject);
var
  i,j:integer;
  jpg:TJpegImage;
begin
  //showmessage('не реализовано');
  frmviewfoto:=Tfrmviewfoto.Create(self);
  for i:=0 to FFotos.Count-1 do
  begin
    if TmyPanel(FFotos.Items[i]).Color=ColorSelect then
    begin
       for j:=0 to TmyPanel(FFotos.Items[i]).ControlCount-1 do
       begin
         if (TmyPanel(FFotos.Items[i]).Controls[j] is TImage) then
         begin
            //frmviewfoto.img.Picture.Bitmap.Assign(TImage(TmyPanel(FFotos.Items[i]).Controls[j]).Picture.Bitmap);
            FPeople.FotoInPeople.Items[TmyPanel(FFotos.Items[i]).Tag].Seek(0,soBeginning);
            jpg:=TJpegImage.Create;
            jpg.LoadFromStream(FPeople.FotoInPeople.Items[TmyPanel(FFotos.Items[i]).Tag]);
            frmviewfoto.setFoto(jpg);
            FreeAndNil(jpg);
            frmviewfoto.ShowModal;
            break;
         end;
       end;
       break;
    end;
  end;
  FreeAndNil(frmviewfoto);
end;

procedure TfrmNode.dtp_dtbChange(Sender: TObject);
begin
  if (not (dtp_dtb.Date>1.7E307))
       then
       begin
            //посчитаем возраст
            if (dtp_dtd.Date>1.7E307) then
               Label9.Caption:='возраст(лет) '+inttostr(yearsBetween(now(),dtp_dtb.Date))
            else
              Label9.Caption:='сейчас было бы (лет) '+inttostr(yearsBetween(now(),dtp_dtb.Date));
       end;
end;

procedure TfrmNode.EditFamKeyPress(Sender: TObject; var Key: char);
begin
  if (utf8length(editfam.Text)>1)and(key=#32) then
  begin
       key:=#0;
       EditNam.SetFocus;
  end;
  BitBtn1.Enabled:=(utf8length(editfam.Text)>1)and(utf8length(editnam.Text)>1)
end;

procedure TfrmNode.EditNamKeyPress(Sender: TObject; var Key: char);
begin
  if (utf8length(editnam.Text)>1)and(key=#32) then
  begin
       key:=#0;
       Editotch.SetFocus;
  end;
  BitBtn1.Enabled:=(utf8length(editfam.Text)>1)and(utf8length(editnam.Text)>1)
end;

procedure TfrmNode.EditOtchKeyPress(Sender: TObject; var Key: char);
begin
  if (key=#32) then
  begin
       key:=#0;
       RadioButtonMen.SetFocus;
  end;
end;

procedure TfrmNode.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin

end;

procedure TfrmNode.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose:=Fexit;
  fexit:=true;
end;

function TfrmNode.GetIsModified: boolean;
begin
  FIsModified:=(FPeople.fotosIsModified)or(FPicIsModified)or(People.fam<>EditFam.Text)or(people.firstFam<>EditdevFam.Text)or(People.nam<>EditNam.Text)or(people.otch<>EditOtch.Text)or
  (people.dateBorn<>dtp_dtb.Date)or(people.dateDeath<>dtp_dtd.Date)or
  (people.dopinfo<>Memodopinfo.Text)or(people.sex<>integer(not RadioButtonMen.Checked))or(people.flag<>integer(CheckBoxUtochn.Checked))or
  (CheckModifiedTextFoto);
  result:=FIsModified;
end;

function TfrmNode.LoadFoto: TJpegImage;
var
  od:topendialog;
  jpg:TJpegImage;
  pct:TPicture;
  w,h:longint;
  //r:TRect;
const
  maxWidth = 1024;//1280;//1024;800;
  maxHeight = 768;//720;//768;600
begin
  result:=nil;
  //окно выбора фото
  od:=topendialog.Create(self.Owner);
  od.Filter:='изображение|*.jpg;*.gif;*.jpeg;*.bmp;*.png;*.JPG;*.JPEG;*.BMP;*.PNG';
  if not  od.Execute then exit;
  //fname:=ExtractFileName(od.FileName);
  //загрузим выбранное фото
  pct:=TPicture.Create;
  pct.LoadFromFile(od.FileName);
  od.Free;

  //преобразуем и сожмем выбранное фото
  w:=pct.Graphic.Width;
  h:=pct.Graphic.Height;
  jpg:=TJpegImage.Create;
  if w>h then
  begin
  if (w/h)<=maxWidth/maxHeight then
  begin
       if h>maxHeight then
       begin
            w:=round(maxHeight*(w/h));
            h:=maxHeight;
       end;
  end else
  begin
     if w>maxWidth then
     begin
          h:=round(maxWidth*(h/w));
          w:=maxWidth;
     end;
  end;
  end else
  begin
     if (h/w)<=maxWidth/maxHeight then
  begin
       if w>maxHeight then
       begin
            h:=round(maxWidth*(h/w));
            w:=maxWidth;
       end;
  end else
  begin
     if h>maxWidth then
     begin
          w:=round(maxHeight*(w/h));
          h:=maxHeight;
     end;
  end;
  end;
  jpg.Width:=w;
  jpg.Height:=h;
  jpg.CompressionQuality:=100;
  jpg.Performance:=jpBestQuality;
  jpg.Canvas.StretchDraw(rect(0,0,jpg.Width,jpg.Height),pct.Graphic);
  FreeAndNil(pct);
  result:=jpg;
  //сохраним в нужное место сжатое фото
  //jpg.SaveToFile('???');
end;

function TfrmNode.CheckModifiedTextFoto: boolean;
var
  i:integer;
begin
  result:=false;
  for i:=0 to FFotos.Count-1 do
  begin
       if TmyPanel(FFotos.Items[i]).dopInf<>FPeople.FotoInPeople.Items[TmyPanel(FFotos.Items[i]).Tag].dopInf then
       begin
          FPeople.FotoInPeople.Items[TmyPanel(FFotos.Items[i]).Tag].dopInf:=TmyPanel(FFotos.Items[i]).dopInf;
          FPeople.fotosIsModified:=true;
          result:=true;
       end;
  end;
end;

procedure TfrmNode.Setnew(AValue: boolean);
begin
  if Fnew=AValue then Exit;
  if FPeople=nil then FPeople:=TPeople.Create;
  Fnew:=AValue;
end;

procedure TfrmNode.SetPredok_Potomok(AValue: integer);
begin
  if FPredok_Potomok=AValue then Exit;
  FPredok_Potomok:=AValue;
end;

procedure TfrmNode.MenuItemClick(Sender: TObject);
var
  sd:TSaveDialog;
  flag:boolean;
begin
  case TMenuItem(Sender).Name of
  'loadjpg':
            begin
              flag:=FDelPic;//Если изображение удалено
              flag:=flag or ((people=nil)or(people<>nil)and(people.foto=nil))and(not FPicIsModified);//Если новый лист и изображение не менялось или редактирование, но лист изначально пуст
              flag:=flag or (QuestionDlg('Загрузка','Текущее изображение будет безвозвратно удалено.'+lineending+'Загрузить новое?', mtConfirmation,[mrYes,'Да',mrNo,'Нет','isdefault'],'')=mryes);
              if flag then ImageFotoDblClick(ImageFoto);
            end;
  'savejpg':
    begin
       //окно выбора фото
       sd:=TSaveDialog.Create(self.Owner);
       //Заголовок окна
       sd.Title:='Выбор файла';
       //Установка начального каталога
       //sd.InitialDir:=getcurrentdir;
       //GetEnvironmentVariable;
       // Разрешаем сохранять файлы типа .txt и .doc
       sd.Filter:='изображение(*.jpg)|*.jpg';//|изображение(bmp)|*.bmp';
       // Установка расширения по умолчанию
       sd.DefaultExt := 'jpg';
       // Выбор текстовых файлов как стартовый тип фильтра
       sd.FilterIndex := 1;
       if not  sd.Execute then exit;
       {showmessage(sd.FileName+lineending+extractfileext(sd.FileName));
       exit; }
       //Сохраним фото
       ImageFoto.Picture.Jpeg.Performance:=jpBestQuality;
       ImageFoto.Picture.Jpeg.CompressionQuality:=100;
       ImageFoto.Picture.Jpeg.SaveToFile(sd.FileName);
       sd.Free;
       ImageFoto.Hint:='щелкните правой кнопкой мыши для добавления/сохранения/удаления фото';
    end;
  'deletejpg':
    begin
                           case QuestionDlg('Удаление','Изображение будет безвозвратно удалено.'+lineending+'Удалить?', mtConfirmation,[mrYes,'удалить',mrNo,'Не Удалять','isdefault'],'') of
                        mryes:
                                  begin
                                     ImageFoto.Picture.Jpeg.Clear;
                                     FPeople.foto:=nil;
                                     FPicIsModified:=true;
                                     FDelPic:=true;
                                     PopupMenu1.Items.Items[1].Visible:=false;
                                     PopupMenu1.Items.Items[2].Visible:=false;
                                     Panel1.Caption:='щелкните правой кнопкой мыши для добавления фото';
                                     ImageFoto.Hint:='щелкните правой кнопкой мыши для добавления фото';
                                  end;
                           end;
    end;
  end;
end;

procedure TfrmNode.addFOTO(MemoryStream: TmyMemoryStream; Index: integer;
  select: boolean);
var
  pnl:TmyPanel;
  img:TImage;
  jpg:TJpegImage;
begin
  //Добавим панель в scrollbox
  pnl:=TmyPanel.Create(self);
  FFotos.Add(pnl);//Добавим в список для удобного обращения
  pnl.Parent:=ScrollBox1;//Укажем компонент ответственный за отображение
  //Установим размеры и положение
  pnl.Left:=leftwidth+(FFotos.Count-1)*(WidthFotos+beetweenFotos);
  pnl.top:=topheight;
  pnl.Width:=widthFotos;
  pnl.Height:=heightFotos;
  pnl.Tag:=Index;
  pnl.dopInf:=MemoryStream.dopInf;
  //Добавим Image в панель
  img:=TImage.Create(self);
  img.Parent:=pnl;//Укажем компонент ответственный за отображение
  //Установим размеры и положение
  img.Align:=alClient;
  img.BorderSpacing.Left:=5;
  img.BorderSpacing.right:=5;
  img.BorderSpacing.top:=5;
  img.BorderSpacing.Bottom:=5;
  img.Stretch:=true;//вписываем фотку в размер
  img.Proportional:=true;//сохраняем пропорции
  img.OnClick:=@Image1Click;//нажатие клавиши мыши
  //Добавим в Image фотку
  jpg:=TJpegImage.Create;
  MemoryStream.Seek(0, soBeginning);
  jpg.LoadFromStream(MemoryStream);
  //ms.Free;
  img.Picture.Jpeg.Assign(jpg);
  FreeAndNil(jpg);
  if select then
     LigthSelect(pnl.Tag);
  //if FSelectIndex=-1 then FSelectIndex:=Index;//По умолчанию выделен первый
  Memo1.Enabled:=True;
end;

procedure TfrmNode.LigthSelect(Index: integer);
var
  i:integer;
  clr:TColor;
begin
  for i:=0 to FFotos.Count-1 do
  begin
       if TmyPanel(FFotos.Items[i]).Tag= Index then
       begin
            clr:=ColorSelect;
            FSelectingFoto:=Index;
       end else  clr:=clDefault;
       TmyPanel(FFotos.Items[i]).Color:=clr;
  end;
  Memo1.Text:=TmyPanel(FFotos.Items[FSelectingFoto]).dopInf;
end;

end.

