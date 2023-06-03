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

  if ParamCount > 0 then
     if LowerCase(ParamStr(1)) = '--version' then begin
        Writeln( FileVerInfo.VersionStrings.Values['InternalName'] +
                 ' Version: ' +
                 FileVerInfo.VersionStrings.Values['ProductVersion']
        );
        exit;
     end;

  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TdmMain, dmMain);
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.

