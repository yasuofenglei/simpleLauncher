unit welcome;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Winapi.ShellAPI, Vcl.Menus,
  System.Actions, Vcl.ActnList, System.IniFiles, uFunction, System.ImageList,
  Vcl.ImgList, udata, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls, FileCtrl;

const
  mousemsg = wm_user + 1; //自定义消息，用于处理用户在图标上点击鼠标的事件
  iid = 100;   //用户自定义数值，在TnotifyIconDataA类型全局变量ntida中使用
  CSection: string = 'DIR';
  IMenueMax: Integer = 1000;
  menuIdent: string = 'menu';
  //Alpha（α）、Beta（β）和Gamma（γ）
  simpleLauncher = 'simpleLauncher Alpha';

type
  PDir = ^RDir;

  RDir = record
    CDir: string;
  end;

  TFormWelcome = class(TForm)
    alMain: TActionList;
    actExit: TAction;
    actConfig: TAction;
    pmlm: TPopupMenu;
    pmrm: TPopupMenu;
    mniExit: TMenuItem;
    mniConfig: TMenuItem;
    ilmenu: TImageList;
    actRefresh: TAction;
    mniRefresh: TMenuItem;
    mniOpen: TMenuItem;
    actOpen: TAction;
    pnl1: TPanel;
    OpenAdd: TOpenDialog;
    pnlWrite: TPanel;
    btnConfig: TButton;
    btn2: TButton;
    EdtDir: TEdit;
    pmtv: TPopupMenu;
    actAdd: TAction;
    actDelete: TAction;
    mniAdd: TMenuItem;
    mniDelete: TMenuItem;
    actaddChild: TAction;
    mniaddChild: TMenuItem;
    actModify: TAction;
    mniModify: TMenuItem;
    btnSaveConfig: TButton;
    lbl1: TLabel;
    mmMain: TMainMenu;
    mniN1: TMenuItem;
    mniN2: TMenuItem;
    actInfo: TAction;
    pnl2: TPanel;
    tvConfig: TTreeView;
    actGetCode: TAction;
    mniGetCode: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormPaint(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actConfigExecute(Sender: TObject);
    procedure actRefreshExecute(Sender: TObject);
    procedure actOpenExecute(Sender: TObject);
    procedure tvConfigChange(Sender: TObject; Node: TTreeNode);
    procedure btnConfigClick(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btnSaveConfigClick(Sender: TObject);
    procedure EdtDirChange(Sender: TObject);
    procedure actAddExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actaddChildExecute(Sender: TObject);
    procedure actModifyExecute(Sender: TObject);
    procedure tvConfigDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure tvConfigMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure tvConfigDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure actInfoExecute(Sender: TObject);
    procedure actGetCodeExecute(Sender: TObject);
  private
    FList: TStrings;
    FList2: TStrings;
    Aerror: string;
    ntida: TNotifyIcondataA;  //用于增加和删除系统状态图标
    Tovis: Boolean; //是否已经首次刷新过界面.
    procedure HideMain; //隐藏主窗体
    //自定义消息处理函数，处理鼠标点击图标事件
    procedure Mousemessage(var message: tmessage); message mousemsg;
    //打开配置
    function ConfigIni: string;
    //读取配置文件
    function ReadIni: Boolean;
    //读取配置文件到Treeview
    function ReadIniToTreeview: Boolean;
    //打开路径菜单
    procedure AOpenDirExecute(Sender: TObject);
    //重写路径
    function ReWrite(S: string): string;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormWelcome: TFormWelcome;

implementation

{$R *.dfm}

procedure TFormWelcome.actaddChildExecute(Sender: TObject);
var
  CName: string;
  Anode: TTreeNode;
begin
  if not inputquery('添加菜单', '请输入菜单名称', CName) then
    exit;
  Anode := tvConfig.Items.AddChild(tvconfig.Selected, CName);
  Anode.Data := New(PDir);

end;

procedure TFormWelcome.actAddExecute(Sender: TObject);
var
  CName: string;
  Anode: TTreeNode;
begin
  if not inputquery('添加菜单', '请输入菜单名称', CName) then
    exit;
  Anode := tvConfig.Items.Add(nil, CName);
  Anode.Data := New(PDir);
end;

procedure TFormWelcome.actConfigExecute(Sender: TObject);
var
  TXTfileName: string;
begin
  TXTfileName := Configini;
//  ShellExecute(Handle, 'Open', PChar('notepad.exe'), PChar(TXTfileName), nil, SW_SHOWNORMAL);
//  Exit;
  //暂未做配置功能.
  ShowWindow(Handle, SW_SHOW);
    //在任务栏上显示应用程序窗口
  ShowWindow(Application.handle, SW_SHOW);
  SetWindowLong(Application.Handle, GWL_EXSTYLE, not (GetWindowLong(Application.handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW and not WS_EX_APPWINDOW));

end;

procedure TFormWelcome.actDeleteExecute(Sender: TObject);
var
  CMsg: string;
begin
  CMsg := '确认要删除[' + tvConfig.Selected.Text + ']?';
  if Application.MessageBox(PChar(CMsg), '', MB_YESNO + MB_ICONQUESTION) = IDNO then
  begin
    exit;
  end;

  tvconfig.Selected.Delete;

end;

procedure TFormWelcome.actExitExecute(Sender: TObject);
begin

  //为ntida赋值，指定各项参数
  ntida.cbSize := sizeof(tnotifyicondataa);
  ntida.wnd := handle;
  ntida.uID := iid;
  ntida.uFlags := nif_icon + nif_tip + nif_message;
  ntida.uCallbackMessage := mousemsg;
  ntida.hIcon := Application.Icon.handle;
  ntida.szTip := 'Icon';
  shell_notifyicona(NIM_DELETE, @ntida);
  //删除已有的应用程序图标
  Application.Terminate;

end;

procedure TFormWelcome.actGetCodeExecute(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'Explorer.exe', 'https://github.com/yasuofenglei/simpleLauncher', nil, 1);
end;

procedure TFormWelcome.actInfoExecute(Sender: TObject);
var
  MessageStr: string;

  function getVer: string;
  var
    FileName: string;
    InfoSize, Wnd: DWORD;
    VerBuf: Pointer;
    VerInfo: ^VS_FIXEDFILEINFO;
  begin
    Result := '0.0.0.0';
    FileName := Application.ExeName;
    InfoSize := GetFileVersionInfoSize(PChar(FileName), Wnd);
    if InfoSize <> 0 then
    begin
      GetMem(VerBuf, InfoSize);
      try
        if GetFileVersionInfo(PChar(FileName), Wnd, InfoSize, VerBuf) then
        begin
          VerInfo := nil;
          VerQueryValue(VerBuf, '\', Pointer(VerInfo), Wnd);
          if VerInfo <> nil then
            Result := Format('%d.%d.%d.%d', [VerInfo^.dwFileVersionMS shr 16, VerInfo^.dwFileVersionMS and $0000ffff, VerInfo^.dwFileVersionLS shr 16, VerInfo^.dwFileVersionLS and $0000ffff]);
        end;
      finally
        FreeMem(VerBuf, InfoSize);
      end;
    end;
  end;

begin
  MessageStr := simpleLauncher //
    + slinebreak + getVer;
  Application.MessageBox(Pchar(MessageStr), '', MB_OK + MB_ICONINFORMATION);

end;

procedure TFormWelcome.actModifyExecute(Sender: TObject);
var
  Value: string;
begin
  Value := tvConfig.Selected.Text;
  if InputQuery('修改', '请输入修改后的名称', Value) then
  begin
    tvConfig.Selected.Text := Value;
  end;
end;

procedure TFormWelcome.actOpenExecute(Sender: TObject);
begin

  ShellExecute(Handle, 'open', 'Explorer.exe', PChar(ExtractFileDir(Application.ExeName)), nil, 1);
end;

procedure TFormWelcome.actRefreshExecute(Sender: TObject);
begin
  if not ReadIni then
    Exit;
  if not ReadIniToTreeview then
    Exit;
end;

procedure TFormWelcome.AOpenDirExecute(Sender: TObject);
var
  Dir: string;
begin
  if TMenuItem(Sender).hint = '' then
    Exit;
  Dir := Rewrite(TMenuItem(Sender).Hint);

  ShellExecute(Handle, 'open', 'Explorer.exe', PChar(Dir), nil, 1);
end;

procedure TFormWelcome.btn2Click(Sender: TObject);
var
  Dir: string;
begin
  if SelectDirectory('选择目录 ', ' ', Dir) then
    EdtDir.Text := Dir;
end;

function TFormWelcome.ConfigIni: string;
begin
  //path,最后有\,dir最后没有\
  Result := ExtractFilePath(Application.ExeName) + 'config.ini';
end;

procedure TFormWelcome.EdtDirChange(Sender: TObject);
begin
  if tvconfig.Selected.Data <> nil then
  begin
    PDir(tvconfig.Selected.Data)^.CDir := EdtDir.Text;
  end;
end;

procedure TFormWelcome.FormClose(Sender: TObject; var Action: TCloseAction);
begin

  Action := caNone;   //不对窗体进行任何操作
  ShowWindow(Handle, SW_HIDE);   //隐藏主窗体
  //隐藏应用程序窗口在任务栏上的显示
  ShowWindow(Application.Handle, SW_HIDE);
  SetWindowLong(Application.Handle, GWL_EXSTYLE, GetWindowLong(Application.handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW and not WS_EX_APPWINDOW);
end;

procedure TFormWelcome.FormCreate(Sender: TObject);
begin
  tovis := False;

  ntida.cbSize := sizeof(tnotifyicondataa);   //指定ntida的长度
  ntida.Wnd := handle;   //取应用程序主窗体的句柄
  ntida.uID := iid;   //用户自定义的一个数值，在uCallbackMessage参数指定的消息中使
  ntida.uFlags := nif_icon + nif_tip + nif_message; //指定在该结构中uCallbackMessage、hIcon和szTip参数都有效
  ntida.uCallbackMessage := mousemsg; //指定的窗口消息
  ntida.hIcon := Application.Icon.handle; //指定系统状态栏显示应用程序的图标句柄
  ntida.szTip := simpleLauncher; //当鼠标停留在系统状态栏该图标上时，出现该提示信息
  shell_notifyicona(NIM_ADD, @ntida);  //在系统状态栏增加一个新图标

  Readini;
  ReadiniTotreeview;

end;

procedure TFormWelcome.FormPaint(Sender: TObject);
begin
  HideMain;
end;

procedure TFormWelcome.HideMain;
begin
  if tovis then
    Exit;

  ShowWindow(Handle, SW_HIDE);   //隐藏主窗体
  //隐藏应用程序窗口在任务栏上的显示
  ShowWindow(Application.Handle, SW_HIDE);
  SetWindowLong(Application.Handle, GWL_EXSTYLE, GetWindowLong(Application.handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW and not WS_EX_APPWINDOW);
  Tovis := True;
end;

procedure TFormWelcome.Mousemessage(var message: tmessage);
var
  mousept: TPoint;   //鼠标点击位置
begin
  GetCursorPos(mousept);
  if message.LParam = wm_rbuttonup then
  begin
    SetForegroundWindow(self.Handle); // 这句一定要加,否则弹出菜单不会自动隐藏 //用鼠标右键点击图标
//    getcursorpos(mousept);   //获取光标位置
//    pnRm.popup(mousept.x, mousept.y); //在光标位置弹出选单
    PmRm.Popup(mousept.X, mousept.Y);

  end;
  //用鼠标左键点击图标//显示应用程序窗口
  if message.LParam = wm_lbuttonup then
  begin
    SetForegroundWindow(self.Handle); // 这句一定要加,否则弹出菜单不会自动隐藏 //用鼠标右键点击图标

    pmlm.Popup(mousept.X, mousept.Y);
  end;


  //用鼠标左键点击图标//显示应用程序窗口
//  if message.LParam = wm_lbuttonup then
//  begin
//    ShowWindow(Handle, SW_SHOW);
//    //在任务栏上显示应用程序窗口
//    ShowWindow(Application.handle, SW_SHOW);
//    SetWindowLong(Application.Handle, GWL_EXSTYLE, not (GetWindowLong(Application.handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW and not WS_EX_APPWINDOW));
//  end;
  message.Result := 0;

end;

function TFormWelcome.ReadIni: Boolean;
var
  AiniFile: TiniFile;
  I, J, K: Integer;
  S: string;
  AIdent: string;
  ICount: Integer;
  AParentMenu: TMenuItem;
  AItem: TMenuItem;
  IsNewItem: Boolean;
  ITBCount: integer;
  ITBIndex: integer;
  ICO: TIcon;
begin
  Result := False;
  AiniFile := TiniFile.Create(Configini);
  FList := TStringList.Create;
  FList2 := TStringList.Create;
  PmLm.Items.Clear;
  ICO := TIcon.Create;
  try
    if not FileExists(AiniFile.FileName) then
    begin
      AERROR := '在目录下不存在' + AiniFile.FileName + ' ,请将该文件放该目录下!';
      ShowMessage(Aerror);
      Exit;
    end;
    //开始读取配置文件
    for I := 0 to IMenueMax do
    begin
      AIdent := menuIdent + inttostr(I);
      S := Trim(AiniFile.ReadString(CSection, AIdent, ''));
      if S = '' then
        Continue;
      FList.Clear;
      DivideData(FList, S, '|');
      ICount := FList.Count;
      AParentMenu := nil;
      for J := 0 to ICount - 1 do// 因为最后一个数据包含路径.
      begin
        DivideData(FList2, FList[J], '$');
        if pos('----', FList2[0]) > 0 then //认为是分隔线, 产生新菜单
        begin
          AItem := nil;
        end
        else
        begin
        //先查询是否有该菜单
          if AParentMenu = nil then
          begin
            AItem := PmLm.Items.Find(FList2[0]);
          end
          else
          begin
            AItem := AParentMenu.Find(FList2[0]);
          end;
        end;
        //如果没有菜单,则新建一个
        IsNewItem := AItem = nil;
        if IsNewItem then
        begin
          IsNewItem := True;
          AItem := TMenuItem.Create(Self);
          AItem.Caption := FList2[0];
          AItem.Name := 'menu' + inttostr(I) + 'm' + inttostr(J);
          //
          if Flist2.Count > 1 then
          begin
            AItem.Hint := FList2[1];
          //加载EXE图标
            ITBCount := ExtractIcon(HInstance, PChar(FList2[1]), $FFFFFFFF);
            if ITBCount > 0 then
            begin
              ICO.Handle := ExtractIcon(HInstance, PChar(FList2[1]), 0);
              ilmenu.AddIcon(ICO);
              AItem.ImageIndex := ilmenu.Count - 1;
            end
            else
            begin
              if Pos('.exe', Flist2[1]) > 0 then
              begin
                AItem.ImageIndex := 2;

              end
              else if (Pos('http://', Flist2[1]) > 0) or (Pos('https://', Flist2[1]) > 0) then
              begin
                AItem.ImageIndex := 1;
              end
              else
              begin
                AItem.ImageIndex := 0;
              end;

            end;
          end;

          AItem.OnClick := AOpenDirExecute;
        end;

        //1级菜单
        if AParentMenu = nil then
        begin
          if IsNewItem then
          begin
            PmLm.Items.Add(AItem);
          end;
        end;
        //下级菜单
        if AParentMenu <> nil then
        begin
          if IsNewItem then
          begin
            AParentMenu.Add(AItem);
          end;
        end;
        AParentMenu := AItem;
      end;

    end;
  finally
    AiniFile.Free;
    FList.Clear;
    FList2.Clear;
    ICO.Free;
  end;
  Result := True;
end;

function TFormWelcome.ReadIniToTreeview: Boolean;
var
  AiniFile: TiniFile;
  I, J, K: Integer;
  S: string;
  AIdent: string;
  ICount: Integer;
  AParentNode: TTreeNode;
  Anode: TTreeNode;
  IsNewItem: Boolean;

  function findNode(FNode: TTreeNode; AValue: string; BFirst: Boolean = false): TTreeNode;
  var
    Node: TTreenode;
  begin
    Result := nil;
    if FNode = nil then
    begin
      Result := nil;
      Exit;
    end;
    Node := FNode;
    while Node <> nil do
    begin
      if Node.Text = AValue then
      begin
        if BFirst then
        begin
          if Node.Parent = nil then
          begin
            Result := Node;
            Exit;
          end;

        end
        else
        begin
          Result := Node;
          Exit;
        end;
      end;
      Node := Node.GetNext;
    end;

  end;

begin
  Result := False;
  AiniFile := TiniFile.Create(Configini);
  FList := TStringList.Create;
  FList2 := TStringList.Create;
  TvConfig.items.Clear;
  try
    if not FileExists(AiniFile.FileName) then
    begin
      AERROR := '在' + AiniFile.FileName + '下不存在该文件,请该文件放在该目录下!';
      ShowMessage(Aerror);
      Exit;
    end;
    //开始读取配置文件
    for I := 0 to IMenueMax do
    begin
      AIdent := menuIdent + inttostr(I);
      S := Trim(AiniFile.ReadString(CSection, AIdent, ''));
      if S = '' then
        Continue;
      FList.Clear;
      DivideData(FList, S, '|');
      ICount := FList.Count;
      AParentNode := nil;
      for J := 0 to ICount - 1 do// 因为最后一个数据包含路径.
      begin
        DivideData(FList2, FList[J], '$');
        if pos('----', FList2[0]) > 0 then //认为是分隔线, 产生新菜单
        begin
          Anode := nil;
        end
        else
        begin
//        先查询是否有该菜单
          if AParentNode = nil then
          begin
            Anode := findNode(tvconfig.Items.GetFirstNode, FList2[0], true);
          end
          else
          begin
            Anode := findNode(AParentNode.getFirstChild, FList2[0]);
          end;
        end;
        //如果没有菜单,则新建一个
        IsNewItem := Anode = nil;
        if IsNewItem then
        begin
          if AParentNode = nil then
          begin
            Anode := tvConfig.Items.Add(Anode, Flist2[0]);
          end
          else
          begin
            Anode := tvconfig.Items.AddChild(AParentNode, Flist2[0]);
          end;
          if Flist2.Count > 1 then
          begin
            Anode.Data := New(PDir);
            PDir(Anode.Data)^.CDir := Flist2[1];
          end;

        end;

        //1级菜单
//        if AParentMenu = nil then
//        begin
//          if IsNewItem then
//          begin
//            PmLm.Items.Add(AItem);
//          end;
//        end;
//        //下级菜单
//        if AParentMenu <> nil then
//        begin
//          if IsNewItem then
//          begin
//            AParentMenu.Add(AItem);
//          end;
//        end;
        AParentNode := Anode;
      end;

    end;
  finally
    AiniFile.Free;
    FList.Clear;
    FList2.Clear;
  end;
  Result := True;
end;

function TFormWelcome.ReWrite(S: string): string;
var
  I1, I2: Integer;
  Str1, Str2: string;
begin
  Result := S;
  //日期替换
  I1 := pos('[', Result);
  repeat
    if I1 > 0 then
    begin
      I2 := Pos(']', Result);
      Str1 := Copy(Result, I1 + 1, I2 - I1 - 1);
      Str2 := FormatDateTime(Str1, Now);
      Result := StringReplace(Result, '[' + Str1 + ']', Str2, [rfReplaceAll, rfIgnoreCase])
    end;
    I1 := pos('[', Result);
  until I1 <= 0
end;

procedure TFormWelcome.tvConfigChange(Sender: TObject; Node: TTreeNode);
begin
  if Node.Data <> nil then
  begin
    EdtDir.Text := PDir(Node.Data)^.CDir;
  end
  else
  begin
    edtdir.Clear;
  end;
  //检查是否有子节点
  if Node.Count > 0 then
  begin
    pnlWrite.Enabled := false;
  end
  else
  begin
    pnlWrite.Enabled := true;
  end;

end;

procedure TFormWelcome.tvConfigDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  node: TTreeNode;
begin
  node := tvConfig.GetNodeAt(X, Y);
  if node <> nil then
  begin
    tvConfig.Selected.MoveTo(node, naAddChild);
     // 将节点移动到目标节点的下一级，也就是使目标节点成为被拖动节点的父节点
    tvConfig.EndDrag(True);
  end
  else
  begin
    tvConfig.Selected.MoveTo(node, naAdd);
    tvConfig.EndDrag(false);
    //
//  TNodeAttachMode = (naAdd, naAddFirst, naAddChild, naAddChildFirst, naInsert);
  end;
end;

procedure TFormWelcome.tvConfigDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  if Source <> nil then
    Accept := True;
end;

procedure TFormWelcome.tvConfigMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  node: TTreeNode;
begin
  node := tvConfig.GetNodeAt(X, Y);  // 获取鼠标按下位置的节点
//  if (node <> nil) and (node.Level > 0) and (Button = mbLeft) then
  if node <> nil then
    tvConfig.BeginDrag(False);  // 启动拖动
end;

procedure TFormWelcome.btnConfigClick(Sender: TObject);
begin
  if not OpenAdd.Execute then
    exit;
  edtDir.Text := OpenAdd.FileName;
end;

procedure TFormWelcome.btnSaveConfigClick(Sender: TObject);
var
  AiniFile: Tinifile;
  IMenueCount: Integer;
  I: Integer;
  Aident: string;
  ANode: TTreeNode;
  Value: string;
  AParentNode: TTreeNode;
begin

  IMenueCount := Tvconfig.Items.Count;
  AiniFile := TiniFile.Create(Configini);
  try
    for I := 0 to IMenueCount - 1 do
    begin
      Aident := menuIdent + inttostr(I);
      ANode := tvconfig.Items[I];
      if ANode.Count = 0 then
      begin
        Value := '';
        if ANode.data <> nil then
        begin
          Value := Value + '$' + PDir(ANode.Data)^.CDir
        end;
        Value := ANode.Text + Value;
        //
        AParentNode := ANode.Parent;
        while AParentNode <> nil do
        begin
          Value := AParentNode.Text + '|' + Value;
          AParentNode := AParentNode.Parent;
        end;
        AiniFile.WriteString(CSection, Aident, Value);
      end
      else
      begin
        AiniFile.WriteString(CSection, Aident, '');

      end;

    end;
    for I := IMenueCount to IMenueMax do
    begin
      Aident := menuIdent + inttostr(I);
//      AiniFile.WriteString(CSection, Aident, '');
      AiniFile.DeleteKey(CSection, Aident);
    end;
  finally
    AiniFile.Free;
  end;
  Readini;
  ReadiniTotreeview;
  formWelcome.close;

end;

end.

