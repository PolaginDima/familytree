unit CreateTree;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, Forms, {mylvlGraphTree,} ExtCtrls, controls,
  mysqlite3conn, sqldb, Menus, lazutf8, dialogs, workdb, UnitNodeFromBD, mygraphinbmp;
type
  TColorFrmEvent=procedure(Color:Tcolor) of object;
  {TMyKeyUp=procedure(Sender: TObject; var Key: Word;  Shift: TShiftState); }

type
  TStatePredokPotomok=(SelectPredok, SelectPotomok, SelectAny);
  TFrmClose = procedure of object;
  TChangePercent = procedure(Value:byte) of object;

 type
   ESQLiteException = class(Exception)
   end;

   const
        Default_color_frm=$0000CC00;

  type
   {
   перенести всю работу с базой в модуль workdb
   }
      { TCreateTree }

   TCreateTree=class(TScrollbox)
   private
     Fbeautiful_tree: boolean;
     Fcolor_CaptionNode: TColor;
     FonChangePercent: TChangePercent;
     FX,FY:integer;
     FColorFrmEvent: TColorFrmEvent;
     Fcolor_BackGround: TColor;
     Fcolor_Bevel_Foto: TColor;
     Fcolor_Edge: TColor;
     Fcolor_Foto: TColor;
     FColor_frm: TColor;
     Fcolor_ligth_Edge: TColor;
     Fcount_view_birthday_skoro: integer;
     Fcount_view_potomk: integer;
     Fcount_view_predk: integer;
     FPositionX: extended;
     FPositionY: extended;
     Fview_birthday: boolean;
     Fview_birthday_skoro: boolean;
     Fview_potomk: boolean;
     Fview_predk: boolean;
     Fnastr: Tstringlist;
       //Fnastr:Tstringlist;
       Fversion:string[13];
       FMouseMove:boolean;
     FCaption: string;
     FClosefrm: boolean;
       FID_koren:integer;
       FflagDraw:boolean;
       FonFrmClose: TFrmClose;
       FOnProgressEvent: FProgressEvent;
       FPercentM: integer;
       Fstate: TStatePredokPotomok;
//       myTree:TMyTree;
       myTreeInBMP:TMyTreeInBMP;
       Image:TImage;
       //FSQL_table:TSQLiteTable2;
       Fobj:TCustomControl;
       Fpath:string;
       rod:Tworkdb;
       //FMaxDepth:integer;
       //FMaxCountInLevel:integer;
       PopupMenu1: TPopupMenu;
       //PopupMenu2: TPopupMenu;
       function GetcountPeople: integer;
       procedure MouseUp(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);overload;
       procedure MouseDown(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);overload;
       procedure MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);overload;
       procedure MouseWheelDown(Sender: TObject; Shift: TShiftState;MousePos: TPoint; var Handled: Boolean);
       procedure MouseWheelUp(Sender: TObject; Shift: TShiftState;MousePos: TPoint; var Handled: Boolean);
       procedure GetPotomk(ID_Roditel:integer;Reset:boolean=false);overload;
       procedure GetPotomk(Fam, Nam, Otch:string;sex:integer;Reset:Boolean=false);overload ;
       procedure GetPredok(ID_Potomok:integer;Reset:Boolean=false);overload;
       procedure GetPredok(Fam, Nam, Otch:string;sex:integer;Reset:Boolean=false);overload ;
       procedure DelPeople(ID:integer);
       procedure AddConnect(ID_Roditel,ID_Potomok:integer; Predok:boolean=false);
       procedure DelConnect(ID_Roditel,ID_Potomok:integer;Predok:boolean=false);
       function Getversion: string;
       procedure Setbeautiful_tree(AValue: boolean);
       //procedure DrawTreeshow;
       procedure SetCaption(AValue: string);
       procedure MenuItemClick(Sender: TObject);
       procedure Setcolor_BackGround(AValue: TColor);
       procedure Setcolor_Bevel_Foto(AValue: TColor);
       procedure Setcolor_CaptionNode(AValue: TColor);
       procedure Setcolor_Edge(AValue: TColor);
       procedure Setcolor_Foto(AValue: TColor);
       procedure SetColor_frm(AValue: TColor);
       procedure Setcolor_ligth_Edge(AValue: TColor);
       procedure Setcount_view_birthday_skoro(AValue: integer);
       procedure Setcount_view_potomk(AValue: integer);
       procedure Setcount_view_predk(AValue: integer);
       procedure SetPercentM(AValue: integer);
       procedure ProgressBar(Position:integer;capt:string);
       procedure SaveSpisok;
       procedure SaveNastr;
       procedure ApplyNastr;
       procedure Setview_birthday(AValue: boolean);
       procedure Setview_birthday_skoro(AValue: boolean);
       procedure Setview_potomk(AValue: boolean);
       procedure Setview_predk(AValue: boolean);
       procedure SelectedNode;
       function startpos:boolean;
       function addpeople(ppl: Tpeople;predok:boolean=false): integer;
       function savepeople(ppl: Tpeople;id:integer): boolean;
   protected
   public
       constructor Create(pathdb:string;frm:TCustomControl);overload;
       destructor Destroy;override;
       function getparametrbase:string;
       function DefaultColor_frm:TColor;
       function Defaultcolor_ligth_Edge:TColor;
       function Defaultcolor_Edge:TColor;
       function Defaultcolor_BackGround:TColor;
       function Defaultcolor_Foto:TColor;
       function Defaultcolor_Bevel_Foto:TColor;
       function Defaultcolor_Caption_Node:TColor;
       procedure ClearSelection;
       procedure Resize(Sender: TObject);overload;
       procedure DrawTree;
       procedure SaveTree;
       procedure SlivBD;
       procedure Execute;
       property CaptionTree:string read FCaption write SetCaption;
       property state:TStatePredokPotomok read Fstate write Fstate;
       property Closefrm:boolean read FClosefrm write FClosefrm;
       property onFrmClose:TFrmClose read FonFrmClose write FonFrmClose;
       property onChangePercent:TChangePercent read FonChangePercent write FonChangePercent;
       property PercentM:integer read FPercentM write SetPercentM default 100;
       property OnProgressEvent:FProgressEvent read FOnProgressEvent write FOnProgressEvent;
       property versionBD:string read Getversion;
       property countPeople:integer read GetcountPeople;
       property nastr:Tstringlist read Fnastr write Fnastr;
       property view_predk:boolean read Fview_predk write Setview_predk;
       property count_view_predk:integer read Fcount_view_predk write Setcount_view_predk;
       property view_potomk:boolean read Fview_potomk write Setview_potomk;
       property count_view_potomk:integer read Fcount_view_potomk write Setcount_view_potomk;
       property view_birthday:boolean read Fview_birthday write Setview_birthday;
       property view_birthday_skoro:boolean read Fview_birthday_skoro write Setview_birthday_skoro;
       property count_view_birthday_skoro:integer read Fcount_view_birthday_skoro write Setcount_view_birthday_skoro;
       property Color_frm:TColor read FColor_frm write SetColor_frm;
       property color_ligth_Edge:TColor read Fcolor_ligth_Edge write Setcolor_ligth_Edge;
       property color_Edge:TColor read Fcolor_Edge write Setcolor_Edge;
       property color_BackGround:TColor read Fcolor_BackGround write Setcolor_BackGround;
       property color_Foto:TColor read Fcolor_Foto write Setcolor_Foto;
       property color_Bevel_Foto:TColor read Fcolor_Bevel_Foto write Setcolor_Bevel_Foto;
       property color_CaptionNode:TColor read Fcolor_CaptionNode write Setcolor_CaptionNode;
       property beautiful_tree:boolean read Fbeautiful_tree write Setbeautiful_tree;
       property OnColorFrmEvent:TColorFrmEvent read FColorFrmEvent write FColorFrmEvent;
       property PositionX:extended read FPositionX write FPositionX;
       property PositionY:extended read FPositionY write FPositionY;
   end;

implementation
uses unitNode, startpos, inifiles;//, slivbd;

   { TCreateTree }


procedure TCreateTree.GetPotomk(ID_Roditel: integer; Reset: boolean);
var
  ppl:TPeople;
  flag:boolean;
  cnt:integer;
begin
  if not Reset then myTreeInBMP.RemoveAllEdgeAndNodeLevelNil;
  FID_koren:=ID_Roditel;
  if not rod.GetPotomok(ID_Roditel) then exit;
  if rod.RowCount<>0 then
  begin
     cnt:=0;
     rod.First;
     //myTreeInBMP.Sorting:=true;
     //image.Cursor:=crAppStart;
     while not rod.EOF do
       begin
          //Получим идентификатор листа и его родителя дерева
          inc(cnt);
          ProgressBar(round(100*cnt/rod.RowCount),'строим дерево потомков');
          ppl:=rod.GetPeople_ID;
          flag:=myTreeInBMP.GetNodesIDNode(ppl.ID)<>nil;
          if ppl.predok_potomok=-1 then
          begin
           myTreeInBMP.addNode(ppl.ID);
          end
          else
          begin
             myTreeInBMP.addEdge(ppl.predok_potomok,ppl.ID);
          end;
          ppl.Free;
          if not flag then
           begin
             //Получим минимальную информацию о листе дерева
             ppl:=rod.GetPeople_min;
             myTreeInBMP.GetNodesIDNode(ppl.ID).Flag:=ppl.flag and 1;
             myTreeInBMP.GetNodesIDNode(ppl.ID).Birthday:=(rod.FieldAsString('dtb')='1');
             myTreeInBMP.GetNodesIDNode(ppl.ID).BirthdaySkoro:=(rod.FieldAsString('dtb2')='1');
             if (rod.FieldAsString('dt_b')<>'UNKNOWN') then
              begin
                  myTreeInBMP.GetNodesIDNode(ppl.ID).dtbirthday:=Encodedate( strtoint(utf8copy(rod.FieldAsString('dt_b'),1,4)),
                strtoint(utf8copy(rod.FieldAsString('dt_b'),6,2)),
                strtoint(utf8copy(rod.FieldAsString('dt_b'),9,2)));
              end
                else
                 myTreeInBMP.GetNodesIDNode(ppl.ID).dtbirthday:=1.7E308;
             if (rod.FieldAsString('dt_d')<>'UNKNOWN') then
              begin
                myTreeInBMP.GetNodesIDNode(ppl.ID).dtdeath:=Encodedate(strtoint(utf8copy(rod.FieldAsString('dt_d'),1,4)),
                strtoint(utf8copy(rod.FieldAsString('dt_d'),6,2)),
                strtoint(utf8copy(rod.FieldAsString('dt_d'),9,2)));
              end
                else
                 myTreeInBMP.GetNodesIDNode(ppl.ID).dtdeath:=1.7E308;
             myTreeInBMP.GetNodesIDNode(ppl.ID).Caption:=ppl.fam+' '+ppl.nam+lineending+ppl.otch;
             myTreeInBMP.GetNodesIDNode(ppl.ID).avatar:=ppl.foto;
             myTreeInBMP.GetNodesIDNode(ppl.ID).Death:=ppl.Death;
             ppl.Free;
           end;
          rod.Next;
       end;
       ProgressBar(0,'');
     //myTreeInBMP.Sorting:=false;
  end;

  //Установим состояние дерево потомков
  state:=SelectPotomok;
  //GetMaxDepth;//Количество уровней
  //GetMaxCountInLevel;//Максимальное количество потомков на уровне
  //rod.Transaction.Commit;
 //Освободим ресурсы
 rod.SQL_table_FREE;
