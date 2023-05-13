unit umain;

{$MODE DELPHI}
interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, Buttons, ActnList, Menus, VirtualTrees, SynEdit,
  synhighlighterunixshellscript
  // ,VirtualStringTree
  , fpjson
  , utypes
  ;


type

  TViewMode = (vmList, vmTree);


  { TfmMain }

  TfmMain = class(TForm)
    acCheckUpdates: TAction;
    acSearchPackages: TAction;
    acInspectPackage: TAction;
    acHistoryCopyItem: TAction;
    acGuiShowRepository: TAction;
    acGuiShowKernel: TAction;
    acGuiShowPackages: TAction;
    acSearchRepositories: TAction;
    ActionList1: TActionList;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    cbSearchInstalled: TCheckBox;
    cbSearchLocation: TComboBox;
    cbSearchRepoType: TComboBox;
    edTextToSearch: TEdit;
    Image1: TImage;
    images: TImageList;
    Label2: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    lbSystemKernelName: TStaticText;
    lbViewAsList: TLabel;
    Label4: TLabel;
    lbViewAsTree: TLabel;
    lboxHistory: TListBox;
    listUrls: TListBox;
    Memo1: TMemo;
    MenuItem1: TMenuItem;
    miHistoryCopy: TMenuItem;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    pnRepoUrls: TPanel;
    pnRepository: TPanel;
    pnSearchOtions: TPanel;
    pnBody: TPanel;
    pnMacroMenu: TPanel;
    pnHistory: TPanel;
    pmItems: TPopupMenu;
    pmHistory: TPopupMenu;
    Splitter1: TSplitter;
    lbSystemHostName: TStaticText;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StatusBar1: TStatusBar;
    tsRepository: TTabSheet;
    tsKernel: TTabSheet;
    tsDebug: TTabSheet;
    tsHome: TTabSheet;
    SynUNIXShellScriptSyn1: TSynUNIXShellScriptSyn;
    TrayIcon1: TTrayIcon;
    vst: TVirtualStringTree;
    vstRepo: TVirtualStringTree;
    procedure acCheckUpdatesExecute(Sender: TObject);
    procedure acGuiShowKernelExecute(Sender: TObject);
    procedure acGuiShowPackagesExecute(Sender: TObject);
    procedure acGuiShowRepositoryExecute(Sender: TObject);
    procedure acHistoryCopyItemExecute(Sender: TObject);
    procedure acInspectPackageExecute(Sender: TObject);
    procedure acSearchPackagesExecute(Sender: TObject);
    procedure acSearchRepositoriesExecute(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure Label4Click(Sender: TObject);
    procedure Label5Click(Sender: TObject);
    procedure Label6Click(Sender: TObject);
    procedure lbViewAsListClick(Sender: TObject);
    procedure lbViewAsTreeClick(Sender: TObject);
    procedure lbViewAsTreeMouseEnter(Sender: TObject);
    procedure vstChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex);
    procedure vstFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstGetNodeDataSize(Sender: TBaseVirtualTree; var NodeDataSize: Integer);
    procedure vstGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure vstRepoChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstRepoFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex);
    procedure vstRepoFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstRepoGetNodeDataSize(Sender: TBaseVirtualTree;var NodeDataSize: Integer);
    procedure vstRepoGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure vstRepoNodeClick(Sender: TBaseVirtualTree; const HitInfo: THitInfo
      );
  private
    FPackages: TJSONArray;
    FRepositories: TJSONArray;
    FViewMode: TViewMode;
    procedure SetStatusPanel_FormStatus(AValue: string);
    procedure SetStatusPanel_ItemsCount(AValue: integer);
    procedure SetStatusPanel_SumOf_Size(AValue: integer);

    procedure PopulateGrid(const APackagesList: TJSONArray);
    procedure DoPopulateGridAsList(const APackagesList: TJSONArray);
    procedure DoPopulateGridAsGroupByCat(const APackagesList: TJSONArray);

    procedure DoPopulateRepoGridAsList(const ARepositoriesList: TJSONArray);

    procedure SetViewMode(AValue: TViewMode);

  private
    property Packages: TJSONArray read FPackages write FPackages;
    property Repositories: TJSONArray read FRepositories write FRepositories;
    property ViewMode: TViewMode read FViewMode write SetViewMode;
  public
     procedure SearchPackages(const AValueToSearch: string);
     procedure SearchRepositoryes(const AType: TRepositorySearchMode = rsmAll);
     procedure InspectPackage(const APackageName: string);
     {$IFDEF DEBUG_INCLUDE_TEST}
     procedure CheckUpdates;
     {$ENDIF}
     procedure SendHistoryPanel(const AValue: string);

     property StatusPanel_FormStatus: string write SetStatusPanel_FormStatus;
     property StatusPanel_ItemsCount: integer write SetStatusPanel_ItemsCount;
     property StatusPanel_SumOf_Size: integer write SetStatusPanel_SumOf_Size;
  end;

