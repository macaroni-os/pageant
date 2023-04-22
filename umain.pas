unit umain;

{$MODE DELPHI}
interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, Buttons, ActnList, Menus, VirtualTrees, SynEdit,
  synhighlighterunixshellscript
  // ,VirtualStringTree
  , fpjson
  ;


type

  TViewMode = (vmList, vmTree);


  { TfmMain }

  TfmMain = class(TForm)
    acCheckUpdates: TAction;
    acSearchPackages: TAction;
    acInspectPackage: TAction;
    acHistoryCopyItem: TAction;
    ActionList1: TActionList;
    BitBtn1: TBitBtn;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    cbSearchInstalled: TCheckBox;
    cbSearchLocation: TComboBox;
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
    Memo1: TMemo;
    MenuItem1: TMenuItem;
    miHistoryCopy: TMenuItem;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    pnSearchOtions: TPanel;
    pnBody: TPanel;
    pnMacroMenu: TPanel;
    pnHistory: TPanel;
    pmItems: TPopupMenu;
    pmHistory: TPopupMenu;
    Splitter1: TSplitter;
    lbSystemHostName: TStaticText;
    StatusBar1: TStatusBar;
    tsDebug: TTabSheet;
    tsHome: TTabSheet;
    SynUNIXShellScriptSyn1: TSynUNIXShellScriptSyn;
    TrayIcon1: TTrayIcon;
    vst: TVirtualStringTree;
    procedure acCheckUpdatesExecute(Sender: TObject);
    procedure acHistoryCopyItemExecute(Sender: TObject);
    procedure acInspectPackageExecute(Sender: TObject);
    procedure acSearchPackagesExecute(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Image1Click(Sender: TObject);
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
    procedure vstGetNodeDataSize(Sender: TBaseVirtualTree;
      var NodeDataSize: Integer);
    procedure vstGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
  private
    FPackages: TJSONArray;
    FViewMode: TViewMode;
    procedure SetStatusPanel_FormStatus(AValue: string);
    procedure SetStatusPanel_ItemsCount(AValue: integer);
    procedure SetStatusPanel_SumOf_Size(AValue: integer);

    procedure PopulateGrid(const APackagesList: TJSONArray);
    procedure DoPopulateGridAsList(const APackagesList: TJSONArray);
    procedure DoPopulateGridAsGroupByCat(const APackagesList: TJSONArray);
    procedure SetViewMode(AValue: TViewMode);

  private
    property Packages: TJSONArray read FPackages write FPackages;
    property ViewMode: TViewMode read FViewMode write SetViewMode;
  public
     procedure SearchPackages(const AValueToSearch: string);
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

uses ucustompackagemanager, upackagedetails_fm, utypes, uabout_fm, Clipbrd;

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

  //
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
end;

procedure TfmMain.Image1Click(Sender: TObject);
begin

end;

procedure TfmMain.Label4Click(Sender: TObject);
begin
  ShowMessage('Not yet implemented');
end;

procedure TfmMain.Label5Click(Sender: TObject);
begin
  ShowMessage('Not yet implemented');
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