end;

function TCreateTree.GetcountPeople: integer;
begin
  result:=rod.countPeople;
end;

procedure TCreateTree.MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FX:=-1;
  image.Cursor:=crDefault;
end;

procedure TCreateTree.GetPotomk(Fam, Nam, Otch: string; sex: integer;
  Reset: Boolean);
var
  SQL_table: TSQLiteTable2;
begin
  SQL_table:=rod.GetTable('select ID from people where (Fam="'+Fam+'")and(Nam="'+
  Nam+'")and(Otch="'+Otch+'")and(sex='+inttostr(sex)+')');
  if SQL_table.Count=0 then exit;
  SQL_table.First;
  GetPotomk(SQL_table.FieldAsInteger('ID'));
  SQL_table.Free;
end;

procedure TCreateTree.GetPredok(ID_Potomok: integer; Reset: Boolean);
var
  ppl:TPeople;
  flag:boolean;
  cnt:integer;
begin
  if not Reset then myTreeInBMP.RemoveAllEdgeAndNodeLevelNil;
  FID_koren:=ID_Potomok;
  if not rod.GetPredok(ID_Potomok) then exit;
  //if (mytree<>nil)and(self.state<>SelectPredok) then
   //begin
    { mytree.Free;
     mytree:=TMyTree.Create;
     mytree.PercentM:=PercentM;   }
   //end;
   //mytree
   cnt:=rod.RowCount;
  if rod.RowCount<>0 then
  begin
     cnt:=0;
     rod.First;
     //myTreeInBMP.Sorting:=true;
     //image.Cursor:=crAppStart;
     while not rod.EOF do
       begin
          //Получим идентификатор листа и его родителя дерева
          inc(cnt);
          ProgressBar(round(100*cnt/rod.RowCount),'строим дерево предков');
          ppl:=rod.GetPeople_ID(true);
          flag:=myTreeInBMP.GetNodesIDNode(ppl.ID)<>nil;
          if ppl.predok_potomok=-1 then
          begin
            myTreeInBMP.addNode(ppl.ID);
          end else
          begin
               myTreeInBMP.addEdge(ppl.ID, ppl.predok_potomok);
          end;
          ppl.Free;
          if not flag then
           begin
             //Получим минимальную информацию о листе дерева
             ppl:=rod.GetPeople_min(true);
             myTreeInBMP.GetNodesIDNode(ppl.ID).Flag:=ppl.flag and 1;
             myTreeInBMP.GetNodesIDNode(ppl.ID).Birthday:=(rod.FieldAsString('dtb')='1');
             myTreeInBMP.GetNodesIDNode(ppl.ID).BirthdaySkoro:=(rod.FieldAsString('dtb2')='1');
             if (rod.FieldAsString('dt_b')<>'UNKNOWN') then
              begin
                  myTreeInBMP.GetNodesIDNode(ppl.ID).dtbirthday:=Encodedate( strtoint(utf8copy(rod.FieldAsString('dt_b'),1,4)),
                strtoint(utf8copy(rod.FieldAsString('dt_b'),6,2)),
                strtoint(utf8copy(rod.FieldAsString('dt_b'),9,2)));
              end
                else
                 myTreeInBMP.GetNodesIDNode(ppl.ID).dtbirthday:=1.7E308;
             if (rod.FieldAsString('dt_d')<>'UNKNOWN') then
              begin
                //try
                   myTreeInBMP.GetNodesIDNode(ppl.ID).dtdeath:=Encodedate(strtoint(utf8copy(rod.FieldAsString('dt_d'),1,4)),
                strtoint(utf8copy(rod.FieldAsString('dt_d'),6,2)),
                strtoint(utf8copy(rod.FieldAsString('dt_d'),9,2)));
                {finally
                end;}

              end
                else
                 myTreeInBMP.GetNodesIDNode(ppl.ID).dtdeath:=1.7E308;
             myTreeInBMP.GetNodesIDNode(ppl.ID).Caption:=ppl.fam+' '+ppl.nam+lineending+ppl.otch;
             myTreeInBMP.GetNodesIDNode(ppl.ID).avatar:=ppl.foto;
             myTreeInBMP.GetNodesIDNode(ppl.ID).Death:=ppl.Death;
             ppl.Free;
           end;
          rod.Next;
       end;
     ProgressBar(0,'');
    // myTreeInBMP.Sorting:=false;
   end;
  //Установи состояние дерево предков
  state:=SelectPredok;
  //Освободим ресурсы
 rod.SQL_table_FREE;
end;

procedure TCreateTree.GetPredok(Fam, Nam, Otch: string; sex: integer;
  Reset: Boolean);
var
  SQL_table: TSQLiteTable2;
begin
  //showmessage('select ID from people where (Fam="'+Fam+'")and(Nam="'+Nam+'")and(Otch="'+Otch+'")and(sex='+inttostr(sex)+')');
 // SQL_table:=rod.GetTable('select ID from people where (ID="'+inttostr(13)+'")');
  SQL_table:=rod.GetTable('select ID from people where (Fam="'+Fam+'")and(Nam="'+
  Nam+'")and((Otch="UNKNOWN")or(Otch is null)or(Otch="'+Otch+'"))and(sex='+inttostr(sex)+')');
  if SQL_table.Count=0 then exit;
  SQL_table.First;
  GetPredok(SQL_table.FieldAsInteger('ID'));
  SQL_table.Free;
end;

procedure TCreateTree.DelPeople(ID: integer);
begin
  {mytree.Free;
  mytree:=Tmytree.Create;
  mytree.PercentM:=PercentM;}
  rod.DeletePeople(ID);
  myTreeInBMP.removeNodeIDNode(ID);
  if ID=FID_koren then
  begin
    if (not startpos) then
     begin
       if (assigned(FonFrmClose)) then
        begin
          FonFrmClose;
          exit;
        end;
     end;
  end;
  DrawTree;
end;

procedure TCreateTree.AddConnect(ID_Roditel, ID_Potomok: integer;
  Predok: boolean);
{var
  ID_Koren:integer; }
begin
  rod.addconnect(ID_Roditel,ID_Potomok);
  //ID_KOREN:=FID_koren;
  //Устьановим новую связь
  //myTreeInBMP.addEdge(ID_Roditel, ID_Potomok);
  //Подгрузим недостающую часть дерева
  if (state=SelectPotomok)and(not Predok) then
   GetPotomk(FID_koren);
  //if (state=SelectPotomok)and(Predok) then GetPotomk(ID_Potomok);
  //if (state=SelectPredok)and(not Predok) then GetPredok(FID_koren);
  if (state=SelectPredok)and(Predok) then
   GetPredok(FID_koren);
  //FID_koren:=ID_KOREN;
  //if (state=SelectPotomok)and(not Predok) then
  myTreeInBMP.Sorting:=true;
  myTreeInBMP.DrawTree(FID_koren);
  myTreeInBMP.Sorting:=false;
end;

procedure TCreateTree.DelConnect(ID_Roditel, ID_Potomok: integer;
  Predok: boolean);
begin
  rod.delconnect(ID_Roditel,ID_Potomok);
  if state=SelectPotomok then GetPotomk(FID_koren);
  if state<>SelectPotomok then GetPredok(FID_koren);
  DrawTree;
end;

function TCreateTree.Getversion: string;
begin
  result:=Fversion;
end;

procedure TCreateTree.Setbeautiful_tree(AValue: boolean);
begin
  if Fbeautiful_tree=AValue then Exit;
  Fbeautiful_tree:=AValue;
  if nastr.IndexOfName('beautiful_tree')=-1 then
     nastr.Add('beautiful_tree='+inttostr(integer(beautiful_tree))) else
      nastr.Values['beautiful_tree']:=inttostr(integer(beautiful_tree));
  myTreeInBMP.beautiful_tree:=beautiful_tree;
end;

constructor TCreateTree.Create(pathdb: string; frm: TCustomControl);
var
  mi:TMenuItem;
  inif:tinifile;
