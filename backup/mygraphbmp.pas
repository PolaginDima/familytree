unit myGraphBMP;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, mygraph;
type
      TSostNd=(SelNode);//selNode-Node выбран
      TSostNodes=set of TSostNd;
      {TSostTr=(TrSelNode);
      TSostTree=set of TSostTr; }

      {TCoord=record
        x,y:integer;
      end; }

     const
       //edge style
       DefaultEdgeWidthLine=1;//2
       DefaultEdgeColorLine=TColor($F9F9F9);//clSilver;//clOlive;//clblack;
       DefaultEdgeColorFill=clSilver;
       DefaultEdgeColorLigth=clYellow;

       // node style
       DefaultNodeWidthLine=1;
       DefaultNodeColorLine=clblack;
       DefaultNodeColorFill=clSilver;//clgreen;//clSilver;
       DefaultColorNodeCaption=TColor($020202);

       //Graph Style
       DefaultFotoWidth=50;//200
       DefaultFotoHeight=50;//200
       DefaultBeetweenWidth=15;//50
       DefaultBeetweenHeight=50;//150
       DefaultTextHeight=30;
       DefaultTopHeight=35;
       DefaultBottomHeight=15;
       DefaultLeftWidth=15;
       DefaultRigthWidth=15;
       DefaultwidthBorder=10;
       defaultSizeCaptionMain=18;
       defaultSizeCaption=8;//14

       //
       MinDist                             =30;//100;
       ColorBackGround                     =clSilver;
       ColorCaption                        =clAqua;//TColor($020202);
       //ColorNodeCaption             =TColor($020202);
       ColorTransparent1                   =clBlack;//TColor($010101);
       ColorTransparent2                   =TColor($010101);
       ColorTransparentMask                =clWhite;//TColor($020202);
type
       { TNodeStyle }

     TNodeStyle=class(TObject)
     private
       FColorCaption: TColor;
       FColorFill: TColor;
       FColorLine: TColor;
       FWidthLine: integer;
     protected
     public
       constructor Create;
       destructor Destroy;override;
       property WidthLine:integer read FWidthLine write FWidthLine;
       property ColorLine:TColor read FColorLine write FColorLine;
       property ColorFill:TColor read FColorFill write FColorFill;
       property ColorCaption:TColor read FColorCaption write FColorCaption;
     end;

      { TEdgeStyle }

      TEdgeStyle=class(Tobject)
      private
        FColorFill: TColor;
        FColorLine: TColor;
        FWidthLine: integer;
      protected
      public
        constructor Create;
        destructor Destroy;override;
        property WidthLine:integer read FWidthLine write FWidthLine;
        property ColorLine:TColor read FColorLine write FColorLine;
        property ColorFill:TColor read FColorFill write FColorFill;
      end;

       { TLevel }

     TLevel=class(TMyGraphLevel)
       private
         FcountDrawLevelNode: integer;
       protected
       public
         constructor Create;override;
         destructor Destroy;override;
         property countDrawLevelNode:integer read FcountDrawLevelNode write FcountDrawLevelNode;
      end;

     { TNode }

     TNode=class(TMyGraphNode)
       private
         Favatar: TMemoryStream;
         FavatarHeight: integer;
         FavatarWidth: integer;
         FBirthday: boolean;
         FBirthdaySkoro: boolean;
         FCaption: string;
         FcaptionChange: boolean;
         FCaptionOLD: string;
         FDeath: boolean;
         Fdtbirthday: Tdate;
         Fdtdeath: Tdate;
         Fflag: integer;
         FNodeCenter: TPoint;
         FNodeCenterOLD: TPoint;
         FSelectNode: TSostNodes;
         FStyle: TNodeStyle;
         procedure Setavatar(AValue: TMemoryStream);
         procedure SetCaption(AValue: string);
         procedure SetCaptionOLD(AValue: string);
         procedure SetDeath(AValue: boolean);
       protected
       public
         constructor Create(id_Node:integer);override;
         destructor Destroy;override;
         property Caption: string read FCaption write SetCaption;
         property CaptionOLD: string read FCaptionOLD write SetCaptionOLD;
         property NodeCenter:TPoint read FNodeCenter write FNodeCenter;
         property NodeCenterOLD:TPoint read FNodeCenterOLD write FNodeCenterOLD;
         property SostNode:TSostNodes read FSelectNode write FSelectNode;
         property Style:TNodeStyle read FStyle write FStyle;
         property avatar:TMemoryStream read Favatar write Setavatar;
         property avatarWidth:integer read FavatarWidth write FavatarWidth;
         property avatarHeight:integer  read FavatarHeight write FavatarHeight;
         property Death:boolean read FDeath write SetDeath;
         property captionChange:boolean read FcaptionChange write FcaptionChange;
         property Birthday:boolean read FBirthday write FBirthday;
         property BirthdaySkoro:boolean read FBirthdaySkoro write FBirthdaySkoro;
         property dtbirthday:Tdate read Fdtbirthday write Fdtbirthday;
         property dtdeath:Tdate read Fdtdeath write Fdtdeath;
         property Flag:integer read Fflag write Fflag default 0;
      end;

     { TEdge }

     TEdge=class(TMyGraphEdge)
       private
         FDrawnAt: TRect;
         FDrawnAtOLD: TRect;
         FStyle: TEdgeStyle;
       protected
       public
         constructor Create(Source_Top,Target_Bottom:TObject);override;
         destructor Destroy;override;
         property DrawnAt: TRect read FDrawnAt write FDrawnAt;
         property DrawnAtOLD: TRect read FDrawnAtOLD write FDrawnAtOLD;
         property Style:TEdgeStyle read FStyle write FStyle;
      end;

