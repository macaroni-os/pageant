program pageant;

{$mode objfpc}{$H+}

{$DEFINE UseCThreads}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  LazUTF8,
  Interfaces, // this includes the LCL widgetset
  Forms, umain, // ucustompackagemanager, upackagedetails_fm, utypes, uutils,
  umain_dm;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TdmMain, dmMain);
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.

