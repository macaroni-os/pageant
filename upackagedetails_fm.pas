unit upackagedetails_fm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  ExtCtrls, Buttons, ActnList, VirtualTrees, SynEdit, SynHighlighterJScript,
  fpjson
  , utypes
  , uutils
  ;


const
   KEYVAL_SEPARATOR = ':';

type

  { TfmPackageDetails }

  TfmPackageDetails = class(TForm)
    acDetCopyValue: TAction;
    DetailAction: TActionList;
    edDraft: TSynEdit;
    Label1: TLabel;
    lbPackageName: TLabel;
    lboxFiles: TListBox;
    PageControl1: TPageControl;
    pnValue: TPanel;
    pnValueTitle: TPanel;
    pnTop: TPanel;
    SpeedButton1: TSpeedButton;
    lbValueTitle: TStaticText;
    edValueValue: TSynEdit;
    Splitter1: TSplitter;
    StatusBar1: TStatusBar;
    SynJScriptSyn1: TSynJScriptSyn;
    tsContent: TTabSheet;
    tvDet: TTreeView;
    tsJson: TTabSheet;
    tsRaw: TTabSheet;

    procedure acDetCopyValueExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tsContentShow(Sender: TObject);
    procedure tvDetChanging(Sender: TObject; Node: TTreeNode;
      var AllowChange: Boolean);
    procedure tvDetExit(Sender: TObject);
  private
    FBeautifyer: TPropertyBeautifyer;
    FOptions: TPackageDetailOptions;
    FPackageDetails: TJsonObject;
    FShowPanelValue: boolean;
    function GetTitle: string;
    procedure SetPackageDetails(AValue: TJsonObject);
    procedure SetPanelValueTitle(AValue: string);
    procedure SetPanelValueValue(AValue: string);
    procedure SetShowPanelValue(AValue: boolean);
    procedure SetTitle(AValue: string);
    procedure ShowJSONData(AParent: TTreeNode; Data: TJSONData);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure ShowJson(const ARoot: TJsonObject);
    procedure LoadPackageContent;

  public
    property PackageDetails: TJsonObject read FPackageDetails write SetPackageDetails;
    property Options: TPackageDetailOptions read FOptions;
    property ShowPanelValue: boolean read FShowPanelValue write SetShowPanelValue;
    property PanelValueTitle: string write SetPanelValueTitle;
    property PanelValueValue: string write SetPanelValueValue;
    property Beautifyer: TPropertyBeautifyer read FBeautifyer write FBeautifyer;

    property Title: string read GetTitle write SetTitle;
  end;


implementation

{$R *.lfm}

uses umain_dm, Clipbrd;


{ TfmPackageDetails }

procedure TfmPackageDetails.acDetCopyValueExecute(Sender: TObject);
begin
  Clipboard.AsText:=edValueValue.Text;
end;

procedure TfmPackageDetails.FormCreate(Sender: TObject);
begin
  PageControl1.ActivePageIndex:=0;
end;



procedure TfmPackageDetails.tsContentShow(Sender: TObject);
begin
  LoadPackageContent;
end;



procedure TfmPackageDetails.tvDetChanging(Sender: TObject; Node: TTreeNode;
  var AllowChange: Boolean);
var sKey, sVal: string;
    p: integer;
begin
  ShowPanelValue:=False;
  sKey:=Node.Text;
  p:=pos(KEYVAL_SEPARATOR, sKey);
  if p>0 then begin
     sVal:=copy(sKey, p+1, length(sKey));
     sKey:=copy(sKey,1,p-1);
     PanelValueTitle:=sKey;
     PanelValueValue:=sVal;
     ShowPanelValue:=True;
  end;
end;

procedure TfmPackageDetails.tvDetExit(Sender: TObject);
begin
end;


procedure TfmPackageDetails.SetPackageDetails(AValue: TJsonObject);
begin
  if FPackageDetails=AValue then Exit;
  FPackageDetails:=AValue;

  ShowJson(FPackageDetails);
  // set raw data
  edDraft.Text:=FPackageDetails.FormatJSON(DefaultFormat, 3);

end;

function TfmPackageDetails.GetTitle: string;
begin
  result := lbPackageName.Caption;
end;



procedure TfmPackageDetails.SetPanelValueTitle(AValue: string);
begin
  lbValueTitle.Caption:=AValue;
end;

