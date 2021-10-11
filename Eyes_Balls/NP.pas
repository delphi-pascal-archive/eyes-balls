unit NP;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Menus, ShellApi, XpMan, IniFiles, AppEvnts;

  const
   Tray   = Wm_User + 1;

 type
   TMainFrm = class(TForm)
    T1: TTimer;
    T2: TTimer;
    TrayMenu: TPopupMenu;
    HomePageItem: TMenuItem;
    AboutItem: TMenuItem;
    SourceCodeItem: TMenuItem;
    OnTopItem: TMenuItem;
    CloseItem: TMenuItem;
    RunCursorItem: TMenuItem;
    sp1: TMenuItem;
    sp2: TMenuItem;
    sp3: TMenuItem;
    AnimationItem: TMenuItem;
    ApplicationEvents: TApplicationEvents;

    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure T1Timer(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
    procedure f1Click(Sender: TObject);
    procedure T2Timer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CloseItemClick(Sender: TObject);
    procedure HomePageItemClick(Sender: TObject);
    procedure RunCursorItemClick(Sender: TObject);
    procedure OnTopItemClick(Sender: TObject);
    procedure SourceCodeItemClick(Sender: TObject);
    procedure AboutItemClick(Sender: TObject);
    procedure ApplicationEventsIdle(Sender: TObject; var Done: Boolean);
    procedure FormShow(Sender: TObject);

  private

    Ini: TIniFile;

    Pos : TPoint;

    Icon: TNotifyIconData;

    procedure SystemTrayIcon(var SysTrayIcon: TMessage);
    message Tray;

    procedure EyesBalls(const EyesPupil: TRect);

    procedure WMHotKey(var a: TWMHotKey);
    message WM_HOTKEY;

  public

  end;

var
  MainFrm: TMainFrm;

implementation

{$R *.dfm}

procedure TMainFrm.EyesBalls(const EyesPupil: TRect);
const
PUPIL_WIDTH  = 10;
PUPIL_HEIGHT = 14;
MOVE_RADIUS  = 8;
FULL_DIST    = 40;
var
eyePos    : TPoint;
eyeDist   : integer;
dx, dy    : integer;
pupilRect : TRect;
begin
eyePos    := Point((EyesPupil.Left + EyesPupil.Right) div 2, (EyesPupil.Top + EyesPupil.Bottom) div 2);
pupilRect := Rect(eyePos.X - PUPIL_WIDTH div 2, eyePos.Y - PUPIL_HEIGHT div 2,
eyePos.X + PUPIL_WIDTH div 2 +1, eyePos.Y + PUPIL_HEIGHT div 2 + 1);
eyePos  := ClientToScreen(eyePos);
dx      := Pos.X - eyePos.X;
dy      := Pos.Y - eyePos.Y;
eyeDist := Round(Sqrt(Sqr(dx) + Sqr(dy)));
if (eyeDist > FULL_DIST) then
begin
OffsetRect(pupilRect, MulDiv(dx, MOVE_RADIUS, eyeDist), MulDiv(dy, MOVE_RADIUS, eyeDist));
end else
if (eyeDist > 0) then
begin
OffsetRect(pupilRect, MulDiv(dx, MulDiv(MOVE_RADIUS, eyeDist, FULL_DIST), eyeDist),
MulDiv(dy, MulDiv(MOVE_RADIUS, eyeDist, FULL_DIST), eyeDist));
end;
Canvas.Ellipse(pupilRect);
end;

procedure TMainFrm.FormCreate(Sender: TObject);
var
hMutex: Integer;
begin
RegisterHotKey(Handle, 1, MOD_CONTROL or MOD_ALT, ord('R'));
RegisterHotKey(Handle, 2, MOD_CONTROL or MOD_ALT, ord('A'));
DoubleBuffered := true;
with Icon do
begin
Wnd := Handle;
SzTip := 'Eyes Balls';
HIcon := Application.Icon.Handle;
UCallBackMessage := Tray;
UFlags := Nif_Tip + Nif_Message or Nif_Icon;
Shell_NotifyIcon(Nim_Add, @Icon);
end;
hMutex := CreateMutex(nil, true , 'Eyes Balls');
if GetLastError = ERROR_ALREADY_EXISTS then
Halt;
Ini := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
try
OnTopItem.Checked := Ini.ReadBool('Parameters', 'Always on top', OnTopItem.Checked);
RunCursorItem.Checked := Ini.ReadBool('Parameters', 'Run cursor', RunCursorItem.Checked);
AnimationItem.Checked := Ini.ReadBool('Parameters', 'Animation', AnimationItem.Checked);
except
end;
end;

procedure TMainFrm.FormPaint(Sender: TObject);
const
LEFT_EYE  : TRect = (Left:24; Top:8; Right:50; Bottom:38);
RIGHT_EYE : TRect = (Left:52; Top:8; Right:78; Bottom:38);
begin
Canvas.Brush.Color := clWhite;
Canvas.Brush.Style := bsSolid;
Canvas.Pen.Color   := clBlack;
Canvas.Pen.Style   := psSolid;
Canvas.Pen.Width   := 1;
Canvas.Ellipse(LEFT_EYE);
Canvas.Ellipse(RIGHT_EYE);
Canvas.Brush.Color := clBlack;
Canvas.Brush.Style := bsSolid;
Canvas.Pen.Style   := psClear;
EyesBalls(LEFT_EYE);
EyesBalls(RIGHT_EYE);
end;

procedure TMainFrm.T1Timer(Sender: TObject);
var
mousePos : TPoint;
begin
if AnimationItem.Checked then
begin
mousePos := Mouse.CursorPos;
if (mousePos.X <> Pos.X) or (mousePos.Y <> Pos.Y) then
begin
self.Invalidate;
Pos := mousePos;
end;
end;
end;

procedure TMainFrm.FormMouseDown(Sender: TObject; Button: TMouseButton;
Shift: TShiftState; X, Y: Integer);
begin
ReleaseCapture;
Perform(Wm_SysCommand, $f012, 0);
end;

procedure TMainFrm.f1Click(Sender: TObject);
begin
Close;
end;

procedure TMainFrm.T2Timer(Sender: TObject);
var
dx,dy,i: integer;
point: Tpoint;
begin
GetCursorPos(point);
Dx:=point.X-MainFrm.Left;
dx:=round(19*dx/20);
MainFrm.Left:=point.X-dx;
Dy:=point.y-MainFrm.top;
dy:=round(19*dy/20);
MainFrm.top:=point.y-dy;
end;

procedure TMainFrm.SystemTrayIcon(var SysTrayIcon: TMessage);
var
Ico: TPoint;
begin
case SysTrayIcon.LParam of
WM_LBUTTONDOWN:
begin
SetForegroundWindow(Handle);
GetCursorPos(Ico);
TrayMenu.Popup(Ico.X, Ico.Y);
end;
WM_RBUTTONDOWN:
begin
SetForegroundWindow(Handle);
GetCursorPos(Ico);
TrayMenu.Popup(Ico.X, Ico.Y);
end;
end;
end;

procedure TMainFrm.FormDestroy(Sender: TObject);
begin
Shell_NotifyIcon(Nim_Delete, @Icon);
UnRegisterHotKey(Handle, 1);
UnRegisterHotKey(Handle, 2);
ApplicationEvents.Free;
TrayMenu.Free;
Ini.Free;
T1.Free;
T2.Free;
end;

procedure TMainFrm.CloseItemClick(Sender: TObject);
begin
Close;
end;

procedure TMainFrm.HomePageItemClick(Sender: TObject);
begin
ShellExecute(Handle, nil, 'http://viacoding.mylivepage.ru/', nil, nil, Sw_ShowNormal);
end;

procedure TMainFrm.RunCursorItemClick(Sender: TObject);
begin
if RunCursorItem.Checked then
T2.Enabled := True else
T2.Enabled := False;
end;

procedure TMainFrm.OnTopItemClick(Sender: TObject);
begin
if OnTopItem.Checked = False then
begin
SetWindowPos(Handle, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE+SWP_NOSIZE);
end else begin
SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE+SWP_NOSIZE);
end;
end;

