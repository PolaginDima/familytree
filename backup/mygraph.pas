unit myGraph;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;//, dialogs;

type
    TMyGraphNode=class;
    TMyGraphEdge=class;
    TMyGraphLevel=class;

    FBeforeRemoveEdgeEvent=procedure(Sender:Tobject) of object;
    FBeforeRemoveLevelEvent=procedure(Sender:Tobject) of object;
    FBeforeRemoveNodeEvent=procedure(Sender:Tobject) of object;

  type

   { TMyGraph }

   TMyGraph=class(TObject)
     private
       FlistNodes:Tlist;
       FlistEdges:Tlist;
       FlistLevels:Tlist;
       function GetcountEdge: integer;
       function GetEdge(i: integer): TMyGraphEdge;
       function GetNodecount: integer;
       function GetNodes(index: integer): TMyGraphNode;
       function addNode(Node:TMyGraphNode):TMyGraphNode;
       //function FindPraRoditels(id_Node:integer):TList;
       //function CompareRoditels(id_Source, id_Target:integer):boolean;
       function GetcountLevel: integer;
       //function ExistCommonFather(Source, Target:TMyGraphNode;lev:integer):boolean;
       //procedure moveNodes(TargetBottom:TMyGraphNode;countLevel:integer;IdNode:integer=-1; moveTree:boolean=false);virtual;
     protected
       function CreatedNode(idNode:integer):TMyGraphNode;virtual;
       function CreatedEdge(SourceTop,TargetBottom:TObject):TMyGraphEdge; virtual;
       function CreatedLevel:TMyGraphLevel;virtual;
       function GetNodesIDNode(IDNode: integer): TMyGraphNode;virtual;
       function GetLevels(index: integer): TMyGraphLevel;virtual;
       function GetLevelNumber(Node:TObject):integer;overload;
       //function GetLevelNumber(Level:TObject):integer;overload;
       function GetNodeNumberInLevel(Node:TObject):integer;
       function addEdge(SourceTop,TargetBottom:TMyGraphNode):TMyGraphEdge;virtual;
       procedure AfterAddEdge(Sender:TObject);virtual;abstract;
       procedure AfterAddNode(Sender:TObject);virtual;abstract;
       procedure BeforeRemoveEdge(Sender:TObject);virtual;
       procedure BeforeRemoveNode(Sender:TObject);virtual;
       procedure BeforeRemoveLevel(Sender:TObject);virtual;
       procedure removeAllNodes;virtual;
       //procedure SortingNodeInLevel(Level:TMyGraphLevel;Compare: TListSortCompare);
       property countLevel:integer read GetcountLevel;
       property countEdge:integer read GetcountEdge;
       property Edges[i:integer]:TMyGraphEdge read GetEdge;
     public
       constructor Create;virtual;
       destructor Destroy;override;
       function addNode(idNode:integer):TMyGraphNode;virtual;
       function addEdge(idSourceTop,idTargetBottom:integer):TMyGraphEdge;virtual;
       function RemoveAllEdge:boolean;virtual;
       function RemoveAllEdgeAndNodeLevelNil:boolean;virtual;
       procedure removeEdge(idSource,idTarget:integer);
       procedure removeNodeIDNode(ID:integer);
       property Nodecount:integer read GetNodecount;
       property Nodes[i:integer]:TMyGraphNode read GetNodes;
   end;

   { TMyGraphLevel }

   TMyGraphLevel=class(TObject)
     private
       FlistNodes:TList;
       FOnBeforeRemoveLevel:FBeforeRemoveLevelEvent;
       function GetcountNode: integer;
     protected
     public
       constructor Create;virtual;
       destructor Destroy;override;
       function AddNode(Node:TMyGraphNode):integer;
       function IndexOfNode(Node:TMyGraphNode): integer;
       function GetNodes(index: integer): TMyGraphNode;
       procedure RemoveNode(Node:TObject);
       procedure MoveNode(oldIndex, newIndex:integer);
       procedure Sort(Compare: TListSortCompare);virtual;
       property countNode:integer read GetcountNode;
       property OnBeforeRemoveLevel:FBeforeRemoveLevelEvent read FOnBeforeRemoveLevel write FOnBeforeRemoveLevel;
   end;

   { TMyGraphNode }

   TMyGraphNode=class(TObject)
     private
       FidNode: integer;
       Flevel:TMyGraphlevel;
       FlistinEdges:Tlist;
       FlistoutEdges:Tlist;
       FOnBeforeRemoveNode: FBeforeRemoveNodeEvent;
       function GetinEdgecount: integer;
       function GetinEdges(index: integer): TMyGraphEdge;
       function GetLevel: TMyGraphLevel;
       function GetoutEdgecount: integer;
       function GetoutEdges(index: integer): TMyGraphEdge;
       procedure SetLevel(AValue: TMyGraphlevel);
     protected
     public
       constructor Create(idNode:integer);virtual;
       destructor Destroy;override;
       procedure removeinEdge(Edge:TMyGraphEdge);
       procedure removeoutEdge(Edge:TMyGraphEdge);
       property outEdgecount:integer read GetoutEdgecount;
       property outEdges[index:integer]:TMyGraphEdge read GetoutEdges;
       property inEdgecount:integer read GetinEdgecount;
       property inEdges[index:integer]:TMyGraphEdge read GetinEdges;
       property idNode:integer read FidNode write FidNode;
       property Level:TMyGraphlevel read GetLevel write SetLevel;
       property OnBeforeRemoveNode:FBeforeRemoveNodeEvent read FOnBeforeRemoveNode write FOnBeforeRemoveNode;
   end;

   { TMyGraphEdge }

   TMyGraphEdge=class(TObject)
     private
       FOnBeforeRemoveEdge: FBeforeRemoveEdgeEvent;
       FSourceTop: TMyGraphNode;
       FTargetBottom: TMyGraphNode;
     protected
     public
     constructor Create(SourceTop,TargetBottom:TObject);virtual;
     destructor Destroy;override;
     property SourceTop:TMyGraphNode read FSourceTop;
     property TargetBottom:TMyGraphNode read FTargetBottom;
     property OnBeforeRemoveEdge:FBeforeRemoveEdgeEvent read FOnBeforeRemoveEdge write FOnBeforeRemoveEdge;
   end;