var
  fmMain: TfmMain;

implementation

{$R *.lfm}

uses ucustompackagemanager, upackagedetails_fm, uabout_fm, Clipbrd, StrUtils;

{ TfmMain }

procedure TfmMain.Button1Click(Sender: TObject);
begin
  {$IFDEF DEBUG_INCLUDE_TEST}
  // memo1.Clear;
  CheckUpdates;
  {$ENDIF}
end;

procedure TfmMain.acCheckUpdatesExecute(Sender: TObject);
begin
{$IFDEF DEBUG_INCLUDE_TEST}
  // StatusPanel_FormStatus:='Searching for updates...';
  // SendHistoryPanel( TCustomPackageManager.Test_CheckUpdates_PreviewCommand );
  // try
  //   StatusPanel_ItemsCount:=-1;
  //   StatusPanel_SumOf_Size:=-1;
  //   CheckUpdates;
  // finally
  //   StatusPanel_FormStatus:='Ready';
  // end;
{$ENDIF}
end;

procedure TfmMain.acGuiShowKernelExecute(Sender: TObject);
begin
  PageControl1.ActivePage:=tsKernel;
end;

procedure TfmMain.acGuiShowPackagesExecute(Sender: TObject);
begin
  PageControl1.ActivePage:=tsHome;
end;

procedure TfmMain.acGuiShowRepositoryExecute(Sender: TObject);
begin
   PageControl1.ActivePage:=tsRepository;
end;

procedure TfmMain.acHistoryCopyItemExecute(Sender: TObject);
begin
  Clipboard.AsText:=lboxHistory.Items[lboxHistory.ItemIndex];
  showmessage(Clipboard.AsText);
end;

procedure TfmMain.acInspectPackageExecute(Sender: TObject);
var Data: PPackageItemData;
begin
  if not Assigned(VST.FocusedNode) then
     Exit;

  // case view as list
  Data := VST.GetNodeData(VST.FocusedNode);
  InspectPackage(Data^.PackageName);
end;

procedure TfmMain.acSearchPackagesExecute(Sender: TObject);
begin
  StatusPanel_FormStatus:='Searching packages...';
  try
    self.Cursor:=crAppStart;
    StatusPanel_ItemsCount:=-1;
    StatusPanel_SumOf_Size:=-1;
    SearchPackages(edTextToSearch.Text);
  finally
    self.Cursor:=crDefault;
    StatusPanel_FormStatus:='Ready';
  end;
end;

procedure TfmMain.acSearchRepositoriesExecute(Sender: TObject);
begin
  StatusPanel_FormStatus:='Searching repositoryes...';
  try
    self.Cursor:=crAppStart;
    StatusPanel_ItemsCount:=-1;
    StatusPanel_SumOf_Size:=-1;
    SearchRepositoryes( TRepositorySearchMode( cbSearchRepoType.ItemIndex) );
  finally
    self.Cursor:=crDefault;
    StatusPanel_FormStatus:='Ready';
  end;
end;

