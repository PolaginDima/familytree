unit mygraphinbmp;
//Получить построенную картинку BMP(граф) можно двумя способами
//1) с помощью свойства BMP предварительно вызвав DrawTree
//2) непосредственно из класса подключив компонент Image к классу
{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, mygraphinmemory, Graphics, mygraphbmp, lazutf8, GraphType,
  ExtCtrls, dialogs, FPReadJPEG, IntfGraphics, FPimage;
 type
      FProgressEvent=procedure(Position:integer;caption:string) of object;
      FSelectedNodeEvent=procedure of object;
 type
      TNapravlenie=(NapravlenieDown,NapravlenieUp);
      TSostTr=(TrSelNode);
     TSostTree=set of TSostTr ;
type

     { TJPEGImagePlus }

     TJPEGImagePlus = class(TJPEGImage)
      private
        FScale: TJPEGScale;
      protected
        procedure InitializeReader(AImage: TLazIntfImage;
          AReader: TFPCustomImageReader); override;
      public
        property Scale: TJPEGScale read FScale write FScale;
      end;

     { TMyTreeInBMP }

     TMyTreeInBMP=class(TMyGraphinMemory)
       private
         FMessageErr:string;
         Fbeautiful_tree: boolean;
         FMinDistance:cardinal;
         FbmpMask:TBitMap;
         FBMPBackground:TBitMap;
         FBMPBorder:TBitMap;
         FColor_BackGround: TColor;
         //Fcolor_Bevel_Foto: TColor;
         //Fcolor_CaptionNode: TColor;
         FColor_Edge: TColor;
         FColor_Edge_Ligth: TColor;
         //Fcolor_Foto: TColor;
         Fcount_view_potomk: integer;
         Fcount_view_predk: integer;
         FflagDraw:boolean;
         FListDrawEdge:TList;
         FlistDraw:TList;
         FlistVisible:TList;
         FListReDraw:TList;
         FDrawClear:boolean;
         FID_Koren:integer;
         FKoefM:double;//коеффициент масштабирования
         FBeetweenHeight: integer;
         FBeetweenWidth: integer;
         FBMP:TbitMap;
         FBMPFon:TBitMap;
         FBottomHeight: integer;
         FCaption: string;
         FFotoHeight: integer;
         FFotoWidth: integer;
         FGetSelNodeIndex: integer;
         FImage: TImage;
         FLeftWidth: integer;
         FMaxNodeinLevel: integer;
         FOnProgressEvent: FProgressEvent;
         FOnSelectedNodeEvent:FSelectedNodeEvent;
         FpicBackGround: string;
         FpicBorder: string;
         FRigthWidth: integer;
         FSizeCanvas: TPoint;
         FNapravlenie: TNapravlenie;
         FPercentM: integer;
         DefaultNodeStyle:TNodeStyle;
         DefaultEdgeStyle:TEdgeStyle;
         FSostTree: TSostTree;
         FTextHeight: integer;
         FTopHeight: integer;
         Fview_birthday: boolean;
         Fview_birthday_skoro: boolean;
         Fview_potomk: boolean;
         Fview_predk: boolean;
         FwidthBorder: integer;
         FSizeCaptionMain:integer;
         FSizeCaption:integer;
         SelectNodeStyle:TNodeStyle;
         SelectEdgeStyle:TEdgeStyle;
         ClearEdgeStyle:TEdgeStyle;
         FTxtH: integer;
         function GetBMP: TBitMap;
         function ComputeSizeCanvas:TPoint;inline;
         function CreateFotoFromMask(r:TRect;jpg:TJPEGImagePlus):TBitMap;inline;
         procedure SetFonBMP;
         procedure CreateMask();inline;
         procedure ClearPreviouseSelectNode;
         procedure ComputeNodeCoords_old;
         procedure ComputeNodeCoords;
         procedure ComputeEdgeCoords;
         procedure DoSpisDrawEdges;
         procedure DoSpisDrawNodes;
         procedure ClearEdges;
         procedure DoDrawEdge(Edge: TEdge;OLD:boolean=false;Color:TColor=-$1); // draw line at Edge.DrawX1,Y1,X2,Y2 with current Canvas colors
         procedure DrawCaption(NodeCaption:string;x, y:integer;Clear:Boolean=false);
         procedure DrawCaptions(Node:TNode=nil;Clear:boolean=false;OLD:boolean=false);
         procedure ClearNodes;inline;
         procedure DrawNodes;
         procedure DrawEdges;
         function Getcolor_BevelFoto: TColor;
         function Getcolor_Bevel_Foto: TColor;
         function Getcolor_CaptionNode: TColor;
         function Getcolor_Caption_Node: TColor;
         function Getcolor_Foto: TColor;
         function GetDefaultColorBackGround: TColor;
         function GetDefaultColorEdge: TColor;
         function GetDefaultColorEdge_Ligth: TColor;
         function GetDefaultcolor_Foto: TColor;
         //function GetDefaultColor_BackGround: TColor;
         function GetMaxNodeInLevels: integer;inline;
         function GetPositionX(id: integer): extended;
         function GetPositionY(id: integer): extended;
         procedure LigthPredkPotomk(Node:TNode;Clear:boolean=false);inline;
         procedure Setbeautiful_tree(AValue: boolean);
         procedure SetCaption(AValue: string);
         procedure SetColor_BackGround(AValue: TColor);
         procedure Setcolor_Bevel_Foto(AValue: TColor);
         procedure Setcolor_CaptionNode(AValue: TColor);
         procedure SetColor_Edge(AValue: TColor);
         procedure SetColor_Edge_Ligth(AValue: TColor);
         procedure Setcolor_Foto(AValue: TColor);
         procedure Setcount_view_potomk(AValue: integer);
         procedure Setcount_view_predk(AValue: integer);
         procedure SetPercentM(AValue: integer);
         procedure Calculate;
         procedure DrawTreeID(IDNode:integer;LeftBevel,rightBevel:integer);//overload;
         //procedure DrawTreeID(IDNode:integer;countChild:byte);overload;
         procedure Drawing;inline;
         procedure resizing(Iwidth: integer; Iheight: integer;IDNode: integer=-1);
         procedure CheckVisible;inline;
         procedure checkReDraw;inline;
         procedure DrawSelected(Node:TNode;Clear:boolean=false;Color:TColor=-$1);
         procedure SetpicBackGround(AValue: string);
         procedure SetpicBorder(AValue: string);
         procedure Setview_birthday(AValue: boolean);
         procedure Setview_birthday_skoro(AValue: boolean);
         procedure Setview_potomk(AValue: boolean);
         procedure Setview_predk(AValue: boolean);
         procedure SortingNodeInLevels;inline;
       protected
         function CreatedNode(idNode:integer):TNode;override;
         function CreatedEdge(SourceTop,TargetBottom:TObject):TEdge;override;
         function CreatedLevel:TLevel;override;
         procedure DoDrawClearNode(NodeCenter: TPoint);
         procedure DoDrawClearEdgeFromNode(Node:TNode;OLD:boolean=false);inline;
         property TxtH:integer read FTxtH write FTxtH;
         procedure AfterAddEdge(Sender:TObject);override;
         procedure AfterAddNode(Sender:TObject);override;
         procedure BeforeRemoveEdge(Sender:TObject);override;
         procedure BeforeRemoveNode(Sender:TObject);override;
       public
         constructor Create;override;
         destructor Destroy;override;
         function addNode(idNode:integer):TNode;override;
         function GetNodesIDNode(IDNode: integer): TNode;override;
         function mouseMove_old(X,  Y: Integer):boolean;
         function mouseMove(X,  Y: Integer):boolean;
         function addEdge(idSourceTop,idTargetBottom:integer):TEdge;override;
         procedure ClearSelection;
         procedure DrawTreeClear;
         procedure DoClearNode(Node: TNode);
         procedure DoDrawNode(Node: TNode);inline;
         //procedure AddDrawTreeDown(IDNode:integer;FCalculateON: boolean=true);overload;
         procedure DrawTree(IDNode:integer;FCalculateON: boolean=true; UpDaown:boolean=false);overload;
         procedure DrawTree(IDNode:integer;Iwidth: integer; Iheight: integer;FCalculateON: boolean=true; UpDown:boolean=false);overload;
         procedure resizeTree(Iwidth:integer;Iheight:integer);
         procedure removeAllNodes;override;
         procedure refresh;
         property BMP:TBitMap read GetBMP write FBMP;
         property Napravlenie:TNapravlenie read FNapravlenie write FNapravlenie;
         property PercentM:integer read FPercentM write SetPercentM default 100;
         property FotoWidth:integer read FFotoWidth write FFotoWidth;
         property FotoHeight:integer read FFotoHeight write FFotoHeight;
         property BeetweenWidth:integer read FBeetweenWidth write FBeetweenWidth;
         property BeetweenHeight:integer read FBeetweenHeight write FBeetweenHeight;
         property TextHeight:integer read FTextHeight write FTextHeight;
         property TopHeight:integer read FTopHeight write FTopHeight;
         property BottomHeight:integer read FBottomHeight write FBottomHeight;
         property LeftWidth:integer read FLeftWidth write FLeftWidth;
         property RigthWidth:integer read FRigthWidth write FRigthWidth;
         property widthBorder:integer read FwidthBorder write FwidthBorder;
         property SizeCaptionMain:integer read FSizeCaptionMain write FSizeCaptionMain;
         property SizeCaption:integer read FSizeCaption write FSizeCaption;
         property MaxNodeInLevels:integer read FMaxNodeinLevel;
         property Caption: string read FCaption write SetCaption;
         property Image:TImage read FImage write FImage;
         property GetSelNodeIndex:integer read FGetSelNodeIndex write FGetSelNodeIndex;
         property SostTree:TSostTree read FSostTree write FSostTree;
         property OnProgressEvent:FProgressEvent read FOnProgressEvent write FOnProgressEvent;
         property OnSelectedNodeEvent:FSelectedNodeEvent read FOnSelectedNodeEvent write FOnSelectedNodeEvent;
         property view_predk:boolean read Fview_predk write Setview_predk;
         property count_view_predk:integer read Fcount_view_predk write Setcount_view_predk;
         property view_potomk:boolean read Fview_potomk write Setview_potomk;
         property count_view_potomk:integer read Fcount_view_potomk write Setcount_view_potomk;
         property view_birthday:boolean read Fview_birthday write Setview_birthday;
         property view_birthday_skoro:boolean read Fview_birthday_skoro write Setview_birthday_skoro;
         property beautiful_tree:boolean read Fbeautiful_tree write Setbeautiful_tree;
         property picBackGround:string read FpicBackGround write SetpicBackGround;
         property picBorder:string read FpicBorder write SetpicBorder;
         property DefaultColorBackGround:TColor read GetDefaultColorBackGround;
         property Color_BackGround:TColor read FColor_BackGround write SetColor_BackGround;
         property Defaultcolor_Foto:TColor read GetDefaultcolor_Foto;
         property color_Foto:TColor read Getcolor_Foto write Setcolor_Foto;
         property Defaultcolor_Caption_Node:TColor read Getcolor_Caption_Node;
         property color_CaptionNode:TColor read Getcolor_CaptionNode write Setcolor_CaptionNode;
         property Defaultcolor_Bevel_Foto:TColor read Getcolor_BevelFoto;
         property color_Bevel_Foto:TColor read Getcolor_Bevel_Foto write Setcolor_Bevel_Foto;
         property DefaultColorEdge_Ligth:TColor read GetDefaultColorEdge_Ligth;
         property Color_Edge_Ligth:TColor read FColor_Edge_Ligth write SetColor_Edge_Ligth;
         property DefaultColorEdge:TColor read GetDefaultColorEdge;
         //property DefaultColor_BackGround:TColor read GetDefaultColor_BackGround;
         property Color_Edge:TColor read FColor_Edge write SetColor_Edge;
         property PositionX[id:integer]:extended read GetPositionX;
         property PositionY[id:integer]:extended read GetPositionY;
     end;

implementation

{ TJPEGImagePlus }

procedure TJPEGImagePlus.InitializeReader(AImage: TLazIntfImage;
  AReader: TFPCustomImageReader);
begin
  (AReader as TFPReaderJpeg).Scale := FScale;
      //inherited;
      inherited InitializeReader(AImage, AReader);
end;

{ TMyTreeInBMP }

function TMyTreeInBMP.GetBMP: TBitMap;
begin
  result:=FBMP;
end;

function TMyTreeInBMP.ComputeSizeCanvas: TPoint;inline;
begin
  if not beautiful_tree then fSizeCanvas.x:=(LeftWidth+({widthBorder*2+}BeetweenWidth+FotoWidth)*GetMaxNodeInLevels-BeetweenWidth+rigthwidth);
  fSizeCanvas.y:=(TopHeight+({widthBorder*2}+FotoHeight+TextHeight+BeetweenHeight)*countLevel-BeetweenHeight+BottomHeight+FTxtH*countLevel);
  result:=FSizeCanvas;
end;

function TMyTreeInBMP.CreateFotoFromMask(r: TRect; jpg: TJPEGImagePlus
  ): TBitMap;inline;
var
  bmpF:TBitMap;
  {rMask:TRect;
  razn:integer;
  W:integer;
  const
    prop = 0.8;}
begin
  bmpF:=TBitMap.Create;
  bmpF.SetSize(r.Width,r.Height);//Установим размер
  if FBMPBorder<>nil then
   begin
     bmpF.Transparent:=true;//включим прозрачность
     bmpF.TransparentMode:=tmFixed;//цвет прозрачности будем задавать сами
     bmpF.TransparentColor:=ColorTransparent1;//задаем прозрачный цвет - черный
     bmpF.Canvas.Brush.Color:=ColorTransparent1;//цвет кисти
     bmpF.Canvas.Pen.Color:=ColorTransparent1;//цвет карандаша
     bmpF.Canvas.Rectangle(Rect(0,0,r.Width,r.Height));//зальем
   end;

  bmpF.Canvas.StretchDraw({r}rect(0,0,bmpF.Width,bmpF.Height),jpg);//нарисуем фото
  //showmessage(inttostr(FbmpMask.Width));
  //razn:=(FbmpMask.Width-bmpF.Width) div 2;
 { if (r.Width/r.Height)>prop then
   begin
    razn:=(FbmpMask.Height-r.Height) div 2;

    FbmpMask.Canvas.Brush.Color:=clblack;
    FbmpMask.Canvas.Pen.Color:=clblack;
    FbmpMask.Canvas.Rectangle(rect(0,0,FbmpMask.Width,FbmpMask.Height));
    FbmpMask.Canvas.Pen.Color:=clwhite;
    FbmpMask.Canvas.Brush.Color:=clwhite;
    W:=round(r.Height*prop);
    FbmpMask.Canvas.Ellipse(rect((FbmpMask.Width-W) div 2,razn,((FbmpMask.Width-W) div 2)+W,razn+r.Height));

    //rMask:=Rect(razn,0,bmpF.Width-razn,bmpF.Height);
    bmpF.Canvas.Draw(0,0,FbmpMask);
   end else
   begin
     {razn:=(bmpF.Height*prop);
     razn:=(bmpF.Width-razn) div 2;}
     rMask:=Rect(0,0,bmpF.Width,bmpF.Height);
   end; }
  //bmpF.Canvas.StretchDraw(rMask, FbmpMask);//наложим маску на фото
  //bmpF.Canvas.Draw(0,0, FbmpMask);//наложим маску на фото
  if FBMPBorder<>nil then
   bmpF.Canvas.StretchDraw(rect(0,0,bmpF.Width,bmpF.Height),FbmpMask);
  //showmessage(inttostr(bmpF.Width));
  result:=bmpF;
end;

procedure TMyTreeInBMP.SetFonBMP;
begin
  if picBackGround='' then
           begin
                FBMP.Canvas.Brush.Style:=bsSolid;
                FBMP.Canvas.Brush.Color:=Color_BackGround;
                FBMP.Canvas.pen.Color:=Color_BackGround;
                FBMP.Canvas.FillRect(bounds(0,0,FBMP.Width,FBMP.Height));
           end else
             FBMP.Canvas.Draw(0,0,FBMPFon);
end;

procedure TMyTreeInBMP.CreateMask();inline;
begin
  if FBMPBorder=nil then exit;
  if FbmpMask=nil then
   begin
    FbmpMask:=TBitMap.Create;
    FbmpMask.Transparent:=true;//включим прозрачность
    FbmpMask.TransparentMode:=tmFixed;//цвет прозрачности будем задавать сами
    FbmpMask.TransparentColor:=ColorTransparentMask; //задаем прозрачный цвет - белый
   end;
  FbmpMask.Clear;
  FbmpMask.SetSize(round(FotoHeight*FkoefM),round(FotoHeight*FkoefM));
  FbmpMask.Canvas.Brush.Color:=ColorTransparent1;
  FbmpMask.Canvas.Pen.Color:=ColorTransparent1;
  FbmpMask.Canvas.Rectangle(rect(0,0,FbmpMask.Width,FbmpMask.Height));
  FbmpMask.Canvas.Pen.Color:=ColorTransparentMask;
  FbmpMask.Canvas.Brush.Color:=ColorTransparentMask;
  //FbmpMask.Canvas.Ellipse(rect(0,0,FbmpMask.Width,FbmpMask.Height));
  //FbmpMask.Canvas.Draw(0,0, FBMPBorder);
  FbmpMask.Canvas.StretchDraw(rect(0,0,FbmpMask.Width,FbmpMask.Height), FBMPBorder);
  //FbmpMask.Assign(FBMPBorder);
  //showmessage(inttostr(FbmpMask.Width));
end;

procedure TMyTreeInBMP.ComputeNodeCoords_old;
var
  i,lev, nod, cnt:integer;
  x0,y0,stepX,intX,stepY,x1,y1:integer;
  redraw:boolean;
  Node:Tnode;
begin
  //Вычислим координаты цетров прямоугольников
  stepY:=(widthBorder*2+FotoHeight+BeetweenHeight+TxtH);
   y0:=(TopHeight+(FotoHeight div 2)+stepY*(countLevel-1));
  {FBMP.canvas.Pen.Width:=3;
  FBMP.canvas.Pen.Style:=psSolid;}
  //переберем Nod-ы по списку
  cnt:=flistDraw.Count;
  for i:=0 to cnt-1 do
  begin
       //Получим Node
       Node:=TNode(flistDraw.Items[i]);
       //Получим уровень из Node
       lev:=GetLevelNumber(Node);
       nod:=Getlevels(lev).countNode;
       intX:=((FotoWidth+BeetweenWidth)*Getlevels(lev).countNode)-BeetweenWidth;
       intX:=(FSizeCanvas.x{canvas.Width}-LeftWidth-RigthWidth-intX) div (Getlevels(lev).countNode+1);
       stepX:=FotoWidth+BeetweenWidth+intX;
       x0:=leftWidth+intX+(FotoWidth div 2);
       //Получим номер Node на уровне
       nod:=GetNodeNumberInLevel(Node);
       x1:=(x0+stepX*nod);
       y1:=(y0-stepY*lev);
       (GetLevels(lev).GetNodes(nod) as TNode).NodeCenterOLD:=(GetLevels(lev).GetNodes(nod) as TNode).NodeCenter;
       (GetLevels(lev).GetNodes(nod) as TNode).NodeCenter:=Point(round(FKoefM*x1),round(FKoefM*y1));
       redraw:=
       ((GetLevels(lev).GetNodes(nod) as TNode).NodeCenterOLD.x<>(GetLevels(lev).GetNodes(nod) as TNode).NodeCenter.x)or
      ((GetLevels(lev).GetNodes(nod) as TNode).NodeCenterOLD.y<>(GetLevels(lev).GetNodes(nod) as TNode).NodeCenter.y)or
      ((flistVisible.IndexOf(GetLevels(lev).GetNodes(nod) as TNode)<0)and(flistDraw.IndexOf(GetLevels(lev).GetNodes(nod) as TNode)>-1));
      if redraw then
       FListReDraw.Add(GetLevels(lev).GetNodes(nod) as TNode);
  end;
end;

procedure TMyTreeInBMP.ComputeNodeCoords;
var
  i,lev, nod, cnt:integer;
  x0,y0,stepX,intX,stepY,x1,y1,minX,maxX:integer;
  tmpkoef:double;
  redraw:boolean;
  Node:Tnode;
  tmpcoord:TPoint;
begin
  //Вычислим координаты цетров прямоугольников
  stepY:=(widthBorder*2+FotoHeight+BeetweenHeight+TxtH);
   y0:=(TopHeight+(FotoHeight div 2)+stepY*(countLevel-1));
   tmpkoef:=(BeetweenWidth+FotoWidth)/FMinDistance;
  //переберем Nod-ы по списку
  cnt:=flistDraw.Count;
  minX:=maxLongint;
  maxX:=-maxLongint;
  for i:=0 to cnt-1 do
  begin
       //Получим Node
       Node:=TNode(flistDraw.Items[i]);
       //Получим уровень из Node
       lev:=GetLevelNumber(Node);
       //nod:=Getlevels(lev).countNode;//количество nod на уровне
       {intX:=((FotoWidth+BeetweenWidth)*Getlevels(lev).countNode)-BeetweenWidth;
       intX:=(FSizeCanvas.x{canvas.Width}-LeftWidth-RigthWidth-intX) div (Getlevels(lev).countNode+1);
       stepX:=FotoWidth+BeetweenWidth+intX;
       x0:=leftWidth+intX+(FotoWidth div 2);
       //Получим номер Node на уровне
       nod:=GetNodeNumberInLevel(Node);//порядковый номер nod на уровне
       x1:=(x0+stepX*nod);}
       //x0:=Node.NodeCenter.x;
       x1:=round(Node.NodeCenter.x*tmpkoef);
       if x1<minX then
        minX:=x1;
       y1:=(y0-stepY*lev);
       tmpcoord.x:=x1;
       tmpcoord.y:=round(FKoefM*y1);
       Node.NodeCenter:=tmpcoord;
       //(GetLevels(lev).GetNodes(nod) as TNode).NodeCenter:=tmpcoord;
       //(GetLevels(lev).GetNodes(nod) as TNode).NodeCenterOLD:=(GetLevels(lev).GetNodes(nod) as TNode).NodeCenter;

  end;
  for i:=0 to cnt-1 do
  begin
       //Получим Node
    Node:=TNode(flistDraw.Items[i]);
    x1:=Node.NodeCenter.x+abs(minX)+LeftWidth+(FotoWidth div 2);
    if x1>maxX then
     maxX:=x1;
    tmpcoord.x:=round(FKoefM*x1);
    tmpcoord.y:=Node.NodeCenter.y;
    Node.NodeCenter:=tmpcoord;
    redraw:=
    (Node.NodeCenterOLD.x<>Node.NodeCenter.x)or
    (Node.NodeCenterOLD.y<>Node.NodeCenter.y)or
    ((flistVisible.IndexOf(Node)<0)and(flistDraw.IndexOf(Node)>-1));
       if redraw then
        FListReDraw.Add(Node);
  end;
  fSizeCanvas.x:=maxX+(FotoWidth div 2) +RigthWidth;
end;

procedure TMyTreeInBMP.ComputeEdgeCoords;
var
  lev,nod,edg,cnt:integer;
  NodeIn,NodeOut:TNode;
  Edge:TEdge;
begin
  //Вычислим координаты концов ветвей(edge)
  for lev:=0 to countLevel-1 do
  begin
    for nod:=0 to GetLevels(lev).countNode-1 do
    begin
      nodeout:=TNode(Getlevels(lev).GetNodes(nod));
      cnt:=nodeout.outEdgecount;
      for edg:=0 to cnt -1 do
      begin
        Edge:=TEdge(nodeout.outEdges[edg]);
        nodein:=TNode(edge.TargetBottom);
        edge.DrawnAtOLD:=edge.DrawnAt;
        edge.DrawnAt:=bounds(nodeout.NodeCenter.x,
        nodeout.NodeCenter.y-round(((FotoHeight div 2)+SelectNodeStyle.WidthLine)*FkoefM),
        (nodein.NodeCenter.x-nodeout.NodeCenter.x),
        nodein.NodeCenter.y-(nodeout.NodeCenter.y-round((FotoHeight + 2*SelectNodeStyle.WidthLine+3*TxtH)*FkoefM)));
      end;
    end;
  end;
end;

procedure TMyTreeInBMP.DoSpisDrawEdges;
var
  edg, lev, nod:integer;
  Edge:TEdge;
begin
  if FListDrawEdge= nil then
   FListDrawEdge:=TList.Create else FListDrawEdge.Clear;
  for lev:=0 to countLevel-1 do
  begin
    (GetLevels(lev) as TLevel).countDrawLevelNode:=0;
    for nod:=0 to GetLevels(lev).countNode-1 do
    begin
      (GetLevels(lev) as TLevel).countDrawLevelNode:=(GetLevels(lev) as TLevel).countDrawLevelNode+1;
      if FlistDraw.IndexOf(GetLevels(lev).GetNodes(nod))<0 then continue;
      for edg:=0 to GetLevels(lev).GetNodes(nod).outEdgecount-1 do
      begin
        Edge:=TEdge(GetLevels(lev).GetNodes(nod).outEdges[edg]);
         if (flistdraw.IndexOf(Edge.TargetBottom as TNode)>-1) then
          //добавим в список, если ранее не было Edge которые надо нарисовать
          if FListDrawEdge.IndexOf(Edge)<0 then FListDrawEdge.Add(Edge);
      end;
    end;
  end;
end;

procedure TMyTreeInBMP.DoSpisDrawNodes;
begin

end;

procedure TMyTreeInBMP.ClearEdges;
var
  edg:integer;
begin
  //теперь сотрем по списку
  for edg:=0 to FListDrawEdge.Count-1 do
  begin
    TEdge(FListDrawEdge.Items[edg]).Style:=ClearEdgeStyle;
    DoDrawEdge(TEdge(FListDrawEdge.Items[edg]), true);
  end;
end;

procedure TMyTreeInBMP.DrawEdges;
var
  edg:integer;
begin
  //теперь нарисуем по списку
  for edg:=0 to FListDrawEdge.Count-1 do
  begin
    TEdge(FListDrawEdge.Items[edg]).Style:=DefaultEdgeStyle;
    DoDrawEdge(TEdge(FListDrawEdge.Items[edg]));
  end;
end;

function TMyTreeInBMP.Getcolor_BevelFoto: TColor;
begin
  result:=DefaultNodeColorLine;
end;

function TMyTreeInBMP.Getcolor_Bevel_Foto: TColor;
begin
  result:=DefaultNodeStyle.ColorLine;
end;

function TMyTreeInBMP.Getcolor_CaptionNode: TColor;
begin
  result:=DefaultNodeStyle.ColorCaption;
end;

function TMyTreeInBMP.Getcolor_Caption_Node: TColor;
begin
  result:=DefaultColorNodeCaption;
end;

function TMyTreeInBMP.Getcolor_Foto: TColor;
begin
  result:=DefaultNodeStyle.ColorFill;
end;

procedure TMyTreeInBMP.DoDrawEdge(Edge: TEdge; OLD: boolean; Color: TColor);
var
  r:TRect;
begin
  //Здесь в зависимости от каких то условий вызываются разные функции рисования
  //или линия или Curve
  if (Edge.Style.WidthLine*FkoefM)<0.8 then
     FBMP.canvas.Pen.Width:=1
     else
       if round(Edge.Style.WidthLine*FkoefM)>2 then
        FBMP.canvas.Pen.Width:=round(Edge.Style.WidthLine*FkoefM)
        else
          FBMP.canvas.Pen.Width:=2;
  if Color<$0 then
     FBMP.canvas.Pen.Color:=Edge.Style.ColorLine else
       FBMP.canvas.Pen.Color:=Color;
  if OLD then r:=Edge.DrawnAtOLD else r:=Edge.DrawnAt;
  if (picBackGround='')or(Edge.Style<>ClearEdgeStyle) then
     FBMP.Canvas.PolyBezier([Point(r.Left,r.Top),
     Point(r.Left,r.Bottom-((r.Bottom-r.Top) div 6)),
     Point(r.Right,r.Top+((r.Bottom-r.Top) div 6)),
     Point(r.Right,r.Bottom)])
     else
       if Edge.Style=ClearEdgeStyle then
        if r.Left<r.Right then
         FBMP.Canvas.CopyRect(rect(r.Left-4,r.top,r.Right+4,r.Bottom),FBMPFon.Canvas,rect(r.Left-4,r.top,r.Right+4,r.Bottom))
         else
           FBMP.Canvas.CopyRect(rect(r.Left+4,r.top,r.Right-4,r.Bottom),FBMPFon.Canvas,rect(r.Left+4,r.top,r.Right-4,r.Bottom));
  //FBMP.Canvas.Rectangle(rect(r.Left-2,r.top,r.Right+8,r.Bottom));
end;

procedure TMyTreeInBMP.DrawCaption(NodeCaption: string; x, y: integer;
  Clear: Boolean);
var
  TxtW:integer;
  TxtH_:integer;
  slova:Tstringlist;
  outtxt:string;
  RectClear:TRect;
  bmptxt:TBitMap;
begin
  bmptxt:=nil;
  slova:=Tstringlist.Create;
            if utf8length(NodeCaption)>0 then
                 begin
                      extractstrings([' '],[],pchar(NodeCaption), slova);
                      if slova.Count>1 then
                           begin
                                TxtH_:=FBMP.canvas.TextHeight(slova[0]{+' '+slova[1]});
                                TxtW:=FBMP.canvas.TextWidth(slova[0]{+' '+slova[1]});
                                outtxt:=slova[0]{+' '+slova[1]};
                           end
                      else
                      begin
                        TxtH_:=FBMP.canvas.TextHeight(slova[0]);
                        TxtW:=FBMP.canvas.TextWidth(slova[0]);
                        outtxt:=slova[0];
                      end;
                      if Clear then
                       begin
                            RectClear:=Rect(x-(TxtW div 2)-1
                            ,y+round(FKoefM*(fotoheight div 2))+
                            SelectNodeStyle.WidthLine,
                            x+(TxtW div 2)+2,
                            y+round(FKoefM*(fotoheight div 2))+
                            SelectNodeStyle.WidthLine+TxtH_);
                            {FBMP.canvas.Pen.color:=clred;;
                                      FBMP.Canvas.Rectangle(RectClear); }
                            if (picBackGround<>'')then
                             FBMP.Canvas.CopyRect(RectClear,FBMPFon.Canvas,RectClear)
                             else
                               FBMP.Canvas.Rectangle(RectClear)
                            {FBMP.canvas.Pen.color:=clred;}
                            ;
                       end
                       else
                       begin
                         if (picBackGround<>'')then
                          begin
                               bmptxt:=TBitMap.Create;
                               bmptxt.SetSize(TxtW,TxtH_);
                               //bmptxt.Canvas.AntialiasingMode:=amOff;
                               //bmptxt.canvas.Font.Style:=[fsBold];
                               bmptxt.canvas.Font.Quality:=fqNonAntialiased;
                               bmptxt.Transparent:=true;//включим прозрачность
                               bmptxt.TransparentMode:=tmFixed;//цвет прозрачности будем задавать сами
                               bmptxt.TransparentColor:=ColorTransparent1;//задаем прозрачный цвет - черный
                               bmptxt.Canvas.Brush.Color:=ColorTransparent1;//цвет кисти
                               bmptxt.Canvas.Pen.Color:=ColorTransparent1;//цвет карандаша
                               bmptxt.Canvas.Rectangle(Rect(0,0,bmptxt.Width,bmptxt.Height));//зальем
                               bmptxt.Canvas.Font.Color:=color_CaptionNode;// DefaultColorNodeCaption;
                               //showmessage(colortostring(color_CaptionNode));
                               //bmptxt.canvas.Font.Style:=bmptxt.canvas.Font.Style-[fsBold];
                               bmptxt.canvas.Font.Size:=round(FKoefM*SizeCaption);
                               bmptxt.Canvas.TextOut(0,0,outtxt);
                               {FBMP.canvas.TextOut(x-(TxtW div 2)
                               ,y+round(FKoefM*(fotoheight div 2))+
                               SelectNodeStyle.WidthLine
                               , outtxt);}
                               FBMP.Canvas.Draw(x-(TxtW div 2)
                               ,y+round(FKoefM*(fotoheight div 2))+
                               SelectNodeStyle.WidthLine
                               ,bmptxt);
                               bmptxt.Transparent:=false;
                               bmptxt.TransparentColor:=ColorTransparent2;
                          end else
                          FBMP.canvas.TextOut(x-(TxtW div 2)
                               ,y+round(FKoefM*(fotoheight div 2))+
                               SelectNodeStyle.WidthLine
                               , outtxt);
                       end;
                       if slova.Count>1 then
                           begin
                                TxtH_:=FBMP.canvas.TextHeight(slova[1]);
                                TxtW:=FBMP.canvas.TextWidth(slova[1]);
                                if Clear then
                                 begin
                                      RectClear:=Rect(x-(TxtW div 2),
                                   y+round(FKoefM*((fotoheight div 2)))+
                                   SelectNodeStyle.WidthLine+TxtH_,
                                   x+(TxtW div 2)+2,
                                   y+round(FKoefM*((fotoheight div 2)))+
                                   SelectNodeStyle.WidthLine+2*TxtH_);
                                      {FBMP.canvas.Pen.color:=clred;;
                                      FBMP.Canvas.Rectangle(RectClear);}
                                   if (picBackGround<>'')then
                                       FBMP.Canvas.CopyRect(RectClear,FBMPFon.Canvas,RectClear)
                                       else
                                         FBMP.Canvas.Rectangle(RectClear);
                                 end
                                 else
                                 begin
                                   if (picBackGround<>'')then
                                    begin
                                         bmptxt.Clear;
                                         bmptxt.SetSize(TxtW,TxtH_);
                                         bmptxt.Transparent:=true;//включим прозрачность
                                         bmptxt.TransparentMode:=tmFixed;//цвет прозрачности будем задавать сами
                                         bmptxt.TransparentColor:=ColorTransparent1;//задаем прозрачный цвет - черный
                                         bmptxt.Canvas.Brush.Color:=ColorTransparent1;//цвет кисти
                                         bmptxt.Canvas.Pen.Color:=ColorTransparent1;//цвет карандаша
                                         bmptxt.Canvas.Rectangle(Rect(0,0,bmptxt.Width,bmptxt.Height));//зальем
                                         bmptxt.Canvas.Font.Color:=color_CaptionNode;// DefaultColorNodeCaption;
                                         //bmptxt.canvas.Font.Style:=bmptxt.canvas.Font.Style+[fsBold];
                                         bmptxt.canvas.Font.Size:=round(FKoefM*SizeCaption);
                                         bmptxt.Canvas.AntialiasingMode:=amOff;
                                         bmptxt.Canvas.TextOut(0,0,slova[1]);{
                                         FBMP.canvas.TextOut(x-(TxtW div 2),
                                         y+round(FKoefM*((fotoheight div 2)+TxtH))+
                                         SelectNodeStyle.WidthLine
                                         ,slova[2]);   }
                                         FBMP.Canvas.Draw(x-(TxtW div 2),
                                         y+round(FKoefM*((fotoheight div 2)))+
                                         SelectNodeStyle.WidthLine+TxtH_
                                         ,bmptxt);
                                    end else
                                    FBMP.canvas.TextOut(x-(TxtW div 2),
                                         y+round(FKoefM*((fotoheight div 2)+TxtH))+
                                         SelectNodeStyle.WidthLine
                                         ,slova[1]);;
                                 end;
                           end;
                      if slova.Count>2 then
                           begin
                                TxtH_:=FBMP.canvas.TextHeight(slova[2]);
                                TxtW:=FBMP.canvas.TextWidth(slova[2]);
                                if Clear then
                                 begin
                                      RectClear:=Rect(x-(TxtW div 2),
                                   y+round(FKoefM*((fotoheight div 2)))+
                                   SelectNodeStyle.WidthLine+2*TxtH_,
                                   x+(TxtW div 2)+2,
                                   y+round(FKoefM*((fotoheight div 2)))+
                                   SelectNodeStyle.WidthLine+3*TxtH_);
                                      {FBMP.canvas.Pen.color:=clred;;
                                      FBMP.Canvas.Rectangle(RectClear);}
                                   if (picBackGround<>'')then
                                       FBMP.Canvas.CopyRect(RectClear,FBMPFon.Canvas,RectClear)
                                       else
                                         FBMP.Canvas.Rectangle(RectClear);
                                 end
                                 else
                                 begin
                                   if (picBackGround<>'')then
                                    begin
                                         bmptxt.Clear;
                                         bmptxt.SetSize(TxtW,TxtH_);
                                         bmptxt.Transparent:=true;//включим прозрачность
                                         bmptxt.TransparentMode:=tmFixed;//цвет прозрачности будем задавать сами
                                         bmptxt.TransparentColor:=ColorTransparent1;//задаем прозрачный цвет - черный
                                         bmptxt.Canvas.Brush.Color:=ColorTransparent1;//цвет кисти
                                         bmptxt.Canvas.Pen.Color:=ColorTransparent1;//цвет карандаша
                                         bmptxt.Canvas.Rectangle(Rect(0,0,bmptxt.Width,bmptxt.Height));//зальем
                                         bmptxt.Canvas.Font.Color:=color_CaptionNode;// DefaultColorNodeCaption;
                                         //bmptxt.canvas.Font.Style:=bmptxt.canvas.Font.Style+[fsBold];
                                         bmptxt.canvas.Font.Size:=round(FKoefM*SizeCaption);
                                         bmptxt.Canvas.AntialiasingMode:=amOff;
                                         bmptxt.Canvas.TextOut(0,0,slova[2]);{
                                         FBMP.canvas.TextOut(x-(TxtW div 2),
                                         y+round(FKoefM*((fotoheight div 2)+TxtH))+
                                         SelectNodeStyle.WidthLine
                                         ,slova[2]);   }
                                         FBMP.Canvas.Draw(x-(TxtW div 2),
                                         y+round(FKoefM*((fotoheight div 2)))+
                                         SelectNodeStyle.WidthLine+2*TxtH_
                                         ,bmptxt);
                                    end else
                                    FBMP.canvas.TextOut(x-(TxtW div 2),
                                         y+round(FKoefM*((fotoheight div 2)+2*TxtH))+
                                         SelectNodeStyle.WidthLine
                                         ,slova[2]);;
                                 end;
                           end;
                 end;
  slova.Clear;
  //if bmptxt<>nil then
   if (picBackGround<>'')then
   FreeAndNil(bmptxt);
  freeandnil(slova)
end;


{
procedure TMyTreeInBMP.DrawCaption(NodeCaption: string; x, y: integer;
  Clear: Boolean);inline;
var
  TxtW:integer;
  TxtH_:integer;
  slova:Tstringlist;
  outtxt:string;
  RectClear:TRect;
  bmptxt:TBitMap;
begin
  bmptxt:=nil;
  slova:=Tstringlist.Create;
            if utf8length(NodeCaption)>0 then
                 begin
                      extractstrings([' '],[],pchar(NodeCaption), slova);
                      if slova.Count>1 then
                           begin
                                TxtH_:=FBMP.canvas.TextHeight(slova[0]+' '+slova[1]);
                                TxtW:=FBMP.canvas.TextWidth(slova[0]+' '+slova[1]);
                                outtxt:=slova[0]+' '+slova[1];
                           end
                      else
                      begin
                        TxtH_:=FBMP.canvas.TextHeight(slova[0]);
                        TxtW:=FBMP.canvas.TextWidth(slova[0]);
                        outtxt:=slova[0];
                      end;
                      if Clear then
                       begin
                            RectClear:=Rect(x-(TxtW div 2)-1
                            ,y+round(FKoefM*(fotoheight div 2))+
                            SelectNodeStyle.WidthLine,
                            x+(TxtW div 2)+2,
                            y+round(FKoefM*(fotoheight div 2))+
                            SelectNodeStyle.WidthLine+TxtH_);
                            {FBMP.canvas.Pen.color:=clred;;
                                      FBMP.Canvas.Rectangle(RectClear); }
                            if (picBackGround<>'')then
                             FBMP.Canvas.CopyRect(RectClear,FBMPFon.Canvas,RectClear)
                             else
                               FBMP.Canvas.Rectangle(RectClear)
                            {FBMP.canvas.Pen.color:=clred;}
                            ;
                       end
                       else
                       begin
                         if (picBackGround<>'')then
                          begin
                               bmptxt:=TBitMap.Create;
                               bmptxt.SetSize(TxtW,TxtH_);
                               //bmptxt.Canvas.AntialiasingMode:=amOff;
                               //bmptxt.canvas.Font.Style:=[fsBold];
                               bmptxt.canvas.Font.Quality:=fqNonAntialiased;
                               bmptxt.Transparent:=true;//включим прозрачность
                               bmptxt.TransparentMode:=tmFixed;//цвет прозрачности будем задавать сами
                               bmptxt.TransparentColor:=ColorTransparent1;//задаем прозрачный цвет - черный
                               bmptxt.Canvas.Brush.Color:=ColorTransparent1;//цвет кисти
                               bmptxt.Canvas.Pen.Color:=ColorTransparent1;//цвет карандаша
                               bmptxt.Canvas.Rectangle(Rect(0,0,bmptxt.Width,bmptxt.Height));//зальем
                               bmptxt.Canvas.Font.Color:=color_CaptionNode;// DefaultColorNodeCaption;
                               //showmessage(colortostring(color_CaptionNode));
                               //bmptxt.canvas.Font.Style:=bmptxt.canvas.Font.Style-[fsBold];
                               bmptxt.canvas.Font.Size:=round(FKoefM*SizeCaption);
                               bmptxt.Canvas.TextOut(0,0,outtxt);
                               {FBMP.canvas.TextOut(x-(TxtW div 2)
                               ,y+round(FKoefM*(fotoheight div 2))+
                               SelectNodeStyle.WidthLine
                               , outtxt);}
                               FBMP.Canvas.Draw(x-(TxtW div 2)
                               ,y+round(FKoefM*(fotoheight div 2))+
                               SelectNodeStyle.WidthLine
                               ,bmptxt);
                               bmptxt.Transparent:=false;
                               bmptxt.TransparentColor:=ColorTransparent2;
                          end else
                          FBMP.canvas.TextOut(x-(TxtW div 2)
                               ,y+round(FKoefM*(fotoheight div 2))+
                               SelectNodeStyle.WidthLine
                               , outtxt);
                       end;
                      if slova.Count>2 then
                           begin
                                TxtH_:=FBMP.canvas.TextHeight(slova[2]);
                                TxtW:=FBMP.canvas.TextWidth(slova[2]);
                                if Clear then
                                 begin
                                      RectClear:=Rect(x-(TxtW div 2),
                                   y+round(FKoefM*((fotoheight div 2)))+
                                   SelectNodeStyle.WidthLine+TxtH_,
                                   x+(TxtW div 2)+2,
                                   y+round(FKoefM*((fotoheight div 2)))+
                                   SelectNodeStyle.WidthLine+2*TxtH_);
                                      {FBMP.canvas.Pen.color:=clred;;
                                      FBMP.Canvas.Rectangle(RectClear);}
                                   if (picBackGround<>'')then
                                       FBMP.Canvas.CopyRect(RectClear,FBMPFon.Canvas,RectClear)
                                       else
                                         FBMP.Canvas.Rectangle(RectClear);
                                 end
                                 else
                                 begin
                                   if (picBackGround<>'')then
                                    begin
                                         bmptxt.Clear;
                                         bmptxt.SetSize(TxtW,TxtH_);
                                         bmptxt.Transparent:=true;//включим прозрачность
                                         bmptxt.TransparentMode:=tmFixed;//цвет прозрачности будем задавать сами
                                         bmptxt.TransparentColor:=ColorTransparent1;//задаем прозрачный цвет - черный
                                         bmptxt.Canvas.Brush.Color:=ColorTransparent1;//цвет кисти
                                         bmptxt.Canvas.Pen.Color:=ColorTransparent1;//цвет карандаша
                                         bmptxt.Canvas.Rectangle(Rect(0,0,bmptxt.Width,bmptxt.Height));//зальем
                                         bmptxt.Canvas.Font.Color:=color_CaptionNode;// DefaultColorNodeCaption;
                                         //bmptxt.canvas.Font.Style:=bmptxt.canvas.Font.Style+[fsBold];
                                         bmptxt.canvas.Font.Size:=round(FKoefM*SizeCaption);
                                         bmptxt.Canvas.AntialiasingMode:=amOff;
                                         bmptxt.Canvas.TextOut(0,0,slova[2]);{
                                         FBMP.canvas.TextOut(x-(TxtW div 2),
                                         y+round(FKoefM*((fotoheight div 2)+TxtH))+
                                         SelectNodeStyle.WidthLine
                                         ,slova[2]);   }
                                         FBMP.Canvas.Draw(x-(TxtW div 2),
                                         y+round(FKoefM*((fotoheight div 2)))+
                                         SelectNodeStyle.WidthLine+TxtH_
                                         ,bmptxt);
                                    end else
                                    FBMP.canvas.TextOut(x-(TxtW div 2),
                                         y+round(FKoefM*((fotoheight div 2)+TxtH))+
                                         SelectNodeStyle.WidthLine
                                         ,slova[2]);;
                                 end;
                           end;
                 end;
  slova.Clear;
  //if bmptxt<>nil then
   if (picBackGround<>'')then
   FreeAndNil(bmptxt);
  freeandnil(slova)
end;
}

procedure TMyTreeInBMP.DrawCaptions(Node: TNode; Clear: boolean; OLD: boolean);inline;
var
  lev,nod:integer;
  Node_:TNode;
          procedure DrCpt(Node:TNode;Clear:boolean=false;OLD:boolean=false);
          var
            pnt:TPoint;
          begin
                  if (utf8length(Node.CaptionOLD)>0)and(Node.Caption<>Node.CaptionOLD) then
                  begin
                       FBMP.canvas.Font.Color:=Color_BackGround;
                       DrawCaption(Node.CaptionOLD, node.NodeCenter.x, node.NodeCenter.y);
                  end;
                  if Clear then
                   begin
                    FBMP.canvas.Font.Color:=Color_BackGround;
                    if OLD then
                       Pnt:=TPoint.Create(node.NodeCenterOLD.x, node.NodeCenterOLD.y)
                       else
                         Pnt:=TPoint.Create(node.NodeCenter.x, node.NodeCenter.y);
                   end
                    else
                    begin
                      FBMP.canvas.Font.Color:=color_CaptionNode;// DefaultColorNodeCaption;//clBlack;
                      Pnt:=TPoint.Create(node.NodeCenter.x, node.NodeCenter.y);
                    end;
                  if Clear and (picBackGround<>'') then
                   begin
                     DrawCaption(Node.Caption, pnt.x, pnt.y, true)
                   end
                   else
                      DrawCaption(Node.Caption, pnt.x, pnt.y);
                  Node.CaptionOLD:=node.Caption;
          end;
begin
  //Определим высоту текста подписей
  //стиль текста
  //FBMP.canvas.Font.Color:=DefaultColorNodeCaption;//clBlack;
  //FBMP.canvas.Font.Style:=[fsBold];
  //FBMP.canvas.Font.Style:=[fsBold];
  FBMP.canvas.Font.Size:=round(FKoefM*SizeCaption);
  FBMP.canvas.Brush.Color:=color_BackGround;
  //Переберем все уровни
  if Node=nil then
  for lev:=0 to countLevel-1 do
  begin
    //переберем Nod-ы на уровне
    for nod:=0 to self.GetLevels(lev).countNode-1 do
    begin
      Node_:=TNode(Getlevels(lev).GetNodes(nod));
      //Разобъем текст на строки
      DrCpt(Node_, Clear);
    end;
  end
  else DrCpt(Node, Clear, OLD);
end;

procedure TMyTreeInBMP.ClearNodes;inline;
var
  nod:integer;
  Node:Tnode;
begin
   for nod:=0 to FlistReDraw.Count-1 do
  begin
    Node:=Tnode(FlistReDraw.Items[nod]);
    if Node.NodeCenterOLD.x<>0 then
    begin
     DoDrawClearNode(Node.NodeCenterOLD);   //сотрем Node со старого места, если нужно
     DrawCaptions(node,true, true);//сотрем заголовок со старого места, если нужно
    end;
  end;
end;

procedure TMyTreeInBMP.DoClearNode(Node: TNode);inline;
begin
  Node:=Tnode(FlistDraw.Items[FlistDraw.IndexOf(Node)]);
  if Node<>nil then
  begin
   DoDrawClearNode(Node.NodeCenter);   //сотрем Node
   DrawCaptions(node,true);//сотрем заголовок
   //DrawSelected(Node, true);//сотрем рамку
  end;
end;

procedure TMyTreeInBMP.DrawNodes;
var
  nod:integer;
  Node:Tnode;
  countNode:integer;
begin
  //Перебер те Node которые нужно перерисовать
  countNode:=FlistReDraw.Count;
  for nod:=0 to countNode-1 do
  begin
    Node:=Tnode(FlistReDraw.Items[nod]);
    node.Style:=DefaultNodeStyle;
    DoDrawNode(Node);//нарисуем Node на новом месте
    if FlistVisible.IndexOf(Node)<0 then
     FListVisible.Add(Node);
    if assigned(FOnProgressEvent) then FOnProgressEvent(trunc(100*nod/countNode),'рисуем листья');
  end;
  if assigned(FOnProgressEvent) then FOnProgressEvent(0,'');
end;

function TMyTreeInBMP.GetDefaultColorBackGround: TColor;
begin
  result:=ColorBackGround
end;

function TMyTreeInBMP.GetDefaultColorEdge: TColor;
begin
  result:=DefaultEdgeColorLine;
end;

function TMyTreeInBMP.GetDefaultColorEdge_Ligth: TColor;
begin
  result:=DefaultEdgeColorLigth;
end;

function TMyTreeInBMP.GetDefaultcolor_Foto: TColor;
begin
  result:=DefaultNodeColorFill;
end;

procedure TMyTreeInBMP.DoDrawNode(Node: TNode);inline;
           procedure DrawDopInfo(r:TRect);
          begin
              if (node.Flag and 1)=1 then
              begin
               FBMP.canvas.Font.Color:=clYellow;
               FBMP.canvas.Font.Size:=round(FKoefM*10);;
               FBMP.canvas.Pen.Color:=clYellow;
               FBMP.canvas.Pen.Width:=3;
               FBMP.canvas.Brush.Color:=TColor($000080FF);
               FBMP.canvas.TextOut(Node.NodeCenter.x+((r.Right-r.Left) div 2)-FBMP.canvas.TextWidth(' ! '),
               Node.NodeCenter.y-((r.Bottom-r.Top) div 2),' ! ');
              end;
          end;

          procedure DrawBirthday(r:TRect);
          begin
            if not node.Death then
            begin
              if view_birthday and Node.Birthday then
              begin
               FBMP.canvas.Font.Color:=clYellow;
               FBMP.canvas.Font.Size:=round(FKoefM*10);;
               FBMP.canvas.Pen.Color:=clYellow;
               FBMP.canvas.Pen.Width:=3;
               FBMP.canvas.Brush.Color:=clGreen;
               FBMP.canvas.TextOut(Node.NodeCenter.x-((r.Right-r.Left) div 2),
               Node.NodeCenter.y-((r.Bottom-r.Top) div 2),'ДР');
              end else
              if view_birthday and view_birthday_skoro and Node.BirthdaySkoro then
              begin
               FBMP.canvas.Font.Color:=clLtGray;
               FBMP.canvas.Font.Size:=round(FKoefM*10);;
               FBMP.canvas.Pen.Color:=clGray;
               FBMP.canvas.Pen.Width:=3;
               FBMP.canvas.Brush.Color:=clGreen;
               FBMP.canvas.TextOut(Node.NodeCenter.x-((r.Right-r.Left) div 2),
               Node.NodeCenter.y-((r.Bottom-r.Top) div 2),'ДР');
              end;
            end;
          end;
          procedure Draw_triangle(r:TRect);
          begin
            //Проверим признак кончины(смерти)
            if node.Death then
            begin
             FBMP.canvas.Pen.Color:=clblack;//node.Style.ColorLine;
             FBMP.canvas.Pen.Width:=round(6*FkoefM);
             FBMP.canvas.Brush.Color:=clblack;
             FBMP.canvas.Brush.Style:=bssolid;;
             FBMP.canvas.Line(Node.NodeCenter.x+((r.Right-r.Left) div 4),
             Node.NodeCenter.y+((r.Bottom-r.Top) div 2),
             Node.NodeCenter.x+((r.Right-r.Left) div 2),
             Node.NodeCenter.y+((r.Bottom-r.Top) div 4));

            { FBMP.canvas.Pen.Width:=1;
             FBMP.canvas.Line(Node.NodeCenter.x+((r.Right-r.Left) div 4),
             Node.NodeCenter.y+((r.Bottom-r.Top) div 2),
             Node.NodeCenter.x+((r.Right-r.Left) div 2),
             Node.NodeCenter.y+((r.Bottom-r.Top) div 2));

             FBMP.canvas.Line(Node.NodeCenter.x+((r.Right-r.Left) div 2),
             Node.NodeCenter.y+((r.Bottom-r.Top) div 2),
             Node.NodeCenter.x+((r.Right-r.Left) div 2),
             Node.NodeCenter.y+((r.Bottom-r.Top) div 4));

             FBMP.canvas.FloodFill(Node.NodeCenter.x+(((r.Right-r.Left) div 4)+((r.Right-r.Left) div 8)),
             Node.NodeCenter.y+(((r.Bottom-r.Top) div 2)-(FBMP.canvas.Pen.Width+1)),
             FBMP.canvas.Pen.Color, fsBorder);}
            end{ else
            begin
            if view_birthday and Node.Birthday then
            begin
            FBMP.canvas.Font.Color:=clYellow;
            FBMP.canvas.Font.Size:=round(FKoefM*10);;
            FBMP.canvas.Pen.Color:=clYellow;
            FBMP.canvas.Pen.Width:=3;
            FBMP.canvas.Brush.Color:=clGreen;
            FBMP.canvas.TextOut(Node.NodeCenter.x-((r.Right-r.Left) div 2),
            Node.NodeCenter.y-((r.Bottom-r.Top) div 2),'ДР');
            end else
            if view_birthday and view_birthday_skoro and Node.BirthdaySkoro then
            begin
            FBMP.canvas.Font.Color:=clLtGray;
            FBMP.canvas.Font.Size:=round(FKoefM*10);;
            FBMP.canvas.Pen.Color:=clGray;
            FBMP.canvas.Pen.Width:=3;
            FBMP.canvas.Brush.Color:=clGreen;
            FBMP.canvas.TextOut(Node.NodeCenter.x-((r.Right-r.Left) div 2),
            Node.NodeCenter.y-((r.Bottom-r.Top) div 2),'ДР');
            end;
            end};
          end;
var
  r:TRect;
koef:double;
LJPEGImage:TJPEGImagePlus;
bmpFoto:TBitMap;
jpg:TJpegImage;
//ms:TMemoryStream;
begin
//Здесь в зависимости от каких то условий вызываются разные функции рисования
FBMP.canvas.Pen.Width:=node.Style.WidthLine;
FBMP.canvas.Pen.Color:=node.Style.ColorLine;
FBMP.canvas.Brush.Color:=node.Style.ColorFill;
//Фотку нарисуем
//r:=bounds(Node.NodeCenter.x-(fotowidth div 2),Node.NodeCenter.y-fotoheight div 2,Node.NodeCenter.x+fotowidth div 2,Node.NodeCenter.y+fotoheight div 2);
if node.avatar<>nil then
begin
 //Если есть фотка, то выводим фотку
 //Попробуем аккуратно вписать фотку, чтобы пропорции сохранить
     LJPEGImage := TJPEGImagePlus.Create;
     //showmessage(Node.Caption+lineending+inttostr(node.avatar.Size));
     //node.avatar.SaveToFile('D:\1.jpg');
     if node.avatar.Size>35000 then LJPEGImage.Scale := jsEighth     //Если фотка сильно большая возьмем 1/8
     else
         if node.avatar.Size>15000 then LJPEGImage.Scale := jsQuarter //Если фотка большая возьмем 1/4
     else
         if node.avatar.Size>5000 then LJPEGImage.Scale := jsHalf  //Если фотка не маленькая возьмем 1/2
     else
         LJPEGImage.Scale := jsFullSize; //Если фотка маленькая возьмем полный размер
     LJPEGImage.CompressionQuality:=50;
     LJPEGImage.Performance:=jpBestSpeed;//jpBestQuality;
     node.avatar.Seek(0, soBeginning);
     LJPEGImage.LoadFromStream(node.avatar);
     node.avatarWidth:=LJPEGImage.Width;
     node.avatarHeight:=LJPEGImage.Height;
     if LJPEGImage.Scale<>jsFullSize then
      begin
           jpg:=TJpegImage.Create;
           jpg.SetSize(LJPEGImage.Width,LJPEGImage.Height);
           jpg.Canvas.Draw(0,0,LJPEGImage);
           node.avatar.Clear;
           jpg.SaveToStream(node.avatar);
           //ms:=TMemoryStream.Create;
           //jpg.SaveToStream(ms);
           //LJPEGImage.SaveToFile('D:\2.jpg');
           //showmessage(inttostr(ms.Size));
           //ms.Free;
           FreeAndNil(jpg);
      end;
     koef:=LJPEGImage.Width/LJPEGImage.Height;
     if koef>=1 then
     begin
      r:=rect(Node.NodeCenter.x-round(FKoefM*(fotowidth div 2)),
      Node.NodeCenter.y-round(FKoefM*(fotoheight div 2)/koef)
      ,Node.NodeCenter.x+round(FKoefM*(fotowidth div 2)),
      Node.NodeCenter.y+round(FKoefM*(fotoheight div 2)/koef));
     end else
     begin
     r:=rect(Node.NodeCenter.x-round(FKoefM*(fotowidth div 2)*koef),
     Node.NodeCenter.y-round(FKoefM*(fotoheight div 2)),
     Node.NodeCenter.x+round(FKoefM*(fotowidth div 2)*koef),
     Node.NodeCenter.y+round(FKoefM*(fotoheight div 2)));
     end;
     if FBMPBorder<>nil then
      begin
           bmpFoto:=CreateFotoFromMask(r, LJPEGImage);
           FBMP.canvas.StretchDraw(r, bmpFoto);
           FreeAndNil(bmpFoto);
      end else
          FBMP.canvas.StretchDraw(r, LJPEGImage);;
     //FBMP.canvas.StretchDraw(r, LJPEGImage);
     FreeAndNil(LJPEGImage);
     //Признак смерти
     Draw_triangle(r);
     //Вывод подсказки о дне рождении
     DrawBirthday(r);
     //Вывод признака того, что требуется уточнение данных - восклицательный знак
     DrawDopInfo(r);
end else
begin//Если нет фотки, то рисуем прямоугольник
            node.avatarWidth:=0;
            node.avatarHeight:=0;
            r:=rect(Node.NodeCenter.x-round(FKoefM*(fotowidth div 2)),
            Node.NodeCenter.y-round(FKoefM*(fotoheight div 2)),
            Node.NodeCenter.x+round(FKoefM*(fotowidth div 2)),
            Node.NodeCenter.y+round(FKoefM*(fotoheight div 2)));
            FBMP.canvas.Brush.Style:=bsSolid;
            FBMP.canvas.Rectangle(r);
            //Признак смерти
            Draw_triangle(r);
            //Вывод подсказки о дне рождении
            DrawBirthday(r);
            //Вывод признака того, что требуется уточнение данных - восклицательный знак
            DrawDopInfo(r);
end;
    DrawCaptions(Node);
end;

function TMyTreeInBMP.GetMaxNodeInLevels: integer;inline;
var
  lev:integer;
begin
  result:=-1;
  for lev:=0 to countLevel-1 do
  if GetLevels(lev).countNode>result then
   result:=Getlevels(lev).countNode;
  FMaxNodeinLevel:=result;
end;

function TMyTreeInBMP.GetPositionX(id: integer): extended;
var
  tmp:integer;
begin
  tmp:=(FBMP.Width-leftWidth-rigthWidth-FotoWidth);
  if tmp<=0 then
     result:=0
     else
       result:=(GetNodesIDNode(id).NodeCenter.x-leftWidth-(FotoWidth div 2))/(FBMP.Width-leftWidth-rigthWidth-FotoWidth);
end;

function TMyTreeInBMP.GetPositionY(id: integer): extended;
var
  tmp:integer;
begin
     tmp:=(FBMP.Height-TopHeight-BottomHeight-FotoHeight);
     if tmp<=0 then
        result:=0
        else
          result:=(GetNodesIDNode(id).NodeCenter.y-TopHeight-(FotoHeight div 2))/(FBMP.Height-TopHeight-BottomHeight-FotoHeight);
end;

procedure TMyTreeInBMP.ClearSelection;
begin
     ClearPreviouseSelectNode;
end;

procedure TMyTreeInBMP.LigthPredkPotomk(Node: TNode; Clear: boolean);inline;
        procedure LigthPotomk(Node: TNode; Clear: boolean;step: integer);
        var
          i:integer;
        begin
          if not (view_potomk or Clear) then exit;
          for i:=0 to Node.outEdgecount-1 do
          begin
            if FListDrawEdge.IndexOf(Node.outEdges[i] as TEdge)=-1 then continue;
            if step<count_view_potomk then LigthPotomk(Node.outEdges[i].TargetBottom as TNode,Clear,step+1);
            //Подсветим или уберем подсветку у потомков
            {if Clear then
               DrawSelected(Node.outEdges[i].TargetBottom as TNode,true) else
                 DrawSelected(Node.outEdges[i].TargetBottom as TNode,false,SelectEdgeStyle.ColorLine);   }
            //Подсветим ветви ведущие к потомкам
            if Clear then
               DoDrawEdge(Node.outEdges[i] as TEdge) else
                 DoDrawEdge(Node.outEdges[i] as TEdge,false,SelectEdgeStyle.ColorLine);
          end;
        end;

        procedure LigthPredk(Node: TNode; Clear: boolean;step: integer);
        var
          i:integer;
        begin
          if not (view_predk or Clear) then exit;
          for i:=0 to Node.inEdgecount-1 do
          begin
            if FListDrawEdge.IndexOf(Node.inEdges[i] as TEdge)=-1 then continue;
            if step<count_view_predk then LigthPredk(Node.inEdges[i].SourceTop as TNode,Clear,step+1);
            //Подсветим или уберем подсветку у предков
            {if Clear then
               DrawSelected(Node.inEdges[i].SourceTop as TNode,true) else
                 DrawSelected(Node.inEdges[i].SourceTop as TNode,false,SelectEdgeStyle.ColorLine); }
            //Подсветим ветви ведущие к предкам
            if Clear then
               DoDrawEdge(Node.inEdges[i] as TEdge) else
                 DoDrawEdge(Node.inEdges[i] as TEdge,false,SelectEdgeStyle.ColorLine);
          end;
        end;
begin
     //получим потомков
     LigthPotomk(Node,Clear,1);
     //получим предков
     LigthPredk(Node,Clear,1);
end;

procedure TMyTreeInBMP.Setbeautiful_tree(AValue: boolean);
begin
  if Fbeautiful_tree=AValue then Exit;
  Fbeautiful_tree:=AValue;
end;

procedure TMyTreeInBMP.SetCaption(AValue: string);
begin
  if FCaption=AValue then Exit;
  FCaption:=AValue;
end;

procedure TMyTreeInBMP.SetColor_BackGround(AValue: TColor);
begin
  if FColor_BackGround=AValue then Exit;
  FColor_BackGround:=AValue;
  if ClearEdgeStyle<>nil then
   ClearEdgeStyle.ColorLine:=AValue;
end;

procedure TMyTreeInBMP.Setcolor_Bevel_Foto(AValue: TColor);
begin
  {if Fcolor_Bevel_Foto=AValue then Exit;
  Fcolor_Bevel_Foto:=AValue;}
  if DefaultNodeStyle<>nil then
     if DefaultNodeStyle.ColorLine<>AValue then
      DefaultNodeStyle.ColorLine:=AValue;
end;

procedure TMyTreeInBMP.Setcolor_CaptionNode(AValue: TColor);
begin
  {if Fcolor_CaptionNode=AValue then Exit;
  Fcolor_CaptionNode:=AValue; }
  if DefaultNodeStyle<>nil then
     if DefaultNodeStyle.ColorCaption<>AValue then
      DefaultNodeStyle.ColorCaption:=AValue;
end;

procedure TMyTreeInBMP.SetColor_Edge(AValue: TColor);
begin
  if FColor_Edge=AValue then Exit;
  FColor_Edge:=AValue;
  if DefaultEdgeStyle<>nil then
     DefaultEdgeStyle.ColorLine:=FColor_Edge;
end;

procedure TMyTreeInBMP.SetColor_Edge_Ligth(AValue: TColor);
begin
  if FColor_Edge_Ligth=AValue then Exit;
  FColor_Edge_Ligth:=AValue;
  if SelectEdgeStyle<>nil then
     SelectEdgeStyle.ColorLine:=FColor_Edge_Ligth;
end;

procedure TMyTreeInBMP.Setcolor_Foto(AValue: TColor);
begin
  {if Fcolor_Foto=AValue then Exit;
  Fcolor_Foto:=AValue;}
  if DefaultNodeStyle<>nil then
     if DefaultNodeStyle.ColorFill<>AValue then
      DefaultNodeStyle.ColorFill:=AValue;
end;

procedure TMyTreeInBMP.Setcount_view_potomk(AValue: integer);
begin
  if Fcount_view_potomk=AValue then Exit;
  Fcount_view_potomk:=AValue;
end;

procedure TMyTreeInBMP.Setcount_view_predk(AValue: integer);
begin
  if Fcount_view_predk=AValue then Exit;
  Fcount_view_predk:=AValue;
end;

procedure TMyTreeInBMP.SetPercentM(AValue: integer);
begin
  if FPercentM=AValue then Exit;
  FPercentM:=AValue;
  FKoefM:=FPercentM/100;
  if FBMPBorder<>nil then CreateMask;
end;

procedure TMyTreeInBMP.AfterAddEdge(Sender: TObject);
begin
end;

procedure TMyTreeInBMP.AfterAddNode(Sender: TObject);
begin

end;

procedure TMyTreeInBMP.BeforeRemoveEdge(Sender: TObject);
begin
     (Sender as TEdge).Style:=ClearEdgeStyle;
     DoDrawEdge(Sender as TEdge);
     inherited;
end;

procedure TMyTreeInBMP.BeforeRemoveNode(Sender: TObject);
begin
     //Удалим Node из списков
     if FlistDraw<>nil then FlistDraw.Remove(Sender as TNode);
     if FListReDraw<>nil then FListReDraw.Remove(Sender as TNode);
     if FlistVisible<>nil then FlistVisible.Remove(Sender as TNode);
     //Сотрем Node
   DoDrawClearNode((Sender as TNode).NodeCenter);
   //Сотрем выделение
   //DrawSelected((Sender as TNode),true);
   //Сотрем надпись
  { FBMP.canvas.Font.Style:=[fsBold];
   FBMP.canvas.Font.Size:=round(FKoefM*sizeCaption);
   FBMP.canvas.Brush.Color:=color_BackGround;
   FBMP.canvas.Font.Color:=Color_BackGround;}
   DrawCaption((Sender as TNode).Caption,(Sender as TNode).NodeCenter.x,(Sender as TNode).NodeCenter.y, true);
   inherited;
end;

function TMyTreeInBMP.CreatedNode(idNode: integer): TNode;
begin
  FGetSelNodeIndex:=-1;
  Result:=Tnode.Create(idNode);
  result.OnBeforeRemoveNode:=@BeforeRemoveNode;
end;

function TMyTreeInBMP.CreatedEdge(SourceTop, TargetBottom: TObject): TEdge;
begin
Result:=TEdge.Create(SourceTop, TargetBottom);
result.OnBeforeRemoveEdge:=@BeforeRemoveEdge;
end;

function TMyTreeInBMP.CreatedLevel: TLevel;
begin
Result:=Tlevel.Create;
result.OnBeforeRemoveLevel:=@BeforeRemoveLevel;
result.countDrawLevelNode:=0;
end;

procedure TMyTreeInBMP.DoDrawClearNode(NodeCenter: TPoint);inline;
var
  RectClear:TRect;
begin
     if (NodeCenter.x=0)and(NodeCenter.y=0) then exit;
     //Затираем Node Фоном
     if picBackGround<>'' then
     begin
      RectClear:=Rect(NodeCenter.x-round(FKoefM*(fotowidth div 2))-3,
      NodeCenter.y-round(FKoefM*(fotoheight div 2))-3,
      NodeCenter.x+round(FKoefM*(fotowidth div 2))+3,
      NodeCenter.y+round(FKoefM*(fotoheight div 2))+3);
      FBMP.Canvas.CopyRect(RectClear,FBMPFon.Canvas,RectClear);
     end else
     begin
       //Здесь в зависимости от каких то условий вызываются разные функции рисования
       Fbmp.canvas.Pen.Width:=SelectNodeStyle.WidthLine ;
       Fbmp.canvas.Pen.Color:=color_BackGround;
       Fbmp.canvas.Brush.Style:=bsSolid;
       Fbmp.canvas.Brush.Color:=color_BackGround;
       Fbmp.canvas.Rectangle(NodeCenter.x-round(FKoefM*(fotowidth div 2))-3,
       NodeCenter.y-round(FKoefM*(fotoheight div 2))-3,
       NodeCenter.x+round(FKoefM*(fotowidth div 2))+3,
       NodeCenter.y+round(FKoefM*(fotoheight div 2))+3);
     end;
end;

procedure TMyTreeInBMP.DoDrawClearEdgeFromNode(Node: TNode; OLD: boolean);inline;
var
  i:integer;
  r:TRect;
begin
     Fbmp.canvas.Pen.Width:=SelectNodeStyle.WidthLine ;
     Fbmp.canvas.Pen.Color:=color_BackGround;
     for i:=0 to Node.inEdgecount-1 do
            begin
              if OLD then  r:=(Node.inEdges[i] as TEdge).DrawnAtOLD
              else
              r:=(Node.inEdges[i] as TEdge).DrawnAt;
              FBMP.Canvas.PolyBezier([Point(r.Left,r.Top),
              Point(r.Left{+koef},r.Bottom),
              Point(r.Right{-100*koef},r.Top),
              Point(r.Right,r.Bottom)]);
            end;
     for i:=0 to Node.outEdgecount-1 do
            begin
              if OLD then r:=(Node.outEdges[i] as TEdge).DrawnAtOLD
              else
              r:=(Node.outEdges[i] as TEdge).DrawnAt;
              FBMP.Canvas.PolyBezier([Point(r.Left,r.Top),
              Point(r.Left{+koef},r.Bottom),
              Point(r.Right{-100*koef},r.Top),
              Point(r.Right,r.Bottom)]);
            end;
end;

procedure TMyTreeInBMP.removeAllNodes;
begin
  inherited removeAllNodes;
  DrawTreeClear;
end;

procedure TMyTreeInBMP.refresh;
begin
     if assigned(Image) then
         begin
              Image.Picture.Bitmap.Assign(FBMP);
         end;
end;

constructor TMyTreeInBMP.Create;
begin
  inherited Create;
  FflagDraw:=false;
  FBMP:=TBitMap.Create;
  FPercentM:=100;
  FKoefM:=1;
  FMinDistance:=0;
  Napravlenie:=NapravlenieUp;
  Color_Edge_Ligth:=DefaultColorEdge_Ligth;
  Color_BackGround:=DefaultColorBackGround;
  Color_Foto:=DefaultColorBackGround;
  DefaultNodeStyle:=TNodeStyle.Create;
  SelectNodeStyle:=TNodeStyle.Create;
  SelectNodeStyle.WidthLine:=3;
  SelectNodeStyle.ColorLine:=clred;
  DefaultEdgeStyle:=TEdgeStyle.Create;
  SelectEdgeStyle:=TEdgeStyle.Create;
  SelectEdgeStyle.WidthLine:=3;
  SelectEdgeStyle.ColorLine:=Color_Edge_Ligth;
  ClearEdgeStyle:=TEdgeStyle.Create;
  ClearEdgeStyle.WidthLine:=SelectEdgeStyle.WidthLine;
  ClearEdgeStyle.ColorLine:=Color_BackGround;
  FotoWidth:=DefaultFotoWidth;
  FotoHeight:=DefaultFotoHeight;
  BeetweenWidth:=DefaultBeetweenWidth;
  BeetweenHeight:=DefaultBeetweenHeight;
  TextHeight:=DefaultTextHeight;
  TopHeight:=DefaultTopHeight;
  BottomHeight:=DefaultBottomHeight;
  LeftWidth:=DefaultLeftWidth;
  RigthWidth:=DefaultRigthWidth;
  widthBorder:=DefaultwidthBorder;
  SizeCaptionMain:=DefaultSizeCaptionMain;
  SizeCaption:=DefaultSizeCaption;
  //Определим высоту текста
  //стиль текста
  color_CaptionNode:=DefaultColorNodeCaption;//clBlack;
  FBMP.canvas.Font.Color:=color_CaptionNode;
  //FBMP.canvas.Font.Style:=[fsBold];
  FBMP.canvas.Font.Size:=round(FKoefM*SizeCaption);
  TxtH:=FBMP.Canvas.TextHeight('ABCTM');
  FDrawClear:=false;
  FListDraw:=TList.Create;
  FListVisible:=TList.Create;
  flistredraw:=TList.Create;
end;

destructor TMyTreeInBMP.Destroy;
begin
 DefaultEdgeStyle.Free;
 DefaultNodeStyle.Free;
 SelectEdgeStyle.Free;
 SelectNodeStyle.Free;
 freeandnil(flistredraw);
 freeandnil(flistdraw);
 freeandnil(flistvisible);
 FreeAndNil(FbmpMask);
  inherited Destroy;
  FreeAndNil(FBMP);
  FreeAndNil(FBMPFon);
  if FBMPBackground<>nil then
     FreeAndNil(FBMPBackground);
  if FBMPBorder<>nil then
     FreeAndNil(FBMPBorder);
  if FListDrawEdge<>nil then
  FreeAndNil(FListDrawEdge);
end;

function TMyTreeInBMP.addNode(idNode: integer): TNode;
begin
  Result:=(inherited addNode(idNode) as TNode);
  result.Style:=DefaultNodeStyle;
end;

function TMyTreeInBMP.GetNodesIDNode(IDNode: integer): TNode;
begin
  Result:=(inherited GetNodesIDNode(IDNode) as TNode);
end;

procedure TMyTreeInBMP.ClearPreviouseSelectNode;inline;
var
  NodeClear:TNode;
begin
     //сотрем рамку вокруг Node, который был выбран ранее
    if (Trselnode in SostTree) then
    begin
     NodeClear:=GetNodesIDNode(FGetSelNodeIndex);
     if NodeClear<>nil then
      begin
           NodeClear.SostNode:=NodeClear.SostNode-[selnode];
           //DrawSelected(NodeClear,true);
           if view_potomk or view_predk then LigthPredkPotomk(NodeClear,true);
      end;
     SostTree:=SostTree-[Trselnode];
     FGetSelNodeIndex:=-1;
     //сгенерируем событие
     if assigned(OnSelectedNodeEvent) then OnSelectedNodeEvent;
     refresh;
    end;
end;

function TMyTreeInBMP.mouseMove_old(X, Y: Integer): boolean;inline;
var
  lev,nod:integer;
  Node:TNode;
  koordY, {koordX,} intX:integer;
  StepY, StepX, LevYMin, LevYMax, LevXMin, LevXMax:integer;
begin
  result:=false;
  //Вычислим на каком уровне указатель мыши
  koordY:=Y;
  //koordY:=(koordY);
  StepY:=(widthBorder*2+FotoHeight+BeetweenHeight+TxtH);
  Lev:=(koordY div round(StepY*FkoefM));
  if Lev>(countLevel-1) then exit;
  LevYMin:=round((TopHeight+(FotoHeight div 2)+Lev*StepY-MinDist)*FkoefM);
  LevYMax:=round((TopHeight+(FotoHeight div 2)+Lev*StepY+MinDist)*FkoefM);
         {FBMP.Canvas.Pen.Width:=1;
         FBMP.Canvas.Pen.Color:=clblack;
         FBMP.Canvas.line(0,LevYMin,FBMP.Canvas.Width,LevYMin);
         FBMP.Canvas.line(0,LevYMax,FBMP.Canvas.Width,LevYMax);}
    //Вычислим в какой Node "попадает" указатель мыши
    intX:=((FotoWidth+BeetweenWidth)*((GetLevels(countLevel-lev-1) as TLevel).countDrawLevelNode){Getlevels(countLevel-lev-1).countNode})-BeetweenWidth;
    intX:=(FSizeCanvas.x-LeftWidth-RigthWidth-intX) div ((GetLevels(countLevel-lev-1) as TLevel).countDrawLevelNode+1);
    stepX:=(FotoWidth+BeetweenWidth+intX);
    {koordX:=X;
    koordX:=koordX-round(leftWidth+intX*FkoefM);
    Nod:=(koordX div round(stepX*FkoefM));}
    nod:=trunc(((X-leftWidth*FkoefM)) / (stepX*FkoefM));
    if nod<(Getlevels(countLevel-lev-1) as TLevel).countDrawLevelNode then
    begin
         LevXMin:=round(((leftWidth+intX+(FotoWidth div 2))+Nod*StepX-MinDist)*FkoefM);
         LevXMax:=round(((leftWidth+intX+(FotoWidth div 2))+Nod*StepX+MinDist)*FkoefM);
         {FBMP.Canvas.Pen.Width:=1;
         FBMP.Canvas.Pen.Color:=clblack;
         FBMP.Canvas.line(LevXMin,0,LevXMin,FBMP.Canvas.Height);
         FBMP.Canvas.line(LevXMax,0,LevXMax,FBMP.Canvas.Height); }
         if (Y>LevYMin)and(Y<LevYMax)and
          (X>LevXMin)and(X<LevXMax)
          then
          begin
           //нарисуем рамку вокруг выбранного Node
             result:=true;
             Node:=(GetLevels(countLevel-lev-1).GetNodes(nod) as TNode);
             if (Node.idNode=FGetSelNodeIndex) or (FlistDraw.IndexOf(Node)<0) then
              exit;
             ClearPreviouseSelectNode;
             Node.SostNode:=Node.SostNode+[selnode];
             SostTree:=SostTree+[Trselnode];
             //DrawSelected(node);
             FGetSelNodeIndex:=Node.idNode;
             //сгенерируем событие
             if assigned(OnSelectedNodeEvent) then OnSelectedNodeEvent;
             //Если необходимо подсветим прямых потомков/предков
             if view_predk or view_potomk then
                LigthPredkPotomk(Node);
             refresh;
           exit;
          end;
    end;
    ClearPreviouseSelectNode;
end;

function TMyTreeInBMP.mouseMove(X, Y: Integer): boolean;
var
  lev,nod:integer;
  Node:TNode;
  koordY, {koordX,} intX:integer;
  StepY, StepX, LevYMin, LevYMax, LevXMin, LevXMax:integer;
begin
  result:=false;
  //Вычислим на каком уровне указатель мыши
  koordY:=Y;
  //koordY:=(koordY);
  StepY:=(widthBorder*2+FotoHeight+BeetweenHeight+TxtH);
  Lev:=(koordY div round(StepY*FkoefM));
  if Lev>(countLevel-1) then exit;
  LevYMin:=round((TopHeight+(FotoHeight div 2)+Lev*StepY-MinDist)*FkoefM);
  LevYMax:=round((TopHeight+(FotoHeight div 2)+Lev*StepY+MinDist)*FkoefM);
         {FBMP.Canvas.Pen.Width:=1;
         FBMP.Canvas.Pen.Color:=clblack;
         FBMP.Canvas.line(0,LevYMin,FBMP.Canvas.Width,LevYMin);
         FBMP.Canvas.line(0,LevYMax,FBMP.Canvas.Width,LevYMax);}
    //Вычислим в какой Node "попадает" указатель мыши
    if (Y>LevYMin)and(Y<LevYMax) then
    begin
     for nod:=0 to GetLevels(countLevel-lev-1).countNode-1 do
     begin
       Node:=(GetLevels(countLevel-lev-1).GetNodes(nod) as TNode);
       if (X>(Node.NodeCenter.x-MinDist))and(X<(Node.NodeCenter.x+MinDist))then
       begin
        //попали в лист
        result:=true;
        //Проверим отображается ли данный лист
        if (Node.idNode=FGetSelNodeIndex) or (FlistDraw.IndexOf(Node)<0) then
         exit;
        ClearPreviouseSelectNode;//уберем предыдущее выдление
        Node.SostNode:=Node.SostNode+[selnode];//изменим состояние листа
        SostTree:=SostTree+[Trselnode];//изменим состояние дерева
        //DrawSelected(node);
        FGetSelNodeIndex:=Node.idNode;//сохраним индекс выделенного листа
        //сгенерируем событие
        if assigned(OnSelectedNodeEvent) then OnSelectedNodeEvent;
        //Если необходимо подсветим прямых потомков/предков
        if view_predk or view_potomk then
         LigthPredkPotomk(Node);
        refresh;
        exit;
       end;
     end;
    end;
    //**************************
    {
    intX:=((FotoWidth+BeetweenWidth)*((GetLevels(countLevel-lev-1) as TLevel).countDrawLevelNode){Getlevels(countLevel-lev-1).countNode})-BeetweenWidth;
    intX:=(FSizeCanvas.x-LeftWidth-RigthWidth-intX) div ((GetLevels(countLevel-lev-1) as TLevel).countDrawLevelNode+1);
    stepX:=(FotoWidth+BeetweenWidth+intX);
    {koordX:=X;
    koordX:=koordX-round(leftWidth+intX*FkoefM);
    Nod:=(koordX div round(stepX*FkoefM));}
    nod:=trunc(((X-leftWidth*FkoefM)) / (stepX*FkoefM));
    if nod<(Getlevels(countLevel-lev-1) as TLevel).countDrawLevelNode then
    begin
         LevXMin:=round(((leftWidth+intX+(FotoWidth div 2))+Nod*StepX-MinDist)*FkoefM);
         LevXMax:=round(((leftWidth+intX+(FotoWidth div 2))+Nod*StepX+MinDist)*FkoefM);
         {FBMP.Canvas.Pen.Width:=1;
         FBMP.Canvas.Pen.Color:=clblack;
         FBMP.Canvas.line(LevXMin,0,LevXMin,FBMP.Canvas.Height);
         FBMP.Canvas.line(LevXMax,0,LevXMax,FBMP.Canvas.Height); }
         if (Y>LevYMin)and(Y<LevYMax)and
          (X>LevXMin)and(X<LevXMax)
          then
          begin
           //нарисуем рамку вокруг выбранного Node
             result:=true;
             Node:=(GetLevels(countLevel-lev-1).GetNodes(nod) as TNode);
             if (Node.idNode=FGetSelNodeIndex) or (FlistDraw.IndexOf(Node)<0) then
              exit;
             ClearPreviouseSelectNode;
             Node.SostNode:=Node.SostNode+[selnode];
             SostTree:=SostTree+[Trselnode];
             //DrawSelected(node);
             FGetSelNodeIndex:=Node.idNode;
             //сгенерируем событие
             if assigned(OnSelectedNodeEvent) then OnSelectedNodeEvent;
             //Если необходимо подсветим прямых потомков/предков
             if view_predk or view_potomk then
                LigthPredkPotomk(Node);
             refresh;
           exit;
          end;
    end;
    }
    //*****************************
    ClearPreviouseSelectNode;
end;


function TMyTreeInBMP.addEdge(idSourceTop, idTargetBottom: integer): TEdge;
begin
  Result:=(inherited addEdge(idSourceTop, idTargetBottom) as TEdge);
  result.Style:=DefaultEdgeStyle;
end;

procedure TMyTreeInBMP.DrawTreeID(IDNode: integer; LeftBevel,
  rightBevel: integer);
var
  Node:TNode;
  i,min,max:integer;
  widthPlace:cardinal;
  tmpcoord:TPoint;
begin
     Node:=GetNodesIDNode(IDNode);
     if FListDraw.IndexOf(Node)<0 then
        FListDraw.Add(Node);
     if not beautiful_tree then
     begin
      if Napravlenie=NapravlenieUp then
       for i:=0 to Node.outEdgecount-1 do DrawTreeID(Node.outEdges[i].TargetBottom.idNode,0,0)
      else
        for i:=0 to Node.inEdgecount-1 do DrawTreeID(Node.inEdges[i].SourceTop.idNode,0,0);
      exit;
     end;
     Node.NodeCenterOLD:=Node.NodeCenter;
     if ((LeftBevel<0)and(abs(LeftBevel)>abs(rightBevel)))or((rightBevel<0)and(abs(LeftBevel)<abs(rightBevel))) then
     begin
      tmpcoord.x:=cardinal(-(LeftBevel+rightBevel)) div 2;
      tmpcoord.x:=-tmpcoord.x;
     end else
     tmpcoord.x:=cardinal(LeftBevel+rightBevel) div 2;
     tmpcoord.y:=Node.NodeCenter.y;
     Node.NodeCenter:= tmpcoord;
     //Вычислим координаты Node
     //ComputeNodeCoords;
     if FMinDistance=0 then
      FMinDistance:=(rightBevel-LeftBevel);
     if Napravlenie=NapravlenieUp then
     begin
      if Node.outEdgecount>0 then
      begin
       widthPlace:=trunc(cardinal(rightBevel-LeftBevel)/Node.outEdgecount);
       if cardinal(rightBevel-LeftBevel)<=cardinal(BeetweenWidth+FotoWidth) then
        begin
         FMessageErr:='Нарисовано не все дерево.';
         exit;
        end;
       //если интервал слишком маленький, то прекращаем строить дерево
       if (widthPlace<FMinDistance) then
        FMinDistance:=widthPlace;
     end;

      for i:=0 to Node.outEdgecount-1 do
      begin
        min:=LeftBevel+i*widthPlace;
        max:=LeftBevel+(i+1)*widthPlace;
        DrawTreeID(Node.outEdges[i].TargetBottom.idNode,min,max);
      end;
     end
      else
      begin
        if Node.inEdgecount>0 then
        begin
             widthPlace:=trunc(cardinal(rightBevel-LeftBevel)/Node.inEdgecount);
         if cardinal(rightBevel-LeftBevel)<=cardinal(BeetweenWidth+FotoWidth) then exit;
         //если интервал слишком маленький, то прекращаем строить дерево
         if (widthPlace<FMinDistance) then
          FMinDistance:=widthPlace;
        end;
        for i:=0 to Node.inEdgecount-1 do
        begin
          min:=LeftBevel+i*widthPlace;
          max:=LeftBevel+(i+1)*widthPlace;
          DrawTreeID(Node.inEdges[i].SourceTop.idNode,min,max);
        end;
      end;
end;

procedure TMyTreeInBMP.CheckVisible;inline;
var
  i, j:integer;
  Node:TNode;
  FListClearEdge:TList;
  //tmpcoord:TPoint;
begin
     FListClearEdge:=TList.Create;
     if FListVisible.Count=0 then exit;
     for i:=FListVisible.Count-1 downto 0 do
     begin
       Node:=TNode(FListVisible.Items[i]);
       if FListDraw.IndexOf(Node)<0 then
       begin
        //гасим node и делаем их уровень nil
        if Node.NodeCenter.x<>0 then
        begin
         DoDrawClearNode(node.NodeCenter);
         DrawCaptions(node,true);//сотрем заголовок, если нужно
         //гасим выделение на всякий
         //DrawSelected(node,true);
        end;
        node.Level:=nil;
        {tmpcoord.x:=0;
        tmpcoord.y:=0;}
        node.NodeCenter:=Point(0,0);//признак погашенности, нужен в последующем, например процедура DrawNodes
        //гасим и удаляем Edge которые идут от этого Node
        //сначало построим список Edge которые надо погасить
        for j:=0 to node.outEdgecount-1 do
        if FListClearEdge.IndexOf(node.outEdges[j] as TEdge)<0 then FListClearEdge.Add(node.outEdges[j] as TEdge);
        for j:=0 to node.inEdgecount-1 do
        if FListClearEdge.IndexOf(node.inEdges[j] as TEdge)<0 then FListClearEdge.Add(node.inEdges[j] as TEdge);
        //убираем из списка FlistVisible
        flistvisible.Remove(node);
       end;
     end;
     //теперь гасим и удаляем Edge по списку
        for j:=0 to FListClearEdge.Count-1 do
        begin
          //гасим
          TEdge(FListClearEdge.Items[j]).Style:=ClearEdgeStyle;
          DoDrawEdge(TEdge(FListClearEdge.Items[j]));
          //удаляем
          (TEdge(FListClearEdge.Items[j])).Free;
        end;
     freeandnil(FListClearEdge);
end;

procedure TMyTreeInBMP.checkReDraw;inline;
var
  nod, edg:integer;
  Node:TNode;
begin
  for nod:=0 to FlistReDraw.Count-1 do
    begin
      Node:=Tnode(FlistReDraw.Items[nod]);
      //Сотрем Edge связанные с данным Node
      //Входящие
      for edg:=0 to Node.inEdgecount-1 do
      begin
        //гасим
          TEdge(Node.inEdges[edg]).Style:=ClearEdgeStyle;
          DoDrawEdge(TEdge(Node.inEdges[edg]),true);
      end;
      //Исходящие
      for edg:=0 to Node.outEdgecount-1 do
      begin
        //гасим
          TEdge(Node.outEdges[edg]).Style:=ClearEdgeStyle;
          DoDrawEdge(TEdge(Node.outEdges[edg]),true);
      end;
    end;
end;

procedure TMyTreeInBMP.DrawTreeClear;
begin
     FDrawClear:=true;
end;

procedure TMyTreeInBMP.DrawSelected(Node: TNode; Clear: boolean; Color: TColor);
var
  koef:double;
  r:TRect;
begin
     if (node.avatarWidth=0)or(node.avatarHeight=0) then
      koef:=1
      else
     koef:=node.avatarWidth/node.avatarHeight;
     if koef>=1 then
     begin
      r:=rect(Node.NodeCenter.x-round(FKoefM*(fotowidth div 2))-SelectNodeStyle.WidthLine,
      Node.NodeCenter.y-round(FKoefM*(fotoheight div 2)/koef)-SelectNodeStyle.WidthLine
      ,Node.NodeCenter.x+round(FKoefM*(fotowidth div 2))+SelectNodeStyle.WidthLine,
      Node.NodeCenter.y+round(FKoefM*(fotoheight div 2)/koef)+SelectNodeStyle.WidthLine);
     end else
     begin
     r:=rect(Node.NodeCenter.x-round(FKoefM*(fotowidth div 2)*koef)-SelectNodeStyle.WidthLine,
     Node.NodeCenter.y-round(FKoefM*(fotoheight div 2))-SelectNodeStyle.WidthLine,
     Node.NodeCenter.x+round(FKoefM*(fotowidth div 2)*koef)+SelectNodeStyle.WidthLine,
     Node.NodeCenter.y+round(FKoefM*(fotoheight div 2))+SelectNodeStyle.WidthLine);
     end;
     FBMP.Canvas.Pen.Width:=SelectNodeStyle.WidthLine;
     if Clear then
        begin
         FBMP.Canvas.Pen.Color:=Color_BackGround
        end
     else
         if Color<-$0 then
         FBMP.Canvas.Pen.Color:=SelectNodeStyle.ColorLine else
                                                          FBMP.Canvas.Pen.Color:=Color;
     FBMP.canvas.Brush.Style:=bsClear;
     //FBMP.Canvas.Pen.Width:=1;
     FBMP.canvas.Rectangle(r);
end;

procedure TMyTreeInBMP.SetpicBackGround(AValue: string);
begin
  if (FpicBackGround=AValue)or
   (not fileexists(AValue))then Exit;
  FpicBackGround:=AValue;
  try
    FBMPBackground:=TBitMap.Create;
    FBMPBackground.LoadFromFile(FpicBackGround);
    FBMPFon:=TBitMap.Create;
  finally
  end;
end;

procedure TMyTreeInBMP.SetpicBorder(AValue: string);
begin
  if (FpicBorder=AValue)or
   (not fileexists(AValue)) then Exit;
  FpicBorder:=AValue;
  try
    FBMPBorder:=TBitMap.Create;
    FBMPBorder.LoadFromFile(FpicBorder);
    createMask;
  finally
  end;
end;

procedure TMyTreeInBMP.Setview_birthday(AValue: boolean);
begin
  if Fview_birthday=AValue then Exit;
  Fview_birthday:=AValue;
end;

procedure TMyTreeInBMP.Setview_birthday_skoro(AValue: boolean);
begin
  if Fview_birthday_skoro=AValue then Exit;
  Fview_birthday_skoro:=AValue;
end;

procedure TMyTreeInBMP.Setview_potomk(AValue: boolean);
begin
  if Fview_potomk=AValue then Exit;
  Fview_potomk:=AValue;
end;

procedure TMyTreeInBMP.Setview_predk(AValue: boolean);
begin
  if Fview_predk=AValue then Exit;
  Fview_predk:=AValue;
end;

procedure TMyTreeInBMP.DrawTree(IDNode: integer; FCalculateON: boolean;
  UpDaown: boolean);
begin
  DrawTree(IDNode, 0, 0, FCalculateON, UpDaown);
end;

procedure TMyTreeInBMP.Calculate;
begin
          if assigned(FOnProgressEvent) then FOnProgressEvent(50,'вычисляем размеры холста');
           ComputeSizeCanvas;
           FListReDraw.Clear;
           if assigned(FOnProgressEvent) then FOnProgressEvent(50,'вычисляем координаты листьев');
           if beautiful_tree then ComputeNodeCoords else ComputeNodeCoords_old;
           if assigned(FOnProgressEvent) then FOnProgressEvent(50,'вычисляем координаты ветвей');
           ComputeEdgeCoords;
end;

procedure TMyTreeInBMP.SortingNodeInLevels;inline;
var
  lev{,i}:integer;
begin
  if not Sorting then exit;
  if Napravlenie=NapravlenieUp then
  begin
       for lev:=0 to countLevel-1 do
       begin
            {if lev=2 then
            for i:=0 to GetLevels(lev).countNode-1 do
            begin
              showmessage((GetLevels(lev).GetNodes(i) as TNode).Caption)
            end; }
            SortNodeInLevel(GetLevels(lev));
       end;
  end else
  begin
    for lev:=countLevel-1 downto 0 do SortNodeInLevel(GetLevels(lev), true);
  end;
end;

procedure TMyTreeInBMP.Drawing;
var
  w: Integer;
begin
  //Определим ширину
  // header-выведем заголовок
  if (Caption<>'') then begin
    FBMP.canvas.Font.Color:=ColorCaption;//clAqua;
    //FBMP.canvas.Font.Style:=[fsBold];
    FBMP.canvas.Font.Size:=round(FKoefM*FSizeCaptionMain);
    w:=FBMP.Canvas.TextWidth(Caption);
    FBMP.Canvas.Brush.Style:=bsSolid;
    FBMP.Canvas.Brush.Color:=Color_BackGround;
    FBMP.Canvas.Pen.Color:=Color_BackGround;
    FBMP.Canvas.Rectangle(bounds(0,0,FBMP.Width {fSizeCanvas.x},FBMP.Canvas.TextHeight(Caption)));
    FBMP.Canvas.TextOut(round(FKoefM*((fSizeCanvas.x-w) div 2)),0{round(0.25*TxtH)},Caption);
  end;

  DrawEdges;
  DrawNodes;
      if assigned(FOnProgressEvent) then
         FOnProgressEvent(50,'выводим полотно на экран');
      refresh;
      //Image.Picture.Bitmap.Assign(FBMP);
   if assigned(FOnProgressEvent) then
      FOnProgressEvent(0,'нарисовано листьев: '+inttostr(FlistVisible.Count)+'. '+FMessageErr);
   FflagDraw:=false;
end;

procedure TMyTreeInBMP.DrawTree(IDNode: integer; Iwidth: integer;
  Iheight: integer; FCalculateON: boolean; UpDown: boolean);
begin
  FflagDraw:=true;
  FmessageErr:='';
     FID_Koren:=IDNode;
  if FCalculateON then
   begin
        FListDraw.Clear;
        FListReDraw.Clear;
        if assigned(FOnProgressEvent) then FOnProgressEvent(50,'строим дерево');
        //DrawTreeID(IDNode,-maxLongint,maxLongint);//строим дерево помещая node, которые в дереве в список FListDraw
        FMinDistance:=0;
        DrawTreeID(IDNode,-maxLongint,maxLongint);//строим дерево помещая node, которые в дереве в список FListDraw
        //Если нужно и вверх и вниз
        if UpDown then
           begin
                FNapravlenie:=NapravlenieDown;
                //DrawTreeID(IDNode,-maxLongint,maxLongint);
                //FMinDistance:=0;
                DrawTreeID(IDNode,-maxLongint,maxLongint);
                FNapravlenie:=NapravlenieUp;
           end;
        if assigned(FOnProgressEvent) then FOnProgressEvent(50,'гасим ненужные листья и ветви');
        checkVisible; //гасим Node и Edge, которые ранее светились, но теперь не будут отображаться
        if Sorting then
         begin
              if assigned(FOnProgressEvent) then FOnProgressEvent(50,'сортируем листья на уровнях');
              SortingNodeInLevels;//отсортируем Node, которые будем рисовать
         end;
        Calculate;    //Вычисляем координаты Node и Edge, определяя так же те Node,
                      //которые будут на новом месте помещая их в список FListReDraw
        //checkReDraw; //гасим Node и Edge, которые будут перерисованы
   end;

  resizing(IWidth,IHeight, IDNode);//Зададим размер холста

  if assigned(FOnProgressEvent) then FOnProgressEvent(50,'строим список ветвей');
  DoSpisDrawEdges;
  if FDrawClear then
   begin
        if assigned(FOnProgressEvent) then FOnProgressEvent(50,'очищаем полотно');
        setFonBMP;//Установим фон на новый размер - очистим полотно
        FDrawClear:=false;
   end;
  {if not FDrawClear then}
  if FListReDraw.Count>0 then//Если хотя бы один лист изменил положение, то убираем все ветви и листья которые на новом месте
   begin
        if assigned(FOnProgressEvent) then FOnProgressEvent(50,'стираем старые ветви');
        ClearEdges;
        if assigned(FOnProgressEvent) then FOnProgressEvent(50,'стираем старые листья');
        ClearNodes;
   end;

   Drawing;//рисуем на холсте дерево
end;

procedure TMyTreeInBMP.resizing(Iwidth: integer; Iheight: integer;
  IDNode: integer);
var
  szCanvas:TPoint;
  FBMPtmp:TBitmap;
begin
   if (Iwidth>0)and(Iheight>0)and//Если передали размер холста
  (
  ((Iwidth<>FBMP.Width)or(Iheight<>FBMP.height))//и текущий размер отличаеися от переданного
  or
  //или изменилась ширина дерева и  она больше текущего полотна
  ((round(FKoefM*fSizeCanvas.x)>FBMP.Width)or(round(FKoefM*fSizeCanvas.y)>FBMP.height))
  ) then
   begin
        //Зададим размер холста
          if (Iwidth>round(FKoefM*fSizeCanvas.x)) then
           szCanvas:=TPoint.Create(Iwidth, 0)//установим новую ширину
          else
            szCanvas:=TPoint.Create(round(FKoefM*fSizeCanvas.x), 0);//рассчитанная ширина дерева
          if (Iheight>round(FKoefM*fSizeCanvas.y)) then
           szCanvas.y:=Iheight
          else
            szCanvas.y:=round(FKoefM*fSizeCanvas.y);
         if (FBMP.Width<>szCanvas.x)or(FBMP.Height<>szCanvas.y) then
          begin
               if assigned(FOnProgressEvent) then FOnProgressEvent(50,'задаем размеры холста и строим дерево');
               //FDrawClear:=true;
               if picBackGround<>'' then
                FBMPFon.clear;
               FBMPtmp:=TBitmap.Create;
               FBMPtmp.Assign(FBMP);
               FBMP.Clear;
               FBMP.SetSize(szCanvas.x,szCanvas.y);
               SetFonBMP;//Установим фон на новый размер
               FBMP.Canvas.Draw(0,0,FBMPtmp);
               FreeAndNil(FBMPtmp);
               if picBackGround<>'' then
                begin
                     FBMPFon.Assign(FBMP);
                     FBMPFon.Canvas.StretchDraw(rect(0,0,FBMPFon.Width,FBMPFon.Height),FBMPBackground);
                end;
          end;
   end;
end;

procedure TMyTreeInBMP.resizeTree(Iwidth: integer; Iheight: integer);
begin
   resizing(Iwidth, Iheight);
   refresh;
end;

end.

