unit getrectinselection;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,Graphics;

type

  TmyPoints=record//Точка
      X,Y:integer;
    end;

  TmyRect=record//прямоугольник - координаты прямоугольника
      xl,yl,xr,yr:integer;
    end;
  TmyarrayRect=array of TmyRect;

  function getRectFromPoints(var massPoint:array of TmyPoints;countPoint:integer;const deltaX:integer;Ymin,Ymax:integer):TmyarrayRect;//Получаем упорядоченный массив точек и поргешность, возвращаем массив прямоугольников

implementation

uses viewfoto;

type

  TcoordX=record//координата X точки и признак выколотости
      X:integer;
      flag:boolean;
    end;

    TmyarrayXs=record//массив координат X точек и признак выколотости
          X:array of TcoordX;
    end;

    TmyXY=record//Строка координата Y и левый и правый край
      Xl,Xr,Y:integer;
    end;

var
  FminY,FmaxY,Fdeltax:integer;
  FcountStroki:integer;
  FXinY: array of TmyarrayXs;//Значения Х распределенные по Y - строкам
  FStroki:array of TmyXY;

procedure MoveXinY(var massPoint:array of TmyPoints;countPoint:integer);//группируем точки по координате Y
var
  i,ii,coordY,lastX:integer;
begin
  setlength(FXinY,FmaxY-FminY+1);
  for i:=0 to countpoint do//high(massPoint) do
  begin
    coordY:=massPoint[i].Y-FminY;
    if high(FXinY[coordY].X)=-1 then
      setlength(FXinY[coordY].X,1)
    else
      setlength(FXinY[coordY].X,high(FXinY[coordY].X)+2);
    lastX:=high(FXinY[coordY].X);
      FXinY[coordY].X[lastX].X:=massPoint[i].X;
        for ii:=lastX downto 1 do
          begin
            if massPoint[i].X<FXinY[coordY].X[ii-1].X then
            begin
              FXinY[coordY].X[ii].X:=FXinY[coordY].X[ii-1].X;
              FXinY[coordY].X[ii-1].X:=massPoint[i].X;
            end else
                break;
          end;
  end;
end;