procedure TfmMain.Button2Click(Sender: TObject);
var
  Data: PPackageItemData;
  XNode: PVirtualNode;
  Rand: Integer;
begin
  Randomize;
  Rand := Random(99);
  XNode := VST.AddChild(nil);

  // if VST.AbsoluteIndex(XNode) > -1 then
  if Assigned(XNode) then begin
    Data := VST.GetNodeData(Xnode);
    Data^.PackageName := 'One ' + IntToStr(Rand);
    Data^.Repository := 'Two ' + IntToStr(Rand + 10);
    Data^.DownloadSize := Rand;
  end;
end;

procedure TfmMain.Button3Click(Sender: TObject);
var XNode: PVirtualNode;
    Data: PPackageItemData;
begin
  if not Assigned(VST.FocusedNode) then
     Exit;

  XNode := VST.AddChild(VST.FocusedNode);
  Data := VST.GetNodeData(Xnode);

  Data^.PackageName := 'Ch 1';
  Data^.Repository := 'Ch 2';
  Data^.DownloadSize := 250;

  VST.Expanded[VST.FocusedNode] := True;
end;

procedure TfmMain.Button4Click(Sender: TObject);
begin
  VST.DeleteSelectedNodes;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  // fix runtime
  PageControl1.ShowTabs:=False;
  PageControl1.ActivePage:=tsHome;

  // init
  StatusPanel_FormStatus:='Ready';
  ViewMode:=vmList;
  with TCustomPackageManager.GetSystemInfo do begin
      lbSystemHostName.Caption := HostName;
      lbSystemKernelName.Caption := KernelName;
  end;

  // allocate resources
  FPackages:=nil;
  FRepositories:=nil;

  // test
  if not TCustomPackageManager.IsRunningAsSudo then begin
     MessageDlg('PAGeant', 'You are running PAGeant without administrator rights.' + LineEnding +
                           'In this case, not all functionality will be accessible!',
                           mtWarning, [mbOK], '');
  end;

end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin

  // free resoruces
  FreeAndNil(FPackages);
  vst.Clear;

  FreeAndNil(FRepositories);
  vstRepo.Clear;

end;

procedure TfmMain.Image1Click(Sender: TObject);
begin

end;

procedure TfmMain.Label2Click(Sender: TObject);
begin
    acGuiShowPackages.Execute;
end;

procedure TfmMain.Label4Click(Sender: TObject);
begin
  acGuiShowRepository.Execute;
end;

procedure TfmMain.Label5Click(Sender: TObject);
begin
  acGuiShowKernel.Execute;
end;

procedure TfmMain.Label6Click(Sender: TObject);
begin
   with TfmAbout.Create(self) do
      try
        ShowModal;
      finally
        Free;
      end;
end;

procedure TfmMain.lbViewAsListClick(Sender: TObject);
begin
  if PageControl1.ActivePage <> tsHome then
     acGuiShowPackages.Execute;

  ViewMode:=vmList;
  PopulateGrid(Packages);
end;

procedure TfmMain.lbViewAsTreeClick(Sender: TObject);
begin
  ViewMode:=vmTree;
  PopulateGrid(Packages);
end;

procedure TfmMain.lbViewAsTreeMouseEnter(Sender: TObject);
begin

end;

procedure TfmMain.vstChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  VST.Refresh;
end;

procedure TfmMain.vstFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex);
begin
  VST.Refresh;
end;

procedure TfmMain.vstFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  Data: PPackageItemData;
begin
  Data := VST.GetNodeData(Node);
  if Assigned(Data) then begin
    Data^.PackageName := '';

    Data^.Category:='';
    Data^.Version:='';
    Data^.License:='';
    Data^.Repository := '';
    // Action: string;
    // Architecture: string;
    Data^.Installedsize:=0;
    Data^.DownloadSize := 0;
  end;
end;

procedure TfmMain.vstGetNodeDataSize(Sender: TBaseVirtualTree;
  var NodeDataSize: Integer);
begin
  NodeDataSize := SizeOf(TPackageItemData);
end;

