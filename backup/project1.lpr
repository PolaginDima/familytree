program mytree;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, datetimectrls, startmodul, workdb, mySQLite3Conn, SQLiteTable3, SQLite3,
  unitNode, CreateTree, UnitNodeFromBD, startpos, mygraph;

{$R *.res}

begin
  Application.Title:='mytree';
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  //Application.CreateForm(Tfrmprogress, frmprogress);
 // Application.CreateForm(TfrmNodeFromBD, frmNodeFromBD);
  //Application.CreateForm(Tfrmstartpos, frmstartpos);
  //Application.CreateForm(TfrmNode, frmNode);
  Application.Run;
end.