begin
  inherited create(frm);
  FX:=-1;
  mytreeinbmp:=TMyTreeInBMP.Create;
  mytreeinbmp.picBackGround:=ExtractFilePath(pathdb)+'bk.bmp';//Загрузим, если есть фоновую картинку
  mytreeinbmp.picBorder:=ExtractFilePath(pathdb)+'acorn.bmp';//Загрузим, если есть рамку для фотографий
   Fobj:=frm;
   Fpath:=pathdb;
  // Подключение к БД
  try
    //Создадим объект подключения
    rod:=Tworkdb.Create(Fpath, frm);
    rod.count_view_birthday_skoro:=count_view_birthday_skoro;
    //Получим версию базы
    Fversion:=rod.versionBD;
  except
               on E: Exception do
               begin
                 raise ESqliteException.Create(E.Message);
               end;
  end;

  //Задаем настройки
  {Fcount_view_birthday_skoro:=9;
  Fcount_view_potomk:=1;
  Fcount_view_predk:=1;
  Fview_birthday:=true;
  Fview_birthday_skoro:=true;
  Fview_potomk:=true;
  Fview_predk:=true;}
  nastr:=Tstringlist.Create;
  nastr.Duplicates:=dupIgnore;
  if fileexists(ExtractFilePath(Application.ExeName)+{directoryseparator+}'nastr.ini') then
   begin
     try
        //создадим экземпляр класса
        inif:=tinifile.Create(ExtractFilePath(Application.ExeName) + 'nastr.ini');
        //прочитаем настройки в переменную nastr
        inif.ReadSection('Settings', nastr);
        inif.ReadSectionValues('Settings', nastr);
        inif.Free;
        //применим настройки
        ApplyNastr;
     except
                  on E: Exception do
                  begin
                     //MessageDlg('неизвестная ошибка',e.Message,mtError,[mbOK],0) ;
                     //result:=false;
                  end;
     end;
   end else
   begin//Если файла настроек нет, то задаем значения по умолчанию и создаем файл настроек
        nastr.Add('count_view_birthday_skoro=9');
        nastr.Add('view_birthday_skoro=1');
        nastr.Add('view_birthday=1');
        nastr.Add('view_potomk=0');
        nastr.Add('view_predk=0');
        nastr.Add('count_view_potomk=1');
        nastr.Add('count_view_predk=1');
        nastr.Add('color_frm='+colortostring(mytreeinbmp.DefaultColorBackGround));
        nastr.Add('color_ligth_Edge='+colortostring(mytreeinbmp.DefaultColorEdge_Ligth));
        nastr.Add('color_Edge='+colortostring(mytreeinbmp.DefaultColorEdge));
        nastr.Add('Color_BackGround='+colortostring(mytreeinbmp.DefaultColorBackGround));
        nastr.Add('color_Foto='+colortostring(mytreeinbmp.Defaultcolor_Foto));
        nastr.Add('color_Bevel_Foto='+colortostring(mytreeinbmp.Defaultcolor_Bevel_Foto));
        nastr.Add('color_CaptionNode='+colortostring(mytreeinbmp.Defaultcolor_Caption_Node));
        nastr.Add('beautiful_tree=1');
        nastr.Delimiter:='=';
        //FreeAndNil(inif);
        //применим настройки
        ApplyNastr;
      {end;
      //result:=true;
      except
                   on E: Exception do
                   begin
                      //MessageDlg('неизвестная ошибка',e.Message,mtError,[mbOK],0) ;
                      //result:=false;
                   end;
      end; }
   end;
   if Fcount_view_birthday_skoro<1 then Fcount_view_birthday_skoro:=1;
   if Fcount_view_potomk<1 then Fcount_view_potomk:=1;
   if Fcount_view_predk<1 then Fcount_view_predk:=1;
  FMouseMove:=true;
  FflagDraw:=false;
  FPercentM:=100;
  PopupMenu1:=TPopupMenu.Create(self);
  /////////////

  //PopupMenu1.Items.Add(TMenuItem.Create(PopupMenu1));
  {PopupMenu1.Items.Add(TMenuItem.Create(PopupMenu1));
  PopupMenu1.Items.Items[5].Caption:='редактировать лист дерева';
  PopupMenu1.Items.Items[5].Name:='editpeople';
  PopupMenu1.Items.Items[5].OnClick:=@self.MenuItemClick; }


  mi:=TMenuItem.Create(PopupMenu1);
  PopupMenu1.Items.Add(mi);
  mi.Caption:='Вывести дерево потомков';
  mi.Name:='TreePotomok';
  mi.OnClick:=@self.MenuItemClick;

  mi:=TMenuItem.Create(PopupMenu1);
  PopupMenu1.Items.Add(mi);
  mi.Caption:='вывести дерево предков';
  mi.Name:='TreePredok';
  mi.OnClick:=@self.MenuItemClick;

  mi:=TMenuItem.Create(PopupMenu1);
  PopupMenu1.Items.Add(mi);
  mi.Caption:='вывести дерево предков и потомков';
  mi.Name:='TreePredokPotomok';
  mi.OnClick:=@self.MenuItemClick;

  popupmenu1.Items.AddSeparator;

  if application.ParamCount<=0 then
   begin
     mi:=TMenuItem.Create(PopupMenu1);
     mi.Caption:='добавить потомка(сын)';
     mi.Name:='addchild_men';
     mi.OnClick:=@self.MenuItemClick;
     PopupMenu1.Items.Add(mi);

     mi:=TMenuItem.Create(PopupMenu1);
     mi.Caption:='добавить потомка(дочь)';
     mi.Name:='addchild_women';
     mi.OnClick:=@self.MenuItemClick;
     PopupMenu1.Items.Add(mi);

     mi:=TMenuItem.Create(PopupMenu1);
     mi.Caption:='добавить предка';
     mi.Name:='addparent';
     mi.OnClick:=@self.MenuItemClick;
     PopupMenu1.Items.Add(mi);

     popupmenu1.Items.AddSeparator;
   end;

  if application.ParamCount<=0 then
   begin
     mi:=TMenuItem.Create(PopupMenu1);
     PopupMenu1.Items.Add(mi);
     mi.Caption:='редактировать лист дерева';
     mi.Name:='editpeople';
     mi.OnClick:=@self.MenuItemClick;
   end;

  if application.ParamCount<=0 then
   begin
     popupmenu1.Items.AddSeparator;

     mi:=TMenuItem.Create(PopupMenu1);
     mi.Caption:='добавить предка из имеющихся';
     mi.Name:='addparentexist';
     mi.OnClick:=@MenuItemClick;
     PopupMenu1.Items.Add(mi);

     mi:=TMenuItem.Create(PopupMenu1);
     mi.Caption:='добавить потомка из имеющихся';
     mi.Name:='addchildexist';
     mi.OnClick:=@MenuItemClick;
     PopupMenu1.Items.Add(mi);
   end;

   { mi:=TMenuItem.Create(PopupMenu1);
  PopupMenu1.Items.Add(mi);
  mi.Caption:='Вывести дерево потомков';
  mi.Name:='TreePotomok';
  mi.OnClick:=@self.MenuItemClick;

  mi:=TMenuItem.Create(PopupMenu1);
  PopupMenu1.Items.Add(mi);
  mi.Caption:='вывести дерево предков';
  mi.Name:='TreePredok';
  mi.OnClick:=@self.MenuItemClick;  }

  //popupmenu1.Items.AddSeparator;

  if application.ParamCount<=0 then
     popupmenu1.Items.AddSeparator;

  mi:=TMenuItem.Create(PopupMenu1);
  mi.Caption:='главное меню';
  mi.Name:='startwindow';
  mi.OnClick:=@MenuItemClick;
  PopupMenu1.Items.Add(mi);

  if application.ParamCount<=0 then
   begin
     mi:=TMenuItem.Create(PopupMenu1);
     PopupMenu1.Items.Add(mi);
     mi.Caption:='удалить связь с потомком';
     mi.Name:='delchild';
     mi.OnClick:=@self.MenuItemClick;
     mi.Visible:=false;

     mi:=TMenuItem.Create(PopupMenu1);
     PopupMenu1.Items.Add(mi);
     mi.Caption:='удалить связь с предком';
     mi.Name:='delpredok';
     mi.OnClick:=@self.MenuItemClick;
     mi.Visible:=false;

     popupmenu1.Items.AddSeparator;
     //popupmenu1.Items.Items[12].Visible:=false;

     mi:=TMenuItem.Create(PopupMenu1);
     PopupMenu1.Items.Add(mi);
     mi.Caption:='Удалить лист';
     mi.Name:='DelPeople';
     mi.OnClick:=@self.MenuItemClick;
     mi.Visible:=false;
       /////////////
       //PopupMenu2:=TPopupMenu.Create(self);
       /////////////

       mi:=TMenuItem.Create(PopupMenu1);
       PopupMenu1.Items.Add(mi);
       mi.Caption:='предок для нового дерева';
       mi.Name:='newTree';
       mi.OnClick:=@self.MenuItemClick;
       mi.Visible:=false;
  end;
  /////////////

  popupmenu1.Items.AddSeparator;

  mi:=TMenuItem.Create(PopupMenu1);
  PopupMenu1.Items.Add(mi);
  mi.Caption:='Сохранить дерево';
  mi.Name:='savetree';
  mi.OnClick:=@self.MenuItemClick;
  mi.Visible:=false;

  mi:=TMenuItem.Create(PopupMenu1);
  PopupMenu1.Items.Add(mi);
  mi.Caption:='Сохранить листья(всю базу) списком';
  mi.Name:='savespisok';
  mi.OnClick:=@self.MenuItemClick;
  mi.Visible:=false;

  if application.ParamCount<=0 then
   begin
     mi:=TMenuItem.Create(PopupMenu1);
     PopupMenu1.Items.Add(mi);
     mi.Caption:='подгрузить дерево';
     mi.Name:='Sliv';
     mi.OnClick:=@self.MenuItemClick;
     mi.Visible:=false;
   end;

  popupmenu1.Items.AddSeparator;

  mi:=TMenuItem.Create(PopupMenu1);
  mi.Caption:='главное меню';
  mi.Name:='startwindow2';
  mi.OnClick:=@MenuItemClick;
  PopupMenu1.Items.Add(mi);

  ///////////////

  {myTree:=TmyTree.Create;
  mytree.PercentM:=PercentM; }

  Image:=TImage.Create(self);
  Image.Parent:=self;
  image.Align:=alClient;
  image.AutoSize:=true;
  image.OnMouseMove:=@MouseMove; //Убрал подсветку по просьбам трудящихся
  image.OnMouseUp:=@MouseUp;
  //image.Cursor:=crAppStart;
  //Image.Transparent:=true;
  OnResize:=@Resize;
  //Image.OnClick:=@self.Click;
  image.OnMouseDown:=@MouseDown;
  image.OnMouseWheelDown:=@MouseWheelDown;
  image.OnMouseWheelUp:=@MouseWheelUp;

  //OnKeyUp:=@KeyUp;

  //mytreeinbmp:=TMyTreeInBMP.Create;
  mytreeinbmp.PercentM:=PercentM;
  mytreeinbmp.Image:=Image;
  mytreeinbmp.OnProgressEvent:=@ProgressBar;
  mytreeinbmp.OnSelectedNodeEvent:=@SelectedNode;
end;

destructor TCreateTree.Destroy;
begin
  //сохраним настройки
  SaveNastr;
  //rod.Free;
  //rodtrans.Free;
  rod.Free;
  myTreeInBMP.Free;
  nastr.Free;
  //FSQL_table.Free;
  inherited Destroy;
end;

function TCreateTree.getparametrbase: string;
begin
  result:=rod.getparametrbase;
end;

procedure TCreateTree.ClearSelection;
begin
  myTreeInBMP.ClearSelection;
end;