procedure FillSelection(leftx_l,leftx_r,y_start:integer;indexright_old:integer=-1);//Заполняем область
var
  iy,ixl,indexleft,indexleftold,indexrightold,indexright,leftxold,rightxold,leftxtmp,leftxnew,rightxnew:integer;
  first,firstline,endfill:boolean;
  startFcountStroki:integer;

  function checknewstring:byte;{проверяем надо ли искать первую точку строки или она уже найдена
  }
  begin
     if (leftxtmp=-1) then //начало поиска новой строки - значит ищем первую точку
     begin
       if FXinY[iy].x[ixl].flag then
       begin//если очередная точка "выколота"(уже использовалась), то переходим к следующей точке
         result:=2;
         exit;
       end;
       if ((rightxold-1)<=FXinY[iy].x[ixl].X){нет дырки - есть разрыв заполнения
       т.е.если новая точка "слишком" справа}
         then
         begin
           leftxtmp:=-1;
           result:=1;//значит прекращаем заполнение - все
           exit;
         end;
       indexleft:=ixl;//запоминаем индекс левого края левой границы
       //кандидат на левый край левой границы
       leftxtmp:=FXinY[iy].x[ixl].X;
       indexright:=ixl;//запоминаем индекс правого края левой границы
       result:=2;
     end else result:=255;
  end;

  function checknewrightedgeleftborder:byte;
  begin
    if ((rightxold-1)<=FXinY[iy].x[ixl].X)//нет дырки - есть разрыв заполнения
    then  //если новая точка "слишком" справа
      begin
        leftxtmp:=-1;//поиск левой границы заново
        if leftxnew=-1 then result:=0 else result:=1;//если первоначальное заполнение, то прекращаем заполнение, иначе переходим к первоначальному
        exit;
      end;
    if FXinY[iy].x[ixl].flag then //если очередная(соседняя) точка "выколота", то переходим к следующей точке
      begin
        leftxtmp:=-1;//поиск левой границы заново
        result:=2;//переход к следующей точке
        exit;
      end;
     //кандидат на правый край левой границы
     leftxtmp:=FXinY[iy].x[ixl].X;//Устанавливаем новую левую границу
     indexright:=ixl;//запоминаем индекс правого края левой границы
     result:=2;
  end;

  function checkrightborder:boolean;
  begin
    result:=true;
    if firstline and FXinY[iy].x[ixl].flag then //если очередная точка "выколота", то переходим к следующей точке
      begin
        leftxtmp:=-1;
        result:=false;
        exit;
      end;
    if ((leftxold+1)>=FXinY[iy].x[ixl].X)//нет дырки - есть разрыв заполнения
      then  //если новая точка "слишком" слева
        begin
          leftxtmp:=-1;
          dec(ixl);
          result:=false;
        end;
  end;

  procedure correctpoint;
  begin
    if (FXinY[iy].X[indexright].X<(FXinY[iy-1].X[indexleftold].X-1))and(indexleftold>-1) then//если левый край линии сильно левее предыдущей границы
        FXinY[iy-1].X[indexleftold].flag:=false;//отменяем выкалывание, иначе будет пропуск строки

    if (FXinY[iy].x[ixl].X>(FXinY[iy-1].X[indexrightold].X+1))and(indexrightold>-1) then//если правый край линии сильно правее предыдущей границы
        FXinY[iy-1].X[indexrightold].flag:=false;//отменяем выкалывание, иначе будет пропуск строки
  end;

  function checksharppeakright:boolean;
  begin
    result:=//(FXinY[iy].x[ixl].X<(FXinY[iy-1].X[indexrightold].X-1))and(indexrightold>-1)//если правый край линии сильно левее предыдущей границы
    (FXinY[iy].x[ixl].X<(rightxold-1))and(indexrightold>-1)//если правый край линии сильно левее предыдущей границы
              and(high(FXinY[iy].x)>ixl)and//и это не последняя точка
              ((FXinY[iy].x[ixl+1].X-1)<>FXinY[iy].x[ixl].X)//и следующая точка не соседняя, т.е. острая вершина
  end;

