unit welcome;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Winapi.ShellAPI, Vcl.Menus,
  System.Actions, Vcl.ActnList, System.IniFiles, uFunction, System.ImageList,
  Vcl.ImgList,udata;

const
  mousemsg = wm_user + 1; //自定义消息，用于处理用户在图标上点击鼠标的事件
  iid = 100;   //用户自定义数值，在TnotifyIconDataA类型全局变量ntida中使用
  CSection: string = 'DIR';

type
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
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormPaint(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actConfigExecute(Sender: TObject);
    procedure actRefreshExecute(Sender: TObject);
    procedure actOpenExecute(Sender: TObject);
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

procedure TFormWelcome.actConfigExecute(Sender: TObject);
var
  TXTfileName: string;
begin
  TXTfileName := Configini;
  ShellExecute(Handle, 'Open', PChar('notepad.exe'), PChar(TXTfileName), nil, SW_SHOWNORMAL);
  Exit;
  //暂未做配置功能.
  ShowWindow(Handle, SW_SHOW);
    //在任务栏上显示应用程序窗口
  ShowWindow(Application.handle, SW_SHOW);
  SetWindowLong(Application.Handle, GWL_EXSTYLE, not (GetWindowLong(Application.handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW and not WS_EX_APPWINDOW));

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

procedure TFormWelcome.actOpenExecute(Sender: TObject);
begin

  ShellExecute(Handle, 'open', 'Explorer.exe', PChar(ExtractFileDir(Application.ExeName)), nil, 1);
end;

procedure TFormWelcome.actRefreshExecute(Sender: TObject);
begin
  if not ReadIni then
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

function TFormWelcome.ConfigIni: string;
begin
  //path,最后有\,dir最后没有\
  Result := ExtractFilePath(Application.ExeName) + 'config.ini';
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
  ntida.szTip := 'easyLanucher!'; //当鼠标停留在系统状态栏该图标上时，出现该提示信息
  shell_notifyicona(NIM_ADD, @ntida);  //在系统状态栏增加一个新图标

  if not ReadIni then
    Exit;

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
//  LastMenu:string;
  AParentMenu: TMenuItem;
  AItem: TMenuItem;
  IsNewItem: Boolean;
  SecondItem: TMenuItem;
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
      AERROR := '在' + AiniFile.FileName + '下不存在该文件,请该文件放在该目录下!';
      Exit;
    end;
    //开始读取配置文件
    for I := 0 to 1000 do
    begin
      AIdent := 'menu' + inttostr(I);
      S := Trim(AiniFile.ReadString(CSection, AIdent, ''));
      if S = '' then
        Continue;
      FList.Clear;
      DivideData(FList, S, '|');
      ICount := FList.Count;
      AParentMenu := nil;
      for J := 0 to ICount - 1 do//只取到倒数第二个数据, 因为最后一个数据是路径.
      begin
//        DataFJ(FList[J], '$');
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
        if AItem = nil then
        begin
          IsNewItem := True;
          AItem := TMenuItem.Create(Self);
          AItem.Caption := FList2[0];
          AItem.Name := 'menu' + inttostr(I) + 'm' + inttostr(J);
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

            end;
          end;

          AItem.OnClick := AOpenDirExecute;
        end
        else
        begin
          IsNewItem := False;
        end;
        //1级菜单
        if AParentMenu = nil then
        begin
          if IsNewItem then
            PmLm.Items.Add(AItem);
        end;
        //下级菜单
        if AParentMenu <> nil then
        begin
          if IsNewItem then
            AParentMenu.Add(AItem);
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

end.