procedure TCreateTree.DrawTree;
begin
  case state of
  SelectPotomok:
            begin
              myTreeInBMP.Caption:={CaptionTree +} '(потомки)';
              myTreeInBMP.Napravlenie:=NapravlenieUp;
            end;
  SelectPredok:
            begin
              myTreeInBMP.Caption:={CaptionTree +} '(предки)';
              myTreeInBMP.Napravlenie:=NapravlenieDown;
            end;
  SelectAny:
            begin
              myTreeInBMP.Caption:={CaptionTree +} '';
              myTreeInBMP.Napravlenie:=NapravlenieUp;
            end;
  end;
  {if FflagDraw then
     myTreeInBMP.DrawTree(FID_koren, true, state=SelectAny)//, Width, Height);
  else }
      myTreeInBMP.DrawTree(FID_koren, Width, Height,true,state=SelectAny);
  FflagDraw:=true;
  //image.Cursor:=crDefault;
end;

procedure TCreateTree.SaveTree;
var
  sd:TSaveDialog;
  pct:TPicture;
//  tmpi:integer;
begin
   //окно выбора фото
  sd:=TSaveDialog.Create(self.Owner);
  //Заголовок окна
  sd.Title:='Выбор файла';
  //Установка начального каталога
  //sd.InitialDir:=getcurrentdir;
  //GetEnvironmentVariable;
  // Разрешаем сохранять файлы типа .txt и .doc
  sd.Filter:='изображение(*.jpg)|*.jpg';//'изображение(jpg)|*.jpg|изображение(bmp)|*.bmp';
  // Установка расширения по умолчанию
  sd.DefaultExt := 'jpg';
  sd.FileName:='myTree.jpg';
  // Выбор текстовых файлов как стартовый тип фильтра
  sd.FilterIndex := 1;
  if not  sd.Execute then exit;
  while fileexists(sd.FileName) do
    begin
      if QuestionDlg('предупреждение','Файл уже существует.'+lineending+'Перезаписать файл '+ExtractFileName(sd.FileName)+'?'
      , mtWarning,[mrYes,'перезаписать',mrNo,'не перезаписывать','isdefault'],'')=mrYes then break;
      if not  sd.Execute then exit;
    end;
  {showmessage(sd.FileName+lineending+extractfileext(sd.FileName));
  exit; }
  //Сохраним фото
  pct:=TPicture.Create;
  //запомним масштаб
//  tmpi:=myTreeInBMP.PercentM;
  //Сделаем масштаб 100%
//  myTreeInBMP.PercentM:=100;
  //перерисуем в новом масштабе
 // myTreeInBMP.DrawTree;
  //myTree.resizeTree(Width{ Image.width},Height {Image.height});
  //подключим
  pct.Jpeg.Assign(myTreeInBMP.BMP);
  //сохраним
  pct.Jpeg.SaveToFile(sd.FileName);
  //подчистим
  pct.Free;
  sd.Free;
  //вернем масштаб на место
  //Сделаем масштаб 100%
 // myTreeInBMP.PercentM:=tmpi;
  //перерисуем в новом масштабе
 // myTreeInBMP.DrawTree;
  //myTree.resizeTree(Width{ Image.width},Height {Image.height});
end;

procedure TCreateTree.SlivBD;
var
  od:TOpenDialog;
//  slivdb:TslivBD;
begin
  //Слияние двух баз
  //окно выбора базы
  od:=TOpenDialog.Create(self.Owner);
  //Заголовок окна
  od.Title:='Выбор подгружаемой базы';
  //Установка начального каталога
  //sd.InitialDir:=getcurrentdir;
  //GetEnvironmentVariable;
  // Разрешаем открывать файлы типа .txt и .doc
  od.Filter:='база(*.db3)|*.db3';
  // Установка расширения по умолчанию
  od.DefaultExt := 'db3';
  // Выбор стартового типа фильтра
  od.FilterIndex := 1;
  if not  od.Execute then exit;
  rod.Sliyanie(Fpath, od.FileName, self);
  {rod.Close(false);
  rod.Free;
  slivdb:=TslivBD.Create(Fpath, od.FileName, self);
  od.Free;
  slivdb.Sliyanie();
  //Закроем соединение для слияния
  slivdb.Close(false);
  slivdb.Free;
  //Восстанавливаем состояние
  rod:=Tworkdb.Create(Fpath, fobj);
  rod.checkParent;}
  //rod.Open;
  if state=SelectPredok then
     GetPredok(FID_koren)
   else
    GetPotomk(FID_koren);
  DrawTree;
  od.Free;
end;

procedure TCreateTree.Execute;
begin
  //Выведем список деревьев или предложим начать новое дерево
  if assigned(OnColorFrmEvent) then FColorFrmEvent(Color_frm);
  Closefrm:= not startpos;
end;

function TCreateTree.DefaultColor_frm: TColor;
begin
  Color_frm:=Default_color_frm;
  result:=Color_frm;
end;

function TCreateTree.Defaultcolor_ligth_Edge: TColor;
begin
  color_ligth_Edge:=myTreeInBMP.DefaultColorEdge_Ligth;
  result:=color_ligth_Edge;
end;

function TCreateTree.Defaultcolor_Edge: TColor;
begin
  color_Edge:=myTreeInBMP.DefaultColorEdge;
  result:=color_Edge;
end;

function TCreateTree.Defaultcolor_BackGround: TColor;
begin
  color_BackGround:=myTreeInBMP.DefaultcolorBackGround;
  result:=color_BackGround;
end;

function TCreateTree.Defaultcolor_Foto: TColor;
begin
  color_Foto:=myTreeInBMP.Defaultcolor_Foto;
  result:=color_Foto;
end;

function TCreateTree.Defaultcolor_Bevel_Foto: TColor;
begin
  color_Bevel_Foto:=myTreeInBMP.Defaultcolor_Bevel_Foto;
  result:=color_Bevel_Foto;
end;

function TCreateTree.Defaultcolor_Caption_Node: TColor;
begin
  color_CaptionNode:=myTreeInBMP.Defaultcolor_Caption_Node;
  result:=color_CaptionNode;
end;

procedure TCreateTree.MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if FMouseMove then
  begin
    {if not myTreeInBMP.mouseMove(x,y) then
    begin}
      if (FX>-1)and(ssLeft in Shift)and((X<>FX)or(Y<>FY))then
      begin
        VertScrollBar.Position:=VertScrollBar.Position-(Y-FY);
        HorzScrollBar.Position:=HorzScrollBar.Position-(X-FX);
      end else
          {if beautiful_tree then
          begin}
           if not myTreeInBMP.mouseMove(x,y) then Image.Cursor:=crDefault
          {end else
          if not myTreeInBMP.mouseMove_old(x,y) then Image.Cursor:=crDefault};
    //end;
  end;
end;

procedure TCreateTree.MouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if ssCtrl in Shift then
     if assigned(FonChangePercent) then FonChangePercent(1);
end;

procedure TCreateTree.MouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if ssCtrl in Shift then
     if assigned(FonChangePercent) then FonChangePercent(2);
end;

procedure TCreateTree.Resize(Sender: TObject);
begin
  if FflagDraw then
   begin
     //myTreeInBMP.DrawTree;
     //Image.Width:=Width;
     //Image.Height:=height;
     myTreeInBMP.resizeTree(Width,height);
   end;
end;

procedure TCreateTree.MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i:integer;
begin
     myTreeInBMP.mouseMove(x,y);
  if (trselnode in myTreeInBMP.SostTree) then
   begin
     if (ssLeft in Shift) then
      begin
           for i:=0 to PopupMenu1.Items.Count-1 do
           begin
             if PopupMenu1.Items.Items[i].Name='delchild' then break;
             PopupMenu1.Items.Items[i].Visible:=true;
           end;
           for i:=i to PopupMenu1.Items.Count-1 do
           begin
             PopupMenu1.Items.Items[i].Visible:=false;
           end;
      end else
      begin
        for i:=0 to PopupMenu1.Items.Count-1 do
        begin
          if PopupMenu1.Items.Items[i].Name='delchild' then break;
          PopupMenu1.Items.Items[i].Visible:=false;
        end;
        for i:=i to PopupMenu1.Items.Count-1 do
        begin
          if PopupMenu1.Items.Items[i].Name='newTree' then break;
          PopupMenu1.Items.Items[i].Visible:=true;
        end;
        for i:=i to PopupMenu1.Items.Count-1 do
        begin
          PopupMenu1.Items.Items[i].Visible:=false;
        end;
      end;
      PopupMenu1.PopUp;
   end else
   begin
     if not (ssLeft in Shift) then
      begin
        for i:=PopupMenu1.Items.Count-1 downto 0 do
        begin
          PopupMenu1.Items.Items[i].Visible:=true;
          if PopupMenu1.Items.Items[i].Name='newTree' then break;
        end;
        for i:=i-1 downto 0 do
        begin
          PopupMenu1.Items.Items[i].Visible:=false;
        end;
        PopupMenu1.PopUp;
      end else
      begin
        FX:=X;
        FY:=Y;
        image.Cursor:=crSizeAll;
        for i:=0 to PopupMenu1.Items.Count-1 do PopupMenu1.Items.Items[i].Visible:=false;
      end;
   end;
   //PopupMenu1.PopUp;
end;

procedure TCreateTree.SetCaption(AValue: string);
begin
  if avalue=FCaption{myTree.Caption} then exit;
  FCaption:=avalue;
  myTreeInBMP.Caption:=FCaption;
end;

procedure TCreateTree.MenuItemClick(Sender: TObject);
var
  //potomok:Tpeople;
  SQLQuery:TSQLQuery;
  ID:integer;
  tmppeople:TPeople;
