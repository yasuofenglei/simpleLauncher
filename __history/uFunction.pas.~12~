unit uFunction;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Winapi.ShellAPI, Vcl.Menus,
  System.Actions, Vcl.ActnList, System.IniFiles;

procedure DivideData(out AList: Tstrings; Value: string; Divide: string);

implementation

procedure DivideData(out AList: Tstrings; Value: string; Divide: string);
var
  CurrValue: string;
  leavingsValue: string;
  IIndex: integer;
begin
  AList.Clear;
  leavingsValue := Value;
  while pos(Divide, leavingsValue) > 0 do
  begin
    IIndex := pos(Divide, Value);
    CurrValue := Copy(leavingsValue, 1, IIndex - 1);
    leavingsValue := Copy(leavingsValue, IIndex + 1, length(leavingsValue) - IIndex);
    AList.Add(CurrValue);

  end;
  CurrValue := leavingsValue;
  AList.Add(CurrValue);

end;

end.

