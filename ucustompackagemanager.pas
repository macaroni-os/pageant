unit ucustompackagemanager;

{$mode objfpc}{$H+}
{$WARN 5043 off : Symbol "$1" is deprecated}
interface

uses
  Classes, SysUtils, fpjson, utypes;


type

  { TCustomPackageManager }

  TCustomPackageManager = class
  private
    FIsSearchInstalled: boolean;
    FSearchMode: TSearchMode;
  public
    class function IsRunningAsSudo: boolean;
    class function GetSystemInfo: TSystemInfo; virtual;
    class function GetPackageContent(const APackageName: string): TJsonArray; virtual;

  public
    function GetWrappedCommand(const ASearchVal: string; const IsPreview: boolean = False): string;
    function Search(const ASearchVal: string): string; virtual;

    constructor Create; virtual;

  public
    property IsSearchInstalled: boolean read FIsSearchInstalled write FIsSearchInstalled;
    property SearchMode: TSearchMode read FSearchMode write FSearchMode;
  end;


implementation

uses process, jsonparser, BaseUnix, StrUtils;


const
  C_PMS = 'luet';
  C_PMS_OPT_SEARCH = 'search';
  C_PMS_OPT_QUERY = 'q';
  C_PMS_OPT_QUERY_FILES = 'files';
  C_PMS_OPT_JSON = '-o';
  C_PMS_VAL_JSON = 'json';
  C_PMS_OPT_INSTALLED = '--installed';
  C_PMS_OPT_SEARCHMODE_NAME = '-n';
  C_PMS_OPT_SEARCHMODE_CATN = '-p';


{ TCustomPackageManager }

class function TCustomPackageManager.IsRunningAsSudo: boolean;
begin

  result := baseunix.fpgeteuid = 0;

end;


class function TCustomPackageManager.GetSystemInfo: TSystemInfo;
var s: string;
begin
  result.HostName:='';
  result.KernelName:='';

  try
    process.RunCommandInDir('/', 'uname', ['-nr'], s);
    result.HostName:=ExtractWord(1, s, [' ']);
    result.KernelName:=ExtractWord(2, s, [' ']);

  except
    on e: exception do
       result.HostName:=e.Message;
  end;
end;

class function TCustomPackageManager.GetPackageContent(const APackageName: string): TJsonArray;
var s: string;
begin
  // luet q files package-name -o json
  try
    process.RunCommandInDir('/', C_PMS, [C_PMS_OPT_QUERY, C_PMS_OPT_QUERY_FILES, APackageName, C_PMS_OPT_JSON, C_PMS_VAL_JSON], s);
    result := GetJSON(s) as TJSONArray;
  except
    on e: exception do
       result := GetJSON('[]') as TJSONArray;
  end;
end;


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
  SearchMode:= smSearchByName;
end;


end.

