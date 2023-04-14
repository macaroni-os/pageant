unit ucustompackagemanager;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson;


type

  { TPackageItemData }

  TPackageItemData = record
    PackageName: string;
    Category: string;
    Version: string;
    License: string;
    Repository: string;
    // Action: string;
    // Architecture: string;
    Installedsize: Int64;
    DownloadSize: Int64;
  end;

  PPackageItemData = ^TPackageItemData;

  TPackageList= array of TPackageItemData;

  TSearchMode = (smSearchByName, smMatchName, smMatchCatetoryAndName);


  { TCustomPackageManager }

  TCustomPackageManager = class
  private
    FIsSearchInstalled: boolean;
    FSearchMode: TSearchMode;
    FSudoPassword: string;
    function GetIsRunningAsSudo: boolean;
{$IFDEF DEBUG_INCLUDE_TEST}
  public // test
    class function Test_Search(const ASearchVal: string): string; virtual;
    class function Test_CheckUpdates(var UpdateItems: TPackageList; out AOutput: string): Int64; virtual;
    class function Test_CheckUpdates_PreviewCommand: string; virtual;
{$ENDIF}
  public
    function GetWrappedCommand(const ASearchVal: string; const IsPreview: boolean = False): string;
    function Search(const ASearchVal: string): string; virtual;

    constructor Create; virtual;

  public
    property IsRunningAsSudo: boolean read GetIsRunningAsSudo;
    property SudoPassword: string read FSudoPassword write FSudoPassword;
    property IsSearchInstalled: boolean read FIsSearchInstalled write FIsSearchInstalled;
    property SearchMode: TSearchMode read FSearchMode write FSearchMode;
  end;


implementation

uses process, jsonparser, BaseUnix;


const
  C_PMS = 'luet';
  C_PMS_OPT_SEARCH = 'search';
  C_PMS_OPT_JSON = '-o';
  C_PMS_VAL_JSON = 'json';
  C_PMS_OPT_INSTALLED = '--installed';
  C_PMS_OPT_SEARCHMODE_NAME = '-n';
  C_PMS_OPT_SEARCHMODE_CATN = '-p';


{ TCustomPackageManager }

function TCustomPackageManager.GetIsRunningAsSudo: boolean;
begin

  result := baseunix.fpgeteuid = 0;

end;

{$IFDEF DEBUG_INCLUDE_TEST}
class function TCustomPackageManager.Test_Search(const ASearchVal: string): string;
var s, sCmd: string;
begin
  result := '';
  // luet Test_Search --installed -o json
  // sCmd:='luet';
  // process.RunCommandIndir('/', sCmd, ['search', '--installed', '-o', 'json'], sOut, [poWaitOnExit]);

  // sshpass -p "granbasso" sudo luet Test_Search --installed -o json binutils
  sCmd:='sshpass';
  // process.RunCommandIndir('/', sCmd, ['-p', 'granbasso', 'sudo', 'luet', 'search', '--installed', '-o', 'json', trim(ASearchVal)], result, [poWaitOnExit]);
  process.RunCommandIndir('/', sCmd, ['-p', 'granbasso', 'sudo', 'luet', 'search', '-o', 'json', trim(ASearchVal)], result, [poWaitOnExit]);


end;


class function TCustomPackageManager.Test_CheckUpdates(var UpdateItems: TPackageList; out AOutput: string): Int64;
var s, sCmd, sOut: string;
    sl: TStringList;
    a: TStringArray;
    item: ^TPackageItemData;
    index: integer;
    ja: TJsonArray;
    jo, ji: TJSONObject;
    je: TJSONEnum;
begin
  result :=0;
  // luet Test_Search --installed -o json
  // sCmd:='luet';
  // process.RunCommandIndir('/', sCmd, ['search', '--installed', '-o', 'json'], sOut, [poWaitOnExit]);

  // sshpass -p "granbasso" sudo luet Test_Search --installed -o json binutils
  sCmd:='sshpass';
  process.RunCommandIndir('/', sCmd, ['-p', 'granbasso', 'sudo', 'luet', 'search', '--installed', '-o', 'json', 'binutils'], sOut, [poWaitOnExit]);

  jo := GetJSON(sOut) as TJSONObject;
  try
    if jo.Find('stones', ja) then begin
       AOutput:='Packages: ' + ja.Count.ToString;
       SetLength(UpdateItems, ja.Count);

       index:=-1;
       for je in ja do begin
           // if Trim(s) <> '' then begin
              inc(index);
              ji:=je.Value as TJSONObject;
              item:=@UpdateItems[index];
              try
                s:=ji.Strings['name'];
                item^.PackageName       :=s;

                s:=ji.Strings['category'];
                item^.Category      :=s;


                s:=ji.Strings['version'];
                item^.Version      :=s;

                s:=ji.Strings['license'];
                item^.License       :=s;


                s:=ji.Strings['repository'];
                item^.Repository        :=s;

                try item^.Installedsize :=0; except item^.Installedsize := 0; end;
                try item^.DownloadSize  :=0; except item^.DownloadSize  := 0; end;
                result+=item^.DownloadSize;
              except
                on e: exception do begin
                   AOutput+=Format('ERROR: %s', [e.Message]);
                end;
              end;
           // end;
       end;


    end;
  finally
    jo.Free;
  end;

end;

class function TCustomPackageManager.Test_CheckUpdates_PreviewCommand: string;
begin
  result := 'luet search --installed -o json';
end;

{$ENDIF}

function TCustomPackageManager.GetWrappedCommand(const ASearchVal: string;
  const IsPreview: boolean): string;
begin
  // luet Test_Search --installed -o json
  // sCmd:='luet';
  // process.RunCommandIndir('/', sCmd, ['search', '--installed', '-o', 'json'], sOut, [poWaitOnExit]);

  result := C_PMS + ' ' + C_PMS_OPT_SEARCH + ' ' + C_PMS_OPT_JSON + ' ' + C_PMS_VAL_JSON;

  case SearchMode of
     smSearchByName        : begin end;
     smMatchName           : result += ' ' + C_PMS_OPT_SEARCHMODE_NAME;
     smMatchCatetoryAndName: result += ' ' + C_PMS_OPT_SEARCHMODE_CATN;
  end;

  result += ' ' + trim(ASearchVal);

  if IsSearchInstalled then
     result += ' ' + C_PMS_OPT_INSTALLED;




  if not IsPreview then
     if not IsRunningAsSudo then begin
        if SudoPassword = '' then
           raise Exception.Create('Unable to execute without sudo password!');

        result := 'sshpass -p ' + SudoPassword + ' ' + result;
     end;

end;

function TCustomPackageManager.Search(const ASearchVal: string): string;
var s: string;
begin
  result := '';

  s := GetWrappedCommand(ASearchVal);

  // TODO: use not deprecated
  process.RunCommandIndir('/', s, result)

end;

constructor TCustomPackageManager.Create;
begin
  inherited Create;

  FIsSearchInstalled:=False;
  FSudoPassword:='';
  SearchMode:= smSearchByName;
end;


end.