begin
   case TMenuItem(Sender).Name of
       'newTree':
                 begin
                      //Откроем окно ввода нового листа дерева
                    //Создадим экземпляр окна
                    frmNode:=TfrmNode.Create(self);
                    //Настроим окно ввода нового листа
                    frmNode.new:=true;//признак того что новый лист
                    frmNode.Predok_Potomok:=-1;//myTree.GetSelNodeIndex;//указываем предка, т.е. это потомок
                    //Выведем на экран
                    if frmNode.ShowModal=mrok then
                     begin
                       //Прочитаем/проанадизируем введенные данные
                       //potomok:=frmNode.People;
                       if frmNode.People<>nil then
                        begin
                          //Если все верно, то добавим потомка к дереву
                          addpeople(frmNode.People);
                          //potomok.Free;
                        end;
                     end;
                    if frmNode<>nil then  frmNode.Free;
                   {showmessage('новый потомок'+lineending+'fam'+lineending+'name'+lineending+'муж');
                   potomok:=Tpeople.Create;
                   potomok.fam:='fam';
                   potomok.nam:='name';
                   potomok.sex:=0;
                   potomok.predok:=myTree.GetSelNodeIndex;
                   addpeople(potomok);}
                   //уничтожем экземпляр
                      //showmessage('новый предок');
                 end;
       'addchild_men':   //Добавление потомка сын
                 begin
                    //Откроем окно ввода нового листа дерева
                    //Создадим экземпляр окна
                    frmNode:=TfrmNode.Create(self);
                    //Настроим окно ввода нового листа
                    frmNode.new:=true;//признак того, что новый лист
                    tmppeople:=rod.getpeople_full(myTreeInBMP.GetSelNodeIndex);
                    frmNode.People.fam:=tmppeople.fam;
                    frmNode.Predok_Potomok:=myTreeInBMP.GetSelNodeIndex;//указываем предка, т.е. это потомок

                    //Выведем на экран
                    if frmNode.ShowModal=mrok then
                     begin
                       //Прочитаем/проанадизируем введенные данные
                       //potomok:=frmNode.People;
                       if frmNode.People<>nil then
                        begin
                          //Если все верно, то добавим потомка к дереву
                          addpeople(frmNode.People);
                          //potomok.Free;
                        end;
                     end;
                    if frmNode<>nil then  frmNode.Free;
                   {showmessage('новый потомок'+lineending+'fam'+lineending+'name'+lineending+'муж');
                   potomok:=Tpeople.Create;
                   potomok.fam:='fam';
                   potomok.nam:='name';
                   potomok.sex:=0;
                   potomok.predok:=myTree.GetSelNodeIndex;
                   addpeople(potomok);}
                   //уничтожем экземпляр
                   freeAndnil(tmppeople);
                 end;
       'addchild_women':   //Добавление потомка дочь
                 begin
                    //Откроем окно ввода нового листа дерева
                    //Создадим экземпляр окна
                    frmNode:=TfrmNode.Create(self);
                    //Настроим окно ввода нового листа
                    frmNode.new:=true;//признак того, что новый лист
                    tmppeople:=rod.getpeople_full(myTreeInBMP.GetSelNodeIndex);
                    frmNode.People.fam:=tmppeople.fam;
                    frmNode.People.firstFam:=tmppeople.fam;
                    frmNode.People.sex:=1;
                    frmNode.Predok_Potomok:=myTreeInBMP.GetSelNodeIndex;//указываем предка, т.е. это потомок

                    //Выведем на экран
                    if frmNode.ShowModal=mrok then
                     begin
                       //Прочитаем/проанадизируем введенные данные
                       //potomok:=frmNode.People;
                       if frmNode.People<>nil then
                        begin
                          //Если все верно, то добавим потомка к дереву
                          addpeople(frmNode.People);
                          //potomok.Free;
                        end;
                     end;
                    if frmNode<>nil then  frmNode.Free;
                   {showmessage('новый потомок'+lineending+'fam'+lineending+'name'+lineending+'муж');
                   potomok:=Tpeople.Create;
                   potomok.fam:='fam';
                   potomok.nam:='name';
                   potomok.sex:=0;
                   potomok.predok:=myTree.GetSelNodeIndex;
                   addpeople(potomok);}
                   //уничтожем экземпляр
                   freeAndnil(tmppeople);
                 end;
       'editpeople':
                 begin
                    //Откроем окно редактирования листа дерева
                    //Создадим экземпляр окна
                    frmNode:=TfrmNode.Create(self);
                    //Настроим окно редактирования листа
                    frmNode.new:=false;//признак того что не новый лист
                    //Получим people для передачи для редактирования
                    frmNode.People:=rod.getpeople_full(myTreeInBMP.GetSelNodeIndex);
                    //frmNode.Predok:=myTree.GetSelNodeIndex;//указываем предка, т.е. это потомок
                    //Выведем на экран
                    if frmNode.ShowModal=mrok then
                     begin
                       //Прочитаем/проанадизируем введенные данные
                       //potomok:=frmNode.People;
                       //Если есть изменения, то запишем их
                       if (frmNode.People<>nil) and
                       (frmNode.IsModified)then
                        begin
                          //Если есть изменения, то запишем их
                          savepeople(frmNode.People,myTreeInBMP.GetSelNodeIndex);
                          //potomok.Free;
                        end;
                     end;
                    if frmNode<>nil then frmNode.Free;
                 end;
       'addparent':
                 begin
                    //Откроем окно ввода нового листа дерева
                    //Создадим экземпляр окна
                    frmNode:=TfrmNode.Create(self);
                    //Настроим окно ввода нового листа
                    frmNode.new:=true;//признак того что новый лист
                    frmNode.Predok_Potomok:=myTreeInBMP.GetSelNodeIndex;//указываем ID предка, потомка
                    //Выведем на экран
                    if frmNode.ShowModal=mrok then
                     begin
                       //Прочитаем/проанадизируем введенные данные
                       if frmNode.People<>nil then
                        begin
                          //Если все верно, то добавим предка к дереву
                          addpeople(frmNode.People, true);
                          //potomok.Free;
                        end;
                     end;
                    if frmNode<>nil then  frmNode.Free;
                   //уничтожем экземпляр
                 end;
       'addparentexist':
                 begin
                    //Откроем окно редактирования листа дерева
                    //Создадим экземпляр окна
                    SQLQuery:=rod.GetPredokForAdd(myTreeInBMP.GetSelNodeIndex);//Получим список для выбора
                    if SQLQuery=nil then exit;
                    frmNodeFromBD:=TfrmNodeFromBD.Create(self);
                    frmNodeFromBD.frmCaption:='Выбор предка';
                    frmNodeFromBD.SQLQuery:=SQLQuery;
                    if frmNodeFromBD.ShowModal=mrok then
                     begin
                       AddConnect(frmNodeFromBD.ID_Select, myTreeInBMP.GetSelNodeIndex, true);
                     end;
                    if frmNodeFromBD<>nil then  frmNodeFromBD.Free;
                    if SQLQuery<>nil then SQLQuery.Free;
                 end;
       'delchild':
                 begin
                    //Откроем окно редактирования листа дерева
                    //Создадим экземпляр окна
                    //SQLQuery:=rod.GetPredokForAdd(myTree.GetSelNodeIndex);//Получим список для выбора
                    SQLQuery:=rod.GetPotomokForDel(myTreeInBMP.GetSelNodeIndex);//Получим список для выбора
                    if SQLQuery=nil then exit;
                    frmNodeFromBD:=TfrmNodeFromBD.Create(self);
                    frmNodeFromBD.frmCaption:='Выбор потомка';
                    frmNodeFromBD.btnCaption:='удалить связь';
                    frmNodeFromBD.SQLQuery:=SQLQuery;
                    if frmNodeFromBD.ShowModal=mrok then
                     begin
                       DelConnect(myTreeInBMP.GetSelNodeIndex, frmNodeFromBD.ID_Select);
                     end;
                    if frmNodeFromBD<>nil then  frmNodeFromBD.Free;
                    if SQLQuery<>nil then SQLQuery.Free;
                 end;
       'delpredok':
                 begin
                    //Откроем окно редактирования листа дерева
                    //Создадим экземпляр окна
                    //SQLQuery:=rod.GetPredokForAdd(myTree.GetSelNodeIndex);//Получим список для выбора
                    SQLQuery:=rod.GetPredokForDel(myTreeInBMP.GetSelNodeIndex);//Получим список для выбора
                    if SQLQuery=nil then exit;
                    frmNodeFromBD:=TfrmNodeFromBD.Create(self);
                    frmNodeFromBD.frmCaption:='Выбор предка';
                    frmNodeFromBD.btnCaption:='удалить связь';
                    frmNodeFromBD.SQLQuery:=SQLQuery;
                    if frmNodeFromBD.ShowModal=mrok then
                     begin
                      DelConnect(frmNodeFromBD.ID_Select, myTreeInBMP.GetSelNodeIndex,true);
                     end;
                    if frmNodeFromBD<>nil then  frmNodeFromBD.Free;
                    if SQLQuery<>nil then SQLQuery.Free;
                 end;
       'addchildexist':
                 begin
                    //Откроем окно редактирования листа дерева
                    //Создадим экземпляр окна
                    SQLQuery:=rod.GetPotomokForAdd(myTreeInBMP.GetSelNodeIndex);
                    if SQLQuery=nil then exit;
                    frmNodeFromBD:=TfrmNodeFromBD.Create(self);
                    frmNodeFromBD.frmCaption:='Выбор потомка';
                    frmNodeFromBD.SQLQuery:=SQLQuery;
                    if frmNodeFromBD.ShowModal=mrok then
                     begin
                       AddConnect(myTreeInBMP.GetSelNodeIndex, frmNodeFromBD.ID_Select);
                     end;
                    if frmNodeFromBD<>nil then  frmNodeFromBD.Free;
                    if SQLQuery<>nil then SQLQuery.Free;
                 end;
       'TreePotomok':
                 begin
                    FMouseMove:=false;
                    ID:=myTreeInBMP.GetSelNodeIndex;
                    myTreeInBMP.Napravlenie:=NapravlenieUp;
                    //myTreeInBMP.removeAllNodes;
                    //FflagDraw:=false;
                    {myTreeInBMP.Free;
                    myTreeInBMP:=TmyTreeInBMP.Create;
                    myTreeInBMP.Image:=Image;
                    myTreeInBMP.PercentM:=PercentM;  }
                    //showmessage(inttostr(myTree.GetSelNodeIndex));
                    GetPotomk(ID);
                    myTreeInBMP.Sorting:=true;
                    //myTreeInBMP.DrawTreeClear;
                    DrawTree;
                    PositionX:=myTreeInBMP.PositionX[ID];
                    PositionY:=myTreeInBMP.PositionY[ID];
                    HorzScrollBar.Position:=100000;
                    HorzScrollBar.Position:= round(HorzScrollBar.Position*PositionX);
                    VertScrollBar.Position:=100000;
                    VertScrollBar.Position:=round(VertScrollBar.Position*PositionY);
                    SetFocus;
                    myTreeInBMP.Sorting:=false;
                    FMouseMove:=true;
                 end;
       'TreePredok':
                 begin
                    FMouseMove:=false;
                    ID:=myTreeInBMP.GetSelNodeIndex;
                    //myTreeInBMP.removeAllNodes;
                    myTreeInBMP.Napravlenie:=NapravlenieDown;
                    //FflagDraw:=false;
                    {myTreeInBMP.Free;
                    myTreeInBMP:=TmyTreeInBMP.Create;
                    myTreeInBMP.Image:=Image;
                    myTreeInBMP.PercentM:=PercentM;  }
                    GetPredok(ID);
                    //self.myTreeInBMP.DrawTree(FID_KOREN, Width,Height);
                    myTreeInBMP.Sorting:=true;
                    //myTreeInBMP.DrawTreeClear;
                    DrawTree;
                    PositionX:=myTreeInBMP.PositionX[ID];
                    PositionY:=myTreeInBMP.PositionY[ID];
                    HorzScrollBar.Position:=100000;
                    HorzScrollBar.Position:= round(HorzScrollBar.Position*PositionX);
                    VertScrollBar.Position:=100000;
                    VertScrollBar.Position:=round(VertScrollBar.Position*PositionY);
                    SetFocus;
                    myTreeInBMP.Sorting:=false;
                    FMouseMove:=true;
                 end;
       'TreePredokPotomok':
                 begin
                    FMouseMove:=false;
                    ID:=myTreeInBMP.GetSelNodeIndex;
                    //FreeAndNil(mytreeinbmp);
                    //mytreeinbmp:=TMyTreeInBMP.Create;
                    mytreeinbmp.RemoveAllEdgeAndNodeLevelNil;
                    mytreeinbmp.removeAllNodes;
                    {mytreeinbmp.PercentM:=PercentM;
                    mytreeinbmp.Image:=Image;
                    mytreeinbmp.OnProgressEvent:=@ProgressBar;
                    ApplyNastr;}
                    //myTreeInBMP.RemoveAllEdgeAndNodeLevelNil;
                    myTreeInBMP.Napravlenie:=NapravlenieUp;
                    GetPotomk(ID);
                    GetPredok(ID, true);
                    state:=SelectAny;
                    myTreeInBMP.Sorting:=false;
                    //myTreeInBMP.DrawTreeClear;
                    DrawTree;
                    PositionX:=myTreeInBMP.PositionX[ID];
                    PositionY:=myTreeInBMP.PositionY[ID];
                    HorzScrollBar.Position:=100000;
                    HorzScrollBar.Position:= round(HorzScrollBar.Position*PositionX);
                    VertScrollBar.Position:=100000;
                    //showmessage(inttostr(HorzScrollBar.Position)+lineending+inttostr(VertScrollBar.Position));
                    VertScrollBar.Position:=round(VertScrollBar.Position*PositionY);
                    //showmessage(inttostr(HorzScrollBar.Position)+lineending+inttostr(VertScrollBar.Position));
                    SetFocus;
                    FMouseMove:=true;
                 end;
       'DelPeople':
                 begin
                    case QuestionDlg('Удаление','Лист дерева будет безвозвратно удален.'+lineending+'Удалить?', mtConfirmation,[mrYes,'удалить',mrNo,'Не Удалять','isdefault'],'') of
                        mryes:
                                  begin
                                     DelPeople(myTreeInBMP.GetSelNodeIndex);
                                  end;
                        mrno:
                                  begin
                                  end;
                    end;
                 end;
       'savetree':SaveTree;
       'savespisok':SaveSpisok;
       'Sliv':SlivBD;
       'startwindow','startwindow2':
                 begin
                   //вызываем стартовое окно
                   startpos;
                 end;
   end;
