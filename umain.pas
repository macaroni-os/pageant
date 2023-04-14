unit umain;

{$MODE DELPHI}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, Buttons, ActnList, VirtualTrees, SynEdit,
  synhighlighterunixshellscript
  // ,VirtualStringTree
  , fpjson
  ;


type

  TViewMode = (vmList, vmTree);


  { TForm1 }

  TForm1 = class(TForm)
    acCheckUpdates: TAction;
    acSearchPackages: TAction;
    ActionList1: TActionList;
    BitBtn1: TBitBtn;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    cbSearchInstalled: TCheckBox;
    cbSearchLocation: TComboBox;
    edTextToSearch: TEdit;
    images: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Label5: TLabel;
    lbViewAsList: TLabel;
    Label4: TLabel;
    lbViewAsTree: TLabel;
    Memo1: TMemo;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    pnSearchOtions: TPanel;
    pnBody: TPanel;
    pnMacroMenu: TPanel;
    pnNerdPanel: TPanel;
    Splitter1: TSplitter;
    StatusBar1: TStatusBar;
    tsDebug: TTabSheet;
    tsHome: TTabSheet;
    SynUNIXShellScriptSyn1: TSynUNIXShellScriptSyn;
    TrayIcon1: TTrayIcon;
    txShell: TSynEdit;
    vst: TVirtualStringTree;
    procedure acCheckUpdatesExecute(Sender: TObject);
    procedure acSearchPackagesExecute(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Label4Click(Sender: TObject);
    procedure Label5Click(Sender: TObject);
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
    FSudoPassword: string;
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
    property SudoPassword: string read FSudoPassword write FSudoPassword;
    property ViewMode: TViewMode read FViewMode write SetViewMode;
  public
     procedure SearchPackages(const AValueToSearch: string);
     {$IFDEF DEBUG_INCLUDE_TEST}
     procedure CheckUpdates;
     {$ENDIF}
     procedure SendHistoryPanel(const AValue: string);

     property StatusPanel_FormStatus: string write SetStatusPanel_FormStatus;
     property StatusPanel_ItemsCount: integer write SetStatusPanel_ItemsCount;
     property StatusPanel_SumOf_Size: integer write SetStatusPanel_SumOf_Size;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

uses ucustompackagemanager, uAskPassword;

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
  {$IFDEF DEBUG_INCLUDE_TEST}
  // memo1.Clear;
  CheckUpdates;
  {$ENDIF}
end;

procedure TForm1.acCheckUpdatesExecute(Sender: TObject);
begin
{$IFDEF DEBUG_INCLUDE_TEST}
  StatusPanel_FormStatus:='Searching for updates...';
  SendNerdPanel( TCustomPackageManager.Test_CheckUpdates_PreviewCommand );
  try
    StatusPanel_ItemsCount:=-1;
    StatusPanel_SumOf_Size:=-1;
    CheckUpdates;
  finally
    StatusPanel_FormStatus:='Ready';
  end;
{$ENDIF}
end;

procedure TForm1.acSearchPackagesExecute(Sender: TObject);
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

procedure TForm1.Button2Click(Sender: TObject);
var
  Data: PPackageItemData;
  XNode: PVirtualNode;
  Rand: Integer;
begin
  Randomize;
  Rand := Random(99);
  XNode := VST.AddChild(nil);

  if VST.AbsoluteIndex(XNode) > -1 then
  begin
    Data := VST.GetNodeData(Xnode);
    Data^.PackageName := 'One ' + IntToStr(Rand);
    Data^.Repository := 'Two ' + IntToStr(Rand + 10);
    Data^.DownloadSize := Rand;
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
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

procedure TForm1.Button4Click(Sender: TObject);
begin
  VST.DeleteSelectedNodes;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // fix runtime
  PageControl1.ShowTabs:=False;
  PageControl1.ActivePage:=tsHome;

  // init
  StatusPanel_FormStatus:='Ready';
  ViewMode:=vmList;

  // allocate resources
  FPackages:=nil;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin

  // free resoruces
  FreeAndNil(FPackages);
  vst.Clear;
end;

procedure TForm1.Label4Click(Sender: TObject);
begin
  ShowMessage('Not yet implemented');
end;

procedure TForm1.Label5Click(Sender: TObject);
begin
  ShowMessage('Not yet implemented');
end;

procedure TForm1.lbViewAsListClick(Sender: TObject);
begin
  ViewMode:=vmList;
  PopulateGrid(Packages);
end;

procedure TForm1.lbViewAsTreeClick(Sender: TObject);
begin
  ViewMode:=vmTree;
  PopulateGrid(Packages);
end;

procedure TForm1.lbViewAsTreeMouseEnter(Sender: TObject);
begin

end;

procedure TForm1.vstChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  VST.Refresh;
end;

procedure TForm1.vstFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex);
begin
  VST.Refresh;
