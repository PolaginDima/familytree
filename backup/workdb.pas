unit workdb;

{$mode objfpc}{$H+}

interface

uses
  Classes, fgl, SysUtils, Graphics, mysqlite3conn, sqldb, lazutf8, controls, dialogs, db, fileutil, LazFileUtils, dateutils;
type

   { TExObjList }

  { TExObjList = class (TObjectList) //Класс на основе TObjectList для хранения фоток
   protected                        //этот класс удобен тем, что удобнее :) - взято http://www.delphikingdom.com/asp/viewitem.asp?catalogID=751
    procedure Put(Index: Integer; Item: TMemoryStream);
    function Get(Index: Integer): TMemoryStream;
   public
    property Items[Index: Integer]: TMemoryStream read Get write Put; default;
    function Add(Obj: TMemoryStream): Integer;
    procedure Insert(Index: Integer; Obj: TMemoryStream);
   end; }

   { TmyMemoryStream }

   TmyMemoryStream=class(TMemoryStream)
    private
      FDeleting: boolean;
      FdopInf: string;
      FID_Foto: integer;
      FflagdopInf:Boolean;//Признак того, что текст в dopInf был изменен
      procedure SetFdopInf(AValue: string);
    public
      constructor Create;
      property Deleting:boolean read FDeleting write FDeleting default false;//признака удаления записи
      property ID_Foto:integer read FID_Foto write FID_Foto default 0; // 0-добавленная запись иначе id фотки
      property dopInf:string read FdopInf write SetFdopInf;
      property statedopInf:boolean read FflagdopInf;
   end;

   TFotoList = specialize TFPGObjectList<TmyMemoryStream>;

        { Tpeople }

   Tpeople=class
    private
      FdateBorn: Tdate;
      FdateDeath: Tdate;
      FDeath: boolean;
      Fdopinfo: string;
      Ffam: string;
      FfirstFam: string;
      Fflag: integer;
      Ffoto: TMemoryStream;
      FFotoInPeople: TFotoList;
      //Ffotoinppl:TFotoList;//для хранения фоток
      FfotoIsModified: boolean;
      FfotosIsModified: boolean;
      FID: Cardinal;
      FID_Avatar: integer;
      Fnam: string;
      Fotch: string;
      Fpredok_potomok: integer;
      Fsex: byte;
      procedure Setdopinfo(AValue: string);
      procedure Setfam(AValue: string);
      procedure Setfoto(AValue: TMemoryStream);
      procedure Setnam(AValue: string);
    protected
    public
    constructor Create;
    destructor Destroy;override;
     function getdateBornstr:string;
     function getdateDeathstr:string;
     property fam:string read Ffam write Setfam;
     property nam:string read Fnam write Setnam;
     property otch:string read Fotch write Fotch;
     property sex:byte read Fsex write Fsex default  0;
     property predok_potomok:integer read Fpredok_potomok write Fpredok_potomok default -1;
     property foto:TMemoryStream read Ffoto write Setfoto;
     property ID_Avatar:integer read FID_Avatar write FID_Avatar;
     property dopinfo:string read Fdopinfo write Setdopinfo;
     property fotoIsModified:boolean read FfotoIsModified write FfotoIsModified;
     property fotosIsModified:boolean read FfotosIsModified write FfotosIsModified;
     property Death:boolean read FDeath write FDeath default False;
     property ID:Cardinal read FID write FID;
     property dateBorn:Tdate read FdateBorn write FdateBorn;
     property dateDeath:Tdate read FdateDeath write FdateDeath;
     property firstFam:string read FfirstFam write FfirstFam;
     property flag:integer read Fflag write Fflag default 0;
     property FotoInPeople:TFotoList read FFotoInPeople write FFotoInPeople;
   end;

  { Tworkdb }

   Tworkdb=class(TSQLite3Connection)
      private
        Fcount_view_birthday_skoro: integer;
       Fversion:string[13];
       Fpath:string;
       Ffrm:TCustomControl;
       FSQL_table:TSQLiteTable2;
       function GetcountPeople: integer;
       function GetEOF: boolean;
       function GetRowCount: Cardinal;
       function connect(pathdb: string; frm: TCustomControl):boolean;
       function connectSliv(pathdb, attachBD: string; frm: TCustomControl):boolean;
       function GetCountSelParent(ID_Child:integer):integer;
       function Getversion: string;
       procedure createbdinmemorySliv;
       procedure createstructdb;
       procedure CheckVerAndUpdate;
       const version=1028;
       procedure Setcount_view_birthday_skoro(AValue: integer);
      protected

      public
       constructor Create(pathdb:string;frm:TCustomControl);overload;
       destructor Destroy;override;
       function GetPotomok(const ID_Roditel: integer):boolean;
       function GetPredok(const ID_Predok: integer): boolean;
       function GetPeople_min(predok:boolean=false):TPeople;//overload;
       function GetPeople_ID(predok:boolean=false):TPeople;//overload;
       function getparametrbase:string;
       function addpeople(ppl: Tpeople; predok: boolean): integer;
       function savepeople(ppl: Tpeople; id: integer): boolean;
       function updatefoto(ppl: Tpeople; id: integer):integer;
       function updatefotos(ppl: Tpeople):boolean;
       function getpeople_full(indexid: Cardinal): Tpeople;
       function GetPredokForAdd(ID_Potomok:integer):TSQLQuery;
       function GetPotomokForDel(ID_Predok:integer):TSQLQuery;
       function GetPredokForDel(ID_Potomok:integer):TSQLQuery;
       function GetPotomokForAdd(ID_Predok:integer):TSQLQuery;
       function GetPredokForStart:TSQLQuery;
       function GetPotomkForStart:TSQLQuery;
       function GetAllPeopleForStart:TSQLQuery;
       function first:boolean;
       function Last:boolean;
       function Next:boolean;
       function Previouse:boolean;
       function FieldAsBlob(nameField: string): TMemoryStream;
       function FieldAsDataTime(nameField: string): TdateTime;
       function FieldAsInteger(nameField: string): integer;
       function FieldAsReal(nameField: string): double;
       function FieldAsString(nameField: string): string;
       function FieldIsNull(nameField: string): boolean;
       function GetParentTwo(ID_Child:integer):TSQLQuery;
       function GetCountSelParentForAddParent(ID_Child:integer):integer;
       function AddParentTwoForAddParent(ID_Child:integer):boolean;
       procedure SaveSpisok;
       procedure ExportGEDCOM;
       procedure checkParent;
       procedure DeletePeople(ID:integer);
       procedure addconnect(ID_Roditel, ID_Potomok:integer);
       procedure delconnect(ID_Roditel, ID_Potomok:integer);
       procedure Sliyanie(pathdb, attachBD: string; frm: TCustomControl);
       procedure createbdinmemory;
       procedure SQL_table_FREE;
       property EOF:boolean read GetEOF;
       property RowCount:Cardinal read GetRowCount;
       property versionBD:string read Getversion;
       property countPeople:integer read GetcountPeople;
       property count_view_birthday_skoro:integer read Fcount_view_birthday_skoro write Setcount_view_birthday_skoro;
   end;

implementation

{ TmyMemoryStream }

procedure TmyMemoryStream.SetFdopInf(AValue: string);
begin
  if FdopInf=AValue then Exit;
  FdopInf:=AValue;
  FflagdopInf:=true;
end;

constructor TmyMemoryStream.Create;
begin
  inherited Create;
  FflagdopInf:=false;
end;

{ TExObjList }
{
procedure TExObjList.Put(Index: Integer; Item: TMemoryStream);
begin

end;

function TExObjList.Get(Index: Integer): TMemoryStream;
begin
  //if self.
  result:=nil;
end;

function TExObjList.Add(Obj: TMemoryStream): Integer;
begin
  result:=inherited Add(Obj);
end;

procedure TExObjList.Insert(Index: Integer; Obj: TMemoryStream);
begin

end; }

 { Tpeople }

procedure Tpeople.Setfam(AValue: string);
begin
  if Ffam=AValue then Exit;
  if UTF8Length(AValue)<2 then raise Exception.Create('Фамилия должна быть не менее 2-х символов');
  Ffam:=AValue;
end;

procedure Tpeople.Setdopinfo(AValue: string);
begin
  if Fdopinfo=AValue then Exit;
  Fdopinfo:=AValue;
end;

procedure Tpeople.Setfoto(AValue: TMemoryStream);
begin
  Ffoto:=AValue;
  FfotoIsModified:=true;
end;

procedure Tpeople.Setnam(AValue: string);
begin
  if Fnam=AValue then Exit;
  if UTF8Length(AValue)<2 then raise Exception.Create('Имя должно быть не менее 3-х символов');
  Fnam:=AValue;
end;

constructor Tpeople.Create;
begin
  inherited Create;
  FfotoIsModified:=false;
  FfotosIsModified:=false;
  FotoInPeople:=TFotoList.Create;
end;

destructor Tpeople.Destroy;
begin
  if Foto<>nil then foto.Free;
  FotoInPeople.Free;
  inherited Destroy;
end;

function Tpeople.getdateBornstr: string;
var
  yeari,monthi,dayi:word;
  months, days:string;
begin
  if dateBorn<1.7E307 then
  begin
    Decodedate(dateBorn, yeari, monthi, dayi);
    months:=inttostr(monthi);
    if monthi<10 then months:='0'+months;
    days:=inttostr(dayi);
    if dayi<10 then days:='0'+days;
    result:=inttostr(yeari)+'-'+months+'-'+days;
  end
  else result:='UNKNOWN';
end;

function Tpeople.getdateDeathstr: string;
var
  yeari,monthi,dayi:word;
  months, days:string;
begin
  if dateDeath<1.7E307 then
  begin
    Decodedate(dateDeath, yeari, monthi, dayi);
    months:=inttostr(monthi);
    if monthi<10 then months:='0'+months;
    days:=inttostr(dayi);
    if dayi<10 then days:='0'+days;
    result:=inttostr(yeari)+'-'+months+'-'+days;
  end
  else result:='UNKNOWN';
end;

procedure Tworkdb.createstructdb;
var
  SQL_query:string;
begin
  // Создание таблицы version
    SQL_query:='CREATE TABLE IF NOT EXISTS [version] '+lineending+
    '([id] INTEGER primary key,'+lineending+
    '[name] text NOT NULL COLLATE NOCASE,'+lineending+
    '[value] INTEGER NOT NULL'+lineending+
    ''+lineending+
    ''+lineending+
    ''+lineending+
    ');';
    ExecuteDirect(SQL_query);
    ExecuteDirect('create unique index  ind_version_name on version(name) ;');
   // Создание таблицы people
    SQL_query:='CREATE TABLE IF NOT EXISTS [people] '+lineending+
    '([id] INTEGER primary key,'+lineending+
    '[fam] text NOT NULL COLLATE NOCASE,'+lineending+
    '[nam] text NOT NULL COLLATE NOCASE,'+lineending+
    '[otch] text COLLATE NOCASE DEFAULT "UNKNOWN",'+lineending+
    '[sex] integer NOT NULL DEFAULT 0,'+lineending+
    '[famfirst] text COLLATE NOCASE,'+lineending+
    '[dtb] text NOT NULL DEFAULT "UNKNOWN",'+lineending+
    '[dtd] text NOT NULL DEFAULT "UNKNOWN",'+lineending+
    '[dopinfo] text COLLATE NOCASE,'+lineending+
    '[id_avatar] integer references foto(id) ON DELETE restrict ON UPDATE CASCADE DEFERRABLE INITIALLY DEFERRED,'+lineending+
    '[flag] INTEGER not null default 0'+lineending+
    //'[nam] text NOT NULL COLLATE NOCASE DEFAULT ''UNKNOWN'''+lineending+
    ');';
    ExecuteDirect(SQL_query);
    //Создадим уникальный индекс для ФИО + пол + дата рождения
    ExecuteDirect('create unique index  ind_people_f_n_o_s_dtb on people(fam,nam,otch,sex,dtb);');
    // Создание таблицы foto
    SQL_query:='CREATE TABLE IF NOT EXISTS [foto] '+lineending+
    '([id] INTEGER primary key,'+lineending+
    '[foto] BLOB,'+lineending+
    '[dopInf] text,'+lineending+
    '[id_people] integer NOT NULL,'+lineending+
    ' FOREIGN KEY(id_people) REFERENCES people(id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE INITIALLY DEFERRED'+lineending+
    //'[nam] text NOT NULL COLLATE NOCASE DEFAULT ''UNKNOWN'''+lineending+
    ');';
    ExecuteDirect(SQL_query);
    //Создадим дополнительный индекс для поля id_people таблицы parent для ускорения поиска
    //Сделаем его уникальным что бы исключить потерянные фото
    //ExecuteDirect('create unique index  ind_foto_idp on foto(id_people) ;');
     // Создание таблицы parent
    SQL_query:='CREATE TABLE IF NOT EXISTS [parent] '+lineending+
    '([id] INTEGER primary key,'+lineending+
    '[id_people] INTEGER NOT NULL,'+lineending+
    '[id_parent] INTEGER ,'+lineending+
    ' FOREIGN KEY(id_people) REFERENCES people(id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE INITIALLY DEFERRED,'+lineending+
    ' FOREIGN KEY(id_parent)REFERENCES people(id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE INITIALLY DEFERRED'+lineending+
    ');';
    ExecuteDirect(SQL_query);
    //создадим уникальный индекс для пары потомок родитель
    ExecuteDirect('create unique index  ind_parent_idp_idp on parent(id_people,id_parent) ;');
    //Создадим дополнительный индекс для поля id_parent таблицы parent для ускорения поиска
    ExecuteDirect('create index  ind_parent_idp on parent(id_parent) ;');
    //Создадим тригер на вставку для таблицы parent, чтобы не было более двух родителей
    SQL_query:='CREATE TRIGGER parent_BI BEFORE INSERT ON parent'+lineending+
    'WHEN (select count(*) from parent where (new.id_people=parent.id_people) and (parent.id_parent is not null))>1'+lineending+
    'BEGIN'+lineending+
    'select raise(abort,''many_parents'') from parent;'+lineending+
    'END;';
    ExecuteDirect(SQL_query);
    //Создадим просмотры
    SQL_query:='create view GetPotomkForStart as '+
    'select DISTINCT people.id as id, people.fam as fam, people.nam as nam, people.otch as otch, people.flag as flag '+
    'from parent as t2 join people on (people.id=t2.id_people) where '+lineending+
    '(not exists(select id from parent as t1 where (t2.id_people=t1.id_parent))) order by fam, nam, otch';
    ExecuteDirect(SQL_query);
    SQL_query:='create view GetPredokForStart as '+
    'select people.id as id, people.fam as fam, people.nam as nam, people.otch as otch, people.flag as flag '+
    'from parent join people on (people.id=parent.id_people)'+lineending+
  ' where (parent.id_parent is null) order by fam, nam, otch';
    ExecuteDirect(SQL_query);
    //Вставим номер версии базы
     ExecuteDirect('INSERT INTO version (name,value) VALUES ("ver",'+inttostr(version)+');');
   //Применим изменения
   Transaction.Commit;
