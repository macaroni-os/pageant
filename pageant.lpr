program pageant;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, umain, ucustompackagemanager, upackagedetails_fm, utypes, uutils,
umain_dm, uabout_fm;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TdmMain, dmMain);
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.

