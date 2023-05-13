unit utypes;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, jsonscanner;


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

TSearchMode = (smSearchByName, smMatchName, smMatchCatetoryAndName, smMatchLabels);



{ TRepositoryItemData }

TRepositoryItemData = record
  Status: string;
  RepositoryName: string;
  Description: string;
  Revision: string;
  Date: string;
  Priority: string;
  RepoType: string;
  Urls: string;
end;

PRepositoryItemData = ^TRepositoryItemData;

TRepositoryList= array of TRepositoryItemData;

TRepositorySearchMode = (rsmAll, rsmEnabled, rsmDisabled);



{ TSystemInfo }

TSystemInfo = record
  HostName: string;
  KernelName: string
end;


{ PackageDetailOptions }

TPackageDetailOptions = record // Class(TObject)
  FOptions : TJSONOptions;
  FQuoteStrings,
  FSortObjectMembers,
  FCompact,
  FNewObject,
  FSaveFormatted: Boolean;
end;



implementation

end.