end;

procedure Tworkdb.CheckVerAndUpdate;
var
  Query:TSQLQuery;
  SQL_query:string;
  ver,lastID,i:integer;
  tmps:string[7];
  Fout:textFile;
begin
  Query:=TSQLQuery.create(nil);
  Query.DataBase:=self;
  Query.Transaction:=Transaction;
  Query.SQL.Clear;
  Query.SQL.Add('SELECT value FROM version WHERE name="ver"');
  Query.Open;
  if Query.IsEmpty then
   begin
     ver:=version;
   end else
   begin
     Query.First;
     ver:=Query.FieldByName('value').AsInteger;
     if ver>1000001 then
        ver:=1000+ver mod 1000000;
   end;
   tmps:=inttostr(version);
   for i:=1 to utf8length(tmps)-1 do Fversion:=Fversion+copy(tmps,i,1)+'.';
   Fversion:=Fversion+copy(tmps,utf8length(tmps),1);
   //Fversion:=copy(tmps,1,1)+'.'+copy(tmps,2,1)+'.'+copy(tmps,3,1)+'.'+copy(tmps,4,1)+'.'+copy(tmps,5,1)+'.'+copy(tmps,6,1)+'.'+copy(tmps,7,1);
   Query.Close;
   Query.Free;
   //Обновление до 1.0.1.3
  if  (ver<version) then
   begin
     if ver<1006 then ExecuteDirect('create unique index  ind_people_f_n_o_s_dtb on people(fam,nam,otch,sex,dtb);');
     if ver <1007 then
       begin
         ExecuteDirect('drop index  ind_people_f_n_o_s_dtb;');
         ExecuteDirect('create unique index  ind_people_f_n_o_s on people(fam,nam,otch,sex);');
       end;
     if ver <1008 then
       begin
         ExecuteDirect('drop index  ind_people_f_n_o_s;');
         ExecuteDirect('create unique index  ind_people_f_n_o_s_dtb on people(fam,nam,otch,sex,dtb);');
       end;
     if ver <1009 then
       begin
         //Добавим второго родителя у кого можно, т.е. если у братьев/сестер есть второй родитель
         //а данного человека нет, значит ему добавим
         messagedlg('внимание','Будет выполнена рискованная операция!'+lineending+'Добавление второго родителя у тех людей, у кого у братьев/сестер есть второй родитель,'+
         'а у данного человека нет.'+lineending+'Изменения будут записаны в файл izm1000009.txt',mtWarning,[mbOK],'');
         //Получим ID последней записи в таблице parent
         Query:=TSQLQuery.create(nil);
         Query.DataBase:=self;
         Query.Transaction:=Transaction;
         Query.SQL.Clear;
         Query.SQL.Add('SELECT max(id) as lastid FROM parent');
         Query.Open;
         if not Query.IsEmpty then
         begin
           Query.First;
           lastID:=Query.FieldByName('lastid').AsInteger;
         end else lastID:=-1;
         Query.Close;
         SQL_query:='insert into parent select NULL,tbl.id,tb2.id_parent from'+
         '(select ppl.id as id,(select count(*) from people as p join parent as t on ((p.id=t.id_people)and(t.id_parent is not null)) '+
         'join parent as t1 on ((t1.id_parent=t.id_parent)and(t1.id_people<>p.id)) '+
         'join parent as t2 on ((t2.id_people=t1.id_people)and(t2.id_parent<>t1.id_parent)) '+
         'left join parent as t3 on ((t3.id_people=p.id)and(t3.id_parent<>t.id_parent)and(t2.id_parent)) '+
         'where (t3.id_parent is null)and(ppl.id=p.id)) as cnt from people as ppl where (cnt=1)) tbl '+
         'join parent as tb on ((tbl.id=tb.id_people)and(tb.id_parent is not null)) '+
         'join parent as tb1 on ((tb1.id_parent=tb.id_parent)and(tb1.id_people<>tbl.id)) '+
         'join parent as tb2 on ((tb2.id_people=tb1.id_people)and(tb2.id_parent<>tb.id_parent))';
         ExecuteDirect(SQL_query);
         Query.SQL.Clear;
         Query.SQL.Add('SELECT p1.fam as fam1,p1.nam as nam1,p1.otch as otch1,p2.fam as fam2,p2.nam as nam2,p2.otch as otch2 FROM parent join people as p1 on (parent.id_people=p1.id) join people as p2 on (parent.id_parent=p2.id) where (parent.id>'+inttostr(lastID)+')');
         Query.Open;
         AssignFile(Fout,ExtractFilePath(Fpath)+'izm1000009.txt');
         ReWrite(Fout);
         Query.First;
         if not Query.IsEmpty then Writeln(Fout, 'Автоматически добавлены');
         while not Query.EOF do
         begin
           Writeln(Fout,'У '+Query.FieldByName('fam1').AsString+' '+Query.FieldByName('nam1').AsString+' '+Query.FieldByName('otch1').AsString+' '+
           'добавлен родитель '+Query.FieldByName('fam2').AsString+' '+Query.FieldByName('nam2').AsString+' '+Query.FieldByName('otch2').AsString);
           Query.Next;
         end;
         CloseFile(Fout);
         //Создадим тригер на вставку для таблицы parent, чтобы не было более двух родителей
         SQL_query:='CREATE TRIGGER parent_BI BEFORE INSERT ON parent'+lineending+
         'WHEN (select count(*) from parent where (new.id_people=parent.id_people) and (parent.id_parent is not null))>1'+lineending+
         'BEGIN'+lineending+
         'select raise(abort,''many_parents'') from parent;'+lineending+
         'END;';
         ExecuteDirect(SQL_query);
         FreeandNil(Query);
       end;
     if ver <1010 then
       begin
         //Создадим дополнительный индекс для поля id_parent таблицы parent для ускорения поиска
         ExecuteDirect('create index  ind_parent_idp on parent(id_parent);');
         //Создадим дополнительный индекс для поля id_people таблицы parent для ускорения поиска
         //Сделаем его уникальным что бы исключить потерянные фото
         ExecuteDirect('create unique index  ind_foto_idp on foto(id_people) ;');
       end;
      if ver <1011 then
       begin
         //Создадим просмотры
         SQL_query:='create view GetPotomkForStart as '+
         'select DISTINCT people.id as id, people.fam as fam, people.nam as nam, people.otch as otch '+
         'from parent as t2 join people on (people.id=t2.id_people) where '+lineending+
         '(not exists(select id from parent as t1 where (t2.id_people=t1.id_parent))) order by fam, nam, otch';
         ExecuteDirect(SQL_query);
         SQL_query:='create view GetPredokForStart as '+
         'select people.id as id, people.fam as fam, people.nam as nam, people.otch as otch '+
         'from parent join people on (people.id=parent.id_people)'+lineending+
         ' where (parent.id_parent is null) order by fam, nam, otch';
         ExecuteDirect(SQL_query);
       end;
       if ver <1013 then
       begin
         //Добавим в таблицу people служебное поле flag
         SQL_query:='ALTER TABLE people '+lineending+
         'add column flag integer not null default 0;';
         ExecuteDirect(SQL_query);
       end;

       if ver <1015 then
       begin
         //Удалим просмотр GetPotomkForStart
         ExecuteDirect('Drop view GetPotomkForStart');
         //Создадим заново с новым полем flag
         SQL_query:='create view GetPotomkForStart as '+
         'select DISTINCT people.id as id, people.fam as fam, people.nam as nam, people.otch as otch, people.flag as flag '+
         'from parent as t2 join people on (people.id=t2.id_people) where '+lineending+
         '(not exists(select id from parent as t1 where (t2.id_people=t1.id_parent))) order by fam, nam, otch';
         ExecuteDirect(SQL_query);
         //Удалим просмотр GetPredokForStart
         ExecuteDirect('Drop view GetPredokForStart');
         //Создадим заново с новым полем flag
         SQL_query:='create view GetPredokForStart as '+
         'select people.id as id, people.fam as fam, people.nam as nam, people.otch as otch, people.flag as flag '+
         'from parent join people on (people.id=parent.id_people)'+lineending+
         ' where (parent.id_parent is null) order by fam, nam, otch';
         ExecuteDirect(SQL_query);
       end;

       if ver <1019 then
       begin
         //Добавим поле id_avatar в таблицу people
         SQL_query:='ALTER TABLE people '+lineending+
         'add column id_avatar integer references foto(id) ON DELETE restrict ON UPDATE CASCADE DEFERRABLE INITIALLY DEFERRED;';
         //'UPDATE people set id_avatar=1 where ID=1;';//строка для проверки
         ExecuteDirect(SQL_query);
         //Заполним поле id_avatar
         Query:=TSQLQuery.create(nil);
         Query.DataBase:=self;
         Query.Transaction:=Transaction;
         Query.SQL.Clear;
         Query.SQL.Add('SELECT people.id as idp, foto.id as idf FROM foto join people on (foto.id_people=people.id)');
         Query.Open;
         Query.First;
         while not Query.EOF do
         begin
           SQL_query:='UPDATE people '+lineending+
           'set id_avatar='+Query.FieldByName('idf').AsString+' where id='+Query.FieldByName('idp').AsString+';';
           ExecuteDirect(SQL_query);
           Query.Next;
         end;
         Query.Close;
         FreeAndNil(Query);
         //SQL_query:='DELETE FROM foto where ID=44;';//строка для проверки
         //ExecuteDirect(SQL_query);
       end;

       if ver <1020 then
       begin
         //Удалим индекс ind_foto_idp
         SQL_query:='DROP index ind_foto_idp;';
         ExecuteDirect(SQL_query);
       end;

       if ver <1021 then
       begin
         //Добавим поле dopInf в таблицу foto
         SQL_query:='ALTER TABLE foto '+lineending+
         'add column dopInf text COLLATE NOCASE;';
         ExecuteDirect(SQL_query);
       end;

     //Запишем номер версии
     SQL_query:='UPDATE version set value='+inttostr(version)+' where name="ver";';
     ExecuteDirect(SQL_query);
     {SQL_db.BeginTransaction;
     SQL_db.ExecSQL(SQL_query);
     SQL_db.Commit;}
     Transaction.Commit;//temp;

   end;
