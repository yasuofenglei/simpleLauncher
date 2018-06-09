unit welcome;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Winapi.ShellAPI, Vcl.Menus,
  System.Actions, Vcl.ActnList, System.IniFiles, uFunction, System.ImageList,
  Vcl.ImgList,udata;

const
  mousemsg = wm_user + 1; //�Զ�����Ϣ�����ڴ����û���ͼ���ϵ�������¼�
  iid = 100;   //�û��Զ�����ֵ����TnotifyIconDataA����ȫ�ֱ���ntida��ʹ��
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
    ntida: TNotifyIcondataA;  //�������Ӻ�ɾ��ϵͳ״̬ͼ��
    Tovis: Boolean; //�Ƿ��Ѿ��״�ˢ�¹�����.
    procedure HideMain; //����������
    //�Զ�����Ϣ�������������������ͼ���¼�
    procedure Mousemessage(var message: tmessage); message mousemsg;
    //������
    function ConfigIni: string;
    //��ȡ�����ļ�
    function ReadIni: Boolean;
    //��·���˵�
    procedure AOpenDirExecute(Sender: TObject);
    //��д·��
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
  //��δ�����ù���.
  ShowWindow(Handle, SW_SHOW);
    //������������ʾӦ�ó��򴰿�
  ShowWindow(Application.handle, SW_SHOW);
  SetWindowLong(Application.Handle, GWL_EXSTYLE, not (GetWindowLong(Application.handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW and not WS_EX_APPWINDOW));

end;

procedure TFormWelcome.actExitExecute(Sender: TObject);
begin

  //Ϊntida��ֵ��ָ���������
  ntida.cbSize := sizeof(tnotifyicondataa);
  ntida.wnd := handle;
  ntida.uID := iid;
  ntida.uFlags := nif_icon + nif_tip + nif_message;
  ntida.uCallbackMessage := mousemsg;
  ntida.hIcon := Application.Icon.handle;
  ntida.szTip := 'Icon';
  shell_notifyicona(NIM_DELETE, @ntida);
  //ɾ�����е�Ӧ�ó���ͼ��
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
  //path,�����\,dir���û��\
  Result := ExtractFilePath(Application.ExeName) + 'config.ini';
end;

procedure TFormWelcome.FormClose(Sender: TObject; var Action: TCloseAction);
begin

  Action := caNone;   //���Դ�������κβ���
  ShowWindow(Handle, SW_HIDE);   //����������
  //����Ӧ�ó��򴰿����������ϵ���ʾ
  ShowWindow(Application.Handle, SW_HIDE);
  SetWindowLong(Application.Handle, GWL_EXSTYLE, GetWindowLong(Application.handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW and not WS_EX_APPWINDOW);
end;

procedure TFormWelcome.FormCreate(Sender: TObject);
begin
  tovis := False;

  ntida.cbSize := sizeof(tnotifyicondataa);   //ָ��ntida�ĳ���
  ntida.Wnd := handle;   //ȡӦ�ó���������ľ��
  ntida.uID := iid;   //�û��Զ����һ����ֵ����uCallbackMessage����ָ������Ϣ��ʹ
  ntida.uFlags := nif_icon + nif_tip + nif_message; //ָ���ڸýṹ��uCallbackMessage��hIcon��szTip��������Ч
  ntida.uCallbackMessage := mousemsg; //ָ���Ĵ�����Ϣ
  ntida.hIcon := Application.Icon.handle; //ָ��ϵͳ״̬����ʾӦ�ó����ͼ����
  ntida.szTip := 'easyLanucher!'; //�����ͣ����ϵͳ״̬����ͼ����ʱ�����ָ���ʾ��Ϣ
  shell_notifyicona(NIM_ADD, @ntida);  //��ϵͳ״̬������һ����ͼ��

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

  ShowWindow(Handle, SW_HIDE);   //����������
  //����Ӧ�ó��򴰿����������ϵ���ʾ
  ShowWindow(Application.Handle, SW_HIDE);
  SetWindowLong(Application.Handle, GWL_EXSTYLE, GetWindowLong(Application.handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW and not WS_EX_APPWINDOW);
  Tovis := True;
end;

procedure TFormWelcome.Mousemessage(var message: tmessage);
var
  mousept: TPoint;   //�����λ��
begin
  GetCursorPos(mousept);
  if message.LParam = wm_rbuttonup then
  begin
    SetForegroundWindow(self.Handle); // ���һ��Ҫ��,���򵯳��˵������Զ����� //������Ҽ����ͼ��
//    getcursorpos(mousept);   //��ȡ���λ��
//    pnRm.popup(mousept.x, mousept.y); //�ڹ��λ�õ���ѡ��
    PmRm.Popup(mousept.X, mousept.Y);

  end;
  //�����������ͼ��//��ʾӦ�ó��򴰿�
  if message.LParam = wm_lbuttonup then
  begin
    SetForegroundWindow(self.Handle); // ���һ��Ҫ��,���򵯳��˵������Զ����� //������Ҽ����ͼ��

    pmlm.Popup(mousept.X, mousept.Y);
  end;


  //�����������ͼ��//��ʾӦ�ó��򴰿�
//  if message.LParam = wm_lbuttonup then
//  begin
//    ShowWindow(Handle, SW_SHOW);
//    //������������ʾӦ�ó��򴰿�
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
      AERROR := '��' + AiniFile.FileName + '�²����ڸ��ļ�,����ļ����ڸ�Ŀ¼��!';
      Exit;
    end;
    //��ʼ��ȡ�����ļ�
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
      for J := 0 to ICount - 1 do//ֻȡ�������ڶ�������, ��Ϊ���һ��������·��.
      begin
//        DataFJ(FList[J], '$');
        DivideData(FList2, FList[J], '$');
        if pos('----', FList2[0]) > 0 then //��Ϊ�Ƿָ���, �����²˵�
        begin
          AItem := nil;
        end
        else
        begin
        //�Ȳ�ѯ�Ƿ��иò˵�
          if AParentMenu = nil then
          begin
            AItem := PmLm.Items.Find(FList2[0]);
          end
          else
          begin
            AItem := AParentMenu.Find(FList2[0]);
          end;
        end;
        //���û�в˵�,���½�һ��
        if AItem = nil then
        begin
          IsNewItem := True;
          AItem := TMenuItem.Create(Self);
          AItem.Caption := FList2[0];
          AItem.Name := 'menu' + inttostr(I) + 'm' + inttostr(J);
          if Flist2.Count > 1 then
          begin

            AItem.Hint := FList2[1];
          //����EXEͼ��
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
        //1���˵�
        if AParentMenu = nil then
        begin
          if IsNewItem then
            PmLm.Items.Add(AItem);
        end;
        //�¼��˵�
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
  //�����滻
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