implementation

{ TMyGraphEdge }

constructor TMyGraphEdge.Create(SourceTop, TargetBottom: TObject);
begin
 inherited Create;
 FSourceTop:=(sourcetop as TMyGraphNode);
 FTargetBottom:=(targetbottom as TMyGraphNode);
 //добавим концы пути
 (sourcetop as TMyGraphNode).FlistoutEdges.Add(self);
 (TargetBottom as TMyGraphNode).FlistinEdges.Add(self);
end;

destructor TMyGraphEdge.Destroy;
begin
 if assigned(FOnBeforeRemoveEdge) then FOnBeforeRemoveEdge(self);
 inherited Destroy;
end;

{ TLevel }

function TMyGraphLevel.GetNodes(index: integer): TMyGraphNode;
begin
 if (FlistNodes=nil)or(FlistNodes.Count<index)or(index<0) then exit;
 result:=TMyGraphNode(FlistNodes.Items[index]);
end;

function TMyGraphLevel.GetcountNode: integer;
begin
 result:=FlistNodes.Count;
end;

procedure TMyGraphLevel.RemoveNode(Node: TObject);
begin
 FlistNodes.Remove(Node);
 if FlistNodes.Count=0 then
  FreeAndNil(self);
end;

function TMyGraphLevel.IndexOfNode(Node: TMyGraphNode): integer;
begin
  result:=FlistNodes.IndexOf(Node);
end;

procedure TMyGraphLevel.MoveNode(oldIndex, newIndex: integer);
begin
 FlistNodes.Move(oldIndex, newIndex);
end;

procedure TMyGraphLevel.Sort(Compare: TListSortCompare);
begin
  FlistNodes.Sort(Compare);
end;

constructor TMyGraphLevel.Create;
begin
 inherited Create;
 FlistNodes:=TList.Create;
end;

destructor TMyGraphLevel.Destroy;
begin
 FlistNodes.Free;
 if assigned(FOnBeforeRemoveLevel) then
  FOnBeforeRemoveLevel(self);
 inherited Destroy;
end;

function TMyGraphLevel.AddNode(Node: TMyGraphNode): integer;
begin
 result:=flistNodes.IndexOf(Node);
 if result=-1 then
   begin
        flistNodes.add(Node);
        result:=flistNodes.Count-1;
   end;
end;

{ TNode }

function TMyGraphNode.GetinEdges(index: integer): TMyGraphEdge;
begin
 result:=TMyGraphEdge(flistinEdges.Items[index]);
end;

function TMyGraphNode.GetinEdgecount: integer;
begin
 result:=FlistinEdges.Count;
end;

function TMyGraphNode.GetLevel: TMyGraphLevel;
begin
 result:=nil;
 if FLevel=nil then exit;
 result:=FLevel;
end;

function TMyGraphNode.GetoutEdgecount: integer;
begin
 result:=FlistoutEdges.Count;
