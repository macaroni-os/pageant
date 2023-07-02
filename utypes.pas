unit utypes;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, jsonscanner, fgl;


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

  Description: string;
  Uri: string;
  Sha256: string;
end;

PPackageItemData = ^TPackageItemData;

TPackageList= array of TPackageItemData;

TSearchMode = (smSearchByName, smMatchName, smMatchCatetoryAndName, smMatchLabels);

TPkgInstalled = specialize TFPGMap<string, TPackageItemData>;

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

TArrayOfString = array of string;

TCommandLineDef = record
  CurDir: string;
  Cmd: string;
  Params: TArrayOfString
end;


{ TKerListItemData }

// |  KERNEL  | KERNEL VERSION |  TYPE   | HAS INITRD | HAS KERNEL IMAGE | HAS BZIMAGE,INITRD LINKS |
// |----------|----------------|---------|------------|------------------|--------------------------|
// | macaroni | 6.1.18         | vanilla | true       | true             | false                    |

TKerListItemData = record
  Kernel: string;
  Version: string;
  KerType: string;
  HasInitRd: boolean;
  InitRdFileName: string;
  HasKernelImage: boolean;
  KernelFileName: string;
  HasBzImageImage: boolean;
end;

PKerListItemData = ^TKerListItemData;

TKerListList= array of TKerListItemData;


{ TKerAvailItemData }

// |  KERNEL  | KERNEL VERSION | PACKAGE VERSION |    EOL    |  LTS  |  RELEASED  |  TYPE   |
// |----------|----------------|-----------------|-----------|-------|------------|---------|
// | macaroni | 4.14.309       | 4.14.309        | Jan, 2024 | true  | 2017-11-12 | vanilla |

TKerAvailItemData = record
  Name: string;
  Category: string;
  Version: string;
  Repository: string;
  EOL: string;
  IsLTS: boolean;
  Released: string;
  KerType: string;
end;

PKerAvailItemData = ^TKerAvailItemData;

TKerAvailList= array of TKerAvailItemData;


{ TKerProfileItemData }

// |   NAME   | KERNEL PREFIX | INITRD PREFIX |  SUFFIX  |   TYPE    | WITH ARCH |
// |----------|---------------|---------------|----------|-----------|-----------|
// | Sabayon  | kernel        | initramfs     | sabayon  | genkernel | true      |
// | Macaroni | kernel        | initramfs     | macaroni | vanilla   | true      |

TKerProfileItemData = record
  Name: string;
  Suffix: string;
  ProfileType: string;
  WithArch: boolean;
end;

PKerProfileItemData = ^TKerProfileItemData;

TKerProfileList= array of TKerProfileItemData;


{ TSystemInfo }

TSystemInfo = record
  HostName: string;
  KernelName: string
end;


{ PackageDetailOptions }

TPackageDetailOptions = record
  FOptions : TJSONOptions;
  FQuoteStrings,
  FSortObjectMembers,
  FCompact,
  FNewObject,
  FSaveFormatted: Boolean;
end;


function ArrayOfStringToString(const AArray: TArrayOfString): string;


implementation

function ArrayOfStringToString(const AArray: TArrayOfString): string;
var s: string;
begin
  result := '';
  for s in AArray do begin
      if result <> '' then
         result += ' ';
      result += s
  end;
end;

end.

