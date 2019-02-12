unit progress;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { Tfrmprogress }

  Tfrmprogress = class(TForm)
    lblMessage: TLabel;
  private
    FmaintextMessage: string;
    procedure SetmaintextMessage(AValue: string);
    procedure SettextMessage(AValue: string);

  public
    procedure ProcessMessages;
    property maintextMessage:string read FmaintextMessage write SetmaintextMessage;
    property textMessage:string write SettextMessage;

  end;

var
  frmprogress: Tfrmprogress;

implementation

{$R *.lfm}

{ Tfrmprogress }

procedure Tfrmprogress.SetmaintextMessage(AValue: string);
begin
  if FmaintextMessage=AValue then exit;
  FmaintextMessage:=AValue;
end;

procedure Tfrmprogress.SettextMessage(AValue: string);
begin
  lblMessage.Caption:=FmaintextMessage+AValue;
end;

procedure Tfrmprogress.ProcessMessages;
begin
  //sleep(200);
   application.ProcessMessages;
end;

end.