end;

function TMyGraphNode.GetoutEdges(index: integer): TMyGraphEdge;
begin
 result:=TMyGraphEdge(flistoutEdges.Items[index]);
end;

procedure TMyGraphNode.SetLevel(AValue: TMyGraphlevel);
begin
 if FLevel=AValue then exit;
 if FLevel<>nil then
  begin
       FLevel.RemoveNode(self);
  end;
 Flevel:=AValue;
 if FLevel<>nil then
  FLevel.AddNode(self);
end;

constructor TMyGraphNode.Create(idNode: integer);
begin
 inherited Create();
 idNode:=idnode;
 FlistinEdges:=TList.Create;
 FlistoutEdges:=TList.Create;
end;

destructor TMyGraphNode.Destroy;
begin
 if assigned(FOnBeforeRemoveNode) then
    FOnBeforeRemoveNode(self);
 FreeAndNil(FlistinEdges);
 FreeAndNil(FlistoutEdges);
 inherited Destroy;
end;

procedure TMyGraphNode.removeinEdge(Edge: TMyGraphEdge);
begin
 //Удалим из списка
 FlistinEdges.Remove(Edge);
end;

procedure TMyGraphNode.removeoutEdge(Edge: TMyGraphEdge);
begin
 //Удалим из списка
 FlistoutEdges.Remove(Edge);
end;

{ TMyGraph }

function TMyGraph.GetNodes(index: integer): TMyGraphNode;
begin
 if ((index>(flistNodes.Count-1))or
 (index<0))then
   begin
     result:=nil;
     exit;
   end;
 result:=TMyGraphNode(flistNodes.Items[index]);
end;

function TMyGraph.GetNodecount: integer;
begin
 if FlistNodes=nil then result:=0 else
  result:=FlistNodes.Count;
end;

function TMyGraph.GetcountEdge: integer;
begin
  result:=FlistEdges.Count;
end;

function TMyGraph.GetEdge(i: integer): TMyGraphEdge;
begin
  result:=TMyGraphEdge(FlistEdges.Items[i]);
end;

function TMyGraph.CreatedNode(idNode: integer): TMyGraphNode;
begin
 result:=TMyGraphNode.Create(idnode);
 result.OnBeforeRemoveNode:=@BeforeRemoveNode;
end;

function TMyGraph.CreatedEdge(SourceTop, TargetBottom: TObject): TMyGraphEdge;
begin
 result:=TMyGraphEdge.Create(SourceTop,TargetBottom);
 result.OnBeforeRemoveEdge:=@BeforeRemoveEdge;
end;

function TMyGraph.CreatedLevel: TMyGraphLevel;
begin
  result:=TMyGraphLevel.Create;
  result.OnBeforeRemoveLevel:=@BeforeRemoveLevel;
end;

function TMyGraph.GetNodesIDNode(IDNode: integer): TMyGraphNode;
var i:integer;
begin
 for i:=0 to FlistNodes.Count-1 do
 begin
 if TMyGraphNode(FlistNodes.Items[i]).idNode=idnode then
   begin
        result:=TMyGraphNode(FlistNodes.Items[i]);
        exit;
        break;
   end;
 end;
 result:=nil;
end;

function TMyGraph.GetLevels(index: integer): TMyGraphLevel;
begin
 if ((index>(flisTLevels.Count-1))or
 (index<0))then
   begin
     result:=nil;
     exit;
   end;
 result:=TMyGraphLevel(flisTLevels.Items[index]);
end;

function TMyGraph.GetLevelNumber(Node: TObject): integer;
begin
 if (Node is TMyGraphNode) then
  result:=FlistLevels.IndexOf((node as TMyGraphNode).Level);
 if (Node is TMyGraphLevel) then
  result:=FlistLevels.IndexOf(Node);
end;

function TMyGraph.GetNodeNumberInLevel(Node: TObject): integer;
begin
  result:=(Node as TMyGraphNode).Level.IndexOfNode(Node as TMyGraphNode);
end;

constructor TMyGraph.Create;
begin
 inherited Create;
 FlistNodes:=TList.Create;
 FlisTLevels:=TList.Create;
 FlistEdges:=TList.Create;
end;

destructor TMyGraph.Destroy;
var
 i:integer;
begin
 //уничтожим все Node
 for i:=flistNodes.Count-1 downto 0 do
 begin
   removeNodeIDNode(TMyGraphNode(flistNodes.Items[i]).idNode);
 end;
 FlistNodes.Free;
 FlisTLevels.Free;
 FlistEdges.Free;
 inherited Destroy;
end;

