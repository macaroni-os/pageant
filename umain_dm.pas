unit umain_dm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, AvgLvlTree;

type

  { TdmMain }

  TdmMain = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FPkgFiles: TStringToStringTree;
  public

    function GetPackageContent_Files(const APackageName: string): string;

  end;

var
  dmMain: TdmMain;

implementation

{$R *.lfm}

uses ucustompackagemanager, fpjson;

{ TdmMain }

procedure TdmMain.DataModuleCreate(Sender: TObject);
begin
  FPkgFiles:=TStringToStringTree.Create(false);
end;

procedure TdmMain.DataModuleDestroy(Sender: TObject);
begin
  FreeAndNil(FPkgFiles);
end;

function TdmMain.GetPackageContent_Files(const APackageName: string): string;
var ja: TJSONArray;
    je: TJSONEnum;
    sl: TStringList;
    s: string;
begin
  result :='';

  sl:=TStringList.Create;
  ja:=nil;
  try

    result := FPkgFiles[APackageName];

    if result = '' then begin

      ja := TCustomPackageManager.GetPackageContent(APackageName);
      for je in ja do begin
         try
            s:=(je.Value as TJSONString).AsString;
            sl.Add(s);
         except
            on e: exception do
               Writeln(e.Message);
         end;
      end;

      if sl.Count = 0 then
         sl.Add('no file detected');


      FPkgFiles[APackageName]:=sl.Text;
      result := FPkgFiles[APackageName];

    end; // if

  finally
     // free resources
     FreeAndNil(ja);
     FreeAndNil(sl);
  end;
end;

(*

initialization
  dmMain:=TdmMain.Create(Application);

finalization
  FreeAndNil(dmMain);
*)

end.

