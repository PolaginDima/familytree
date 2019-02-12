unit Slivbd;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,mysqlite3conn, controls, sqldb, dialogs;
  type

    { TslivBD }

    TslivBD=class(TSQLite3Connection)
      private
       Fcurrpath, Fattachpath:string;
      protected
      public
       constructor Create(pathdb, attachBD:string;frm:TCustomControl);
       destructor Destroy;override;
       procedure createbdinmemory;
       procedure Sliyanie;
   end;
implementation

{ TslivBD }

constructor TslivBD.Create(pathdb, attachBD: string; frm: TCustomControl);
{var
  existsdb:boolean;  }
begin
  Fcurrpath:=pathdb;
  Fattachpath:=attachBD;
  // Подключение к БД
  try
    //Добавить проверку версии присоединяемой базы!!!


    //Создадим объект подключения
    inherited create(frm);
    //настроим  параметры подключения к базе
    DatabaseName:=':memory:';//Fpath;//'rod.db3';
    Params.Add('foreign_keys=ON');
    Params.Add('journal_mode=DELETE');
    Params.Add('synchronous=full');
    Params.Add('auto_vacuum=full');
    //Создадим пустую базу
    Transaction:=TSQLTransaction.Create(frm);
    Open;
    //прицепим текущую базу
    execsql('ATTACH "'+Fcurrpath+'" AS currBD');
    //прицепим базу которую будем подгружать
    if not fileexists(Fattachpath) then raise exception.Create('база для присоединения не найдена');
    execsql('ATTACH "'+Fattachpath+'" AS attachBD');
  except
               on E: Exception do
               begin
                 //result:=false;
                 raise Exception.Create('Ошибка подключения/содания базы '+pathdb);
               end;
  end;
  //Создадим нужную таблицу в памяти
  createbdinmemory;
end;

destructor TslivBD.Destroy;
begin
  inherited Destroy;
end;

procedure TslivBD.createbdinmemory;
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

procedure TslivBD.Sliyanie;
var
  SQL_query:string;
  SQL_table:TSQLiteTable2;
begin
  //Заполним таблицу SlivBD
  //сначало добавим тех, кто уже есть в текущей базе
  SQL_query:='insert into SlivBD select null, attachBD.people.id, currBD.people.id from currBD.people join attachBD.people on '+lineending+
  '((currBD.people.fam = attachBD.people.fam)and(currBD.people.nam = attachBD.people.nam)and(currBD.people.otch = attachBD.people.otch)and(currBD.people.dtb = attachBD.people.dtb));';
  ExecuteDirect(SQL_query);

  //Теперь тех, кого нет в текущей базе

  //Надо в цикле каждого отдельно!!!
  //Выберем тех кого нету в основной базе
  SQL_query:='select attachBD.people.id, attachBD.people.fam, attachBD.people.nam, attachBD.people.otch, attachBD.people.sex, attachBD.people.famfirst, '+lineending+
  'attachBD.people.dtb, attachBD.people.dtd, attachBD.people.dopinfo from attachBD.people where ('+
  'not exists ('+
  'select * from currBD.people where '+
  '((currBD.people.fam = attachBD.people.fam)and(currBD.people.nam = attachBD.people.nam)and(currBD.people.otch = attachBD.people.otch)and(currBD.people.dtb = attachBD.people.dtb))'+
  '))';
  SQL_table:=GetTable(SQL_query);
  //Теперь переберем и добавим в основную базу, а потом в SlivBD
  if SQL_table.Count>0 then
  begin
    SQL_table.First;
    while not SQL_table.EOF do
          begin
            //обрабатываем
            //Добавим в основную базу
            ExecuteDirect('insert into currBD.people (fam, nam, otch, sex, dtb, dtd, famfirst, dopinfo) values('+
            '"'+SQL_table.FieldAsString('fam')+'",'+
            '"'+SQL_table.FieldAsString('nam')+'",'+
            '"'+SQL_table.FieldAsString('otch')+'",'+
            ''+SQL_table.FieldAsString('sex')+','+
            '"'+SQL_table.FieldAsString('dtb')+'",'+
            '"'+SQL_table.FieldAsString('dtd')+'",'+
            '"'+SQL_table.FieldAsString('famfirst')+'",'+
            '"'+SQL_table.FieldAsString('dopinfo')+'"'+
            ');');
            //Добавим в SlivBD
            ExecuteDirect('insert into SlivBD (id_old, id_new) values('+SQL_table.FieldAsString('id')+','+inttostr(GetInsertID)+')');
            SQL_table.Next;
          end;
    Transaction.Commit;
  end;

  //Теперь перенесем связи
  SQL_query:='select id from SlivBD';
  SQL_table:=GetTable(SQL_query);
  if SQL_table.Count>0 then
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
  Transaction.Commit;
end;

end.