end;

procedure Tworkdb.Setcount_view_birthday_skoro(AValue: integer);
begin
  if Fcount_view_birthday_skoro=AValue then Exit;
  if AValue<1 then
     Fcount_view_birthday_skoro:=1 else
                                   Fcount_view_birthday_skoro:=AValue;
end;

function Tworkdb.GetEOF: boolean;
begin
  result:=self.FSQL_table.EOF;
end;

function Tworkdb.GetcountPeople: integer;
var
  SQLQuery:TSQLQuery;
begin
  //Получим кол-во родителей, которых можно добавить
  SQLQuery:=TSQLQuery.Create(nil);
  SQLQuery.DataBase:=self;
  SQLQuery.Transaction:=Transaction;
  SQLQuery.SQL.Clear;
  SQLQuery.SQL.Add('select count(*) as cnt from people');
  SQLQuery.Open;
  if SQLQuery.IsEmpty then result:=0 else
  result:=SQLQuery.FieldByName('cnt').AsInteger;
end;

function Tworkdb.FieldAsBlob(nameField: string): TMemoryStream;
begin
  if (FSQL_table=nil)or(FSQL_table.Count<=0) then raise Exception.Create('row count 0');
  result:=FSQL_table.FieldAsBlob(nameField);
end;

function Tworkdb.FieldAsDataTime(nameField: string): TdateTime;
begin
  if (FSQL_table=nil)or(FSQL_table.Count<=0) then raise Exception.Create('row count 0');
  result:=FSQL_table.FieldAsDateTime(nameField);
end;

function Tworkdb.FieldAsInteger(nameField: string): integer;
begin
  if (FSQL_table=nil)or(FSQL_table.Count<=0) then raise Exception.Create('row count 0');
  result:=FSQL_table.FieldAsInteger(nameField);
end;

function Tworkdb.FieldAsReal(nameField: string): double;
begin
  if (FSQL_table=nil)or(FSQL_table.Count<=0) then raise Exception.Create('row count 0');
  result:=FSQL_table.FieldAsDouble(nameField);
end;

function Tworkdb.FieldAsString(nameField: string): string;
begin
  if (FSQL_table=nil)or(FSQL_table.Count<=0) then raise Exception.Create('row count 0');
  result:=FSQL_table.FieldAsString(nameField);
end;

function Tworkdb.FieldIsNull(nameField: string): boolean;
begin
  if (FSQL_table=nil)or(FSQL_table.Count<=0) then raise Exception.Create('row count 0');
  result:=self.FSQL_table.FieldIsNull(nameField);
end;

function Tworkdb.GetCountSelParent(ID_Child: integer): integer;
var
  SQLQuery:TSQLQuery;
begin
  //Получим кол-во родителей, которых можно добавить
  SQLQuery:=TSQLQuery.Create(nil);
  SQLQuery.DataBase:=self;
  SQLQuery.Transaction:=Transaction;
  SQLQuery.SQL.Clear;
  SQLQuery.SQL.Add('select count(*) as cnt from (select distinct p.id,t3.id_parent from people as p join parent as t on ((p.id=t.id_people)and(t.id_parent is not null)) '+
  'join parent as t2 on ((t2.id_parent=t.id_parent)and(t2.id_people<>p.id)) join parent as t3 on ((t3.id_people=t2.id_people)and(t2.id_parent<>t3.id_parent)) '+
  'left join parent as t1 on ((p.id=t1.id_people)and(t1.id_parent<>t.id_parent)) where (t1.id_parent is null)and(p.id='+inttostr(ID_Child)+'))');
  SQLQuery.Open;
  result:=SQLQuery.FieldByName('cnt').AsInteger;
end;

function Tworkdb.GetCountSelParentForAddParent(ID_Child: integer): integer;
var
  SQLQuery:TSQLQuery;
begin
  //Получим кол-во родителей, которых можно добавить
  SQLQuery:=TSQLQuery.Create(nil);
  SQLQuery.DataBase:=self;
  SQLQuery.Transaction:=Transaction;
  SQLQuery.SQL.Clear;
  SQLQuery.SQL.Add('select count(*) as cnt from (select distinct p.id,t3.id_parent from people as p join parent as t on ((p.id=t.id_people)and(t.id_parent is not null)) '+
  'join parent as t2 on ((t2.id_parent=t.id_parent)and(t2.id_people<>p.id)) join parent as t3 on ((t3.id_people=t2.id_people)and(t2.id_parent<>t3.id_parent)) '+
  'left join parent as t1 on ((p.id=t1.id_people)and(t1.id_parent<>t.id_parent)) where (t1.id_parent is null)and(t2.id_people='+inttostr(ID_Child)+'))');
  SQLQuery.Open;
  result:=SQLQuery.FieldByName('cnt').AsInteger;
end;

function Tworkdb.GetParentTwo(ID_Child: integer): TSQLQuery;
var
  SQLQuery:TSQLQuery;
begin
  //result:=nil;
  if GetCountSelParent(ID_Child)=0 then exit(nil);
    //Если есть варианты второго родителя
      SQLQuery:=TSQLQuery.Create(nil);
      SQLQuery.DataBase:=self;
      SQLQuery.Transaction:=Transaction;
      SQLQuery.SQL.Clear;
      SQLQuery.SQL.Add('select tbl.id as id,ppl.fam as fam,ppl.nam as nam,ppl.otch as otch,ppl.sex as sex,ppl.dtb as dtb from (select distinct p.id as i,t3.id_parent as id from people as p '+
      'join parent as t on ((p.id=t.id_people)and(t.id_parent is not null)) '+
      'join parent as t2 on ((t2.id_parent=t.id_parent)and(t2.id_people<>p.id)) join parent as t3 on ((t3.id_people=t2.id_people)and(t2.id_parent<>t3.id_parent)) '+
      'left join parent as t1 on ((p.id=t1.id_people)and(t1.id_parent<>t.id_parent)) where (t1.id_parent is null)and(p.id='+inttostr(ID_Child)+')) as tbl '+
      'join people as ppl on (ppl.id=tbl.id)');
      result:=SQLQuery
end;

function Tworkdb.AddParentTwoForAddParent(ID_Child: integer): boolean;
var
  SQL_query:string;
begin
  SQL_query:='insert into parent '+
      'select distinct NULL,p.id as i,t3.id_parent as id from people as p '+
      'join parent as t on ((p.id=t.id_people)and(t.id_parent is not null)) '+
      'join parent as t2 on ((t2.id_parent=t.id_parent)and(t2.id_people<>p.id)) join parent as t3 on ((t3.id_people=t2.id_people)and(t2.id_parent<>t3.id_parent)) '+
      'left join parent as t1 on ((p.id=t1.id_people)and(t1.id_parent<>t.id_parent)) where (t1.id_parent is null)and(t2.id_people='+inttostr(ID_Child)+')';
    ExecuteDirect(SQL_query);
    result:=true;
end;

procedure Tworkdb.SaveSpisok;
var
  Query:TSQLQuery;
  Fout:textFile;
  txt:string;
  sd:TSaveDialog;
begin
  //окно выбора фото
  sd:=TSaveDialog.Create(nil);
  //Заголовок окна
  sd.Title:='Выбор файла';
  //Установка начального каталога
  sd.InitialDir:=getcurrentdir;
  //GetEnvironmentVariable;
  // Разрешаем сохранять файлы типа .txt и .doc
  sd.Filter:='текстовый файл(*.csv)|*.csv';//'изображение(jpg)|*.jpg|изображение(bmp)|*.bmp';
  // Установка расширения по умолчанию
  sd.DefaultExt := 'csv';
  sd.FileName:='spisok.csv';
  // Выбор текстовых файлов как стартовый тип фильтра
  sd.FilterIndex := 1;
  if not  sd.Execute then exit;
  while fileexists(sd.FileName) do
    begin
      if QuestionDlg('предупреждение','Файл уже существует.'+lineending+'Перезаписать файл '+ExtractFileName(sd.FileName)+'?'
      , mtWarning,[mrYes,'перезаписать',mrNo,'не перезаписывать','isdefault'],'')=mrYes then break;
      if not  sd.Execute then exit;
    end;
  Query:=TSQLQuery.create(nil);
  Query.DataBase:=self;
  Query.Transaction:=Transaction;
  Query.SQL.Clear;
  Query.SQL.Add('SELECT fam,nam,otch,famfirst,dtb,dtd FROM people order by fam,nam,otch,dtb');
  Query.Open;
  Query.First;
  //AssignFile(Fout,ExtractFilePath(Fpath)+'spisok.csv');
  AssignFile(Fout,sd.FileName);
  ReWrite(Fout);
  writeln(Fout,'Фамилия;Имя;Отчество;Девичья_фамилия;дата рождения;дата смерти');
  while not Query.EOF do
  begin
    txt:=Query.FieldByName('Fam').AsString+';'+Query.FieldByName('Nam').AsString+';';
    if Query.FieldByName('Otch').AsString='UNKNOWN' then txt:=txt+';' else txt:=txt+Query.FieldByName('Otch').AsString+';';
    if Query.FieldByName('famfirst').AsString='UNKNOWN' then txt:=txt+';' else txt:=txt+Query.FieldByName('famfirst').AsString+';';
    if Query.FieldByName('dtb').AsString='UNKNOWN' then txt:=txt+';' else txt:=txt+Query.FieldByName('dtb').AsString+';';
    if Query.FieldByName('dtd').AsString<>'UNKNOWN' then txt:=txt+Query.FieldByName('dtd').AsString;
    writeln(Fout,txt);
    Query.Next;
  end;
  closefile(Fout);
  Query.Close;
  FreeAndNil(Query);
  FreeAndNil(sd);
end;

procedure Tworkdb.ExportGEDCOM;
var
  Query,Query2,Query3, Query4, Query5:TSQLQuery;
  Fout:textFile;
  txt:string;
  sd:TSaveDialog;
  dt:TDatetime;
  idNote,idOBJE, tmpi:integer;
  //Notes:TStringList;
  FamC,FamS,Fam:TStringlist;
  Note,tmps1,DirPic:String;
  flagO,flagD,flagN:boolean;
  sl:TStringList;
const HeadF = '0 HEAD'+lineending+'1 SOUR GEDKeeper'+lineending+'2 VERS 40'+lineending+'1 DEST GEDKeeper'+lineending+
  '1 CHAR UTF-8'+lineending+'1 LANG Russian'+lineending+'1 GEDC'+lineending+'2 VERS 5.5.1'+lineending+'2 FORM LINEAGE-LINKED'+lineending;
