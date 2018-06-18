program simpleLauncher;

uses
  Vcl.Forms,
  welcome in 'welcome.pas' {FormWelcome},
  uFunction in 'uFunction.pas',
  uData in 'uData.pas' {DataModule1: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormWelcome, FormWelcome);
  Application.CreateForm(TDataModule1, DataModule1);
  Application.Run;
end.