end;

procedure TCreateTree.Setcolor_BackGround(AValue: TColor);
begin
  if Fcolor_BackGround=AValue then Exit;
  Fcolor_BackGround:=AValue;
  if nastr.IndexOfName('color_BackGround')=-1 then
     nastr.Add('color_BackGround='+colortostring(color_BackGround)) else
      nastr.Values['color_BackGround']:=colortostring(color_BackGround);
  //myTreeInBMP.color_BackGround:=color_BackGround;
  if FflagDraw then
   begin
     DrawTree;
   end;
end;

procedure TCreateTree.Setcolor_Bevel_Foto(AValue: TColor);
begin
  if Fcolor_Bevel_Foto=AValue then Exit;
  Fcolor_Bevel_Foto:=AValue;
  if nastr.IndexOfName('color_Bevel_Foto')=-1 then
     nastr.Add('color_Bevel_Foto='+colortostring(color_Bevel_Foto)) else
      nastr.Values['color_Bevel_Foto']:=colortostring(color_Bevel_Foto);
  myTreeInBMP.color_Bevel_Foto:=color_Bevel_Foto;
  if FflagDraw then
   begin
     DrawTree;
   end;
end;

procedure TCreateTree.Setcolor_CaptionNode(AValue: TColor);
begin
  if Fcolor_CaptionNode=AValue then Exit;
  Fcolor_CaptionNode:=AValue;
  if nastr.IndexOfName('color_CaptionNode')=-1 then
     nastr.Add('color_CaptionNode='+colortostring(color_CaptionNode)) else
      nastr.Values['color_CaptionNode']:=colortostring(color_CaptionNode);
  myTreeInBMP.color_CaptionNode:=color_CaptionNode;
  if FflagDraw then
   begin
     DrawTree;
   end;
end;

procedure TCreateTree.Setcolor_Edge(AValue: TColor);
begin
  if Fcolor_Edge=AValue then Exit;
  Fcolor_Edge:=AValue;
  if nastr.IndexOfName('color_Edge')=-1 then
     nastr.Add('color_Edge='+colortostring(color_Edge)) else
      nastr.Values['color_Edge']:=colortostring(color_Edge);
  myTreeInBMP.Color_Edge:=Color_Edge;
  if FflagDraw then
   begin
     DrawTree;
   end;
end;

procedure TCreateTree.Setcolor_Foto(AValue: TColor);
begin
  if Fcolor_Foto=AValue then Exit;
  Fcolor_Foto:=AValue;
  if nastr.IndexOfName('color_Foto')=-1 then
     nastr.Add('color_Foto='+colortostring(color_Foto)) else
      nastr.Values['color_Foto']:=colortostring(color_Foto);
   myTreeInBMP.color_Foto:=color_Foto;
  if FflagDraw then
   begin
     DrawTree;
   end;
end;

procedure TCreateTree.SetColor_frm(AValue: TColor);
begin
  if FColor_frm=AValue then Exit;
  FColor_frm:=AValue;
  if nastr.IndexOfName('color_frm')=-1 then
     nastr.Add('color_frm='+colortostring(Color_frm)) else
      nastr.Values['color_frm']:=colortostring(Color_frm);
  if assigned(OnColorFrmEvent) then
     FColorFrmEvent(FColor_frm);
end;

procedure TCreateTree.Setcolor_ligth_Edge(AValue: TColor);
begin
  if Fcolor_ligth_Edge=AValue then Exit;
  Fcolor_ligth_Edge:=AValue;
  if nastr.IndexOfName('color_ligth_Edge')=-1 then
     nastr.Add('color_ligth_Edge='+colortostring(color_ligth_Edge)) else
      nastr.Values['color_ligth_Edge']:=colortostring(color_ligth_Edge);
  myTreeInBMP.Color_Edge_Ligth:=color_ligth_Edge;
end;

procedure TCreateTree.Setcount_view_birthday_skoro(AValue: integer);
begin
  if Fcount_view_birthday_skoro=AValue then Exit;
  Fcount_view_birthday_skoro:=AValue;
  if nastr.IndexOfName('count_view_birthday_skoro')=-1 then
     nastr.Add('count_view_birthday_skoro='+inttostr(count_view_birthday_skoro)) else
      nastr.Values['count_view_birthday_skoro']:=inttostr(count_view_birthday_skoro);
  if rod<>nil then rod.count_view_birthday_skoro:=count_view_birthday_skoro;
end;

procedure TCreateTree.Setcount_view_potomk(AValue: integer);
begin
  if Fcount_view_potomk=AValue then Exit;
  Fcount_view_potomk:=AValue;
  if nastr.IndexOfName('count_view_potomk')=-1 then
     nastr.Add('count_view_potomk='+inttostr(count_view_potomk)) else
      nastr.Values['count_view_potomk']:=inttostr(count_view_potomk);
  myTreeInBMP.count_view_potomk:=Fcount_view_potomk;
end;

procedure TCreateTree.Setcount_view_predk(AValue: integer);
begin
  if Fcount_view_predk=AValue then Exit;
  Fcount_view_predk:=AValue;
  if nastr.IndexOfName('count_view_predk')=-1 then
     nastr.Add('count_view_predk='+inttostr(count_view_predk)) else
      nastr.Values['count_view_predk']:=inttostr(count_view_predk);
  myTreeInBMP.count_view_predk:=Fcount_view_predk;
end;

procedure TCreateTree.SetPercentM(AValue: integer);
begin
  if FPercentM=AValue then Exit;
  FPercentM:=AValue;
  myTreeInBMP.PercentM:=PercentM;
  {if FPercentM<35 then }
  myTreeInBMP.DrawTreeClear;
   //myTreeInBMP.DrawTree(FID_koren, Width, Height);
  myTreeInBMP.DrawTree(FID_koren, Width, Height,true,state=SelectAny);
  //DrawTree;
  //myTreeInBMP.resizeTree(image.Width,image.Height);
end;

procedure TCreateTree.ProgressBar(Position: integer; capt: string);
begin
  if assigned(FOnProgressEvent) then FOnProgressEvent(Position,capt);
end;

procedure TCreateTree.SaveSpisok;
begin
  rod.SaveSpisok
end;

procedure TCreateTree.SaveNastr;
var
  tmpf:file;
  inif:tinifile;
  i:integer;
begin
  if not fileexists(ExtractFilePath(Application.ExeName)+{directoryseparator+}'nastr.ini') then
  try
      //Создадим пустой файл
      assignfile(tmpf, ExtractFilePath(Application.ExeName) + 'nastr.ini');//Подключимся
      rewrite(tmpf);//создадим
      closefile(tmpf);//отключимся

      //проверим создался ли файл
      if  not fileexists(ExtractFilePath(Application.ExeName) + 'nastr.ini') then exit;
  except
               on E: Exception do
               begin
                 //MessageDlg('неизвестная ошибка',e.Message,mtError,[mbOK],0) ;
                 //result:=false;
               end;
  end;
  //создадим экземпляр класса
  inif:=tinifile.Create(ExtractFilePath(Application.ExeName) + 'nastr.ini');
  for i:=0 to nastr.Count-1 do
  begin
    inif.WriteString('Settings',nastr.Names[i],nastr.ValueFromIndex[i]);
  end;
  FreeAndNil(inif);