procedure TfmMain.vstGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
var Data: PPackageItemData;
begin
  Data := VST.GetNodeData(Node);
  case Column of
    0: CellText := Data^.Repository;
    1: CellText := Data^.Category;
    2: CellText := Data^.PackageName;
    3: CellText := Data^.Version;
    4: CellText := Data^.License;
    5: CellText := // Data^.DownloadSize.ToString;
                   Format('%8.2n', [( Data^.DownloadSize / 1048576 )]);
  end;
end;

procedure TfmMain.vstRepoChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  vstRepo.Refresh;
end;

procedure TfmMain.vstRepoFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
  vstRepo.Refresh;
end;

procedure TfmMain.vstRepoFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  Data: PRepositoryItemData;
begin
  Data := vstRepo.GetNodeData(Node);
  if Assigned(Data) then begin
    Data^.Status:='';
    Data^.RepositoryName := '';
    Data^.Description := '';
    Data^.Revision := '';
    Data^.Date := '';
    Data^.Priority := '';
    Data^.RepoType := '';
    Data^.Urls := '';
  end;
end;

procedure TfmMain.vstRepoGetNodeDataSize(Sender: TBaseVirtualTree;
  var NodeDataSize: Integer);
begin
  NodeDataSize := SizeOf(TRepositoryItemData);
end;

procedure TfmMain.vstRepoGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
var Data: PRepositoryItemData;
begin
  Data := vstRepo.GetNodeData(Node);
  case Column of
    0: CellText := Data^.Status;
    1: CellText := Data^.RepositoryName;
    2: CellText := Data^.Description;
    3: CellText := Data^.Revision;
    4: CellText := Data^.Date;
    5: CellText := Data^.Priority;
    6: CellText := Data^.RepoType;
  end;
end;

procedure TfmMain.vstRepoNodeClick(Sender: TBaseVirtualTree; const HitInfo: THitInfo);
var Data: PRepositoryItemData;
begin
  listUrls.Clear;
  try
    Data := vstRepo.GetNodeData(HitInfo.HitNode);
    listUrls.Items.Text:=Data^.Urls;
  except
  end;
end;


procedure TfmMain.SetStatusPanel_FormStatus(AValue: string);
begin
  StatusBar1.Panels[0].Text := 'Status: ' + AValue;
  Application.ProcessMessages;
end;

procedure TfmMain.SetStatusPanel_ItemsCount(AValue: integer);
var s: string;
begin
  if AValue < 0 then
     s:=''
  else
     s:= 'Items found: ' + Format('%d', [AValue]);
  StatusBar1.Panels[1].Text := s;
  Application.ProcessMessages;
end;

procedure TfmMain.SetStatusPanel_SumOf_Size(AValue: integer);
var s: string;
begin
  if AValue < 0 then
     s:=''
  else
     s:= Format('Total size: %8.2n MB', [( AValue / 1048576 )]);
  StatusBar1.Panels[2].Text := s;
  Application.ProcessMessages;
end;

procedure TfmMain.PopulateGrid(const APackagesList: TJSONArray);
begin
  vst.Clear;

  if not Assigned(Packages) then
     exit;

  case ViewMode of
    vmList: DoPopulateGridAsList(APackagesList);
    vmTree: DoPopulateGridAsGroupByCat(APackagesList);
  end;
end;

procedure TfmMain.DoPopulateGridAsList(const APackagesList: TJSONArray);
var je: TJSONEnum;
    ji: TJSONObject;
    js: TJSONString;
    s: string;
    XNode: PVirtualNode;
    Data: PPackageItemData;
begin
  // Update gui
  StatusPanel_ItemsCount:=APackagesList.Count;
  StatusPanel_SumOf_Size:=0;

  for je in APackagesList do begin
      ji:=je.Value as TJSONObject;

      XNode := VST.AddChild(nil);
      // if VST.AbsoluteIndex(XNode) > -1 then
      if Assigned(XNode) then begin

        Data := VST.GetNodeData(Xnode);

        s:=ji.Strings['name'];
        Data^.PackageName := s;

        s:=ji.Strings['category'];
        Data^.Category := s;

        s:=ji.Strings['version'];
        Data^.Version := s;

        if ji.Find('license', js) then begin
           Data^.License := js.AsString;
        end;


        s:=ji.Strings['repository'];
        Data^.Repository := s;

        Data^.DownloadSize := 0;

     end;

  end;