const GEDCOMmonth:array[1..12] of string = ('JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC');
const SEX:array[0..1] of string = ('M','F');
begin
  //окно выбора файла для экспорта
  sd:=TSaveDialog.Create(nil);
  //Заголовок окна
  sd.Title:='Выбор файла';
  //Установка начального каталога
  sd.InitialDir:=getcurrentdir;
  //GetEnvironmentVariable;
  // Разрешаем сохранять файлы типа .txt и .doc
  sd.Filter:='GEDCOM|*.ged';//'изображение(jpg)|*.jpg|изображение(bmp)|*.bmp';
  // Установка расширения по умолчанию
  sd.DefaultExt := 'ged';
  sd.FileName:='tree.ged';
  // Выбор текстовых файлов как стартовый тип фильтра
  sd.FilterIndex := 1;
  if not  sd.Execute then exit;
  while fileexists(sd.FileName) do
    begin
      if QuestionDlg('предупреждение','Файл уже существует.'+lineending+'Перезаписать файл '+ExtractFileName(sd.FileName)+'?'
      , mtWarning,[mrYes,'перезаписать',mrNo,'не перезаписывать','isdefault'],'')=mrYes then break;
      if not  sd.Execute then exit;
    end;
  tmpi:=utf8length(ExtractFileExt(sd.FileName));
  DirPic:=ExtractFileDir(sd.FileName)+DirectorySeparator+utf8copy(ExtractFileName(sd.FileName),1,utf8length(ExtractFileName(sd.FileName))-tmpi);
  if not DirectoryExists(DirPic) then
    flagD:=CreateDir(DirPic)
    else
        flagD:=true;
  DirPic:=DirPic+DirectorySeparator+'images';
  if not DirectoryExists(DirPic) then
       flagD:=CreateDir(DirPic)
       else
           flagD:=true;
  AssignFile(Fout,sd.FileName);
  ReWrite(Fout);
  dt:=now;
  txt:=HeadF+'1 FILE '+ExtractFileName(sd.FileName)+lineending+'2 _REV 8'+lineending+'1 DATE '+ inttostr(dayof(dt))+' ' +GEDCOMmonth[monthof(dt)]+' '+
  inttostr(currentyear)+lineending;
  txt:=txt+'2 TIME '+ timetostr(dt)+'.'+inttostr(MilliSecondOf(dt));
  writeln(Fout,txt);
  //Запрос для поиска общих детей
  Query5:=TSQLQuery.create(nil);
  Query5.DataBase:=self;
  Query5.Transaction:=Transaction;
  Query5.SQL.Clear;
  Query5.SQL.Add('SELECT PARENT.id_people as ppl1, PARENT.id_parent as prnt1, t.id_people as ppl2, t.id_parent as prnt2  '+
  'FROM PARENT left join PARENT as t on ((PARENT.id_people=t.id_people)and(PARENT.id_parent<>t.id_parent))'+
  ' where ((PARENT.id_parent is not null))');
  Query5.Open;
  //Запрос связей человек-родитель
  Query4:=TSQLQuery.create(nil);
  Query4.DataBase:=self;
  Query4.Transaction:=Transaction;
  Query4.SQL.Clear;
  Query4.SQL.Add('SELECT id_people, id_parent FROM PARENT where (id_parent is not null) order by id_parent');
  Query4.Open;
  //Запрос связей человек-родитель
  Query3:=TSQLQuery.create(nil);
  Query3.DataBase:=self;
  Query3.Transaction:=Transaction;
  Query3.SQL.Clear;
  Query3.SQL.Add('SELECT id, id_people, id_parent FROM PARENT where (id_parent is not null) order by id_parent');
  Query3.Open;
  //Запрос фотографий
  Query2:=TSQLQuery.create(nil);
  Query2.DataBase:=self;
  Query2.Transaction:=Transaction;
  Query2.SQL.Clear;
  Query2.SQL.Add('SELECT id, id_people, foto FROM FOTO');
  Query2.Open;
  //Запрос людей из базы
  Query:=TSQLQuery.create(nil);
  Query.DataBase:=self;
  Query.Transaction:=Transaction;
  Query.SQL.Clear;
  Query.SQL.Add('SELECT id, fam,nam,otch,famfirst,dtb,dtd,sex,dopinfo FROM people order by fam,nam,otch,dtb');
  Query.Open;
  Query.First;
  idNote:=0;
  idOBJE:=0;
  //Notes:=TStringlist.Create;
  FamC:=TStringlist.Create;
  FamS:=TStringlist.Create;
  Fam:=TStringlist.Create;
  sl:=TStringList.Create;
  while not Query.EOF do
    begin
      sl.Clear;
      flagN:=false;
      flagO:=false;
      Fam.Clear;
      txt:='0 @I'+Query.FieldByName('ID').AsString+'@ INDI'+lineending;
      txt:=txt+'1 SEX '+SEX[Query.FieldByName('SEX').asinteger]+lineending;
      txt:=txt+'1 CHAN'+lineending;
      txt:=txt+'2 DATE '+ inttostr(dayof(dt))+' ' +GEDCOMmonth[monthof(dt)]+' '+inttostr(currentyear)+lineending;
      txt:=txt+'3 TIME '+ timetostr(dt)+'.'+inttostr(MilliSecondOf(dt))+lineending;
      //Проверим есть ли записи
      if (not Query.FieldByName('dopinfo').IsNull)and(utf8length(Query.FieldByName('dopinfo').asstring)<>0)then
      begin
        inc(idNote);
        txt:=txt+'1 NOTE @N'+inttostr(idNote)+'@'+lineending;
        Note:=Query.FieldByName('dopinfo').asstring;
        flagN:=true;
      end;
      //Проверим есть ли фото
      if Query2.Locate('ID_PEOPLE', Query.FieldByName('ID').AsInteger,[]) then
      begin
        inc(idOBJE);
        txt:=txt+'1 OBJE @O'+inttostr(idOBJE)+'@'+lineending;
        txt:=txt+'2 _PRIM Y'+lineending;
        flagO:=true;
      end;

      if (Query.FieldByName('SEX').AsInteger=0)or
                      ((Query.FieldByName('SEX').AsInteger=1)and((Query.FieldByName('FamFirst').IsNull)or(utf8length(Query.FieldByName('FamFirst').AsString)=0))) then
         begin
           txt:=txt+'1 NAME '+Query.FieldByName('Nam').asstring+' '+Query.FieldByName('Otch').asstring+' /'+Query.FieldByName('Fam').asstring+'/'+lineending;
           txt:=txt+'2 SURN '+Query.FieldByName('Fam').asstring+lineending;
           if Query.FieldByName('SEX').AsInteger=1 then
              txt:=txt+'2 _MARN '+Query.FieldByName('Fam').asstring+lineending;
         end else
             begin
                    txt:=txt+'1 NAME '+Query.FieldByName('Nam').asstring+' '+Query.FieldByName('Otch').asstring+' /'+Query.FieldByName('FamFirst').asstring+'/'+lineending;
                    txt:=txt+'2 SURN '+Query.FieldByName('FamFirst').asstring+lineending;
                    txt:=txt+'2 _MARN '+Query.FieldByName('Fam').asstring+lineending;
             end;
      txt:=txt+'2 GIVN '+Query.FieldByName('Nam').asstring;
      if (not Query.FieldByName('otch').IsNull) and (utf8length(Query.FieldByName('otch').asstring)<>0) then
         txt:=txt+lineending+'2 _PATN '+Query.FieldByName('otch').asstring;
      //Проверим на предмет вхождения в семью в которой родился
      Query3.Filter:='(id_people = '+Query.FieldByName('ID').asstring+')';
      Query3.Filtered:=true;
      Query3.First;
      if not Query3.EOF then
        begin//Имеется хотя бы один родитель
          tmps1:=Query3.FieldByName('ID_parent').asstring;
          Query3.Next;
          if not Query3.EOF then
          begin//Имеется второй родитель
            tmps1:=tmps1+'-'+Query3.FieldByName('ID_parent').asstring;
          end;
          tmpi:=FamC.IndexOf(tmps1);
          if tmpi=-1 then
             begin
               FamC.Add(tmps1);
               txt:=txt+lineending+'1 FAMC @F'+inttostr(FamC.Count)+'@';
             end else
             begin
               txt:=txt+lineending+'1 FAMC @F'+inttostr(tmpi+1)+'@';
             end;
        end;
      //Проверим на предмет вхождения в семью(и) которую(ые) образовал сам(а)
      Query3.Filter:='(id_parent = '+Query.FieldByName('ID').asstring+')';
      Query3.Filtered:=true;
      Query3.First;
      while not Query3.EOF do
        begin
          tmps1:=Query3.FieldByName('id_parent').AsString;
          //ищем второго родителя
          Query4.Filter:='id_people='+Query3.FieldByName('id_people').AsString;//+') and ( id_parent<>'+tmps1+')';
          Query4.Filtered:=true;
          Query4.First;
          {if not Query4.EOF then
          begin  }
            tmps1:=Query4.FieldByName('id_parent').AsString;//Первый родитель
          //end;
          Query4.Next;
          if not Query4.EOF then
          begin//Если есть, то второй родитель
            tmps1:=tmps1+'-'+Query4.FieldByName('ID_parent').asstring;
          end;
          tmpi:=Fam.IndexOf(tmps1);
          if tmpi=-1 then//Исключаем повторное создание семьи для этого человека
          begin
            Fam.Add(tmps1);//Запоминаем для этого человека семью
            tmpi:=FamC.IndexOf(tmps1);//Проверяем не создавалась ли ранее семья
            if tmpi=-1 then
            begin//Если не создавалась, то создадим
              FamC.Add(tmps1);
              txt:=txt+lineending+'1 FAMS @F'+inttostr(FamC.Count)+'@';
            end else
            begin//Если создавалась, то запишем её номер
              txt:=txt+lineending+'1 FAMS @F'+inttostr(tmpi+1)+'@';
            end;
          end;
          query3.Next;
        end;
      writeln(Fout,txt);
      writeln(Fout,'1 BIRT');//День рождения
      if Query.FieldByName('dtb').AsString<>'UNKNOWN' then
      begin
        if Query.FieldByName('nam').AsString='Василий' then
           showmessage(Query.FieldByName('dtb').AsString);
        if Query.FieldByName('dtb').AsString<>'1900-01-01' then
        txt:='2 DATE '+utf8copy(Query.FieldByName('dtb').AsString,9,2)+' '+GEDCOMmonth[strtoint(utf8copy(Query.FieldByName('dtb').AsString,6,2))]+
        ' '+utf8copy(Query.FieldByName('dtb').AsString,1,4) else
        txt:='2 DATE ABT '+utf8copy(Query.FieldByName('dtb').AsString,9,2)+' '+GEDCOMmonth[strtoint(utf8copy(Query.FieldByName('dtb').AsString,6,2))]+
        ' '+utf8copy(Query.FieldByName('dtb').AsString,1,4);
        writeln(Fout,txt);
      end;
      //Дата смерти, если есть
      if Query.FieldByName('dtd').AsString<>'UNKNOWN' then
      begin
        txt:='1 DEAT';
        if Query.FieldByName('dtd').AsString<>'1900-01-01' then
           txt:=txt+lineending+'2 DATE '+utf8copy(Query.FieldByName('dtd').AsString,9,2)+' '+GEDCOMmonth[strtoint(utf8copy(Query.FieldByName('dtd').AsString,6,2))]+
        ' '+utf8copy(Query.FieldByName('dtd').AsString,1,4);
           //else txt:=txt+'2 DATE AFT 01 JAN 1900';

        writeln(Fout,txt);
      end;
      //Теперь выгрузим для этого человека, если есть, фотку и запишем путь до неё
      if flagO then
      begin
        txt:='0 @O'+inttostr(idOBJE)+'@ OBJE'+lineending;
        txt:=txt+'1 CHAN'+lineending;
        txt:=txt+'2 DATE '+ inttostr(dayof(dt))+' ' +GEDCOMmonth[monthof(dt)]+' '+inttostr(currentyear)+lineending;
        txt:=txt+'3 TIME '+ timetostr(dt)+'.'+inttostr(MilliSecondOf(dt))+lineending;
        txt:=txt+'1 FILE stg:images/'+inttostr(idOBJE)+'.jpg'+lineending;
        txt:=txt+'2 FORM jpg'+lineending;
        txt:=txt+'3 TYPE photo'+lineending;
        txt:=txt+'2 TITL '+Query.FieldByName('fam').AsString+' '+Query.FieldByName('nam').AsString;
        writeln(Fout,txt);
        //Выгрузим фото
        //ExtractFileExt(sd.FileName);
        //showmessage(ExtractFileDir(sd.FileName)+'\'+ExtractFileName(sd.FileName));
        if flagD then
           tblobfield(Query2.FieldByName('foto')).SaveToFile(DirPic+DirectorySeparator+inttostr(idOBJE)+'.jpg');
      //ms:=TMemoryStream.Create;
      //ms.LoadFromStream(Query2.FieldByName('foto'). SQL_table_.FieldAsBlob('foto'));
      end;
      //Добавим, если есть, заметку
      if flagN then
      begin
        txt:='0 @N'+inttostr(idNOTE)+'@ NOTE'+lineending;
        extractstrings([chr(13)],[' '],pchar(Note),sl);
        for tmpi:=0 to sl.Count-1 do
            {if tmpi=(sl.Count-1) then
               txt:=txt+'1 CONT '+sl[tmpi]
               else}
                   txt:=txt+'1 CONT '+sl[tmpi]+lineending;
        txt:=txt+'1 CHAN'+lineending;
        txt:=txt+'2 DATE '+ inttostr(dayof(dt))+' ' +GEDCOMmonth[monthof(dt)]+' '+inttostr(currentyear)+lineending;
        txt:=txt+'3 TIME '+ timetostr(dt)+'.'+inttostr(MilliSecondOf(dt));
        writeln(Fout,txt);
      end;
      Query.Next;
    end;
  //Теперь выгрузим семьи
  for tmpi:=0 to famC.Count-1 do
  begin
    txt:='0 @F'+inttostr(tmpi+1)+'@ FAM'+lineending;
    sl.Clear;
    extractstrings(['-'],[' '],pchar(FamC.Strings[tmpi]),sl);
    //showmessage(FamC.Strings[tmpi]+lineending+sl[0]);
    Query.Locate('id',sl[0],[]);
    if Query.FieldByName('sex').AsInteger=0 then
    begin
      txt:=txt+'1 HUSB @I'+Query.FieldByName('id').AsString+'@'+lineending;
      if sl.Count>1 then
      begin
        Query.Locate('id',sl[1],[]);
        txt:=txt+'1 WIFE @I'+Query.FieldByName('id').AsString+'@'+lineending;
      end;
      txt:=txt+'1 CHAN'+lineending;
      txt:=txt+'2 DATE '+ inttostr(dayof(dt))+' ' +GEDCOMmonth[monthof(dt)]+' '+inttostr(currentyear)+lineending;
      txt:=txt+'3 TIME '+ timetostr(dt)+'.'+inttostr(MilliSecondOf(dt));
    end else
    begin
      txt:=txt+'1 WIFE @I'+Query.FieldByName('id').AsString+'@'+lineending;
      if sl.Count>1 then
      begin
        Query.Locate('id',sl[1],[]);
        txt:=txt+'1 HUSB @I'+Query.FieldByName('id').AsString+'@'+lineending;
      end;
      txt:=txt+'1 CHAN'+lineending;
      txt:=txt+'2 DATE '+ inttostr(dayof(dt))+' ' +GEDCOMmonth[monthof(dt)]+' '+inttostr(currentyear)+lineending;
      txt:=txt+'3 TIME '+ timetostr(dt)+'.'+inttostr(MilliSecondOf(dt));
    end;
    //Добавим детей
      tmps1:='(prnt1 = '+sl[0]+')';
      if sl.Count>1 then
         tmps1:=tmps1+' and (prnt2 = '+sl[1]+')';
      Query5.Filter:=tmps1;
      Query5.Filtered:=true;
      Query5.First;
      while not Query5.EOF do
        begin
          txt:=txt+lineending+'1 CHIL @I'+Query5.FieldByName('ppl1').AsString+'@';
          Query5.Next;
        end;
      writeln(Fout,txt);
  end;
  writeln(Fout,'0 TRLR');
  Query.Close;
  Query2.Close;
  Query3.Close;
  Query4.Close;
  Query5.Close;
  FreeAndNil(Query);
  FreeAndNil(Query2);
  FreeAndNil(Query3);
  FreeAndNil(Query4);
  FreeAndNil(Query5);
  closefile(Fout);
  FreeAndNil(sd);
  //FreeAndNil(Notes);
  FreeAndNil(FamC);
  FreeAndNil(FamS);
  FreeAndNil(Fam);
  exit;


  //AssignFile(Fout,ExtractFilePath(Fpath)+'spisok.csv');
  AssignFile(Fout,sd.FileName);
  ReWrite(Fout);
  writeln(Fout,'Фамилия;Имя;Отчество;Девичья_фамилия;дата рождения;дата смерти');
  while not Query.EOF do
  begin
    txt:=Query.FieldByName('Fam').AsString+';'+Query.FieldByName('Nam').AsString+';';
    if Query.FieldByName('Otch').AsString='UNKNOWN' then txt:=txt+';' else txt:=txt+Query.FieldByName('Otch').AsString+';';
    if Query.FieldByName('famfirst').AsString='UNKNOWN' then txt:=txt+';' else txt:=txt+Query.FieldByName('famfirst').AsString+';';
    if Query.FieldByName('dtb').AsString='UNKNOWN' then txt:=txt+';' else txt:=txt+Query.FieldByName('dtb').AsString+';';
    if Query.FieldByName('dtd').AsString<>'UNKNOWN' then txt:=txt+Query.FieldByName('dtd').AsString;
    writeln(Fout,txt);
    Query.Next;
  end;
  closefile(Fout);
  Query.Close;
  FreeAndNil(Query);
  FreeAndNil(sd);