implementation

{ TNodeStyle }

constructor TNodeStyle.Create;
begin
  inherited Create;
  ColorLine:=DefaultNodeColorLine;
  WidthLine:=DefaultNodeWidthLine;
  ColorFill:=DefaultNodeColorFill;
  ColorCaption:=DefaultColorNodeCaption;
end;

destructor TNodeStyle.Destroy;
begin
  inherited Destroy;
end;

{ TEdgeStyle }

constructor TEdgeStyle.Create;
begin
  inherited Create;
  ColorLine:=DefaultEdgeColorLine;
  WidthLine:=DefaultEdgeWidthLine;
  ColorFill:=DefaultEdgeColorFill;
end;

destructor TEdgeStyle.Destroy;
begin
  inherited Destroy;
end;

{ TEdge }

constructor TEdge.Create(Source_Top, Target_Bottom: TObject);
begin
  inherited Create(Source_Top, Target_Bottom);
end;

destructor TEdge.Destroy;
begin
  inherited Destroy;
end;

{ TLevel }

constructor TLevel.Create;
begin
  inherited Create;
end;

destructor TLevel.Destroy;
begin
  inherited Destroy;
end;

{ TNode }

procedure TNode.Setavatar(AValue: TMemoryStream);
begin
  if ((AValue=nil) and (Favatar=nil))then exit;
  if ((AValue=nil) and (Favatar<>nil))then
   begin
        FAvatar.Free;
        FAvatar:=nil;
   end
   else if (AValue<>nil) then
  begin
       if Favatar<>nil then FAvatar.Free;
       FAvatar:=TMemoryStream.Create;
       Favatar.LoadFromStream(AValue);
  end;
end;

procedure TNode.SetCaption(AValue: string);
begin
  if FCaption=AValue then Exit;
  FCaption:=AValue;
  captionChange:=true;
end;

procedure TNode.SetCaptionOLD(AValue: string);
begin
  if FCaptionOLD=AValue then Exit;
  FCaptionOLD:=AValue;
end;

procedure TNode.SetDeath(AValue: boolean);
begin
  if FDeath=AValue then Exit;
  FDeath:=AValue;
end;

constructor TNode.Create(id_Node: integer);
begin
  inherited Create(id_Node);
  Death:=false;
  FcaptionChange:=false;
  FBirthday:=false;
  FBirthdaySkoro:=false;
  Fflag:=0;
end;

destructor TNode.Destroy;
begin
  Favatar.Free;
  inherited Destroy;
end;

end.

