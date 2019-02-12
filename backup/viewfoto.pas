unit viewfoto;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Menus, Types, getrectinselection;

type

  TStateFoto=(sfPic,sfHint,sfBeforeSelectioned,sfSelectioned,sfMove,sfScale);//текущее состояние фотографии

    {TmyPoints=record//Точка
      X,Y:integer;
    end; }

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

    PmyRect=^TmyRect;//Указатель на координаты прямоугольника

    {TmyRect=record//координаты прямоугольника
      xl,yl,xr,yr:integer;
    end; }

    ParRect=^TarRect;//Указатель на массив прямоугольников выделения
    TarRect=array of TmyRect;//массив прямоугольников выделения

    PmySortarray=^TmySortarray;//Указатель на отсортированный список укзателей???(возможно не нужно)

    TmySortarray=array of PmyRect;//отсортированный список указателей???(возможно не нужно)

    PcurSelection=^TmySelection;//указатель на ваделенную область

    TmySelection=record//Выделенная область
      xmin,xmax:integer;
      ymin,ymax:integer;
      FRects:array of TmyRect;
      FSortRectsfor_Y_top:TmySortarray;//???(возможно не нужно)
    end;

    TmyListSelections=array of TmySelection;//Список выделенных ообластей

  { Tfrmviewfoto }

  Tfrmviewfoto = class(TForm)
    MenuItem1: TMenuItem;
    PopupMenu1: TPopupMenu;
    ScrollBox1: TScrollBox;
    ShapeFoto: TShape;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure ShapeFotoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ShapeFotoMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ShapeFotoMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ShapeFotoMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure ShapeFotoMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure ShapeFotoPaint(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    FcountStroki:integer;
    aRow:integer;
    FbmpFoto:TBitmap;
    Fstate:byte; //0-не рисуем, 1-рисуем
    Ffirstview:boolean;
    FminY,FmaxY:integer;
    FarrayPoint:array of TmyPoints;//Точки обведенного контура
    FXinY: array of TmyarrayXs;//Значения Х распределенные по Y - строкам
    FStroki:array of TmyXY;
    //FRects:array of TmyRect; //?????
    FListSelections:TmyListSelections;
    FStateFoto:TStateFoto;//0-исходная картинка,1-всплывающая подсказка,2-выделение
    Fcountpoint:integer;
    procedure SearchStartSelect;//Ищем вверху начало областей которые можно заполнить
    procedure FillSelection(leftx_l,leftx_r,y_start:integer;indexright_old:integer=-1);//Заполняем область
    procedure CreateRect;
    procedure SortRectInSelection(curSelection:PcurSelection);
    procedure checkSelections(x,y:integer);
    procedure MoveXinY;
    procedure AddPoints(xold,yold,x,y:integer);
    procedure checkstateDown(Sender: TObject;Button: TMouseButton);
    procedure checkstateUp(Sender: TObject;Button: TMouseButton);
    function checkstateMove(Sender: TObject;Button: TShiftState):boolean;
    procedure Test;//Временная процедура для тестирования
    const ColorSelect = clYellow;
    const WidthSelect = 1;
    const Fdeltax = 15;
  public
        procedure setFoto(jpg:TJpegImage);
  end;

var
  frmviewfoto: Tfrmviewfoto;

implementation

{$R *.lfm}

{ Tfrmviewfoto }

procedure Tfrmviewfoto.FormShow(Sender: TObject);
begin
  if not Ffirstview then
  begin
    shapeFoto.Width:=FbmpFoto.Width;
    shapeFoto.Height:=FbmpFoto.Height;
    shapeFoto.Canvas.Draw(0,0,FbmpFoto);
    //shapeFoto:=0;
    Ffirstview:=true;
    Setlength(Farraypoint,2*FbmpFoto.Width+2*FbmpFoto.Height);
  end;
  timer1.Enabled:=true;
end;

procedure Tfrmviewfoto.MenuItem1Click(Sender: TObject);
begin
  FStateFoto:=sfBeforeSelectioned;//переводим в режим подготовки к рисованию
end;

procedure Tfrmviewfoto.ShapeFotoMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  //checkstateDown(Sender,Button);
end;

procedure Tfrmviewfoto.ShapeFotoMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if not checkstateMove(Sender,Shift) then exit;
  case FStateFoto of
       sfSelectioned:
         begin
           if FState=0 then //если перед этим не была нажата левая клавиша
           begin
             FState:=1;//признак того, что мы выделяем
             Fcountpoint:=0;
             shapeFoto.Canvas.Pixels[x,y]:=ColorSelect;//рисуем начальную точку
             Farraypoint[Fcountpoint].X:=X;//координаты первой точки
             Farraypoint[Fcountpoint].Y:=Y;
             if Y<FminY then FminY:=Y;
             if Y>FmaxY then FmaxY:=Y;
             exit;
           end;
           if Y<FminY then FminY:=Y;
           if Y>FmaxY then FmaxY:=Y;
           if (abs(Farraypoint[Fcountpoint].X-X)>1)or(abs(Farraypoint[Fcountpoint].Y-Y)>1) then//если есть дырка
           //то добавляем точки
           addPoints(Farraypoint[Fcountpoint].X,Farraypoint[Fcountpoint].Y,X,Y);//добавляем точки между старой и новой точкой
           inc(Fcountpoint);//увеличиваем счетчик
           if Fcountpoint>high(Farraypoint) then
           setlength(Farraypoint,2*high(Farraypoint));//если необходимо увеличиваем массив
           Farraypoint[Fcountpoint].X:=X;//координаты новой точки
           Farraypoint[Fcountpoint].Y:=Y;
           shapeFoto.Canvas.Pixels[Farraypoint[Fcountpoint].X,Farraypoint[Fcountpoint].Y]:=ColorSelect;//рисуем новую точку на экране
           //shapeFoto.Invalidate;
         end;
       sfPic:
         begin
           //checkSelections(X,Y);
         end;
  end;
end;

procedure Tfrmviewfoto.ShapeFotoMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i:integer;
begin
  checkstateUP(Sender,Button);
  exit;

  if Fstate=0 then exit; //Если мы не выделяли перед этим то выходим
   if (abs(Farraypoint[Fcountpoint].X-Farraypoint[0].X)>1)or
    (abs(Farraypoint[Fcountpoint].Y-Farraypoint[0].Y)>1) then  //если между конечной и начальной точкой дырка, то заполняем её
    addPoints(Farraypoint[Fcountpoint].X,Farraypoint[Fcountpoint].Y,Farraypoint[0].X,Farraypoint[0].Y);
  FState:=0;//признак того, что мы не выделяем
  for i:=0 to Fcountpoint do
    FbmpFoto.Canvas.Pixels[farraypoint[i].X,farraypoint[i].Y]:=ColorSelect;//рисуем точки в памяти
  MoveXinY;
  SearchStartSelect;
  //CreateRect;
end;

procedure Tfrmviewfoto.ShapeFotoMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure Tfrmviewfoto.ShapeFotoMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure Tfrmviewfoto.MoveXinY;//группируем точки по координате Y
var
  i,ii,coordY,lastX:integer;
begin
  setlength(FXinY,FmaxY-FminY+1);
  for i:=0 to Fcountpoint do//high(farraypoint) do
  begin
    coordY:=farraypoint[i].Y-FminY;
    if high(FXinY[coordY].X)=-1 then
      setlength(FXinY[coordY].X,1)
    else
      setlength(FXinY[coordY].X,high(FXinY[coordY].X)+2);
    lastX:=high(FXinY[coordY].X);
      FXinY[coordY].X[lastX].X:=farraypoint[i].X;
        for ii:=lastX downto 1 do
          begin
            if farraypoint[i].X<FXinY[coordY].X[ii-1].X then
            begin
              FXinY[coordY].X[ii].X:=FXinY[coordY].X[ii-1].X;
              FXinY[coordY].X[ii-1].X:=farraypoint[i].X;
            end else
                break;
          end;
  end;
end;

procedure Tfrmviewfoto.Test;
var
  f:textfile;
  tmpstr:string;
  i,count,countX:integer;
  sl:TStringList;
  first:boolean;
begin
  first:=false;
  FXinY:=nil;
  if not fileexists(ExtractFilePath(Application.ExeName)+{directoryseparator+}'тест.csv') then exit;
  finalize(FXinY);
  sl:=TStringList.Create;
  assignfile(f,ExtractFilePath(Application.ExeName)+{directoryseparator+}'тест.csv');
  reset(f);
  count:=0;
  while not eof(f) do
  begin
    readln(f, tmpstr);
    if not first then
    begin
      first:=true;
      continue;
    end;
    inc(count);
    setlength(FXinY,count);
    extractstrings([';'],['0'],pchar(tmpstr),sl,true);
    //showmessage(sl.Text);
    countX:=0;
    for i:=1 to sl.Count-1 do
    begin
      if sl[i]='1' then
      begin
        inc(countX);
        setlength(FXinY[count-1].X,countX);
        FXinY[count-1].X[countX-1].X:=i+450;
        FbmpFoto.Canvas.Pixels[FXinY[count-1].X[countX-1].X,count+550]:=clyellow;
        //ShapeFoto.Repaint;
      end;
    end;
    sl.Clear;
  end;
  closefile(f);
  FreeAndNil(sl);
  ShapeFoto.Refresh;
  FminY:=551;
  FmaxY:=550+count;
  SearchStartSelect;
  CreateRect;
end;

procedure Tfrmviewfoto.SearchStartSelect;//поиск начальных позиций для закрашивания
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

procedure Tfrmviewfoto.FillSelection(leftx_l, leftx_r, y_start: integer;
  indexright_old: integer);
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
          {
          indexleft:=ixl;
          //кандидат на левую границу
          leftxtmp:=FXinY[iy].x[ixl].X;
          indexright:=ixl;
          if ((rightxold-1)<=FXinY[iy].x[ixl].X)//нет дырки - есть разрыв заполнения
            then  //если новая точка "слишком" справа
              begin
                leftxtmp:=-1;
                if leftxnew=-1 then result:=0 else result:=1;
                exit;
              end;}
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
  shapeFoto.Canvas.Pen.Color:=clblue;
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
            shapeFoto.Canvas.Line(leftxtmp+1,iy+FminY,FXinY[iy].x[ixl].X,iy+FminY);
            //sleep(100);
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

procedure Tfrmviewfoto.CreateRect;
var
   Rct:ParRect;//Для удобства чтобы запись покороче была(вместо FListSelections[high(FListSelections)].FRects)
   curSelection:PcurSelection;//Для удобства - запись короче (вместо FListSelections[high(FListSelections)])
  procedure saveRect(xl,yl,xr,yr,numberRect:integer);
    begin
      Rct^[numberRect].xl:=xl;
      Rct^[numberRect].yl:=yl;
      Rct^[numberRect].xr:=xr;
      Rct^[numberRect].yr:=yr;
      if xl<curSelection^.xmin then curSelection^.xmin:=xl;
      if xr>curSelection^.xmax then curSelection^.xmax:=xr;
      if yl<curSelection^.ymin then curSelection^.ymin:=yl;
      if yr>curSelection^.ymax then curSelection^.ymax:=yr;
      //временно рисуем потом убрать
      //FbmpFoto.Canvas.frame(FRects[numberRect].xl,FRects[numberRect].yl,FRects[numberRect].xr+1,FRects[numberRect].yr+1);//добавляем 1 т.к. рисуется до этой координаты
      ShapeFoto.Canvas.frame(Rct^[numberRect].xl,Rct^[numberRect].yl,Rct^[numberRect].xr+1,Rct^[numberRect].yr+1);
      //ShapeFoto.Canvas.Pixels[Rct^[numberRect].xr+1,Rct^[numberRect].yr+1]:=clred;
      //ShapeFoto.Canvas.Pixels[Rct^[numberRect].xl,Rct^[numberRect].yl]:=clred;
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

begin

  if high(FListSelections)=-1 then setlength(FListSelections,1) else setlength(FListSelections,high(FListSelections)+2);
  curSelection:=@FListSelections[high(FListSelections)];
  //FbmpFoto.Canvas.Pen.Width:=1;
  ShapeFoto.Canvas.Pen.Width:=1;
  //FbmpFoto.Canvas.Pen.color:=clgreen;
  shapeFoto.Canvas.Pen.color:=clgreen;
  curRect:=0;
  xl:=-1;
  yl:=-1;
  xr:=-1;
  yr:=-1;
  sumxl:=0;
  sumxr:=0;
  countStrok:=0;
  Setlength(curSelection^.FRects,high(FStroki)+1);
  Rct:=@curSelection^.FRects;

  curSelection^.xmin:=maxLongint;
  curSelection^.xmax:=-maxLongint;
  curSelection^.ymin:=maxLongint;
  curSelection^.ymax:=-maxLongint;
  for istr:=0 to high(FStroki) do
  begin
    shapeFoto.Canvas.Line(FStroki[istr].Xl,FStroki[istr].Y,FStroki[istr].Xr,FStroki[istr].Y);//Заливаем выделенную область
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
         //continue;
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
  Setlength(Rct^,currect+1);
  Rct:=nil;
  SortRectInSelection(curSelection);//Сортируем по координате Y ???
  curSelection:=nil;
end;

procedure Tfrmviewfoto.SortRectInSelection(curSelection: PcurSelection);
          procedure SelectionSort_top(curarrayRects: PmySortarray); //сортировка выбором
          var
            i,ii,best_i:integer;
            best_value:PmyRect;
          begin
            for i:=0 to high(curarrayRects^)-1 do
            begin
              best_value:=curarrayRects^[i];
              best_i:=i;
              for ii:=i+1 to high(curarrayRects^) do
              if curarrayRects^[ii]^.yl<best_value^.yl then
              begin
                best_value:=curarrayRects^[ii];
                best_i:=ii;
              end;
              curarrayRects^[best_i]:=curarrayRects^[i];
              curarrayRects^[i]:=best_value;
            end;
          end;
  var
    i:integer;
begin
  //Зададим размеры массивов указателей для сортировки
  setlength(curSelection^.FSortRectsfor_Y_top,high(curSelection^.FRects)+1);
  //инициализируем массивы
  for i:=0 to high(curSelection^.FSortRectsfor_Y_top) do
      curSelection^.FSortRectsfor_Y_top[i]:=@curSelection^.FRects[i];
  SelectionSort_top(@curSelection^.FSortRectsfor_Y_top);//сортируем по Y левый верхний угол по возрастанию
end;

procedure Tfrmviewfoto.checkSelections(x, y: integer);
          function checkSelect(index:integer):boolean;
          begin
            result:=(y>=FListSelections[index].ymin)and
            (y<=FListSelections[index].ymax)and
            (x>=FListSelections[index].xmin)and
            (x<=FListSelections[index].xmax);
          end;
          function checkRect(index:integer):boolean;
          var
            i:integer;
          begin
            result:=false;
            for i:=0 to high(FListSelections[index].FSortRectsfor_Y_top) do
            begin
              if (y>=FListSelections[index].FSortRectsfor_Y_top[i]^.yl)and
               (y<=FListSelections[index].FSortRectsfor_Y_top[i]^.yr)and
               (x>=FListSelections[index].FSortRectsfor_Y_top[i]^.xl)and
               (x<=FListSelections[index].FSortRectsfor_Y_top[i]^.xr)then
               begin
                 result:=true;
                 ShapeFoto.Canvas.Pen.Color:=clred;
                 ShapeFoto.Canvas.Frame(FListSelections[index].FSortRectsfor_Y_top[i]^.xl,
                 FListSelections[index].FSortRectsfor_Y_top[i]^.yl,
                 FListSelections[index].FSortRectsfor_Y_top[i]^.xr+1,
                 FListSelections[index].FSortRectsfor_Y_top[i]^.yr+1);
                 break;
               end;
            end;
          end;

var
  isel:integer;
begin
  for isel:=0 to high(FListSelections) do
      if checkSelect(isel) then
           if checkRect(isel) then
              begin
                //Что-то делаем
                break;
              end;
end;

procedure Tfrmviewfoto.ShapeFotoPaint(Sender: TObject);
begin
  if FbmpFoto<>nil then
  ShapeFoto.Canvas.CopyRect(ShapeFoto.Canvas.ClipRect,FbmpFoto.Canvas,ShapeFoto.Canvas.ClipRect);//перерисовываем только испорченную область, свойство cliprect
end;

procedure Tfrmviewfoto.Timer1Timer(Sender: TObject);
begin
  timer1.Enabled:=false;
  //test;
end;

procedure Tfrmviewfoto.FormCreate(Sender: TObject);
begin
  Ffirstview:=false;
  FState:=0;
  Fcountpoint:=0;
  WindowState:=wsMaximized;
  FminY:=MaxInt;
  FmaxY:=-MaxInt;
  FcountStroki:=0;
  aRow:=1;
end;

procedure Tfrmviewfoto.AddPoints(xold, yold, x, y: integer);
var
  i,deltax,deltay,maxi,znak:integer;
  step:extended;
begin
  deltax:=x-xold;deltay:=y-yold;
  maxi:=0;
  if abs(deltay)>=abs(deltax) then
  begin
    step:=deltax/abs(deltay);
    if deltay<0 then znak:=-1 else znak:=1;
    maxi:=abs(deltay)-1;
  end else
  begin
    step:=deltay/abs(deltax);
    if deltax<0 then znak:=-1 else znak:=1;
    maxi:=abs(deltax)-1;
  end;
  for i:=1 to maxi do
  begin
    inc(Fcountpoint);
    if abs(deltay)>=abs(deltax) then
       begin
         farraypoint[Fcountpoint].X:=xold+round(step*i);
         farraypoint[Fcountpoint].Y:=yold+znak*i;
       end else
       begin
         farraypoint[Fcountpoint].X:=xold+znak*i;
         farraypoint[Fcountpoint].Y:=yold+round(step*i);
       end;
       shapeFoto.Canvas.Pixels[farraypoint[Fcountpoint].X,farraypoint[Fcountpoint].Y]:=ColorSelect;
  end;
end;

procedure Tfrmviewfoto.checkstateDown(Sender: TObject; Button: TMouseButton);
begin

end;

procedure Tfrmviewfoto.checkstateUp(Sender: TObject; Button: TMouseButton);
var
  i:integer;
begin
  if (Sender is TShape) then//Если событие вызвала фотография
  begin
    case Button of
         mbLeft://Если нажата левая клавиша
           begin
             case FStateFoto of
                  sfPic://Если фотка находится в исходном состоянии
                    begin
                      PopupMenu1.PopUp;//Покажем контекстное меню
                    end;
                  sfSelectioned:
                    begin
                      FStateFoto:=sfPic;
                      if (abs(Farraypoint[Fcountpoint].X-Farraypoint[0].X)>1)or
                       (abs(Farraypoint[Fcountpoint].Y-Farraypoint[0].Y)>1) then  //если между конечной и начальной точкой дырка, то заполняем её
                       addPoints(Farraypoint[Fcountpoint].X,Farraypoint[Fcountpoint].Y,Farraypoint[0].X,Farraypoint[0].Y);

                       MoveXinY;
                       SearchStartSelect;
                       //CreateRect;
                      {if high(FListSelections)=-1 then setlength(FListSelections,1) else setlength(FListSelections,high(FListSelections)+2);
                      FListSelections[high(FListSelections)].FRects:=getRectFromPoints(Farraypoint,Fcountpoint,Fdeltax,FminY,FmaxY);}
                      //ShapeFoto.Canvas.Pen.Color:=clred;
                      {for i:=0 to high(FListSelections[high(FListSelections)].FRects)-1 do
                          ShapeFoto.Canvas.Frame(FListSelections[high(FListSelections)].FRects[i].xl,
                          FListSelections[high(FListSelections)].FRects[i].yl,
                          FListSelections[high(FListSelections)].FRects[i].xr
                          ,FListSelections[high(FListSelections)].FRects[i].yr); }
                    end;
             end;
           end;
    end;
  end;
end;

function Tfrmviewfoto.checkstateMove(Sender: TObject; Button: TShiftState
  ): boolean;
begin
  if (Sender is TShape) then//Если событие вызвала фотография
  begin
    if (ssLeft in Button) then  //Если нажата левая клавиша
           begin
             case FStateFoto of
                  sfBeforeSelectioned://готова начать выделение
                    begin
                      FStateFoto:=sfSelectioned;
                      result:=true;
                    end;
             end;
           end;
    end;
end;

procedure Tfrmviewfoto.setFoto(jpg: TJpegImage);
begin
  if FbmpFoto=nil then FbmpFoto:=TBitMap.Create;
  FbmpFoto.SetSize(jpg.Width,jpg.Height);
  FbmpFoto.Canvas.Draw(0,0,jpg);
end;

end.