function TMyGraph.addNode(idNode: integer): TMyGraphNode;
var
 i:integer;
begin
 i:=flistNodes.Count-1;
 //проверим может уже есть такой
 while (i>=0)and(TMyGraphNode(FlistNodes.Items[i]).idNode<>idnode) do dec(i);
 if i>-1 then
   begin
   //если есть, то
     //поместим на уровень 0, если без уровня
   if flisTLevels.Count<=0 then flisTLevels.Add(CreatedLevel);
   //вернем на него ссылку
   result:=TMyGraphNode(FlistNodes.Items[i]);
   result.Level:=GetLevels(0);
   exit;
   end
 else
   //если нет, то создадим
   result:=CreatedNode(idnode);
 result.idNode:=idNode;
 addNode(result);
end;

function TMyGraph.addNode(Node: TMyGraphNode): TMyGraphNode;
begin
 //Добавим ссылку в список
 FlistNodes.Add(Node);
 //поместим на уровень 0
 if flisTLevels.Count<=0 then flisTLevels.Add(CreatedLevel);
 node.Level:=GetLevels(0);  //запомним на каком уровне Node
 result:=Node;
 AfterAddNode(result);
end;

function TMyGraph.addEdge(idSourceTop,idTargetBottom:integer): TMyGraphEdge;
var
 i{, j, LevelMin}:integer;
 SourceNode,TargetNode:TMyGraphNode;
 Level:TMyGraphLevel;
begin
 //проверим есть ли такой путь
 i:=flistEdges.Count-1;
 while (i>=0)and(not ((TMyGraphEdge(FlistEdges.Items[i]).SourceTop.idNode=idSourceTop)and
(TMyGraphEdge(FlistEdges.Items[i]).TargetBottom.idNode=idTargetBottom))) do dec(i);
 if i>-1 then
   begin
        //если есть, то вернем на него ссылку
        result:=TMyGraphEdge(FlistEdges.Items[i]) ;
        AfterAddEdge(result);
        exit;
   end ;
   //если нет, то создадим, попутно при необходиомсти node-ы
   SourceNode:=GetNodesIDNode(idSourceTop);
   TargetNode:=GetNodesIDNode(idTargetBottom);
   if ((TargetNode=nil)) then
       begin
            if (SourceNode=nil) then
             SourceNode:=addNode(idSourceTop);
            if SourceNode.Level=nil then
             begin
                  Level:=getlevels(0);
                        if Level=nil then
                         begin
                              Level:=CreatedLevel;
                              FlistLevels.Add(Level);
                         end;
                        SourceNode.Level:=Level;
             end;
            TargetNode:=addNode(idTargetBottom);
            i:=FlistLevels.IndexOf(SourceNode.Level);
            if FlistLevels.Count<(i+2)  then FlistLevels.Add(CreatedLevel);
            TargetNode.Level:=TMyGraphLevel(FlistLevels.Items[i+1]);
       end else
    if ((SourceNode=nil)and(TargetNode<>nil))then
       begin
            if TargetNode.Level=nil then
             begin
                  Level:=getlevels(0);
                        if Level=nil then
                         begin
                              Level:=CreatedLevel;
                              FlistLevels.Add(Level);
                         end;
                        TargetNode.Level:=Level;
             end;
            SourceNode:=addNode(idSourceTop);
            if FlistLevels.IndexOf(TargetNode.Level)=0 then
                  FlistLevels.Insert(0,CreatedLevel);
            i:=FlistLevels.IndexOf(TargetNode.Level);
            SourceNode.Level:=getlevels(i-1);
       end else
       begin
            //Определим какой из двух Node безхозный, т.е. Level=nil
            if TargetNode.Level=nil then
             begin
                  if SourceNode.Level=nil then
                   begin
                        Level:=getlevels(0);
                        if Level=nil then
                         begin
                              Level:=CreatedLevel;
                              FlistLevels.Add(Level);
                         end;
                        SourceNode.Level:=Level;
                   end;
                  i:=FlistLevels.IndexOf(SourceNode.Level)+1;
                  Level:=getlevels(i);
                  if Level=nil then
                   begin
                        Level:=CreatedLevel;
                        FlistLevels.Add(Level);
                   end;
                   TargetNode.Level:=Level;
             end else
             begin
                  i:=FlistLevels.IndexOf(TargetNode.Level)-1;
                  if i<0 then
                   begin
                        FlistLevels.Insert(0,CreatedLevel);
                        Level:=getlevels(0);
                   end else
                       Level:=getlevels(i);;
                   SourceNode.Level:=Level;
             end;
       end;
   result:=addEdge(SourceNode,TargetNode);
   //Добавим в список Edge
   FlistEdges.Add(result);
