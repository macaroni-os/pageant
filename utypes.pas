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