end;

procedure TfmMain.DoPopulateGridAsGroupByCat(const APackagesList: TJSONArray);
var je: TJSONEnum;
    ji: TJSONObject;
    js: TJSONString;
    s, sLastCategory: string;
    XNode, XCategoryNode: PVirtualNode;
    Data: PPackageItemData;
begin

    // Update gui
    StatusPanel_ItemsCount:=APackagesList.Count;
    StatusPanel_SumOf_Size:=0;

    sLastCategory:='';;
    // sLastRepository := '';

    for je in APackagesList do begin
        ji:=je.Value as TJSONObject;

        // new caterogy?
        s:=ji.Strings['category'];
        if (sLastCategory = '') or (s <> sLastCategory) then begin
           XCategoryNode := VST.AddChild(nil);
           Data := VST.GetNodeData(XCategoryNode);

           sLastCategory:=s;
           Data^.Category := sLastCategory;
           Data^.Repository := ji.Strings['repository'];

        end;


        // XNode := VST.AddChild(nil);
        XNode := VST.AddChild(XCategoryNode);
        // if VST.AbsoluteIndex(XNode) > -1 then
        if Assigned(XNode) then begin

          Data := VST.GetNodeData(Xnode);

          s:=ji.Strings['name'];
          Data^.PackageName := s;

          // s:=ji.Strings['category'];
          // Data^.Category := s;

          s:=ji.Strings['version'];
          Data^.Version := s;

          if ji.Find('license', js) then begin
             Data^.License := js.AsString;
          end;


          // s:=ji.Strings['repository'];
          // Data^.Repository := s;

          // Data^.DownloadSize := 0;

       end;

    end;

end;

procedure TfmMain.DoPopulateRepoGridAsList(const ARepositoriesList: TJSONArray);
var je, jeurls: TJSONEnum;
    ja: TJsonArray;
    ji: TJSONObject;
    s: string;
    XNode: PVirtualNode;
    Data: PRepositoryItemData;
begin
  // Update gui
  StatusPanel_ItemsCount:=ARepositoriesList.Count;

  for je in ARepositoriesList do begin
      ji:=je.Value as TJSONObject;

      XNode := vstRepo.AddChild(nil);

      if Assigned(XNode) then begin

        Data := vstRepo.GetNodeData(Xnode);

        s:=ji.Strings['Status'];
        Data^.Status := s;

        s:=ji.Strings['Name'];
        Data^.RepositoryName := s;

        s:=ji.Strings['Description'];
        Data^.Description:= s;

        s:=ji.Strings['Revision'];
        Data^.Revision:= s;

        s:=ji.Strings['Date'];
        Data^.Date:= s;

        s:=ji.Strings['Priority'];
        Data^.Priority:= s;

        s:=ji.Strings['Type'];
        Data^.RepoType:= s;

        ja:=ji.Arrays['Urls'];
        s:='';
        for jeurls in ja do begin
            if s <> '' then
               s+=LineEnding;
            s+=jeurls.Value.AsString;
        end;
        Data^.Urls:=s;

     end;

  end;
end;

procedure TfmMain.SetViewMode(AValue: TViewMode);
begin
  // if FViewMode=AValue then Exit;
  FViewMode:=AValue;

  case FViewMode of
    vmList: begin
       lbViewAsList.Font.Style:=[fsBold];
       lbViewAsList.Font.Color:= $00D6D6D6;

       lbViewAsTree.Font.Style:=[];
       lbViewAsTree.Font.Color:= clSilver;
    end;
    vmTree: begin
       lbViewAsList.Font.Style:=[];
       lbViewAsList.Font.Color:= clSilver;

       lbViewAsTree.Font.Style:=[fsBold];
       lbViewAsTree.Font.Color:= $00D6D6D6;
    end;
  end;