end;

procedure TCreateTree.ApplyNastr;
var
  r,code:integer;
begin
  if nastr.IndexOfName('view_potomk')>-1 then
  begin
    val(nastr.Values['view_potomk'],r,code);
    if code=0 then
       view_potomk:=boolean(r);
  end;
  if nastr.IndexOfName('view_predk')>-1 then
  begin
    val(nastr.Values['view_predk'],r,code);
    if code=0 then
       view_predk:=boolean(r);
  end;
  if nastr.IndexOfName('count_view_potomk')>-1 then
  begin
    val(nastr.Values['count_view_potomk'],r,code);
    if code=0 then
       count_view_potomk:=r;
  end else count_view_potomk:=1;
  if nastr.IndexOfName('count_view_predk')>-1 then
  begin
    val(nastr.Values['count_view_predk'],r,code);
    if code=0 then
       count_view_predk:=r;
  end else count_view_predk:=1;
  if nastr.IndexOfName('view_birthday')>-1 then
  begin
    val(nastr.Values['view_birthday'],r,code);
    if code=0 then
       view_birthday:=boolean(r);
  end;
  if nastr.IndexOfName('view_birthday_skoro')>-1 then
  begin
    val(nastr.Values['view_birthday_skoro'],r,code);
    if code=0 then
       view_birthday_skoro:=boolean(r);
  end;
  if nastr.IndexOfName('count_view_birthday_skoro')>-1 then
  begin
    val(nastr.Values['count_view_birthday_skoro'],r,code);
    if code=0 then
       count_view_birthday_skoro:=r;
  end else count_view_birthday_skoro:=9;
  if nastr.IndexOfName('color_frm')>-1 then
  begin
    Color_frm:=stringtocolor(nastr.Values['color_frm']);
  end else Color_frm:=TColor(Default_color_frm);
  if nastr.IndexOfName('color_ligth_Edge')>-1 then
  begin
    color_ligth_Edge:=stringtocolor(nastr.Values['color_ligth_Edge']);
  end else color_ligth_Edge:=TColor(myTreeInBMP.DefaultColorEdge_Ligth);
  if nastr.IndexOfName('color_Edge')>-1 then
  begin
    color_Edge:=stringtocolor(nastr.Values['color_Edge']);
  end else color_Edge:=TColor(myTreeInBMP.DefaultColorEdge);
  if nastr.IndexOfName('color_BackGround')>-1 then
  begin
    color_BackGround:=stringtocolor(nastr.Values['color_BackGround']);
  end else color_BackGround:=TColor(myTreeInBMP.DefaultcolorBackGround);
  myTreeInBMP.Color_BackGround:=color_BackGround;
  if nastr.IndexOfName('color_Foto')>-1 then
  begin
    color_Foto:=stringtocolor(nastr.Values['color_Foto']);
  end else color_Foto:=TColor(myTreeInBMP.Defaultcolor_Foto);
  if nastr.IndexOfName('color_Bevel_Foto')>-1 then
  begin
    color_Bevel_Foto:=stringtocolor(nastr.Values['color_Bevel_Foto']);
  end else color_Bevel_Foto:=TColor(myTreeInBMP.Defaultcolor_Bevel_Foto);
  if nastr.IndexOfName('color_CaptionNode')>-1 then
  begin
    color_CaptionNode:=stringtocolor(nastr.Values['color_CaptionNode']);
  end else color_CaptionNode:=TColor(myTreeInBMP.Defaultcolor_Caption_Node);
  if nastr.IndexOfName('beautiful_tree')>-1 then
  begin
    val(nastr.Values['beautiful_tree'],r,code);
    if code=0 then
       beautiful_tree:=boolean(r)
       else
        beautiful_tree:=true;
  end else
      beautiful_tree:=true;
  //showmessage(colortostring(color_CaptionNode));
end;

procedure TCreateTree.Setview_birthday(AValue: boolean);
begin
  if Fview_birthday=AValue then Exit;
  Fview_birthday:=AValue;
  if nastr.IndexOfName('view_birthday')=-1 then
     nastr.Add('view_birthday='+inttostr(integer(view_birthday))) else
      nastr.Values['view_birthday']:=inttostr(integer(view_birthday));
  myTreeInBMP.view_birthday:=view_birthday;
end;

procedure TCreateTree.Setview_birthday_skoro(AValue: boolean);
begin
  if Fview_birthday_skoro=AValue then Exit;
  Fview_birthday_skoro:=AValue;
  if nastr.IndexOfName('view_birthday_skoro')=-1 then
     nastr.Add('view_birthday_skoro='+inttostr(integer(view_birthday_skoro))) else
      nastr.Values['view_birthday_skoro']:=inttostr(integer(view_birthday_skoro));
  myTreeInBMP.view_birthday_skoro:=view_birthday_skoro;
end;

procedure TCreateTree.Setview_potomk(AValue: boolean);
begin
  if Fview_potomk=AValue then Exit;
  Fview_potomk:=AValue;
  if nastr.IndexOfName('view_potomk')=-1 then
     nastr.Add('view_potomk='+inttostr(integer(view_potomk))) else
      nastr.Values['view_potomk']:=inttostr(integer(view_potomk));
  myTreeInBMP.view_potomk:=view_potomk;
end;

procedure TCreateTree.Setview_predk(AValue: boolean);
begin
  if Fview_predk=AValue then Exit;
  Fview_predk:=AValue;
  if nastr.IndexOfName('view_predk')=-1 then
     nastr.Add('view_predk='+inttostr(integer(view_predk))) else
      nastr.Values['view_predk']:=inttostr(integer(view_predk));
  myTreeInBMP.view_predk:=view_predk;
end;

procedure TCreateTree.SelectedNode;
var
  y,m,d:word;
begin
  if Image.ShowHint=(TrSelNode in myTreeInBMP.SostTree) then exit;
  Image.ShowHint:=(TrSelNode in myTreeInBMP.SostTree)and
  (not (myTreeInBMP.GetNodesIDNode(myTreeInBMP.GetSelNodeIndex).dtbirthday>1.7E307)or(not (myTreeInBMP.GetNodesIDNode(myTreeInBMP.GetSelNodeIndex).dtdeath>1.7E307)));
  if TrSelNode in myTreeInBMP.SostTree  then
  begin
    Image.Cursor:=crHandPoint;
    //self.Cursor:=crCross;;
    Image.Hint:='';
    if not (myTreeInBMP.GetNodesIDNode(myTreeInBMP.GetSelNodeIndex).dtbirthday>1.7E307) then
       Image.Hint:=datetostr( myTreeInBMP.GetNodesIDNode(myTreeInBMP.GetSelNodeIndex).dtbirthday);
    if (not (myTreeInBMP.GetNodesIDNode(myTreeInBMP.GetSelNodeIndex).dtdeath>1.7E307))then
    begin
      DecodeDate(myTreeInBMP.GetNodesIDNode(myTreeInBMP.GetSelNodeIndex).dtdeath,y,m,d);
      //showmessage(myTreeInBMP.GetNodesIDNode(myTreeInBMP.GetSelNodeIndex).Caption+lineending+      datetostr(myTreeInBMP.GetNodesIDNode(myTreeInBMP.GetSelNodeIndex).dtdeath));
      if (y>1900)or((y=1900)and((m>1)or(d>1))) then
       Image.Hint:=Image.Hint+lineending+datetostr( myTreeInBMP.GetNodesIDNode(myTreeInBMP.GetSelNodeIndex).dtdeath);
    end;
    Image.ShowHint:=not(Image.Hint='');
  end else
  Image.Cursor:=crDefault; ;
end;

function TCreateTree.startpos: boolean;
var
  SQLQuery:TSQLQuery;
  i:integer;
begin
  SQLQuery:=rod.GetPredokForStart;//Получим список для выбора
  frmstartpos:=Tfrmstartpos.Create(self);
  frmstartpos.SQLQueryPotomk:=SQLQuery;
  SQLQuery:=rod.GetPotomkForStart;//Получим следующий список для выбора
  frmstartpos.SQLQueryPredki:=SQLQuery;
  SQLQuery:=rod.GetAllPeopleForStart;//Получим следующий список для выбора
  frmstartpos.SQLQueryPeople:=SQLQuery;
  frmstartpos.workdb:=rod;
  if frmstartpos.ShowModal=mrok then
   begin
     case frmstartpos.Vibor of
         ViborTreePotomk:
                   begin
                    // Visible:=false;
                     //myTreeInBMP.removeAllNodes;
                     myTreeInBMP.RemoveAllEdgeAndNodeLevelNil;
                     myTreeInBMP.Napravlenie:=NapravlenieUp;
                     GetPotomk(frmstartpos.ID);
                     myTreeInBMP.Sorting:=true;
                     DrawTree;
                     PositionX:=myTreeInBMP.PositionX[frmstartpos.ID];//myTreeInBMP.GetNodesIDNode(frmstartpos.ID).NodeCenter.x/myTreeInBMP.BMP.Width;
                     PositionY:=myTreeInBMP.PositionY[frmstartpos.ID];//myTreeInBMP.GetNodesIDNode(frmstartpos.ID).NodeCenter.y/myTreeInBMP.BMP.Height;
                     HorzScrollBar.Position:=100000;
                     HorzScrollBar.Position:= round(HorzScrollBar.Position*PositionX);
                     VertScrollBar.Position:=100000;
                     VertScrollBar.Position:=round(VertScrollBar.Position*PositionY);
                     myTreeInBMP.Sorting:=false;
                     //Visible:=true;
                   end;
         ViborTreeAny:
                   begin
                     //myTreeInBMP.removeAllNodes;
                     myTreeInBMP.RemoveAllEdgeAndNodeLevelNil;
                     myTreeInBMP.Napravlenie:=NapravlenieUp;
                     GetPotomk(frmstartpos.ID);
                     GetPredok(frmstartpos.ID, true);
                     state:=SelectAny;
                     DrawTree;
                     PositionX:=myTreeInBMP.PositionX[frmstartpos.ID];
                     PositionY:=myTreeInBMP.PositionY[frmstartpos.ID];
                     HorzScrollBar.Position:=100000;
                     HorzScrollBar.Position:= round(HorzScrollBar.Position*PositionX);
                     VertScrollBar.Position:=100000;
                     VertScrollBar.Position:=round(VertScrollBar.Position*PositionY);
                     //PositionX:=myTreeInBMP.GetNodesIDNode(frmstartpos.ID).NodeCenter.x/myTreeInBMP.BMP.Width;
                     //PositionY:=myTreeInBMP.GetNodesIDNode(frmstartpos.ID).NodeCenter.y/myTreeInBMP.BMP.Height;
                     //showmessage(floattostr(PositionY));
                   end;
         ViborTreePredki:
                   begin
                     //myTreeInBMP.removeAllNodes;
                     myTreeInBMP.RemoveAllEdgeAndNodeLevelNil;
                     myTreeInBMP.Napravlenie:=NapravlenieDown;
                     GetPredok(frmstartpos.ID);
                     DrawTree;
                     PositionX:=myTreeInBMP.PositionX[frmstartpos.ID];
                     PositionY:=myTreeInBMP.PositionY[frmstartpos.ID];
                     HorzScrollBar.Position:=100000;
                     HorzScrollBar.Position:= round(HorzScrollBar.Position*PositionX);
                     VertScrollBar.Position:=100000;
                     VertScrollBar.Position:=round(VertScrollBar.Position*PositionY);
                     //PositionX:=myTreeInBMP.GetNodesIDNode(frmstartpos.ID).NodeCenter.x/myTreeInBMP.BMP.Width;
                     //PositionY:=myTreeInBMP.GetNodesIDNode(frmstartpos.ID).NodeCenter.y/myTreeInBMP.BMP.Height;
                     myTreeInBMP.Sorting:=true;
                     myTreeInBMP.Sorting:=false;
                   end;
         ViborTreeNew:
                   begin
                     myTreeInBMP.Napravlenie:=NapravlenieUp;
                      for i:=0 to PopupMenu1.Items.Count-1 do if PopupMenu1.Items.Items[i].name='newTree' then break;
                      MenuItemClick(PopupMenu1.Items.Items[i]);
                      PositionX:=0;
                      PositionY:=0;
                      //GetPotomk(frmstartpos.ID);
                   end;
     end;
     frmstartpos.SQLQueryPotomk.Free;
     frmstartpos.SQLQueryPredki.Free;
     frmstartpos.SQLQueryPeople.Free;
     result:=true;
   end else result:=false;
   //SQLQuery.Free;
  FreeAndNil(frmstartpos);
  {self.VertScrollBar.Position:=10000000;
  showmessage(inttostr(self.image.Height- self.ClientHeight)+lineending+
  inttostr(self.VertScrollBar.Position));}
