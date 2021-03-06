unit SQLiteTable3;
(*
 Простой класс для использования базовых функций библиотеки SQLite (exec и get_table).

 TSQLiteDatabase - это обёртка для открытия и закрытия БД SQLite.
 Также она позволяет вызвать SQLite_exec для запросов, которые возвращают наборы данных.

 TSQLiteTable - обёртка для выполнения SQL-запросов.
 Она выполняет запрос и записывает возвращаемые им строки во внутренний буфер.
 Она позволяет обращаться к полям таблицы по именами и обеспечивает навигацию по полям
 (переход к первой и последней строкам, шаг на одну строку вперёд/назад).

 Благодарности
  * Оригинальный модуль - Pablo Pissanetzky (pablo@myhtpc.net)
  * Адаптация к Delphi - Tim Anderson (tim@itwriting.com)
  * Модификация и расширения - Lukas Gebauer, Tobias Gunkel
  * Удаление лишних и дублирующих классов/методов; изменения для большей совместимости
    со стандартным компонентом TQuery; перенос части функций в Private-зону - Nikolay Petrochenko (www.megabyte-web.ru)
*)

interface

{$IFDEF FPC}
  {$MODE Delphi}//{$H+}
{$ENDIF}

uses {$IFDEF WIN32} Windows, {$ENDIF} SQLite3, Classes, SysUtils;

const
  dtInt = 1;
  dtNumeric = 2;
  dtStr = 3;
  dtBlob = 4;
  dtNull = 5;

const
  SecPerDay    =  86400;
  Offset1970  =  25569;

type

  ESQLiteException = class(Exception)
  end;

  THookQuery = procedure(Sender: TObject; SQL: String) of object;

  TSQLiteTable = class;

  { TSQLiteDatabase }

  TSQLiteDatabase = class
  private
    fDB: TSQLiteDB;
    fInTrans: boolean;
    fSync: boolean;
    FOnQuery: THookQuery;
    procedure RaiseError(s: string; SQL: string);
    function GetRowsChanged: integer;
  protected
    procedure SetSynchronised(Value: boolean);
    procedure DoQuery(value: string);
  public
    constructor Create(const FileName: string);overload;
    constructor Create(const DB:TSQLiteDB);overload;
    destructor Destroy; override;
    function GetTable(const SQL: Ansistring): TSQLiteTable; overload;
    procedure ExecSQL(const SQL: Ansistring);
    procedure UpdateBlob(const SQL: Ansistring; BlobData: TStream);
    procedure BeginTransaction;
    procedure Commit;
    procedure Rollback;
    function TableExists(TableName: string): boolean;
    function GetLastInsertRowID: int64;
    function GetLastChangedRows: int64;
    function Version: string;
    procedure AddCustomCollate(name: string; xCompare: TCollateXCompare);
    //adds collate named SYSTEM for correct data sorting by user's locale
    Procedure AddSystemCollate;
    property DB: TSQLiteDB read fDB;
  published
    property IsTransactionOpen: boolean read fInTrans;
    //database rows that were changed (or inserted or deleted) by the most recent SQL statement
    property RowsChanged : integer read getRowsChanged;
    property Synchronised: boolean read FSync write SetSynchronised;
    property OnQuery: THookQuery read FOnQuery write FOnQuery;
  end;

  { TSQLiteTable }

  TSQLiteTable = class
  private
    fResults: TList;
    fRowCount: cardinal;
    fColCount: cardinal;
    fCols: TStringList;
    fColTypes: TList;
    fRow: cardinal;
    fhandle: TSQLiteDB;//psqlite3;
    function GetFields(FieldName: string): string;
    function GetEOF: boolean;
    function GetBOF: boolean;
    function GetFieldIndex(FieldName: string): integer;
    function GetCount: integer;
    procedure RaiseError(s: string; SQL: string);
    {property EOF: boolean read GetEOF;
    property BOF: boolean read GetBOF; }
  public
    constructor Create(filehandle: TSQLiteDB; const SQL: Ansistring); overload;
    destructor Destroy; override;
    function FieldAsInteger(FieldName: string): int64;
    function FieldAsBlob(FieldName: string): TMemoryStream;
    function FieldAsBlobText(FieldName: string): string;
    function FieldIsNull(FieldName: string): boolean;
    function FieldAsString(FieldName: string): string;
    function FieldAsDouble(FieldName: string): double;
    function FieldAsDateTime(FieldName: string): TDateTime;
    function Next: boolean;
    function Previous: boolean;
    property Row: cardinal read fRow;
    function First: boolean;
    function Last: boolean;
    function MoveTo(position: cardinal): boolean;
    property Count: integer read GetCount;
    property EOF: boolean read GetEOF;
    property BOF: boolean read GetBOF;
  end;