procedure TfmPackageDetails.SetPanelValueValue(AValue: string);
begin
  edValueValue.Text:=Trim(AValue);

  // experimental: space = new line... :)
  // edValueValue.Clear;

  // ExtractStrings([' '], [], PChar(AValue.Replace(')', ')'+LineEnding, [rfReplaceAll])), edValueValue.Lines);
  {
  with TPropertyBeautifyer.Create(AValue) do
    try
      edValueValue.Text:=Parse;
    finally
      Free;
    end;
  }
end;

procedure TfmPackageDetails.SetShowPanelValue(AValue: boolean);
begin
  FShowPanelValue:=AValue;

  pnValue.Visible:=AValue;
end;

procedure TfmPackageDetails.SetTitle(AValue: string);
begin
  lbPackageName.Caption := AValue;
end;

procedure TfmPackageDetails.ShowJSONData(AParent: TTreeNode; Data: TJSONData);
const TITLE_Array   = '[%d]';
      TITLE_Object  = '{%d}';
      TITLE_Null    = 'null';
Var
  N,N2 : TTreeNode;
  iApp : Integer;
  jd : TJSONData;
  s : String;
  sl : TStringList;
begin
  if Not Assigned(Data) then
     exit;
  if Options.FCompact and (AParent<>Nil) then
     N:=AParent
  else
     N:=tvDet.Items.AddChild(AParent,'');

  case Data.JSONType of
    jtArray,
    jtObject: begin
        If (Data.JSONType=jtArray) then
          s:=TITLE_Array
        else
          s:=TITLE_Object;

        s:=Format(s,[Data.Count]);
        sl:=TstringList.Create;
        try
           for iApp:=0 to Data.Count-1 do begin
               if Data.JSONtype=jtArray then
                  sl.AddObject(IntToStr(iApp),Data.items[iApp])
               else
                  sl.AddObject(TJSONObject(Data).Names[iApp],Data.items[iApp]);
           end;
           if Options.FSortObjectMembers and (Data.JSONType=jtObject) then
              sl.Sort;
           for iApp:=0 to sl.Count-1 do begin
               N2:=tvDet.Items.AddChild(N,sl[iApp]);
               jd:=TJSONData(sl.Objects[iApp]);
               ShowJSONData(N2,jd);
           end
        finally
          sl.Free;
        end;
      end; // array, object
    jtNull:
      s:=TITLE_Null;
  else
    s:=Data.AsString;
    if Options.FQuoteStrings and  (Data.JSONType=jtString) then
      s:='"'+s+'"';
  end;
  if Assigned(N) then begin
     If N.Text='' then begin
        N.Text:=s;
     end else begin
        if not ((s+' ')[1] in ['{', '[']) then begin
           if pos(' ', s) > 0 then begin
              {
              with TPropertyBeautifyer.Create(s) do
                try
                  s:=Parse;
                finally
                  Free;
                end;
              }
              Beautifyer.Text:=s;
              s:=Beautifyer.Parse;
           end;
           N.Text:=N.Text + KEYVAL_SEPARATOR + ' '+s;
        end;
     end;
     N.Data:=Data;
  end;
end;

constructor TfmPackageDetails.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FOptions.FCompact:=True;
  //FOptions.FOptions:=
  FOptions.FQuoteStrings:=False;

  Beautifyer:=TPropertyBeautifyer.Create('');
end;

destructor TfmPackageDetails.Destroy;
begin
  FreeAndNil(FBeautifyer);
  FreeAndNil(FPackageDetails);

  inherited Destroy;
end;

procedure TfmPackageDetails.ShowJson(const ARoot: TJsonObject);
begin

  tvDet.Options:=[tvoAutoItemHeight,tvoKeepCollapsedNodes,tvoRightClickSelect,tvoShowButtons,tvoShowLines,tvoShowRoot,tvoToolTips,tvoThemedDraw];
  With tvDet.Items do begin
    BeginUpdate;
    try
      tvDet.Items.Clear;
      ShowJSONData(Nil,PackageDetails);
      With tvDet do
        if (Items.Count>0) and Assigned(Items[0]) then begin
           Items[0].Expand(False);
           Selected:=Items[0];
        end;
    finally
      EndUpdate;
    end;
  end;

end;

procedure TfmPackageDetails.LoadPackageContent;
var s: string;
begin
   if lboxFiles.Items.Count > 0 then
      exit;


   lboxFiles.Items.Add('');
   lboxFiles.Items.Add('');
   lboxFiles.Items.Add('loading info...');

   try
     self.Cursor:=crAppStart;
     s:=dmMain.GetPackageContent_Files(self.Title);
     lboxFiles.Items.Text:=s;

   finally
      self.Cursor:=crDefault;
   end;

end;


end.