end;

function TCreateTree.addpeople(ppl: Tpeople; predok: boolean): integer;
var
  txtDlg:string;
  Q:TSQLQuery;
begin
  result:=-1;
  try
    //t1:=gettickcount64;
    result:=rod.addpeople(ppl,predok);
    //t2:=gettickcount64;
    //showmessage(inttostr(t2-t1));
  except      on E: Exception do
               begin
                 //Выводим сообщение
                 if utf8pos('double people',
                 e.Message,1)>0 then
                                 begin
                                   txtDlg:='Воспользуйтесь пунктом "добавить ';
                                   if predok then
                                      txtDlg:=txtDlg+'предка'
                                      else
                                       txtDlg:=txtDlg+'потомка';
                                   txtDlg:=txtDlg+' из имеющихся"';
                                 messagedlg('ошибка','В базе такой человек уже есть.'+lineending+
                                 txtDlg,mtInformation,[mbok],0)
                                 end else
                                 if utf8pos('many_prnts',
                 e.Message,1)>0 then messagedlg('ошибка','уже есть два родителя!',mtWarning,[mbok],0)
                 else messagedlg('ошибка',e.Message,mtInformation,[mbok],0);
                 exit;
               end;
  end;
  myTreeInBMP.Sorting:=true;
  if (ppl.predok_potomok=-1) then
   begin
     myTreeInBMP.addNode(ppl.ID).Caption:=ppl.fam+' '+ppl.nam+lineending+ppl.otch;
     myTreeInBMP.GetNodesIDNode(ppl.ID).Death:=ppl.Death;
     myTreeInBMP.GetNodesIDNode(ppl.ID).Flag:=ppl.flag;
     myTreeInBMP.GetNodesIDNode(ppl.ID).avatar:=ppl.foto;
     FID_koren:=ppl.ID;
     state:=SelectPotomok;
     DrawTree;
   end else
   if predok then
    begin
      myTreeInBMP.addEdge(result, ppl.predok_potomok);
      if state=SelectPredok then
       begin
         myTreeInBMP.Caption:={CaptionTree +} '(предки)';
         myTreeInBMP.Napravlenie:=NapravlenieDown;
         myTreeInBMP.GetNodesIDNode(result).Caption:=ppl.fam+' '+ppl.nam+lineending+ppl.otch;
         myTreeInBMP.GetNodesIDNode(ppl.ID).Death:=ppl.Death;
         myTreeInBMP.GetNodesIDNode(ppl.ID).Flag:=ppl.flag;
         myTreeInBMP.GetNodesIDNode(ppl.ID).avatar:=ppl.foto;
         myTreeInBMP.DrawTree(FID_koren,width,height,true,state=SelectAny);
       end else
       begin
         state:=SelectPredok;
         myTreeInBMP.Caption:={CaptionTree +} '(предки)';
         myTreeInBMP.Napravlenie:=NapravlenieDown;
         myTreeInBMP.GetNodesIDNode(result).Caption:=ppl.fam+' '+ppl.nam+lineending+ppl.otch;
         myTreeInBMP.GetNodesIDNode(ppl.ID).Death:=ppl.Death;
         myTreeInBMP.GetNodesIDNode(ppl.ID).Flag:=ppl.flag;
         myTreeInBMP.GetNodesIDNode(ppl.ID).avatar:=ppl.foto;
         FID_koren:=ppl.predok_potomok;
         GetPredok(FID_koren);
         myTreeInBMP.DrawTree(FID_koren,width,height,true,state=SelectAny);
       end;
       if (rod.GetCountSelParentForAddParent(ppl.predok_potomok)>0) and (QuestionDlg('добавление второго родителя','У '+
       myTreeInBMP.GetNodesIDNode(ppl.predok_potomok).Caption+' есть родные '+'братья/сестры.'+lineending+
       'Добавить данного родителя?',mtConfirmation,[mrYes,'добавить','isdefault',mrNo,'Не добавлять'],'')=mryes) then
                begin
                  rod.AddParentTwoForAddParent(ppl.predok_potomok);
                end;
    end else
    begin
      //t1:=gettickcount64;
      myTreeInBMP.addEdge(ppl.predok_potomok,result);
      if state=SelectPotomok then
       begin
         myTreeInBMP.Caption:={CaptionTree +} '(потомки)';
         myTreeInBMP.Napravlenie:=NapravlenieUp;
         myTreeInBMP.GetNodesIDNode(result).Caption:=ppl.fam+' '+ppl.nam+lineending+ppl.otch;
         myTreeInBMP.GetNodesIDNode(ppl.ID).Death:=ppl.Death;
         myTreeInBMP.GetNodesIDNode(ppl.ID).Flag:=ppl.flag;
         myTreeInBMP.GetNodesIDNode(ppl.ID).avatar:=ppl.foto;
         myTreeInBMP.DrawTree(FID_koren,width,height,true,state=SelectAny);
         //t2:=gettickcount64;
    //showmessage(inttostr(t2-t1));
       end else
       begin
         state:=SelectPotomok;
         myTreeInBMP.Caption:={CaptionTree +} '(потомки)';
         myTreeInBMP.Napravlenie:=NapravlenieUp;
         myTreeInBMP.GetNodesIDNode(result).Caption:=ppl.fam+' '+ppl.nam+lineending+ppl.otch;
         myTreeInBMP.GetNodesIDNode(ppl.ID).Death:=ppl.Death;
         myTreeInBMP.GetNodesIDNode(ppl.ID).Flag:=ppl.flag;
         myTreeInBMP.GetNodesIDNode(ppl.ID).avatar:=ppl.foto;
         FID_koren:=result;
         GetPotomk(FID_koren);
         myTreeInBMP.DrawTree(FID_koren,width,height,true,state=SelectAny);
       end;
       //showmessage(inttostr(rod.GetCountSelParent(ppl.ID)));
       Q:=rod.GetParentTwo(ppl.id);
       if Q<>nil then
        begin
          frmNodeFromBD:=TfrmNodeFromBD.Create(self);
          frmNodeFromBD.frmCaption:='Добавление второго родителя';
          frmNodeFromBD.SQLQuery:=Q;
          if frmNodeFromBD.ShowModal=mrok then
           begin
             AddConnect(frmNodeFromBD.ID_Select, ppl.id, true);
           end;
          if frmNodeFromBD<>nil then  frmNodeFromBD.Free;
          if Q<>nil then FreeAndNil(Q);
        end;
    end;
  myTreeInBMP.Sorting:=false;
end;

function TCreateTree.savepeople(ppl: Tpeople; id: integer): boolean;
begin
  try
  result:=rod.savepeople(ppl,id);
  except      on E: Exception do
               begin
                 //Выводим сообщение
                 if utf8pos('double people',
                 e.Message,1)>-1 then
                                 messagedlg('ошибка','В базе такой человек уже есть.'+lineending+
                                 'Воспользуйтесь пунктом "добавить потомка/предка из имеющихся"',mtInformation,[mbok],0)
                                 else messagedlg('ошибка',e.Message,mtInformation,[mbok],0);
                 exit;
               end;
  end;
  myTreeInBMP.GetNodesIDNode(id).Caption:=ppl.fam+' '+ppl.nam+lineending+ppl.otch;
  myTreeInBMP.GetNodesIDNode(id).Death:=ppl.Death;
  myTreeInBMP.GetNodesIDNode(id).dtbirthday:=ppl.dateBorn;
  myTreeInBMP.GetNodesIDNode(id).dtdeath:=ppl.dateDeath;
  //showmessage(datetostr(ppl.dateDeath));
  myTreeInBMP.GetNodesIDNode(id).Flag:=ppl.flag;
  myTreeInBMP.GetNodesIDNode(id).avatar:=ppl.foto;
  myTreeInBMP.DoClearNode(myTreeInBMP.GetNodesIDNode(id));
  myTreeInBMP.DoDrawNode(myTreeInBMP.GetNodesIDNode(id));
  //перерисуем лист
  myTreeInBMP.DoDrawNode(myTreeInBMP.GetNodesIDNode(id));
  myTreeInBMP.refresh;
end;

{ Tworkdb }
end.