function UnixTimeToDateTime(UnixTime: LongInt): TDate;
function DateTimeToUnixTime(DelphiDate: TDate): LongInt;
//
procedure DisposePointer(ptr: pointer); cdecl;

{$IFDEF WIN32}
function SystemCollate(Userdta: pointer; Buf1Len: integer; Buf1: pointer;
    Buf2Len: integer; Buf2: pointer): integer; cdecl;
{$ENDIF}

implementation

// Функции для преобразования даты между форматами TDate и Unix
function UnixTimeToDateTime(UnixTime :  LongInt): TDate;
begin
  Result:= UnixTime / SecPerDay + Offset1970;
end;
function DateTimeToUnixTime(DelphiDate: TDate): LongInt;
begin
  Result:= Trunc((DelphiDate - Offset1970) * SecPerDay);
end;


procedure DisposePointer(ptr: pointer); cdecl;
begin
  if assigned(ptr) then
    freemem(ptr);
end;

{$IFDEF WIN32}
function SystemCollate(Userdta: pointer; Buf1Len: integer; Buf1: pointer;
    Buf2Len: integer; Buf2: pointer): integer; cdecl;
begin
  Result := CompareStringW(LOCALE_USER_DEFAULT, 0, PWideChar(Buf1), Buf1Len,
    PWideChar(Buf2), Buf2Len) - 2;
end;
{$ENDIF}

//------------------------------------------------------------------------------
// TSQLiteDatabase
//------------------------------------------------------------------------------

constructor TSQLiteDatabase.Create(const FileName: string);
var
  Msg: PAnsiChar;
  iResult: integer;
 // utf8FileName: UTF8string;
begin
  inherited Create;
  self.fInTrans := False;

  Msg := nil;
  try
  //  utf8FileName := UTF8String(FileName);
    iResult := SQLite3_Open(PAnsiChar(FileName), Fdb);

    if iResult <> SQLITE_OK then
      if Assigned(Fdb) then
      begin
        Msg := Sqlite3_ErrMsg(Fdb);
        raise ESqliteException.CreateFmt('Failed to open database "%s" : %s',
          [FileName, Msg]);
      end
      else
        raise ESqliteException.CreateFmt('Failed to open database "%s" : unknown error',
          [FileName]);

  finally
    if Assigned(Msg) then
      SQLite3_Free(Msg);
  end;

end;

constructor TSQLiteDatabase.Create(const DB: TSQLiteDB);
begin
  inherited Create;
  self.fInTrans := False;
  Fdb:=DB;
end;

//..............................................................................

destructor TSQLiteDatabase.Destroy;
begin
  if self.fInTrans then
    self.Rollback;  //assume rollback
  if Assigned(fDB) then
    SQLite3_Close(fDB);
  inherited;
end;

function TSQLiteDatabase.GetLastInsertRowID: int64;
begin
  Result := Sqlite3_LastInsertRowID(self.fDB);
end;

function TSQLiteDatabase.GetLastChangedRows: int64;
begin
  Result := SQLite3_TotalChanges(self.fDB);