end;

procedure TfmMain.SearchPackages(const AValueToSearch: string);
var jo: TJSONObject;
    sOut:string;
    LuetWrap: TCustomPackageManager;
begin

  LuetWrap:=TCustomPackageManager.Create;
  try

    // - - - - - - - - - - - - - - - -
    // init
    // - - - - - - - - - - - - - - - -
    vst.Clear;
    StatusPanel_FormStatus:='luet is searching...';
    Application.ProcessMessages;

    // - - - - - - - - - - - - - - - -
    // search
    // - - - - - - - - - - - - - - - -
    if Assigned(FPackages) then
       FreeAndNil(FPackages);

    LuetWrap.IsSearchInstalled:=cbSearchInstalled.Checked;
    LuetWrap.SearchMode:=TSearchMode( cbSearchLocation.ItemIndex );

    if pnHistory.Visible then
       SendHistoryPanel( LuetWrap.GetWrappedCommand(AValueToSearch, True) );

    sOut := LuetWrap.Search(AValueToSearch);

    // - - - - - - - - - - - - - - - -
    // process results
    // - - - - - - - - - - - - - - - -
    StatusPanel_FormStatus:='Elaboration...';
    Application.ProcessMessages;

    jo := GetJSON(sOut) as TJSONObject;
    FPackages := jo.Extract('stones') as TJSONArray;

    if not Assigned(FPackages) then begin
       MessageDlg('Error', 'search failed!', mtError, [mbOk], 0);
       exit;
    end;

    PopulateGrid(Packages);

  finally
    FreeAndNil(LuetWrap);
    FreeAndNil(jo);
  end;

end;

procedure TfmMain.SearchRepositoryes(const AType: TRepositorySearchMode);
var sl: TStringList;
    sOut:string;
    LuetWrap: TCustomPackageManager;
    i, p: integer;
    s: string;
    ji: TJSONObject;
    ja: TJSONArray;
begin

  LuetWrap:=TCustomPackageManager.Create;
  try

    // - - - - - - - - - - - - - - - -
    // init
    // - - - - - - - - - - - - - - - -
    vstRepo.Clear;
    StatusPanel_FormStatus:='luet is searching...';
    Application.ProcessMessages;

    // - - - - - - - - - - - - - - - -
    // search
    // - - - - - - - - - - - - - - - -
    if Assigned(FRepositories) then
       FreeAndNil(FRepositories);

    if pnHistory.Visible then
       SendHistoryPanel( LuetWrap.GetWrappedRepoCommand(AType) );

    FRepositories := TJSONArray.Create;

    // if pnHistory.Visible then
    //    SendHistoryPanel( LuetWrap.GetWrappedRepoCommand(AType) );

    sOut := LuetWrap.SearchRepositories(AType);

    // - - - - - - - - - - - - - - - -
    // process results
    // - - - - - - - - - - - - - - - -
    StatusPanel_FormStatus:='Elaboration...';
    Application.ProcessMessages;

    sl:=TStringList.Create;
    try
      sl.Text:=sOut;

      i:=-1;
      while i < sl.Count-1 do begin
         ji:=TJSONObject.Create;
         FRepositories.Add(ji);
         // line 1: flag enabled + repository name
         inc(i);
         s:=ExtractWord(1, sl[i], [' ']);
         ji.Add('Status', s);
         s:=ExtractWord(2, sl[i], [' ']);
         ji.Add('Name', s);
         // line 2: repository description
         inc(i);
         s:=sl[i].Trim;
         ji.Add('Description', s);
         // line 3: revision + date
         inc(i);
            p:=pos(' - ', sl[i]);
            // revision
            s:=copy(sl[i], 1, p-1);
            s:=s.Replace('Revision', '', [rfReplaceAll]).Trim;
            ji.Add('Revision', s);
            // date
            s:=copy(sl[i], p+3, length(sl[i]));
            ji.Add('Date', s);
         // line 4: priority + type
         inc(i);
            p:=pos(' - ', sl[i]);
            // priority
            s:=copy(sl[i], 1, p-1);
            s:=s.Replace('Priority', '', [rfReplaceAll]).Trim;
            ji.Add('Priority', s);
            // type
            s:=copy(sl[i], p+3, length(sl[i]));
            s:=s.Replace('Type', '', [rfReplaceAll]).Trim;
            ji.Add('Type', s);
         // line 5: urls
         inc(i);
         s:=sl[i].Trim.ToLower;
         if s <> 'urls:' then
            raise Exception.Create('Unable to extract repository urls');
         ja:=TJSONArray.Create;
         ji.Add('Urls', ja);
         repeat
            inc(i);
            s:=sl[i].Trim;
            p:=pos('*', s);
            s:=copy(s, p+1, length(s)).Trim;
            ja.Add(s);

            if ((i+1) <= sl.Count-1) then
               s:=sl[i+1].Trim
            else
               s:= '';
         until pos('*', s)=0;

      end;

      DoPopulateRepoGridAsList(Repositories);

    finally
      sl.Free;
    end;

    if not Assigned(FRepositories) then begin
       MessageDlg('Error', 'search failed!', mtError, [mbOk], 0);
       exit;
    end;

    // PopulateGrid(Packages);

  finally
    FreeAndNil(LuetWrap);
  end;

