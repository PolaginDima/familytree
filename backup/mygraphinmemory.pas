unit mygraphinmemory;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, dialogs, myGraph;


  type


   { TMyGraphinMemory }

   TMyGraphinMemory=class(TMyGraph)
     private
       FSorting: Boolean;
     protected
       procedure SortNodeInLevel(Level: TMyGraphLevel;Down:boolean=false);
     public
       constructor Create;virtual;
       property Sorting:Boolean read FSorting write FSorting default false;
   end;

   function SortByPositionPredok(Item1, Item2: Pointer): integer;
   function SortByPositionPotomok(Item1, Item2: Pointer): integer;

implementation

function SortByPositionPredok(Item1, Item2: Pointer): integer;
var
 Node1, Node2:TMyGraphNode;
begin
 Node1:=TMyGraphNode(Item1);
 Node2:=TMyGraphNode(Item2);
 if ((node1.inEdgecount=0)and(node2.inEdgecount=0))or
 ((Node1.inEdges[0].SourceTop.Level.IndexOfNode(Node1.inEdges[0].SourceTop)=Node2.inEdges[0].SourceTop.Level.IndexOfNode(Node2.inEdges[0].SourceTop))and
 (Node1.Level.IndexOfNode(node1)>node2.Level.IndexOfNode(node2)))then
    begin
      result:=0;
      exit;
    end else
 if (Node1.inEdges[0].SourceTop.Level.IndexOfNode(Node1.inEdges[0].SourceTop)<Node2.inEdges[0].SourceTop.Level.IndexOfNode(Node2.inEdges[0].SourceTop))or
 ((Node1.inEdges[0].SourceTop.Level.IndexOfNode(Node1.inEdges[0].SourceTop)=Node2.inEdges[0].SourceTop.Level.IndexOfNode(Node2.inEdges[0].SourceTop))and
 (Node1.Level.IndexOfNode(node1)<node2.Level.IndexOfNode(node2)))
 then
    result:=-1
    else
 if (Node1.inEdges[0].SourceTop.Level.IndexOfNode(Node1.inEdges[0].SourceTop)>Node2.inEdges[0].SourceTop.Level.IndexOfNode(Node2.inEdges[0].SourceTop))or
 ((Node1.inEdges[0].SourceTop.Level.IndexOfNode(Node1.inEdges[0].SourceTop)=Node2.inEdges[0].SourceTop.Level.IndexOfNode(Node2.inEdges[0].SourceTop))and
 (Node1.Level.IndexOfNode(node1)>node2.Level.IndexOfNode(node2)))
 then
    result:=1;
end;

function SortByPositionPotomok(Item1, Item2: Pointer): integer;
var
 Node1, Node2:TMyGraphNode;
begin
 Node1:=TMyGraphNode(Item1);
 Node2:=TMyGraphNode(Item2);
 if ((node1.outEdgecount=0)and(node2.outEdgecount=0))or
 (Node1.outEdges[0].TargetBottom.Level.IndexOfNode(Node1.outEdges[0].TargetBottom)=Node2.outEdges[0].TargetBottom.Level.IndexOfNode(Node2.outEdges[0].TargetBottom))then
    begin
      result:=0;
      exit;
    end else
 if Node1.outEdges[0].TargetBottom.Level.IndexOfNode(Node1.outEdges[0].TargetBottom)<Node2.outEdges[0].TargetBottom.Level.IndexOfNode(Node2.outEdges[0].TargetBottom)
 then result:=-1 else
 if Node1.outEdges[0].TargetBottom.Level.IndexOfNode(Node1.outEdges[0].TargetBottom)>Node2.outEdges[0].TargetBottom.Level.IndexOfNode(Node2.outEdges[0].TargetBottom)
 then result:=1;
end;


procedure TMyGraphinMemory.SortNodeInLevel(Level: TMyGraphLevel; Down: boolean);
begin
 if not Down then
    begin
      if (GetLevelNumber(Level)=0)then exit;
      Level.Sort(@SortByPositionPredok);
    end
    else
    begin
        if (GetLevelNumber(Level)=countLevel-1)or (level.countNode<=1) then exit;
        Level.Sort(@SortByPositionPotomok);
    end;
end;

constructor TMyGraphinMemory.Create;
begin
 inherited Create;
 FSorting:=false;
end;

end.


