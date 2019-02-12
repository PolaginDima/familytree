unit searchSelection;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

procedure SearchStartSelect;//Ищем вверху начало областей которые можно заполнить

implementation

uses viewfoto;

procedure SearchStartSelect;//поиск начальных позиций для закрашивания
var
  ix,iy,Min,max:integer;
  procedure SearchHole(min,max,y:integer);//Поиск двух не соседних точек
  var
    iix,leftl,leftr:integer;
  begin   //Проверяем наличие двух не соседних точек
    leftl:=-1;
    leftr:=-1;
        for iix:=0 to high(FXiny[y].X) do
          begin
            if FXinY[y].X[iix].flag then continue;
            if FXinY[y].X[iix].X>(max+1) then break;
            if leftl=-1 then
            begin
              leftl:=FXinY[y].X[iix].X;//Кандидат на левую границу
              leftr:=FXinY[y].X[iix].X;//Кандидат на правую границу
              continue;
            end;

            if (leftr+1)=FXinY[y].X[iix].X then//сосед
            begin
              leftr:=FXinY[y].X[iix].X;//новая правая граница
              continue;
            end else
            begin
              if ((leftr+1)>=min)and((leftr+1)<=max)and((FXinY[y].X[iix].X-leftr)>1) then
              begin
                FillSelection(leftl,FXinY[y].X[iix].X,y);
                leftl:=-1;
                leftr:=-1;
                continue;
              end else
              begin
                leftl:=FXinY[y].X[iix].X;//Кандидат на левую границу
                leftr:=FXinY[y].X[iix].X;//Кандидат на правую границу
              end;
            end;
          end;
  end;

begin     //Ищем одну(одинокую) точку или последовательность точек не выколотую
  min:=-1;
  for iy:=0 to high(FXinY) do
    begin
      for ix:=0 to high(FXinY[iy].X) do
        begin
          if (min=-1) and (not FXinY[iy].X[ix].flag) then
          begin
            min:=ix;
            max:=min;
            continue;
          end;
          if ((FXinY[iy].X[ix].X-1)=FXinY[iy].X[max].X) and (not FXinY[iy].X[ix].flag) then
          begin
            max:=ix;
            continue;
          end
          else
          begin
            SearchHole(FXinY[iy].X[min].X,FXinY[iy].X[max].X,iy+1);
            min:=ix;
            max:=min;
          end;
        end;
      if (min>-1)and(max>-1)and(iy<high(FXinY)) then
         SearchHole(FXinY[iy].X[min].X,FXinY[iy].X[max].X,iy+1);
      min:=-1;
      max:=-1;
    end;
end;

end.