begin
  leftxold:=leftx_l;
  rightxold:=leftx_r;
  leftxtmp:=-1;
  leftxnew:=-1;
  rightxnew:=-1;
  first:=false;
  endfill:=false;
  firstline:=true;
  indexleftold:=-1;
  indexrightold:=indexright_old;
  startFcountStroki:=FcountStroki;
  for iy:=y_start to high(FXinY) do
  begin
    for ixl:=0 to high(FXinY[iy].x) do
    begin
      case checknewstring of //Если ищем первую точку, то
           0,1:
             if not first then
               begin
                 endfill:=true;
                 break;
               end else
                    break;//прекращаем заполнение - очередная левая точка не найдена
           //1:break;//пробуем продолжить заполнение со следующей строки - если было вторичное заполнение ???
           2:continue;//левая точка найдена или выколота переходим к следующей
      end;
      //если ищем вторую точку
      if (FXinY[iy].x[ixl].X-1)=(FXinY[iy].x[ixl-1].X) then//если СОСЕДНЯЯ точка
      begin
        case checknewrightedgeleftborder of ////ищем правый край левой границы
             0,1:
               begin//прекращаем заполнение
                 if indexrightold>-1 then
                 begin
                   endfill:=true;
                   break;
                 end else
                 exit;
               end;
             //1:break;//переходим к первоначальному заполнению
             2:continue;//левая точка найдена или выколота переходим к следующей
        end;
      end else  //если НЕ соседняя точка
          begin
            if not checkrightborder then //ищем правый край линии
                 continue;

            //получаем отрезок
            if first then //Если в данной строке это уже не первая линия, то начинаем заполнение в новой процедуре
            begin
              if (leftxtmp>=(rightxold-1))then //если новая левая граница намного правее предыдущей правой, т.е. нет дырки есть разрыв заполнения
                 break;
              FillSelection(leftxtmp,FXinY[iy].x[ixl].X,iy,indexrightold);
              leftxtmp:=-1;
              continue;
            end;
            first:=true;//признак того, что в этой строке уже нарисован отрезок

            correctpoint;

            FXinY[iy].X[indexright].flag:=true;//выкалываем левую границу

            if checksharppeakright  then //Если справа оказалась острая вершина
              begin
                //FillSelection(FXinY[iy].x[ixl].X,FXinY[iy].x[ixl+1].X,iy);
                FillSelection(FXinY[iy].x[ixl].X,rightxold,iy,indexrightold);
              end
            else
              FXinY[iy].x[ixl].flag:=true;//выкалываем правую границу
            if FcountStroki>high(FStroki) then setlength(Fstroki,(high(Fstroki)+1)+2*(high(FXinY)+1));//Если массив не вмещает точки, то увеличиваем размер массива
            FStroki[FcountStroki].Y:=iy+FminY;
            FStroki[FcountStroki].Xl:=leftxtmp+1;
            FStroki[FcountStroki].Xr:=FXinY[iy].x[ixl].X-1;
            inc(FcountStroki);

            leftxnew:=leftxtmp;
            rightxnew:=FXinY[iy].x[ixl].X;
            indexleftold:=indexleft;
            indexrightold:=ixl;
            leftxtmp:=-1;
            if firstline then
               firstline:=false;
          end;

    end;
    if endfill then
      begin
        break;
      end;
    if leftxnew=-1 then break //Если отрезок не найден, то прекращаем
             else
               begin
                 leftxold:=leftxnew;
                 rightxold:=rightxnew;
                 leftxnew:=-1;
                 rightxnew:=-1;
                 first:=false;
               end;
  end;
  if not endfill then
    begin
      FcountStroki:=startFcountStroki;
    end;
end;

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
  setlength(FStroki, (high(FXinY)+1)*2);
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
          if ((FXinY[iy].X[ix].X-1)=FXinY[iy].X[max].X) and (not FXinY[iy].X[ix].flag) then//соседняя точка и не выколотая
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
  setlength(FStroki,FcountStroki);
  dec(FcountStroki);
end;

function CreateRect(var FRects:array of TmyRect):integer;
var
   pxmin,pxmax,pymin,pymax:Pinteger;

  procedure saveRect(xl,yl,xr,yr,numberRect:integer);
  {var
     tmp:integer; }
    begin
      FRects[numberRect].xl:=xl;
      FRects[numberRect].yl:=yl;
      FRects[numberRect].xr:=xr;
      FRects[numberRect].yr:=yr;
      //tmp:=FRects[high(FRects)].xl;
      if xl<pxmin^ then
         pxmin^:=xl;
      //tmp:=FRects[high(FRects)].xl;
      if xr>pxmax^ then
         pxmax^:=xr;
      if yl<pymin^ then
         pymin^:=yl;
      if yr>pymax^ then
         pymax^:=yr;
    end;

var
  istr:integer;
  xl,yl,xr,yr,curRect,sumxl,sumxr,countStrok:integer;
  procedure InitNewRect();
  begin
    xl:=FStroki[istr].Xl;
    sumxl:=xl;
    yl:=FStroki[istr].Y;
    xr:=FStroki[istr].Xr;
    sumxr:=xr;
    yr:=FStroki[istr].Y;
    countStrok:=1;
  end;

  {var
    tmp:integer;}