end;

procedure TfmMain.InspectPackage(const APackageName: string);
var ji: TJSONObject;
    je: TJSONEnum;
begin
  // - - - - - - - - - - - - - - - -
  // search package
  // - - - - - - - - - - - - - - - -
  ji:=nil;
  for je in Packages do begin
      if TJSONObject(je.Value).Strings['name'] = APackageName then begin
         ji:=je.Value as TJSONObject;
         break;
      end;
  end;

  // - - - - - - - - - - - - - - - -
  // search package
  // - - - - - - - - - - - - - - - -
  with TfmPackageDetails.Create(self) do begin
       Title:=APackageName;
       // AnimationImageList:=Images;
       PackageDetails:=ji;
       Show;
  end;

end;

{$IFDEF DEBUG_INCLUDE_TEST}
procedure TfmMain.CheckUpdates;
{
var ui: TPackageList;
    i:integer;
    sOut: string;
    Data: PPackageItemData;
    XNode: PVirtualNode;
}
begin
  {
  ui:=TPackageList.Create;
  SetLength(ui,0);
  i := TCustomPackageManager.Test_CheckUpdates(ui, sOut);

  // Update gui
  StatusPanel_ItemsCount:=Length(ui);
  StatusPanel_SumOf_Size:=i;

  // memo1.Lines.Add( i.ToString );
  // memo1.Lines.Add(sOut);
  // memo1.Lines.Add('');
  // memo1.Lines.Add('Low: ' + low(ui).ToString);
  // memo1.Lines.Add('High: ' + High(ui).ToString);

  vst.Clear;
  for i:=low(ui) to High(ui) do begin

      XNode := VST.AddChild(nil);
      if VST.AbsoluteIndex(XNode) > -1 then
      begin
        Data := VST.GetNodeData(Xnode);
        Data^.PackageName := ui[i].PackageName;
        Data^.Category := ui[i].Category;
        Data^.Version := ui[i].Version;
        Data^.License := ui[i].License;
        Data^.Repository := ui[i].Repository;
        Data^.DownloadSize := ui[i].DownloadSize;
     end;

      memo1.Lines.Add( Format('%4d %-60.60s %10d %10d %10.10s %s',
                              [ i,
                                ui[i].PackageName,
                                ui[i].Installedsize, ui[i].DownloadSize, ui[i].Category,
                                ui[i].Repository ]) );


  end;
  }
end;

{$ENDIF}

procedure TfmMain.SendHistoryPanel(const AValue: string);
begin
  lboxHistory.Items.Insert(0, AValue);
  Application.ProcessMessages;;
end;

end.