procedure TMainFrm.SourceCodeItemClick(Sender: TObject);
begin
if Application.MessageBox(
'Copyright @2009 Домани Олег (aka ?КТО_Я?)' + #13 +
'======================================' + #13 + #13 + '' +
'Если Вы хотите получить исходный код проекта (архив ' + #13
+ 'с компонентами по желанию пользователя), а также'
+ #13 + 'все последующие новые версии программы, то' + #13 +
'отправьте электронное письмо автору.' + #13 +
'' +  #13 + '======================================' +  #13 +
'' +  #13 +
'Отправить письмо сейчас?',
'Eyes Balls',
mb_IconAsterisk + mb_YesNo) = idYes then
begin
ShellExecute(Handle, 'open',
'mailto:viacoding@mail.ru?Subject=Eyes Balls Project' +
'&Body=Hello, please send me the source code program. Thanks!',
'', '', SW_SHOW);
end;
end;

procedure TMainFrm.AboutItemClick(Sender: TObject);
begin
AboutItem.Enabled := False;
Application.MessageBox(PChar(
'Copyright @2009 Домани Олег (aka ?КТО_Я?)' + #13 +
'=================================='
+ #13 + #13 +
'Eyes Balls v.1.0' + #13 +
'Шуточная программа, которая следит за вашим' +
#13 + 'курсором.'
+ #13 + #13 + '==================================' +  #13
+ 'Контактная информация.'  + #13
+ #13 + 'Home page: http://www.viacoding.mylivepage.ru/'
+ #13 + 'E-mail: GoodWinNix@mail.ru'
+ #13 + 'E-mail: viacoding@mail.ru'
+ #13 + 'ICQ: 415660036'),
'О программе Eyes Balls',
mb_IconAsterisk + MB_OK);
AboutItem.Enabled := True;
end;

procedure TMainFrm.ApplicationEventsIdle(Sender: TObject;
var Done: Boolean);
begin
Ini.WriteBool('Parameters', 'Always on top', OnTopItem.Checked);
Ini.WriteBool('Parameters', 'Run cursor', RunCursorItem.Checked);
Ini.WriteBool('Parameters', 'Animation', AnimationItem.Checked);
end;

procedure TMainFrm.FormShow(Sender: TObject);
begin
ShowWindow(Application.Handle, SW_HIDE);
if OnTopItem.Checked = False then
begin
SetWindowPos(Handle, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE+SWP_NOSIZE);
end else begin
SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE+SWP_NOSIZE);
end;
if RunCursorItem.Checked then
T2.Enabled := True else
T2.Enabled := False;
end;

procedure TMainFrm.WMHotKey(var a: TWMHotKey);
begin
if a.HotKey = 1 then
RunCursorItem.Click;
if a.HotKey = 2 then
AnimationItem.Click;
end;

end.
