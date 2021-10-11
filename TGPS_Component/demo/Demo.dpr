program Demo;

uses
  Forms,
  UDemo in 'UDemo.pas' {FDemo};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFDemo, FDemo);
  Application.Run;
end.