end;

procedure TForm1.vstFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
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

procedure TForm1.vstGetNodeDataSize(Sender: TBaseVirtualTree;
  var NodeDataSize: Integer);
begin
  NodeDataSize := SizeOf(TPackageItemData);
end;

procedure TForm1.vstGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
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

procedure TForm1.SetStatusPanel_FormStatus(AValue: string);
begin
  StatusBar1.Panels[0].Text := 'Status: ' + AValue;
  Application.ProcessMessages;
end;

procedure TForm1.SetStatusPanel_ItemsCount(AValue: integer);
var s: string;
begin
  if AValue < 0 then
     s:=''
  else
     s:= 'Items found: ' + Format('%d', [AValue]);
  StatusBar1.Panels[1].Text := s;
  Application.ProcessMessages;
end;

procedure TForm1.SetStatusPanel_SumOf_Size(AValue: integer);
var s: string;
begin
  if AValue < 0 then
     s:=''
  else
     s:= Format('Total size: %8.2n MB', [( AValue / 1048576 )]);
  StatusBar1.Panels[2].Text := s;
  Application.ProcessMessages;
end;

procedure TForm1.PopulateGrid(const APackagesList: TJSONArray);
begin
  vst.Clear;

  if not Assigned(Packages) then
     exit;

  case ViewMode of
    vmList: DoPopulateGridAsList(APackagesList);
    vmTree: DoPopulateGridAsGroupByCat(APackagesList);
  end;
end;

procedure TForm1.DoPopulateGridAsList(const APackagesList: TJSONArray);
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
      if VST.AbsoluteIndex(XNode) > -1 then
      begin

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

procedure TForm1.DoPopulateGridAsGroupByCat(const APackagesList: TJSONArray);
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
        if VST.AbsoluteIndex(XNode) > -1 then
        begin

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

procedure TForm1.SetViewMode(AValue: TViewMode);
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

procedure TForm1.SearchPackages(const AValueToSearch: string);
var jo: TJSONObject;
    sOut:string;
    LuetWrap: TCustomPackageManager;
    fmSudoPassword: TfmSudoPassword;
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

    if not LuetWrap.IsRunningAsSudo then begin

       if self.SudoPassword <> '' then begin
          LuetWrap.SudoPassword:=self.SudoPassword;
       end else begin
           fmSudoPassword:=TfmSudoPassword.Create(self);
           try
             if fmSudoPassword.ShowModal = mrOK then begin
                LuetWrap.SudoPassword:=fmSudoPassword.edPass.Text;
                if fmSudoPassword.cbRemember.Checked then
                   self.SudoPassword:=fmSudoPassword.edPass.Text;
             end;

           finally
             FreeAndnil(fmSudoPassword);
           end;
       end;

    end;

    LuetWrap.IsSearchInstalled:=cbSearchInstalled.Checked;
    LuetWrap.SearchMode:=TSearchMode( cbSearchLocation.ItemIndex );

    if pnNerdPanel.Visible then
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

{$IFDEF DEBUG_INCLUDE_TEST}
procedure TForm1.CheckUpdates;
var ui: TPackageList;
    i:integer;
    sOut: string;
    Data: PPackageItemData;
    XNode: PVirtualNode;
begin
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

end;

{$ENDIF}

procedure TForm1.SendHistoryPanel(const AValue: string);
begin
  txShell.Lines.Add(AValue);
  Application.ProcessMessages;;
end;

end.