begin
  curRect:=0;
  xl:=-1;
  yl:=-1;
  xr:=-1;
  yr:=-1;
  sumxl:=0;
  sumxr:=0;
  countStrok:=0;
  //Setlength(FRects,high(FStroki)+1+4);//Последние 4 числа это minX,maxX,minY,maxY

  pxmin:=@FRects[high(FRects)].xl;
  pxmax:=@FRects[high(FRects)].yl;
  pymin:=@FRects[high(FRects)].xr;
  pymax:=@FRects[high(FRects)].yr;

  //tmp:=FRects[high(FRects)].xl;

  pxmin^:=maxLongint;
  pxmax^:=-maxLongint;
  pymin^:=maxLongint;
  pymax^:=-maxLongint;

  //tmp:=FRects[high(FRects)].xl;
  viewfoto.frmviewfoto.ShapeFoto.Canvas.Pen.Color:=clblue;
  for istr:=0 to high(FStroki) do
  begin
    viewfoto.frmviewfoto.ShapeFoto.Canvas.Line(FStroki[istr].Xl,FStroki[istr].Y,FStroki[istr].Xr,FStroki[istr].Y);
    continue;
    if xl=-1 then//новый прямоугольник в самом начале
       begin
         InitNewRect;
         continue;
       end;
    if (abs(FStroki[istr].Xl-xl)<=Fdeltax)and(abs(FStroki[istr].Xr-xr)<=Fdeltax)and//разница между краями не больше допустимого(Fdeltax)
     (FStroki[istr].Xr>=(FStroki[istr-1].Xl+1))//не новое заполнение
     then
       begin
         sumxl:=sumxl+FStroki[istr].Xl;
         sumxr:=sumxr+FStroki[istr].Xr;
         yr:=FStroki[istr].Y;
         inc(countStrok);
       end else
       begin
         //сохраним прямоугольник
         saveRect(round(sumxl/countStrok),yl,round(sumxr/countStrok),yr,currect);
         inc(currect);
         //новый прямоугольник
         InitNewRect;
       end;
  end;
  if xl>-1 then
     begin
       //сохраним прямоугольник
       saveRect(round(sumxl/countStrok),yl,round(sumxr/countStrok),yr,currect);
     end;
  //Setlength(FRects,currect+1);
  result:=currect+1;//возвращаем количество прямоугольников
  //SortRectInSelection(curSelection);
end;

procedure SortRectInSelection(var FRects:array of TmyRect);
var
  i,ii,best_i:integer;
  best_value:integer;
begin
  //сортируем по Y левый верхний угол по возрастанию
  for i:=0 to high(FRects)-2 do
  begin
    best_value:=FRects[i].yl;
    best_i:=i;
    for ii:=i+1 to high(FRects)-1 do
    if FRects[ii].yl<best_value then
       begin
         best_value:=FRects[ii].yl;
         best_i:=ii;
       end;
    FRects[best_i].yl:=FRects[i].yl;
    FRects[i].yl:=best_value;
  end;
end;

function getRectFromPoints(var massPoint: array of TmyPoints;
  countPoint: integer; const deltaX: integer; Ymin, Ymax: integer
  ): TmyarrayRect;
var
  countrect:integer;
  x_min,x_max,y_min,y_max:integer;
begin
  FminY:=Ymin;
  FmaxY:=Ymax;
  Fdeltax:=deltaX;
  MoveXinY(massPoint,countPoint);
  SearchStartSelect;
   Setlength(result,high(FStroki)+1+1);//Последние 4 числа это minX,maxX,minY,maxY
  countrect:=CreateRect(result);
  x_min:=result[high(result)].xl;
  x_max:=result[high(result)].yl;
  y_min:=result[high(result)].xr;
  y_max:=result[high(result)].yr;
  Setlength(result,countrect+1);//Уменьшаем размер до необходимого.Последние 4 числа это minX,maxX,minY,maxY
  result[high(result)].xl:=x_min;
  result[high(result)].yl:=x_max;
  result[high(result)].xr:=y_min;
  result[high(result)].yr:=y_max;
  SortRectInSelection(result);//Сортируем по координате Y ???
end;

end.