end;

//..............................................................................

procedure TSQLiteDatabase.RaiseError(s: string; SQL: string);
//look up last error and raise an exception with an appropriate message
var
  Msg: PAnsiChar;
  ret : integer;
begin

  Msg := nil;

  ret := sqlite3_errcode(self.fDB);
  if ret <> SQLITE_OK then
    Msg := sqlite3_errmsg(self.fDB);

  if Msg <> nil then
    raise ESqliteException.CreateFmt(s +'.'#13'Error [%d]: %s.'#13'"%s": %s', [ret, SQLiteErrorStr(ret),SQL, Msg])
  else
    raise ESqliteException.CreateFmt(s, [SQL, 'No message']);

end;

procedure TSQLiteDatabase.SetSynchronised(Value: boolean);
begin
  if Value <> fSync then
  begin
    if Value then
      ExecSQL('PRAGMA synchronous = ON;')
    else
      ExecSQL('PRAGMA synchronous = OFF;');
    fSync := Value;
  end;
end;


procedure TSQLiteDatabase.ExecSQL(const SQL: Ansistring);
var
  Stmt: TSQLiteStmt;
  NextSQLStatement: PAnsiChar;
  iStepResult: integer;
begin
  try
    if Sqlite3_Prepare_v2(self.fDB, PAnsiChar(SQL), -1, Stmt, NextSQLStatement) <>
      SQLITE_OK then
      RaiseError('Error executing SQL', SQL);
    if (Stmt = nil) then
      RaiseError('Could not prepare SQL statement', SQL);
    DoQuery(SQL);

    iStepResult := Sqlite3_step(Stmt);
    if (iStepResult <> SQLITE_DONE) then
      begin
      SQLite3_reset(stmt);
      RaiseError('Error executing SQL statement', SQL);
      end;
  finally
    if Assigned(Stmt) then
      Sqlite3_Finalize(stmt);
  end;
end;

procedure TSQLiteDatabase.UpdateBlob(const SQL: Ansistring; BlobData: TStream);
var
  iSize: integer;
  ptr: pointer;
  Stmt: TSQLiteStmt;
  Msg: PAnsiChar;
  NextSQLStatement: PAnsiChar;
  iStepResult: integer;
  iBindResult: integer;
begin
  //expects SQL of the form 'UPDATE MYTABLE SET MYFIELD = ? WHERE MYKEY = 1'
  if pos('?', SQL) = 0 then
    RaiseError('SQL must include a ? parameter', SQL);

  Msg := nil;
  try

    if Sqlite3_Prepare_v2(self.fDB, PAnsiChar(SQL), -1, Stmt, NextSQLStatement) <>
      SQLITE_OK then
      RaiseError('Could not prepare SQL statement', SQL);

    if (Stmt = nil) then
      RaiseError('Could not prepare SQL statement', SQL);
    DoQuery(SQL);

    //now bind the blob data
    iSize := BlobData.size;

    GetMem(ptr, iSize);

    if (ptr = nil) then
      raise ESqliteException.CreateFmt('Error getting memory to save blob',
        [SQL, 'Error']);

    BlobData.position := 0;
    BlobData.Read(ptr^, iSize);

    iBindResult := SQLite3_Bind_Blob(stmt, 1, ptr, iSize, @DisposePointer);

    if iBindResult <> SQLITE_OK then
      RaiseError('Error binding blob to database', SQL);

    iStepResult := Sqlite3_step(Stmt);

    if (iStepResult <> SQLITE_DONE) then
      begin
      SQLite3_reset(stmt);
      RaiseError('Error executing SQL statement', SQL);
      end;

  finally

    if Assigned(Stmt) then
      Sqlite3_Finalize(stmt);

    if Assigned(Msg) then
      SQLite3_Free(Msg);
  end;

end;

//..............................................................................

function TSQLiteDatabase.GetTable(const SQL: Ansistring): TSQLiteTable;
begin
  Result := TSQLiteTable.Create(Self, SQL);
end;

procedure TSQLiteDatabase.BeginTransaction;
begin
  if not self.fInTrans then
  begin
    self.ExecSQL('BEGIN TRANSACTION');
    self.fInTrans := True;
  end
  else
    raise ESqliteException.Create('Transaction already open');
end;

procedure TSQLiteDatabase.Commit;
begin
  self.ExecSQL('COMMIT');
  self.fInTrans := False;
end;

procedure TSQLiteDatabase.Rollback;
begin
  self.ExecSQL('ROLLBACK');
  self.fInTrans := False;
end;

function TSQLiteDatabase.TableExists(TableName: string): boolean;
var
  sql: string;
  ds: TSqliteTable;
begin
  //returns true if table exists in the database
  sql := 'select [sql] from sqlite_master where [type] = ''table'' and lower(name) = ''' +
    lowercase(TableName) + ''' ';
  ds := self.GetTable(sql);
  try
    Result := (ds.Count > 0);
  finally
    ds.Free;
  end;
end;

function TSQLiteDatabase.Version: string;
begin
  Result := SQLite3_Version;
end;

procedure TSQLiteDatabase.AddCustomCollate(name: string;
  xCompare: TCollateXCompare);
begin
  sqlite3_create_collation(fdb, PAnsiChar(name), SQLITE_UTF8, nil, xCompare);
end;

procedure TSQLiteDatabase.AddSystemCollate;
begin
  {$IFDEF WIN32}
  sqlite3_create_collation(fdb, 'SYSTEM', SQLITE_UTF16LE, nil, @SystemCollate);
  {$ENDIF}
end;


//database rows that were changed (or inserted or deleted) by the most recent SQL statement
function TSQLiteDatabase.GetRowsChanged: integer;
begin
 Result := SQLite3_Changes(self.fDB);
end;

procedure TSQLiteDatabase.DoQuery(value: string);
begin
  if assigned(OnQuery) then
    OnQuery(Self, Value);
end;

//------------------------------------------------------------------------------
// TSQLiteTable
//------------------------------------------------------------------------------

constructor TSQLiteTable.Create(filehandle: TSQLiteDB; const SQL: Ansistring);
var
  Stmt: TSQLiteStmt;
  NextSQLStatement: PAnsiChar;
  iStepResult: integer;
  ptr: pointer;
  iNumBytes: integer;
  thisBlobValue: TMemoryStream;
  thisStringValue: pstring;
  thisDoubleValue: pDouble;
  thisIntValue: pInt64;
  thisColType: pInteger;
  i: integer;
  DeclaredColType: PAnsiChar;
  ActualColType: integer;
  ptrValue: PAnsiChar;
begin
  inherited create;
  try
    self.fRowCount := 0;
    self.fColCount := 0;
    fhandle:=filehandle;
    //if there are several SQL statements in SQL, NextSQLStatment points to the
    //beginning of the next one. Prepare only prepares the first SQL statement.
    if Sqlite3_Prepare_v2(fhandle, PAnsiChar(SQL), -1, Stmt, NextSQLStatement) <> SQLITE_OK then
      RaiseError('Error executing SQL', SQL);
    if (Stmt = nil) then
      RaiseError('Could not prepare SQL statement', SQL);
    //DB.DoQuery(SQL);

    iStepResult := Sqlite3_step(Stmt);
    while (iStepResult <> SQLITE_DONE) do
    begin
      case iStepResult of
        SQLITE_ROW:
          begin
            Inc(fRowCount);
            if (fRowCount = 1) then
            begin
            //get data types
              fCols := TStringList.Create;
              fColTypes := TList.Create;
              fColCount := SQLite3_ColumnCount(stmt);
              for i := 0 to Pred(fColCount) do
                fCols.Add(AnsiUpperCase(Sqlite3_ColumnName(stmt, i)));
              for i := 0 to Pred(fColCount) do
              begin
                new(thisColType);
                DeclaredColType := Sqlite3_ColumnDeclType(stmt, i);
                if DeclaredColType = nil then
                  thisColType^ := Sqlite3_ColumnType(stmt, i) //use the actual column type instead
                //seems to be needed for last_insert_rowid
                else
                  if (DeclaredColType = 'INTEGER') or (DeclaredColType = 'BOOLEAN') then
                    thisColType^ := dtInt
                  else
                    if (DeclaredColType = 'NUMERIC') or
                      (DeclaredColType = 'FLOAT') or
                      (DeclaredColType = 'DOUBLE') or
                      (DeclaredColType = 'REAL') then
                      thisColType^ := dtNumeric
                    else
                      if DeclaredColType = 'BLOB' then
                        thisColType^ := dtBlob
                      else
                        thisColType^ := dtStr;
                fColTypes.Add(thiscoltype);
              end;
              fResults := TList.Create;
            end;

          //get column values
            for i := 0 to Pred(fColCount) do
            begin
              ActualColType := Sqlite3_ColumnType(stmt, i);
              if (ActualColType = SQLITE_NULL) then
                fResults.Add(nil)
              else
                if pInteger(fColTypes[i])^ = dtInt then
                begin
                  new(thisintvalue);
                  thisintvalue^ := Sqlite3_ColumnInt64(stmt, i);
                  fResults.Add(thisintvalue);
                end
                else
                  if pInteger(fColTypes[i])^ = dtNumeric then
                  begin
                    new(thisdoublevalue);
                    thisdoublevalue^ := Sqlite3_ColumnDouble(stmt, i);
                    fResults.Add(thisdoublevalue);
                  end
                  else
                    if pInteger(fColTypes[i])^ = dtBlob then
                    begin
                      iNumBytes := Sqlite3_ColumnBytes(stmt, i);
                      if iNumBytes = 0 then
                        thisblobvalue := nil
                      else
                      begin
                        thisblobvalue := TMemoryStream.Create;
                        thisblobvalue.position := 0;
                        ptr := Sqlite3_ColumnBlob(stmt, i);
                        thisblobvalue.writebuffer(ptr^, iNumBytes);
                      end;
                      fResults.Add(thisblobvalue);
                    end
                    else
                    begin
                      new(thisstringvalue);
                      ptrValue := Sqlite3_ColumnText(stmt, i);
                      setstring(thisstringvalue^, ptrvalue, strlen(ptrvalue));
                      fResults.Add(thisstringvalue);
                    end;
            end;
          end;
        SQLITE_BUSY:
          raise ESqliteException.CreateFmt('Could not prepare SQL statement',
            [SQL, 'SQLite is Busy']);
      else
        begin
        SQLite3_reset(stmt);
        RaiseError('Could not retrieve data', SQL);
        end;
      end;
      iStepResult := Sqlite3_step(Stmt);
    end;
    fRow := 0;
  finally
    if Assigned(Stmt) then
      Sqlite3_Finalize(stmt);
  end;
end;

//..............................................................................

destructor TSQLiteTable.Destroy;
var
  i: cardinal;
  iColNo: integer;
begin
  if Assigned(fResults) then
  begin
    for i := 0 to fResults.Count - 1 do
    begin
      //check for blob type
      iColNo := (i mod fColCount);
      case pInteger(self.fColTypes[iColNo])^ of
        dtBlob:
          TMemoryStream(fResults[i]).Free;
        dtStr:
          if fResults[i] <> nil then
          begin
            setstring(string(fResults[i]^), nil, 0);
            dispose(fResults[i]);
          end;
      else
        dispose(fResults[i]);
      end;
    end;
    fResults.Free;
  end;
  if Assigned(fCols) then
    fCols.Free;
  if Assigned(fColTypes) then
    for i := 0 to fColTypes.Count - 1 do
      dispose(fColTypes[i]);
  fColTypes.Free;
  inherited;
end;

//..............................................................................

function TSQLiteTable.GetCount: integer;
begin
  Result := FRowCount;
end;

procedure TSQLiteTable.RaiseError(s: string; SQL: string);
//look up last error and raise an exception with an appropriate message
var
  Msg: PAnsiChar;
  ret : integer;
begin

  Msg := nil;

  ret := sqlite3_errcode(fhandle);
  if ret <> SQLITE_OK then
    Msg := sqlite3_errmsg(fhandle);

  if Msg <> nil then
    raise ESqliteException.CreateFmt(s +'.'#13'Error [%d]: %s.'#13'"%s": %s', [ret, SQLiteErrorStr(ret),SQL, Msg])
  else
    raise ESqliteException.CreateFmt(s, [SQL, 'No message']);
end;

//..............................................................................

function TSQLiteTable.GetEOF: boolean;
begin
  Result := fRow >= fRowCount;
end;

function TSQLiteTable.GetBOF: boolean;
begin
  Result := fRow <= 0;
end;

//..............................................................................

function TSQLiteTable.GetFieldIndex(FieldName: string): integer;
begin
  if (fCols = nil) then
  begin
    raise ESqliteException.Create('Field ' + fieldname + ' Not found. Empty dataset');
    exit;
  end;

  if (fCols.count = 0) then
  begin
    raise ESqliteException.Create('Field ' + fieldname + ' Not found. Empty dataset');
    exit;
  end;

  Result := fCols.IndexOf(AnsiUpperCase(FieldName));

  if (result < 0) then
  begin
    raise ESqliteException.Create('Field not found in dataset: ' + fieldname)
  end;
end;

//..............................................................................

function TSQLiteTable.FieldAsBlob(FieldName: string): TMemoryStream;
var
 i: cardinal;
begin
  i:=GetFieldIndex(FieldName);

  if EOF then
    raise ESqliteException.Create('Table is at End of File');
  if (self.fResults[(self.frow * self.fColCount) + I] = nil) then
    Result := nil
  else
    if pInteger(self.fColTypes[I])^ = dtBlob then
      Result := TMemoryStream(self.fResults[(self.frow * self.fColCount) + I])
    else
      raise ESqliteException.Create('Not a Blob field');
end;

function TSQLiteTable.FieldAsBlobText(FieldName: string): string;
var
  MemStream: TMemoryStream;
  Buffer: PAnsiChar;
begin
  Result := '';
  MemStream := self.FieldAsBlob(FieldName);
  if MemStream <> nil then
    if MemStream.Size > 0 then
      begin
        MemStream.position := 0;
        {$IFDEF UNICODE}
        Buffer := AnsiStralloc(MemStream.Size + 1);
        {$ELSE}
        Buffer := Stralloc(MemStream.Size + 1);
        {$ENDIF}
        MemStream.readbuffer(Buffer[0], MemStream.Size);
        (Buffer + MemStream.Size)^ := chr(0);
        SetString(Result, Buffer, MemStream.size);
        strdispose(Buffer);
      end;
     //do not free the TMemoryStream here; it is freed when
     //TSqliteTable is destroyed

end;

function TSQLiteTable.GetFields(FieldName: string): string;
var
  thisvalue: pstring;
  thistype: integer;
  i: cardinal;
begin
  i:=GetFieldIndex(FieldName);
  Result := '';
  if EOF then
    raise ESqliteException.Create('Table is at End of File');
  //integer types are not stored in the resultset
  //as strings, so they should be retrieved using the type-specific
  //methods
  thistype := pInteger(self.fColTypes[I])^;

  case thistype of
    dtStr:
      begin
        thisvalue := self.fResults[(self.frow * self.fColCount) + I];
        if (thisvalue <> nil) then
          Result := thisvalue^
        else
          Result := '';
      end;
    dtInt:
      Result := IntToStr(self.FieldAsInteger(FieldName));
    dtNumeric:
      Result := FloatToStr(self.FieldAsDouble(FieldName));
    dtBlob:
      Result := self.FieldAsBlobText(FieldName);
  else
    Result := '';
  end;
end;


function TSQLiteTable.FieldAsInteger(FieldName: string): int64;
var
 i: cardinal;
begin
  i:=GetFieldIndex(FieldName);

  if EOF then
    raise ESqliteException.Create('Table is at End of File');
  if (self.fResults[(self.frow * self.fColCount) + I] = nil) then
    Result := 0
  else
    if pInteger(self.fColTypes[I])^ = dtInt then
      Result := pInt64(self.fResults[(self.frow * self.fColCount) + I])^
    else
      if pInteger(self.fColTypes[I])^ = dtNumeric then
        Result := trunc(strtofloat(pString(self.fResults[(self.frow * self.fColCount) + I])^))
      else
        raise ESqliteException.Create('Not an integer or numeric field');
end;

function TSQLiteTable.FieldAsDouble(FieldName: string): double;
var
 i: cardinal;
begin
  i:=GetFieldIndex(FieldName);

  if EOF then
    raise ESqliteException.Create('Table is at End of File');
  if (self.fResults[(self.frow * self.fColCount) + I] = nil) then
    Result := 0
  else
    if pInteger(self.fColTypes[I])^ = dtInt then
      Result := pInt64(self.fResults[(self.frow * self.fColCount) + I])^
    else
      if pInteger(self.fColTypes[I])^ = dtNumeric then
        Result := pDouble(self.fResults[(self.frow * self.fColCount) + I])^
      else
        raise ESqliteException.Create('Not an integer or numeric field');
end;

function TSQLiteTable.FieldAsString(FieldName: string): string;
var
 i: cardinal;
begin
  i:=GetFieldIndex(FieldName);

  if EOF then
    raise ESqliteException.Create('Table is at End of File');
  if (self.fResults[(self.frow * self.fColCount) + I] = nil) then
    Result := ''
  else
   // Result := UTF8Encode(self.GetFields(FieldName));
   Result := self.GetFields(FieldName);
end;


function TSQLiteTable.FieldAsDateTime(FieldName: string): TDateTime;
begin
 result:=UnixTimeToDateTime(StrToInt(FieldAsString(FieldName)));
end;

function TSQLiteTable.FieldIsNull(FieldName: string): boolean;
var
  thisvalue: pointer;
  i: cardinal;
begin
  i:=GetFieldIndex(FieldName);
  if EOF then
    raise ESqliteException.Create('Table is at End of File');
  thisvalue := self.fResults[(self.frow * self.fColCount) + I];
  Result := (thisvalue = nil);
end;

//..............................................................................

function TSQLiteTable.Next: boolean;
begin
  Result := False;
  if not EOF then
  begin
    Inc(fRow);
    Result := True;
  end;
end;

function TSQLiteTable.Previous: boolean;
begin
  Result := False;
  if not BOF then
  begin
    Dec(fRow);
    Result := True;
  end;
end;

function TSQLiteTable.First: boolean;
begin
  Result := False;
  if self.fRowCount > 0 then
  begin
    fRow := 0;
    Result := True;
  end;
end;

function TSQLiteTable.Last: boolean;
begin
  Result := False;
  if self.fRowCount > 0 then
  begin
    fRow := fRowCount - 1;
    Result := True;
  end;
end;

{$WARNINGS OFF}
function TSQLiteTable.MoveTo(position: cardinal): boolean;
begin
  Result := False;
  if (self.fRowCount > 0) and (self.fRowCount > position) then
  begin
    fRow := position;
    Result := True;
  end;
end;
{$WARNINGS ON}


end.

