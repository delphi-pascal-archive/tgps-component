unit UDemo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, GPS, StdCtrls, CPortCtl, ExtCtrls;

type
  TFDemo = class (TForm)
    GPS1: TGPS;
    BTN_Start: TButton;
    LBL_Latitude: TLabel;
    LBL_Longitude: TLabel;
    LBL_Altitude: TLabel;
    LBL_NbSats: TLabel;
    LBL_NbSatsUsed: TLabel;
    SHP_Connected: TShape;
    CMB_COMPort: TComComboBox;
    Label1: TLabel;
    CHK_Valid: TCheckBox;
    LBL_Speed: TLabel;
    LBL_Time: TLabel;
    procedure CMB_COMPortChange(Sender: TObject);
    procedure BTN_StartClick(Sender: TObject);
    procedure GPS1AfterOpen(Sender: TObject);
    procedure GPS1AfterClose(Sender: TObject);
    procedure GPS1GPSDatasChange(Sender: TObject; GPSDatas: TGPSDatas);
    procedure CHK_ValidClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  FDemo: TFDemo;

implementation

{$R *.dfm}

procedure TFDemo.CMB_COMPortChange(Sender: TObject);
begin
  GPS1.Port := CMB_COMPort.Text;
end;

procedure TFDemo.BTN_StartClick(Sender: TObject);
begin
  if GPS1.Connected then
    GPS1.Close()
  else
  begin
    GPS1.Port := CMB_COMPort.Text;
    GPS1.Open();
  end;
end;

procedure TFDemo.GPS1AfterOpen(Sender: TObject);
begin
  SHP_Connected.Brush.Color := clLime;
  BTN_Start.Caption := 'Stop';
end;

procedure TFDemo.GPS1AfterClose(Sender: TObject);
begin
  SHP_Connected.Brush.Color := clGray;
  BTN_Start.Caption := 'Start';
end;

procedure TFDemo.GPS1GPSDatasChange(Sender: TObject; GPSDatas: TGPSDatas);
begin
  with GPSDatas do
  begin
    LBL_Latitude.Caption := Format('Latitude: %2.6f°', [Latitude]);
    LBL_Longitude.Caption := Format('Longitude: %2.6f°', [Longitude]);
    LBL_Altitude.Caption := Format('Altitude: %f m', [HeightAboveSea]);
    LBL_Speed.Caption := Format('Speed: %f km/h', [Speed]);

    LBL_NbSats.Caption := Format('Number of satellites: %d', [NbrSats]);
    LBL_NbSatsUsed.Caption :=
      Format('Number of satellites used: %d', [NbrSatsUsed]);
    LBL_Time.Caption := Format('UTC Time: %s', [TimeToStr(UTCTime)]);

    CHK_Valid.Checked := Valid;
  end;
  Application.ProcessMessages();
end;

procedure TFDemo.CHK_ValidClick(Sender: TObject);
begin
  CHK_Valid.Checked := GPS1.GPSDatas.Valid;
end;

procedure TFDemo.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  GPS1.Close();
end;

end.
