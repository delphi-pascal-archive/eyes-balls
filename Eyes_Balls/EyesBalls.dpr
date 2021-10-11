program EyesBalls;

uses
  Forms,
  NP in 'NP.pas' {MainFrm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Eyes Balls';
  Application.CreateForm(TMainFrm, MainFrm);
  Application.Run;
end.