end;

function Tworkdb.GetRowCount: Cardinal;
begin
  result:=FSQL_table.Count;
end;

function Tworkdb.getparametrbase: string;
var
  s:string;
begin
  {rod.Synchronised:=syncoff; //-можно менять на "лету"
  rod.Auto_Vacuum:=avacuumoff;
  rod.Journal_mode:=jmodeoff; //-можно менять на "лету"
  rod.ForeignKey:=fkeyoff;//-можно менять на "лету" }

  with TSQLQuery.Create(nil) do
  begin
    Database := self;
    SQL.Text := 'PRAGMA auto_vacuum;';
    Open;
    s:='PRAGMA auto_vacuum = ' + fields[0].AsString+lineending;
    close;
    SQL.Text := 'PRAGMA journal_mode;';
    Open;
    s:=s+'PRAGMA journal_mode = ' + fields[0].AsString+lineending;
    close;
    SQL.Text := 'PRAGMA synchronous;';
    Open;
     s:=s+'PRAGMA synchronous = ' + fields[0].AsString+lineending;
    close;
    SQL.Text := 'PRAGMA foreign_keys;';
    Open;
     s:=s+'PRAGMA foreign_keys = ' + fields[0].AsString+lineending;
    close;
    SQL.Text := 'PRAGMA page_size;';
    Open;
     s:=s+'PRAGMA page_size(bytes) = ' + fields[0].AsString+lineending;
     close;
     SQL.Text := 'PRAGMA cache_size;';
    Open;
     s:=s+'PRAGMA cache_size(kibibytes) = ' + fields[0].AsString+lineending;
     close;
     SQL.Text := 'PRAGMA encoding;';
    Open;
     s:=s+'PRAGMA encoding = ' + fields[0].AsString+lineending;
     close;
     SQL.Text := 'PRAGMA temp_store;';
    Open;
     s:=s+'PRAGMA temp_store = ' + fields[0].AsString+lineending;
     close;
    result:=s;
    Free;
  end;
end;

procedure Tworkdb.DeletePeople(ID: integer);
begin
  ExecuteDirect('DELETE FROM people where (id = '+inttostr(ID)+');');
  Transaction.Commit;
  checkParent;
end;

procedure Tworkdb.addconnect(ID_Roditel, ID_Potomok: integer);
begin
  //Удалим запись потомка о том, что он "первый" предок
  //StartDBTransaction(nil,'');
  ExecuteDirect('DELETE FROM parent WHERE (id_people = '+inttostr(ID_Potomok)+')and(id_parent is null);');
  ExecuteDirect('INSERT INTO parent (id_people, id_parent) VALUES ('+inttostr(ID_Potomok)+','+inttostr(ID_Roditel)+');');
  //EndTransaction;
  Transaction.Commit;
  checkParent;
end;

procedure Tworkdb.delconnect(ID_Roditel, ID_Potomok: integer);
begin
  ExecuteDirect('DELETE FROM parent where ((id_people = '+inttostr(ID_Potomok)+') and (id_parent = '+inttostr(ID_Roditel)+'));');
  Transaction.Commit;
  checkParent;
end;

function Tworkdb.addpeople(ppl: Tpeople; predok: boolean): integer;
var
  id,id_f:integer;
  SQL_query:string;
  fams, nams, otchs, ffams:string;
begin
  result:=-1;
  //Добавим человека в основную таблицу
  SQL_query:='INSERT INTO people (fam,nam,otch,sex,dtb,dtd,famfirst,dopinfo,flag) VALUES (';
  if ppl.fam='' then fams:='null,' else fams:='"'+ppl.fam+'",';
  if ppl.nam='' then nams:='null,' else nams:='"'+ppl.nam+'",';
  if ppl.otch='' then otchs:='"UNKNOWN",' else otchs:='"'+ppl.otch+'",';
  SQL_query:=SQL_query+fams+nams+otchs+inttostr(ppl.sex)+',"'+ppl.getdateBornstr+'","'+ppl.getdateDeathstr+'",';
  if ppl.firstFam='' then ffams:='null,' else ffams:='"'+ppl.firstFam+'",';
  if ppl.dopinfo='' then nams:='null,' else nams:='"'+ppl.dopinfo+'",';
  otchs:=inttostr(ppl.flag);
  SQL_query:=SQL_query+ffams+nams+otchs+');';
  try
  ExecuteDirect(SQL_query);
  except
               on E: Exception do
               begin
                 Transaction.Rollback;//Отменим транзакцию
                 //сгенерируем исключение
                 if utf8pos('UNIQUE constraint failed: people.fam, people.nam, people.otch, people.sex',
                 e.Message,1)>0 then
                                 raise exception.Create('double people')
                                 else raise exception.Create(e.Message);
                 exit;
               end;
  end;
  //добавим, если есть фото(аватар)
  //получим id последней вставленной записи
  id:=SQLiteDatabase.GetLastInsertRowID;
  //добавим фотку, если нужно
  id_f:=updatefoto(ppl,id);
  if id_f>0 then //Если необходимо добавим значение аватара
   begin
     SQL_query:='UPDATE people set id_avatar='+inttostr(id_f)+' where id='+inttostr(id)+';';
     try
       ExecuteDirect(SQL_query);
     except
                  on E: Exception do
                  begin
                    //сгенерируем исключение
                    {if utf8pos('UNIQUE constraint failed: people.fam, people.nam, people.otch, people.sex, people.dtb',
                    e.Message,1)>-1 then
                    raise exception.Create('double people')
                    else} exception.Create(e.Message);
                    exit;
                  end;
     end;
   end;
  if predok then
   begin
     //Добавим в таблицу предков
     try
        ExecuteDirect('INSERT INTO parent (id_parent, id_people) VALUES ('+inttostr(id)+','+inttostr(ppl.predok_potomok)+');');
     except
               on E: Exception do
               begin
                 Transaction.Rollback;//Отменим транзакцию
                 if utf8pos('many_parents',
                 e.Message,1)>0 then
                                raise exception.Create('many_prnts') else
                                                               raise exception.Create(e.Message);
                 exit;
               end;
     end;
       checkParent;
   end else
   begin
     //Добавим в таблицу предков
     if ppl.predok_potomok=-1 then
      begin
        ExecuteDirect('INSERT INTO parent (id_people,id_parent) VALUES ('+inttostr(id)+',null);');
      end
     else
       ExecuteDirect('INSERT INTO parent (id_people,id_parent) VALUES ('+inttostr(ID)+','+inttostr(ppl.predok_potomok)+');');
   end;
  //Сохраним изменения
  Transaction.Commit;
  //перечитаем базу
  ppl.ID:=id;
  result:=id;
end;

procedure Tworkdb.checkParent;
begin
  //уберем запись id_people, null у тех кто имеет уже предков
 // ExecuteDirect('DELETE FROM parent where ((id_parent is null)and(exists(select * from parent as tb where((tb.id_people = id_people)and(id_parent is not null)))))');
  ExecuteDirect('delete from parent where (parent.id_parent is null)and(exists(select * from parent as tbl where ((parent.id_people = tbl.id_people)and(tbl.id_parent is not null))));');
  ExecuteDirect('INSERT INTO parent SELECT NULL, id, NULL FROM people where'+lineending+
  ' (NOT EXISTS(SELECT * FROM parent as tb where (tb.id_people=people.id)))');
  Transaction.Commit;
end;

function Tworkdb.savepeople(ppl: Tpeople; id: integer): boolean;
var
  fams, nams, otchs, ffams:string;
  SQL_query:string;
  id_f:integer;
begin
  result:=false;
  //Добавим человека в основную таблицу
  SQL_query:='UPDATE people SET fam = ';
  if ppl.fam='' then fams:='null,' else fams:='"'+ppl.fam+'", ';
  if ppl.nam='' then nams:='nam = null,' else nams:='nam = "'+ppl.nam+'", ';
  if ppl.otch='' then otchs:='otch = "UNKNOWN",' else otchs:='otch = "'+ppl.otch+'", ';
  SQL_query:=SQL_query+fams+nams+otchs+' sex = "'+inttostr(ppl.sex)+  '", dtb = "'+ppl.getdateBornstr+'", dtd = "'+ppl.getdateDeathstr+'", famfirst = ';
  if ppl.firstFam='' then ffams:='null,' else ffams:='"'+ppl.firstFam+'",';
  if ppl.dopinfo='' then nams:='dopinfo = null,' else nams:='dopinfo = "'+ppl.dopinfo+'",';
  otchs:='flag = '+inttostr(ppl.flag);
  SQL_query:=SQL_query+ffams+nams+otchs+'  WHERE id = '+inttostr(id)+' ;';
  try
  ExecuteDirect(SQL_query);
  except
               on E: Exception do
               begin
                 //сгенерируем исключение
                 if utf8pos('UNIQUE constraint failed: people.fam, people.nam, people.otch, people.sex, people.dtb',
                 e.Message,1)>-1 then
                                 raise exception.Create('double people')
                                 else exception.Create(e.Message);
                 exit;
               end;
  end;
  //добавим, если есть фото(аватар)
  //обновим фотку, если нужно
  id_f:=updatefoto(ppl,id);
  if id_f>0 then //Если необходимо добавим значение аватара
   begin
     SQL_query:='UPDATE people set id_avatar='+inttostr(id_f)+' where id='+inttostr(id)+';';
     try
       ExecuteDirect(SQL_query);
     except
                  on E: Exception do
                  begin
                    //сгенерируем исключение
                    {if utf8pos('UNIQUE constraint failed: people.fam, people.nam, people.otch, people.sex, people.dtb',
                    e.Message,1)>-1 then
                    raise exception.Create('double people')
                    else} exception.Create(e.Message);
                    exit;
                  end;
     end;
   end else
   if id_f=0 then
   begin
     SQL_query:='UPDATE people set id_avatar = NULL where id='+inttostr(id)+';';
     try
       ExecuteDirect(SQL_query);
     except
                  on E: Exception do
                  begin
                    //сгенерируем исключение
                    {if utf8pos('UNIQUE constraint failed: people.fam, people.nam, people.otch, people.sex, people.dtb',
                    e.Message,1)>-1 then
                    raise exception.Create('double people')
                    else} exception.Create(e.Message);
                    exit;
                  end;
     end;
   end;
   //добавим, если есть фотки
   updatefotos(ppl);
  //Сохраним изменения
  Transaction.Commit;
  result:=true;
end;

function Tworkdb.updatefoto(ppl: Tpeople; id: integer): integer;
var
   id_f:integer;
   ms:Tmemorystream;
   //Query:TSQLQuery;
begin
  id_f:=-1;
  if ppl.fotoIsModified then
   begin
     if ppl.foto<>nil then
      begin
        //Сначало посмотрим таблицу foto, есть ли там фотка
        {Query:=TSQLQuery.Create(nil);
        Query.DataBase:=self;
        Query.Transaction:=Transaction;
        Query.SQL.Clear;
        Query.SQL.Add('select id from foto where (id_people = '+inttostr(id)+')');
        Query.Open;}
        //if Query.IsEmpty then
        //begin
          ExecuteDirect('INSERT INTO foto (id_people) VALUES ('+inttostr(id)+');');
          id_f:=SQLiteDatabase.GetLastInsertRowID;
        //end else
        //id_f:=Query.FieldByName('id').AsInteger;
        //Query.Close;
        ms:=Tmemorystream.Create;
        ppl.foto.SaveToStream(ms);
        SQLiteDatabase.UpdateBlob('UPDATE foto SET foto = ? WHERE id = '+inttostr(id_f),ms);
        //Query.Free;
        ms.Free;
      end else
      begin
        //ExecuteDirect('UPDATE people set id_avatar='+inttostr(id_f)+' where id = '+inttostr(id)+';');
        id_f:=0;
      end;
  end;
  result:=id_f;
end;

function Tworkdb.updatefotos(ppl: Tpeople): boolean;
var
   i:integer;
   ms:Tmemorystream;
begin
  result:=false;
  if ppl.fotosIsModified then
  begin
    for i:=0 to ppl.FotoInPeople.Count-1 do
    begin
      if (ppl.FotoInPeople.Items[i].Deleting) then//признак удаления
      begin
        //try
           ExecuteDirect('DELETE FROM foto where id='+inttostr(ppl.FotoInPeople.Items[i].ID_Foto)+';');
        {except
                     on E: Exception do
                     begin
                    //сгенерируем исключение
                    {if utf8pos('UNIQUE constraint failed: people.fam, people.nam, people.otch, people.sex, people.dtb',
                    e.Message,1)>-1 then
                    raise exception.Create('double people')
                    else} exception.Create(e.Message);
                    exit;
                  end;
        end;}
      end;
      if (ppl.FotoInPeople.Items[i].ID_Foto=0) then//новое фото
      begin
        ExecuteDirect('INSERT INTO foto (id_people) VALUES ('+inttostr(ppl.ID)+');');
        ppl.FotoInPeople.Items[i].ID_Foto:=SQLiteDatabase.GetLastInsertRowID;
        ms:=Tmemorystream.Create;
        ppl.FotoInPeople.Items[i].SaveToStream(ms);
        //ppl.foto.SaveToStream(ms);
        SQLiteDatabase.UpdateBlob('UPDATE foto SET foto = ? WHERE id = '+inttostr(ppl.FotoInPeople.Items[i].ID_Foto),ms);
        ms.Free;
      end;
      if ppl.FotoInPeople.Items[i].FflagdopInf then
      begin
        ExecuteDirect('UPDATE foto set dopInf='+ppl.FotoInPeople.Items[i].dopInf+' where id='+inttostr(ppl.FotoInPeople.Items[i].ID_Foto)+';');
      end;
    end;
  end;
  result:=true;
end;

function Tworkdb.first: boolean;
begin
  result:=FSQL_table.First;
end;

function Tworkdb.Last: boolean;
begin
  result:=FSQL_table.Last;
end;

function Tworkdb.Next: boolean;
begin
  result:=FSQL_table.Next;
end;

function Tworkdb.Previouse: boolean;
begin
  result:=FSQL_table.Previous;
end;

constructor Tworkdb.Create(pathdb: string; frm: TCustomControl);
begin
  Fpath:=pathdb;
  //Создадим объект подключения
    inherited create(frm);
  // Подключение к БД
   if not connect(pathdb,frm) then
   begin
     raise Exception.Create('Ошибка подключения/содания базы '+pathdb);
     exit;
   end;
   // Создание таблицы temptb в памяти
    createbdinmemory;
end;

destructor Tworkdb.Destroy;
begin
  //Закроем базу, если не была закрыта
  Close;
  inherited Destroy;
end;

function Tworkdb.connect(pathdb: string; frm: TCustomControl): boolean;
var
  existsdb:boolean;
begin
  result:=true;
  try
    DatabaseName:=Fpath;//'rod.db3';
    Ffrm:=frm;
    Params.Add('foreign_keys=ON');
    Params.Add('journal_mode=DELETE');
    Params.Add('synchronous=full');
    Params.Add('auto_vacuum=full');
    Params.Add('temp_store=memory');
    //rod.CreateDB;
    if Transaction=nil then
    Transaction:=TSQLTransaction.Create(frm);
  //Подключимся к базе или создадим, если не было
    existsdb:=fileexists(pathdb);
    Open;
    if not existsdb then
     //Создадим базовую структуру, если базы ранее не было
    createstructdb;
  //Проверим версию, если не совпадает то обновим базу
    CheckVerAndUpdate;
    //Отключимся, чтобы подключиться в другом режиме - с временной базой в памяти
    close;



    //rod:=TSQLite3Connection.Create(nil);
    {Fbdmem:=TSQLite3Connection.Create(nil);
    Fbdmem.DatabaseName:='file:memdb1?mode=memory&cache=shared';//Fpath;//'rod.db3';
    Fbdmem.Params.Add('foreign_keys=ON');
    Fbdmem.Params.Add('journal_mode=DELETE');
    Fbdmem.Params.Add('synchronous=full');
    Fbdmem.Params.Add('auto_vacuum=full');
    fbdmem.Transaction:=TSQLtransaction.Create(nil);
    Fbdmem.Open;
    fbdmem.ExecuteDirect('create table "mmm" '+lineending+
    '([id] INTEGER primary key,'+lineending+
    '[id_tmp] INTEGER NOT NULL'+lineending+
    ');');
    fbdmem.Transaction.Commit;  }

    //настроим  параметры подключения к базе
    DatabaseName:=':memory:';//Fpath;//'rod.db3';
    Params.Add('foreign_keys=ON');
    Params.Add('journal_mode=DELETE');
    Params.Add('synchronous=full');
    Params.Add('auto_vacuum=full');
    Params.Add('temp_store=memory');
    //Создадим пустую базу
    //rod.CreateDB;
    if Transaction=nil then
     Transaction:=TSQLTransaction.Create(frm);
     Open;
     execsql('ATTACH "'+Fpath+'" AS myBD');
     {
     self.execsql('ATTACH "file:memdb1?mode=memory&cache=shared" AS proba1');
     self.execsql('insert into proba1.mmm (id, id_tmp) values(111, 234)');
     self.FSQL_table:=self.GetTable('select * from proba1.mmm');
     self.FSQL_table.First;
     showmessage(self.FSQL_table.FieldAsString('id_tmp'));}
    //self.ExecuteDirect('ATTACH :memory: as proba1');
    //rod.Synchronised:=syncfull;
    //rod.Auto_Vacuum:=avacuumfull;
    //rod.Journal_mode:=jmodeDelete;
    //rod.Journal_mode:=jmodeoff;
    //Создадим объект транзакция
    //rodTrans:=TSQLTransaction.Create(nil);
    //подключим транзакцию
    //Transaction:=TSQLTransaction.Create(frm);
    //result:=true;
  except
               on E: Exception do
               begin
                 result:=false;
                 raise Exception.Create('Ошибка подключения/содания базы '+pathdb);
               end;
  end;
end;

function Tworkdb.connectSliv(pathdb, attachBD: string; frm: TCustomControl
  ): boolean;
var
  Fcurrpath, Fattachpath:string;
begin
  result:=true;
  Fcurrpath:=pathdb;
  Fattachpath:=attachBD;
  // Подключение к БД
  try
    //Добавить проверку версии присоединяемой базы!!!

    //настроим  параметры подключения к базе
    DatabaseName:=':memory:';//Fpath;//'rod.db3';
    Params.Add('foreign_keys=ON');
    Params.Add('journal_mode=DELETE');
    Params.Add('synchronous=full');
    Params.Add('auto_vacuum=full');
    //Создадим пустую базу
    if Transaction=nil then
    Transaction:=TSQLTransaction.Create(frm)
    ;
    Open;
    //прицепим текущую базу
    execsql('ATTACH "'+Fcurrpath+'" AS currBD');
    //прицепим базу которую будем подгружать
    if not fileexists(Fattachpath) then raise exception.Create('база для присоединения не найдена');
    execsql('ATTACH "'+Fattachpath+'" AS attachBD');
  except
               on E: Exception do
               begin
                 result:=false;
                 raise Exception.Create('Ошибка подключения/содания базы '+pathdb);
               end;
  end;
  //Создадим нужную таблицу в памяти
  createbdinmemorySliv;
end;

procedure Tworkdb.createbdinmemorySliv;
begin
  //Создадим таблицу
    // Создание таблицы SlivBD
  ExecuteDirect( 'CREATE temp TABLE IF NOT EXISTS SlivBD '+lineending+
   '([id] INTEGER primary key,'+lineending+
    '[id_old] INTEGER NOT NULL,'+lineending+   //тут id который был
    '[id_new] INTEGER NOT NULL'+lineending+   //тут id который стал в новой таблице
    ');');
  Transaction.Commit;
end;

function Tworkdb.Getversion: string;
begin
  result:=Fversion;
end;

procedure Tworkdb.Sliyanie(pathdb, attachBD: string; frm: TCustomControl);
var
  SQL_query:string;
  SQL_table_:TSQLiteTable2;
  id:integer;
begin
  //закроем текущее подключение
  Close;
  //сделаем резервную копию
  if not copyfile(pathdb,pathdb+'.bak',true) then
     messagedlg('ошибка','при копировании произошла ошибка',mtError,[mbOK],'');
  //Подключимся с необходимыми для слияния параметрами
  if not connectSliv(pathdb, attachBD, frm) then
  begin
    raise exception.Create('не удалось подключиться');
    exit;
  end;
  //Заполним таблицу SlivBD
  //сначало добавим тех, кто уже есть в текущей базе
  SQL_query:='insert into SlivBD select null, attachBD.people.id, currBD.people.id from currBD.people join attachBD.people on '+lineending+
  '((currBD.people.fam = attachBD.people.fam)and(currBD.people.nam = attachBD.people.nam)and(currBD.people.otch = attachBD.people.otch)and(currBD.people.sex = attachBD.people.sex)'+
  'and(currBD.people.dtb = attachBD.people.dtb));';
  ExecuteDirect(SQL_query);

  //Теперь тех, кого нет в текущей базе

  //Надо в цикле каждого отдельно!!!
  //Выберем тех кого нету в основной базе
  SQL_query:='select attachBD.people.id, attachBD.people.fam, attachBD.people.nam, attachBD.people.otch, attachBD.people.sex, attachBD.people.famfirst, '+lineending+
  'attachBD.people.dtb, attachBD.people.dtd, attachBD.people.dopinfo from attachBD.people where ('+
  'not exists ('+
  'select * from currBD.people where '+
  '((currBD.people.fam = attachBD.people.fam)and(currBD.people.nam = attachBD.people.nam)and(currBD.people.otch = attachBD.people.otch)and(currBD.people.sex = attachBD.people.sex)'+
  'and(currBD.people.dtb = attachBD.people.dtb))'+
  '))';
  //if SQL_Table_<>nil then SQL_Table.Free;
  SQL_table_:=GetTable(SQL_query);
  //Теперь переберем и добавим в основную базу, а потом в SlivBD
  if SQL_table_.Count>0 then
  begin
    SQL_table_.First;
    while not SQL_table_.EOF do
          begin
            //обрабатываем
            //Добавим в основную базу
            ExecuteDirect('insert into currBD.people (fam, nam, otch, sex, dtb, dtd, famfirst, dopinfo) values('+
            '"'+SQL_table_.FieldAsString('fam')+'",'+
            '"'+SQL_table_.FieldAsString('nam')+'",'+
            '"'+SQL_table_.FieldAsString('otch')+'",'+
            ''+SQL_table_.FieldAsString('sex')+','+
            '"'+SQL_table_.FieldAsString('dtb')+'",'+
            '"'+SQL_table_.FieldAsString('dtd')+'",'+
            '"'+SQL_table_.FieldAsString('famfirst')+'",'+
            '"'+SQL_table_.FieldAsString('dopinfo')+'"'+
            ');');
            id:=GetInsertID;
            //Добавим в SlivBD
            ExecuteDirect('insert into SlivBD (id_old, id_new) values('+SQL_table_.FieldAsString('id')+','+inttostr(ID)+')');
             //ExecuteDirect('insert into currBD.foto select foto ');
             //Перенесем фото, если есть
            {SQL_query:='insert into currBD.foto select null, attachBD.foto.foto, SlivBD.id_new from SlivBD join '+
            'attachBD.foto on (SlivBD.id_old=attachBD.foto.id_people) where (SlivBD.id = '+inttostr(GetInsertID)+');';
            ExecuteDirect(SQL_query); }
            SQL_table_.Next;
          end;
    //Transaction.Commit;
  end;

  //Теперь перенесем связи
  SQL_query:='select id from SlivBD';
  if SQL_table_<>nil then SQL_table_.Free;
  SQL_table_:=GetTable(SQL_query);
  if SQL_table_.Count>0 then
  begin
    SQL_query:='insert into currBD.parent '+
    'select null, SlBDppl.id_new, SlBDprnt.id_new from '+
    'attachBD.parent join SlivBD as SlBDppl on (attachBD.parent.id_people = SlBDppl.id_old) join '+
    'SlivBD as SlBDprnt on (attachBD.parent.id_parent = SlBDprnt.id_old) '+
    'where '+
    'not exists('+
    'select * from currBD.parent as currP where ((currP.id_people = SlBDppl.id_new)and(currP.id_parent = SlBDprnt.id_new)) '+
    ')';
    self.ExecuteDirect(SQL_query);
  end;

  //Перенесем фото, если есть и если нет в текущей базе
  SQL_query:='insert into currBD.foto select null, attachBD.foto.foto, SlivBD.id_new from SlivBD join '+
  'attachBD.foto on (SlivBD.id_old=attachBD.foto.id_people) where ('+
  'not exists(select * from currBD.people as t1 join currBD.foto as t2 on (t1.id = t2.id_people) where (SlivBD.id_new = t1.id)));';
  ExecuteDirect(SQL_query);

  Transaction.Commit;
  //Закроем подключение
  if SQL_table_<>nil then SQL_table_.Free;
  close(true);
  //Восстановим подключение
  connect(Fpath, Ffrm);
  checkParent;
end;

procedure Tworkdb.createbdinmemory;
begin
    //Создадим таблицу
    // Создание таблицы treeMEM
  ExecuteDirect( 'CREATE temp TABLE IF NOT EXISTS treeMEM '+lineending+
   '([id] INTEGER primary key,'+lineending+
    '[id_tmp] INTEGER NOT NULL'+lineending+
    ');');
  Transaction.Commit;
end;

procedure Tworkdb.SQL_table_FREE;
begin
  if FSQL_Table<>nil then FSQL_Table.Free;
end;

function Tworkdb.GetPotomok(const ID_Roditel: integer): boolean;
var
  SQL_query:string;
begin
  result:=false;
  //Получим потомков и запишем во временную таблицу
  SQL_query:='with recursive m(depth,id_people,id_parent) as ('+lineending+
  'select DISTINCT 1/* as depth*/, id_people, null from parent where id_people='+inttostr(ID_Roditel){+' group by depth'} +lineending+
  'union all'+lineending+
  'select m.depth+1, t.id_people, t.id_parent from parent as t join m on (t.id_parent=m.id_people)'+lineending+
  ')'+lineending+
  'select  DISTINCT p.dtb as dt_b, p.dtd as dt_d, case when strftime(''%m-%d'',p.dtb) = strftime(''%m-%d'',''now'') then 1 else 0 end as dtb,'+lineending+
  'case when p.dtb=''UNKNOWN'' then ''0'' else '+lineending+
  'case when (strftime(''%m'',''now'')=''01'')or(strftime(''%m'',''now'')=''12'') then '+lineending+
  'case when abs(strftime(''%j'',p.dtb,''+2 month'')-strftime(''%j'',''now'',''+2 month''))<'+inttostr(count_view_birthday_skoro)+' then 1 else 0 end '+lineending+
  'else '+lineending+
  'case when abs(strftime(''%j'',p.dtb)-strftime(''%j'',''now''))<'+inttostr(count_view_birthday_skoro)+' then 1 else 0 end '+lineending+
  'end '+lineending+
  'end as dtb2,'+lineending+
  '/*m.depth as depth,*/ p.id as pid, /*p.fam as pfam,p.nam as pnam,p.otch as potch,*//*p.sex as psex,*//* p.avatar as pfoto,*/ '+lineending+
  'p2.id as p2id/*,p2.fam as p2fam,p2.nam as p2nam,p2.otch as p2otch,p2.sex as p2sex*/ from m join people as p on (m.id_people=p.id)'+lineending+
  'left join people as p2 on (m.id_parent=p2.id)'+lineending+
  '/*order by depth ASC, p2id*/'+lineending+
  ''+lineending+
  '';
  //pid - id - человека
  //p2id - id - родителя
  //Заполним таблицу
  FSQL_table:=GetTable(SQL_query);
  result:=FSQL_table.Count>0;
  //SQL_table_FREE;
end;

function Tworkdb.GetPredok(const ID_Predok: integer): boolean;
var
  SQL_query:string;
begin
  result:=false;
  //Получим потомков и запишем во временную таблицу
  SQL_query:='with recursive m(depth,id_people,id_parent) as ('+lineending+
  'select DISTINCT 1/* as depth*/, null as id_people, id_people as id_parent from parent where id_people='+inttostr(ID_Predok)+lineending+
  'union all'+lineending+
  'select m.depth+1, t.id_people, t.id_parent from parent as t join m on (t.id_people=m.id_parent)'+lineending+
  ')'+lineending+
  'select  DISTINCT p2.dtb as dt_b, p2.dtd as dt_d, case when strftime(''%m-%d'',p2.dtb) = strftime(''%m-%d'',''now'') then 1 else 0 end as dtb,'+lineending+
  'case when p2.dtb=''UNKNOWN'' then ''0'' else '+lineending+
  'case when (strftime(''%m'',''now'')=''01'')or(strftime(''%m'',''now'')=''12'') then '+lineending+
  'case when abs(strftime(''%j'',p2.dtb,''+2 month'')-strftime(''%j'',''now'',''+2 month''))<'+inttostr(count_view_birthday_skoro)+' then 1 else 0 end '+lineending+
  'else '+lineending+
  'case when abs(strftime(''%j'',p2.dtb)-strftime(''%j'',''now''))<'+inttostr(count_view_birthday_skoro)+' then 1 else 0 end '+lineending+
  'end '+lineending+
  'end as dtb2,'+lineending+
  ' /*m.depth as depth,*/p.id as pid, '+
  '/*p.fam as pfam,p.nam as pnam,p.otch as potch,p.sex as psex, p.avatar as pfoto,*/ '+lineending+
  'p2.id as p2id/*, p2.fam as p2fam,p2.nam as p2nam,p2.otch as p2otch, p2.sex as p2sex*/ from m join people as p2 on (m.id_parent=p2.id)'+lineending+
  'left join people as p on (m.id_people=p.id)'+lineending+
  '/*order by depth ASC, p2id*/'+lineending+
  ''+lineending+
  '';
  //pid - id - человека
  //p2id - id - родителя
  //Заполним таблицу
  FSQL_table:=GetTable(SQL_query);
  result:=FSQL_table.Count>0;
  //SQL_table_FREE;
end;

function Tworkdb.GetPeople_min(predok: boolean): TPeople;//минимальные сведения необходимые для построения дерева
var
  SQL_query:string;
  SQL_table_:TSQLiteTable2;
  ms:TMemoryStream;
  tmp1,tmp2:string;
begin
  result:=nil;
  //Сделаем запрос к базе
  if predok then
   begin
     tmp1:='p2id';
     tmp2:='pid';
   end else
   begin
     tmp1:='pid';
     tmp2:='p2id';
   end;
  SQL_query:='select id, dtd, fam, nam, otch, flag/*, avatar*/ from people where id='+inttostr(FieldAsInteger(tmp1));
  SQL_table_:=nil;
  SQL_table_:=GetTable(SQL_query);
  if SQL_table_.Count<=0 then
   begin
     result:=nil;
     exit;
   end;
   result:=TPeople.Create;
   result.fam:=SQL_table_.FieldAsString('fam');
   result.nam:=SQL_table_.FieldAsString('nam');
   if (SQL_table_.FieldAsString('otch')<>'UNKNOWN') then
   result.otch:=SQL_table_.FieldAsString('otch') else result.otch:='';
   //result.sex:=SQL_table.FieldAsInteger('sex');
   result.Death:=(SQL_table_.FieldAsString('dtd')<>'UNKNOWN');
   result.ID:=SQL_table_.FieldAsInteger('id');
   result.flag:=strtoint(SQL_table_.FieldAsString('flag'));
  if FieldIsNull(tmp2) then result.predok_potomok:=-1 else
    result.predok_potomok:=self.FieldAsInteger(tmp2);
  //Подгрузим фотку, если есть
  SQL_query:='select foto.foto, foto.id from people join foto on ((id_people='+inttostr(SQL_table_.FieldAsInteger('id'))+')and(foto.id=people.id_avatar))';
  if SQL_table_<>nil then SQL_table_.Free;
  SQL_table_:=GetTable(SQL_query);
  if SQL_table_.Count>0 then
  begin
    ms:=TMemoryStream.Create;
    ms.LoadFromStream(SQL_table_.FieldAsBlob('foto'));
    result.ID_Avatar:=SQL_table_.FieldAsInteger('id');
    result.foto:=ms;
    result.fotoIsModified:=false;
  end else result.foto:=nil;
   SQL_table_.Free;
end;

function Tworkdb.GetPeople_ID(predok: boolean): TPeople;
var
  tmp1,tmp2:string;
begin
  result:=nil;
  if FSQL_table.Count<=0 then exit;
  if predok then
   begin
     tmp1:='p2id';
     tmp2:='pid';
   end else
   begin
     tmp1:='pid';
     tmp2:='p2id';
   end;
   if FieldIsNull(tmp1) then exit;
   result:=TPeople.Create;
  //Получим идентификатор листа
  result.ID:=FieldAsInteger(tmp1);
  //Получим идентификатор родителя, если есть
  if FieldIsNull(tmp2) then result.predok_potomok:=-1 else
    result.predok_potomok:=self.FieldAsInteger(tmp2);
end;

function Tworkdb.getpeople_full(indexid: Cardinal): Tpeople;
function DatestrTodate(datestr:string):Tdate;
var
  daystr, monthstr, yearstr:integer;
begin
  yearstr:=strtoint(utf8copy(datestr,1,4));
  monthstr:=strtoint(utf8copy(datestr,6,2));
  daystr:=strtoint(utf8copy(datestr,9,2));
  result:=encodedate(yearstr, monthstr, daystr);
end;

var
  SQL_query:string;
  SQL_table_:TSQLiteTable2;
  ms:TMemoryStream;
  msf:TmyMemoryStream;
  i:integer;
begin
  result:=nil;
  //Сделаем запрос к базе
  SQL_query:='select id, dtd, dtb, fam, nam, otch, sex, famfirst, dopinfo, flag from people where id='+inttostr(indexid);
  SQL_table_:=nil;
  SQL_table_:=GetTable(SQL_query);
  if SQL_table_.Count<=0 then
   begin
     result:=nil;
     exit;
   end;
   result:=TPeople.Create;
   result.fam:=SQL_table_.FieldAsString('fam');
   result.nam:=SQL_table_.FieldAsString('nam');
   if (SQL_table_.FieldAsString('otch')<>'UNKNOWN') then
   result.otch:=SQL_table_.FieldAsString('otch') else result.otch:='';
   if (SQL_table_.FieldAsString('famfirst')<>'UNKNOWN') then
   result.firstFam:=SQL_table_.FieldAsString('famfirst') else result.firstFam:='';
   if (not SQL_table_.FieldIsNull('dopinfo')) then
   result.dopinfo:=SQL_table_.FieldAsString('dopinfo') else result.dopinfo:='';
   result.sex:=strtoint(SQL_table_.FieldAsString('sex'));
   result.Death:=(SQL_table_.FieldAsString('dtd')<>'UNKNOWN');
   if SQL_table_.FieldAsString('dtb')='UNKNOWN' then result.dateBorn:=1.7E308 else
   result.dateBorn:=datestrTodate(SQL_table_.FieldAsString('dtb'));
   if SQL_table_.FieldAsString('dtd')='UNKNOWN' then result.dateDeath:=1.7E308 else
   result.dateDeath:=datestrTodate(SQL_table_.FieldAsString('dtd'));
   result.ID:=SQL_table_.FieldAsInteger('id');
   result.flag:=strtoint(SQL_table_.FieldAsString('flag'));
   result.predok_potomok:=-1;

  //Подгрузим фотку-аватар, если есть
  SQL_query:='select foto.foto, foto.id from people join foto on ((people.id='+inttostr(SQL_table_.FieldAsInteger('id'))+')and(people.id_avatar=foto.id))';
  // where id_people='+inttostr(SQL_table_.FieldAsInteger('id'));
  if SQL_table_<>nil then SQL_table_.Free;
  SQL_table_:=GetTable(SQL_query);
  if SQL_table_.Count>0 then
  begin
    ms:=TMemoryStream.Create;
    ms.LoadFromStream(SQL_table_.FieldAsBlob('foto'));
    result.Foto:=ms;
    result.ID_Avatar:=SQL_table_.FieldAsInteger('id');
    result.fotoIsModified:=false;
    {
     jpg:=TJpegImage.Create;
     ms:=TMemoryStream.Create;
     ms:=SQL_table_.FieldAsBlob('foto');
     ms.Seek(0, soBeginning);
     jpg.LoadFromStream(ms);
     result.foto:=jpg;}
  end else result.foto:=nil;
  //Подгрузим фотки, если есть
  SQL_query:='select foto.id as id, foto.foto as foto, foto.dopInf as dopInf from foto where (foto.id_people='+inttostr(result.ID)+')';
  if SQL_table_<>nil then SQL_table_.Free;
  SQL_table_:=GetTable(SQL_query);
  if SQL_table_.Count>0 then
    for i:=0 to SQL_table_.Count-1 do
    begin
      SQL_table_.MoveTo(i);
      msf:=TmyMemoryStream.Create;
      msf.LoadFromStream(SQL_table_.FieldAsBlob('foto'));
      msf.ID_Foto:=SQL_table_.FieldAsInteger('id');
      msf.dopInf:=SQL_table_.FieldAsString('dopInf');
      result.FotoInPeople.Add(msf);
    end;
   SQL_table_.Free;
end;

function Tworkdb.GetPredokForAdd(ID_Potomok: integer): TSQLQuery;
var
  SQL_query:string;
  SQLQuery:TSQLQuery;
begin
  //сначало получим всех потомков данного(ID_Potomok) перца
  //ведь потомок не может стать предком - иначе циклическая ссылка
  result:=nil;
  //Получим потомков и запишем во временную таблицу
  SQL_query:='with recursive m(depth,id_people,id_parent) as ('+lineending+
  'select DISTINCT 1/* as depth*/, id_people, null from parent where id_people='+inttostr(ID_Potomok){+' group by depth'} +lineending+
  'union all'+lineending+
  'select m.depth+1, t.id_people, t.id_parent from parent as t join m on (t.id_parent=m.id_people)'+lineending+
  ')'+lineending+
  'select  case when p.dtd <> "UNKNOWN" then 1 else 0 end as pdeath, m.depth as depth, p.id as pid, /*p.fam as pfam,p.nam as pnam,p.otch as potch,*//*p.sex as psex,*//* p.avatar as pfoto,*/ '+lineending+
  'p2.id as p2id/*,p2.fam as p2fam,p2.nam as p2nam,p2.otch as p2otch,p2.sex as p2sex*/ from m join people as p on (m.id_people=p.id)'+lineending+
  'left join people as p2 on (m.id_parent=p2.id)'+lineending+
  '/*order by depth ASC, p2id*/'+lineending+
  ''+lineending+
  '';
  //pid - id - человека
  //p2id - id - родителя
  //Заполним таблицу
  FSQL_table:=GetTable(SQL_query);
  //Ну а теперь создадим Query и добавим туда записи
  ExecuteDirect('DELETE FROM treeMEM');
  Transaction.Commit;
  SQLQuery:=TSQLQuery.Create(nil);
  SQLQuery.DataBase:=self;
  SQLQuery.Transaction:=Transaction;
  SQLQuery.SQL.Clear;
  SQLQuery.SQL.Add('select * from treeMEM');
  SQLQuery.Open;
  FSQL_table.First;
  while not FSQL_table.EOF do
  begin
    SQLQuery.Insert;
    SQLQuery.FieldByName('id_tmp').AsInteger:=FSQL_table.FieldAsInteger('pid');
    SQLQuery.Post;
    FSQL_table.Next;
  end;
  SQLQuery.ApplyUpdates;
  Transaction.Commit;
  //теперь добавим тех кто уже родители данного перца
  ExecuteDirect('insert into treeMEM select null, id_parent from parent where (id_people='+inttostr(ID_Potomok)+') and (id_parent is not NULL);');
  Transaction.Commit;

  //ну а теперь получим список тех кто может стать предком данного перца
  SQLQuery.SQL.Clear;
  SQLQuery.SQL.Add('select DISTINCT id_people as id, fam, nam, otch, sex, dtb from parent join people on (people.id = parent.id_people)'+lineending+
  ' where not exists(select ID from treeMEM where (parent.id_people=treeMEM.ID_TMP)) order by fam, nam, otch');
  //SQLQuery.Open;
  {SQLQuery.First;
  while not SQLQuery.EOF do
  begin
    showmessage(SQLQuery.FieldByName('id_people').AsString);
    SQLQuery.Next;
  end;        }
  //SQLQuery.Close;
  //SQLQuery.Free;
  self.SQL_table_FREE;
  result:=SQLQuery;
end;

function Tworkdb.GetPotomokForDel(ID_Predok: integer): TSQLQuery;
var
  SQLQuery:TSQLQuery;
begin
    //Получим список потомков данного перца
  SQLQuery:=TSQLQuery.Create(nil);
  SQLQuery.DataBase:=self;
  SQLQuery.Transaction:=Transaction;
  SQLQuery.SQL.Clear;
  SQLQuery.SQL.Add('select DISTINCT id_people as id, fam, nam, otch, sex, dtb from parent join people on (people.id = parent.id_people) where (parent.id_parent = '
  +inttostr(ID_Predok)+') order by fam, nam, otch');
  result:=SQLQuery;
end;

function Tworkdb.GetPredokForDel(ID_Potomok: integer): TSQLQuery;
var
  SQLQuery:TSQLQuery;
begin
    //Получим список предков данного перца
    SQLQuery:=TSQLQuery.Create(nil);
    SQLQuery.DataBase:=self;
    SQLQuery.Transaction:=Transaction;
    SQLQuery.SQL.Clear;
    SQLQuery.SQL.Add('select DISTINCT id_parent as id, fam, nam, otch, sex, dtb from parent join people on (people.id = parent.id_parent) where (parent.id_people = '
    +inttostr(ID_Potomok)+') order by fam, nam, otch');
    result:=SQLQuery;
end;

function Tworkdb.GetPotomokForAdd(ID_Predok: integer): TSQLQuery;
var
  SQL_query:string;
  SQLQuery:TSQLQuery;
begin
  //сначало получим всех предков данного(ID_Potomok) перца
  //ведь предок не может стать потомком - иначе циклическая ссылка
  result:=nil;
  //Получим предков и запишем во временную таблицу
  SQL_query:='with recursive m(depth,id_people,id_parent) as ('+lineending+
  'select DISTINCT 1/* as depth*/, null as id_people, id_people as id_parent from parent where id_people='+inttostr(ID_Predok)+lineending+
  'union all'+lineending+
  'select m.depth+1, t.id_people, t.id_parent from parent as t join m on (t.id_people=m.id_parent)'+lineending+
  ')'+lineending+
  'select  case when p.dtd <> "UNKNOWN" then 1 else 0 end as pdeath, m.depth as depth,p.id as pid, /*p.fam as pfam,p.nam as pnam,p.otch as potch,p.sex as psex, p.avatar as pfoto,*/ '+lineending+
  'p2.id as p2id/*, p2.fam as p2fam,p2.nam as p2nam,p2.otch as p2otch,p2.sex as p2sex*/ from m join people as p2 on (m.id_parent=p2.id)'+lineending+
  'left join people as p on (m.id_people=p.id)'+lineending+
  '/*order by depth ASC, p2id*/'+lineending+
  ''+lineending+
  '';
  //pid - id - человека
  //p2id - id - родителя
  //Заполним таблицу
  FSQL_table:=GetTable(SQL_query);
  ExecuteDirect('DELETE FROM TreeMEM');
  Transaction.Commit;
  //Ну а теперь создадим Query и добавим туда записи
  SQLQuery:=TSQLQuery.Create(nil);
  SQLQuery.DataBase:=self;
  SQLQuery.Transaction:=Transaction;
  SQLQuery.SQL.Clear;
  SQLQuery.SQL.Add('select * from treeMEM');
  SQLQuery.Open;
  FSQL_table.First;
  while not FSQL_table.EOF do
  begin
    SQLQuery.Insert;
    SQLQuery.FieldByName('id_tmp').AsInteger:=FSQL_table.FieldAsInteger('p2id');
    SQLQuery.Post;
    FSQL_table.Next;
  end;
  SQLQuery.ApplyUpdates;
  Transaction.Commit;
  //теперь добавим тех кто уже потомки данного перца
  ExecuteDirect('insert into treeMEM select null, id_people from parent where id_parent='+inttostr(ID_Predok)+'');
  Transaction.Commit;

  //ну а теперь получим список тех кто может стать потомком данного перца
  SQLQuery.SQL.Clear;
  SQLQuery.SQL.Add('select DISTINCT id_people as id, fam, nam, otch, sex, dtb from parent join people on (people.id = parent.id_people)'+lineending+
  ' where not exists(select ID from treeMEM where (parent.id_people=treeMEM.ID_TMP)) order by fam, nam, otch');
  SQL_table_FREE;
  result:=SQLQuery;
end;

function Tworkdb.GetPredokForStart: TSQLQuery;
var
  SQLQuery:TSQLQuery;
begin
  //Получим список предков с которых начинаются деревья
  result:=nil;
  SQLQuery:=TSQLQuery.Create(nil);
  SQLQuery.DataBase:=self;
  SQLQuery.Transaction:=Transaction;
  SQLQuery.SQL.Clear;
  SQLQuery.SQL.Add('select id, fam, nam, otch, flag from GetPredokForStart');
  result:=SQLQuery;
end;

function Tworkdb.GetPotomkForStart: TSQLQuery;
var
  SQLQuery:TSQLQuery;
begin
  //Получим список предков с которых начинаются деревья
  result:=nil;
  SQLQuery:=TSQLQuery.Create(nil);
  SQLQuery.DataBase:=self;
  SQLQuery.Transaction:=Transaction;
  SQLQuery.SQL.Clear;
  SQLQuery.SQL.Add('select id,fam, nam, otch, flag from GetPotomkForStart');
  //SQLQuery.Open;
  result:=SQLQuery
end;

function Tworkdb.GetAllPeopleForStart: TSQLQuery;
var
  SQLQuery:TSQLQuery;
begin
  //Получим список всех людей в базе
  result:=nil;
  SQLQuery:=TSQLQuery.Create(nil);
  SQLQuery.DataBase:=self;
  SQLQuery.Transaction:=Transaction;
  SQLQuery.SQL.Clear;
  SQLQuery.SQL.Add('select id,fam, nam, otch, flag from people');
  {SQLQuery.FilterOptions:=SQLQuery.FilterOptions-[foCaseInsensitive];
  SQLQuery.FilterOptions:=SQLQuery.FilterOptions+[foNoPartialCompare];
  SQLQuery.Open;
  //SQLQuery.close;
  sqlquery.FieldByName('fam').FieldDef.DataType:=ftString;}
  result:=SQLQuery
end;

end.