end;

procedure TMyGraph.removeEdge(idSource, idTarget: integer);
var
 Edge:TMyGraphEdge;
begin
  Edge:=addEdge(idSource, idTarget);
  FreeAndNil(Edge);
  Edge.Free;
end;

function TMyGraph.RemoveAllEdge: boolean;
var
  edg:integer;
  Edge:TMyGraphEdge;
begin
     for edg:=countEdge-1 downto 0 do
     begin
       Edge:=Edges[edg];
       FreeAndNil(Edge);
     end;
     result:=true;
end;

function TMyGraph.RemoveAllEdgeAndNodeLevelNil: boolean;
var
  nod:integer;
  Node:TMyGraphNode;
begin
 RemoveAllEdge;
 for nod:=0 to FlistNodes.Count-1 do
 begin
   Node:=Nodes[nod];
   Node.Level:=nil;
 end;
 result:=true;
end;

procedure TMyGraph.removeAllNodes;
var
 i:integer;
 Node:TMyGraphNode;
begin
  for i:=FlistNodes.Count-1 downto 0 do
  begin
   TMyGraphNode(FlistNodes.Items[i]).Level.RemoveNode(TMyGraphNode(FlistNodes.Items[i]));
   Node:=TMyGraphNode(FlistNodes.Items[i]);
   FlistNodes.Remove(FlistNodes.Items[i]);
   TMyGraphNode(Node).Free;
  end;
  for i:=FlistLevels.Count-1 downto 0 do TMyGraphLevel(FlistLevels.Items[i]).Free;
  for i:=FlistLevels.Count-1 downto 0 do FlistLevels.Delete(i);
end;

function TMyGraph.GetcountLevel: integer;
begin
 result:=FlistLevels.Count;
end;

procedure TMyGraph.removeNodeIDNode(ID: integer);
var
 Node:TMyGraphNode;
begin
 //получим Node по ID
 Node:=GetNodesIDNode(id);
 FreeAndNil(Node);
end;

function TMyGraph.addEdge(SourceTop, TargetBottom: TMyGraphNode): TMyGraphEdge;
begin
 result:=CreatedEdge(SourceTop,TargetBottom);
 //функция после добавления пути
 AfterAddEdge(result);
end;

procedure TMyGraph.BeforeRemoveEdge(Sender: TObject);
begin
 //Удалим у Node-ов указатели на этот Edge
  (Sender as TMyGraphEdge).SourceTop.removeoutEdge((Sender as TMyGraphEdge));
  (Sender as TMyGraphEdge).TargetBottom.removeinEdge((Sender as TMyGraphEdge));
  if ((Sender as TMyGraphEdge).SourceTop.inEdgecount<=0)and((Sender as TMyGraphEdge).SourceTop.outEdgecount<=0) then
  (Sender as TMyGraphEdge).SourceTop.Level:=GetLevels(0);
  if ((Sender as TMyGraphEdge).TargetBottom.inEdgecount<=0)and((Sender as TMyGraphEdge).TargetBottom.outEdgecount<=0) then
  (Sender as TMyGraphEdge).TargetBottom.Level:=GetLevels(0);
  //Удалим из списка
  FlistEdges.Remove(Sender);
end;

procedure TMyGraph.BeforeRemoveNode(Sender: TObject);
var
 i:integer;
 Node:TMyGraphNode;
begin
Node:=(Sender as TMyGraphNode);
//Удалим связанные с Node Edge
for i:=Node.inEdgecount-1 downto 0 do
begin
     //TMyGraphEdge(Node.inEdges[i]).SourceTop.removeoutEdge(TMyGraphEdge(Node.inEdges[i]));
     TMyGraphEdge(Node.inEdges[i]).Free;
end;
for i:= Node.outEdgecount-1 downto 0 do
begin
     //TMyGraphEdge(Node.outEdges[i]).TargetBottom.removeinEdge(TMyGraphEdge(Node.outEdges[i]));
     TMyGraphEdge(Node.outEdges[i]).Free;
end;
 //Удалим из списка
 FlistNodes.Remove(Sender as TMyGraphNode);

 //Удалим с уровня Node
 if (Sender as TMyGraphNode).Level<>nil then
  begin
       (Sender as TMyGraphNode).Level.RemoveNode(Sender as TMyGraphNode);
  end;
end;

procedure TMyGraph.BeforeRemoveLevel(Sender: TObject);
begin
//Удалим из списка
 FlistLevels.Remove(Sender);
end;

end.

