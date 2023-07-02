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
    FUseArtifacts: boolean;
  public
    class function IsRunningAsSudo: boolean;
    class function GetSystemInfo: TSystemInfo; virtual;
    class function GetPackageContent(const APackageName: string): TJsonArray; virtual;
    class function GetKernelList: TJsonObject; virtual;
    class function GetKernelAvailable: TJsonObject; virtual;
    class function GetKernelProfiles: TJsonArray; virtual;
  public
    function GetWrappedCommand(const ASearchVal: string; const IsPreview: boolean = False): string;
    function GetWrappedRepoCommand(const ASearchType: TRepositorySearchMode): string;
    class function GetWrappedKerListCommand(const GetAsJson: boolean = False): TCommandLineDef;
    class function GetWrappedKerAvailCommand(const GetAsJson: boolean = False): TCommandLineDef;
    class function GetWrappedKerProfileCommand(const GetAsJson: boolean = False): TCommandLineDef;

    function Search(const ASearchVal: string): string; virtual;
    function SearchRepositories(const ASearchType: TRepositorySearchMode): string; virtual;


    constructor Create; virtual;

  public
    property IsSearchInstalled: boolean read FIsSearchInstalled write FIsSearchInstalled;
    property SearchMode: TSearchMode read FSearchMode write FSearchMode;
    property UseArtifacts: boolean read FUseArtifacts write FUseArtifacts;
  end;


implementation

uses process, jsonparser, BaseUnix, StrUtils, LazUTF8;


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
  C_PMS_OPT_ARTIFACTS = '--artifacts';

  C_PMS_OPT_REPOSEARCH = 'repo list';
  C_PMS_OPT_REPOSEARCH_OPT_ENABLED = '--enabled';
  C_PMS_OPT_REPOSEARCH_OPT_DISABLEDENABLED = '--disabled';
  C_PMS_OPT_REPOSEARCH_OPT_URLS = '--urls';

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

class function TCustomPackageManager.GetKernelList: TJsonObject;
var s: string;
    cmd: TCommandLineDef;
begin
  try
    cmd:=GetWrappedKerListCommand(True);
    process.RunCommandInDir(cmd.CurDir, cmd.Cmd, cmd.Params, s);
    result := GetJSON(s) as TJsonObject;
  except
    on e: exception do
       result := GetJSON('{}') as TJsonObject;
  end;
end;

class function TCustomPackageManager.GetKernelAvailable: TJsonObject;
var s: string;
    cmd: TCommandLineDef;
begin
  try
    cmd:=GetWrappedKerAvailCommand(True);
    process.RunCommandInDir(cmd.CurDir, cmd.Cmd, cmd.Params, s);
    result := GetJSON(s) as TJsonObject;
  except
    on e: exception do
       result := GetJSON('{}') as TJsonObject;
  end;
end;

class function TCustomPackageManager.GetKernelProfiles: TJsonArray;
var s: string;
    cmd: TCommandLineDef;
begin
  try
    cmd:=GetWrappedKerProfileCommand(True);
    process.RunCommandInDir(cmd.CurDir, cmd.Cmd, cmd.Params, s);
    result := GetJSON(s) as TJsonArray;
  except
    on e: exception do
       result := GetJSON('[]') as TJsonArray;
  end;
end;


function TCustomPackageManager.GetWrappedCommand(const ASearchVal: string; const IsPreview: boolean): string;
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

  if UseArtifacts then
     result += ' ' + C_PMS_OPT_ARTIFACTS;

end;

function TCustomPackageManager.Search(const ASearchVal: string): string;
var s: string;
begin
  result := '';

  s := GetWrappedCommand(ASearchVal);

  // TODO: use not deprecated
  process.RunCommandIndir('/', s, result)

end;

function TCustomPackageManager.SearchRepositories(const ASearchType: TRepositorySearchMode): string;
var s, sok: string;
    sl: TStringList;
    i: integer;
begin
  result := '';

  s := GetWrappedRepoCommand(ASearchType);
  // s := 'luet repo list --enabled';

  // TODO: use not deprecated
  process.RunCommandIndir('/', s, sok);

  // normalize output
  // TODO: PARSER / BEAUTIFYER
  sl:=TStringList.Create;
  try
    sl.Text:=sok;
    for i:=0 to sl.Count -1 do begin
        s:=sl[i];
        if s[1] <> #32 then begin
           s:=s.Replace(#27'[1;92m', 'enabled ', [])
               .Replace(#27'[1;91m', 'disabled ', []);
           sl[i]:=s;
        end;
    end;

    // remove escape chars
    s:=sl.Text;
    s:=s.Replace(#27, '', [rfReplaceAll])
        .Replace('[0m', '', [rfReplaceAll])
        .Replace('[33m', '', [rfReplaceAll])
        .Replace('[1;31m', '', [rfReplaceAll])
        .Replace('[1;32m', '', [rfReplaceAll])
        .Replace('[1;33m', '', [rfReplaceAll])
        .Replace('[1;34m', '', [rfReplaceAll])
        .Replace('[1;35m', '', [rfReplaceAll]);

  finally
    sl.Free;
  end;

  result := s;

end;


function TCustomPackageManager.GetWrappedRepoCommand(const ASearchType: TRepositorySearchMode): string;
begin
  // echo "<enabled>" && luet repo list --enabled && echo "<disabled>" && luet repo list --disabled
  // process.RunCommandIndir('/', sCmd, ['search', '--installed', '-o', 'json'], sOut, [poWaitOnExit]);


  case ASearchType of
     rsmEnabled  : result := C_PMS + ' ' + C_PMS_OPT_REPOSEARCH + ' ' + C_PMS_OPT_REPOSEARCH_OPT_ENABLED;
     rsmDisabled : result := C_PMS + ' ' + C_PMS_OPT_REPOSEARCH + ' ' + C_PMS_OPT_REPOSEARCH_OPT_DISABLEDENABLED;
  else
     result := C_PMS + ' ' + C_PMS_OPT_REPOSEARCH;
  end;

  result += ' ' + C_PMS_OPT_REPOSEARCH_OPT_URLS;

end;

class function TCustomPackageManager.GetWrappedKerListCommand(const GetAsJson: boolean): TCommandLineDef;
var l: integer;
begin
  result.CurDir := '/';
  Result.Cmd    := 'macaronictl';
  Result.Params := ['kernel', 'list'];

  if GetAsJson then begin
     l:=Length(Result.Params);
     SetLength(Result.Params, l+1);
     Result.Params[l] := '--json';
  end;
end;

class function TCustomPackageManager.GetWrappedKerAvailCommand(const GetAsJson: boolean): TCommandLineDef;
var l: integer;
begin
  result.CurDir := '/';
  Result.Cmd    := 'macaronictl';
  Result.Params := ['kernel', 'available'];

  if GetAsJson then begin
     l:=Length(Result.Params);
     SetLength(Result.Params, l+1);
     Result.Params[l] := '--json';
  end;
end;

class function TCustomPackageManager.GetWrappedKerProfileCommand(const GetAsJson: boolean): TCommandLineDef;
var l: integer;
begin
  result.CurDir := '/';
  Result.Cmd    := 'macaronictl';
  Result.Params := ['kernel', 'profiles'];

  if GetAsJson then begin
     l:=Length(Result.Params);
     SetLength(Result.Params, l+1);
     Result.Params[l] := '--json';
  end;
end;


constructor TCustomPackageManager.Create;
begin
  inherited Create;

  FIsSearchInstalled:=False;
  SearchMode:= smSearchByName;
  FUseArtifacts:=False;
end;


end.

