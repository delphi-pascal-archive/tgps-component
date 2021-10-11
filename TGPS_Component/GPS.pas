(******************************************************************************)
(* Copyright © 2010, PLAIS Lionel All rights reserved.                        *)
(*                                                                            *)
(* Redistribution and use in source and binary forms, with or without         *)
(* modification, are permitted provided that the following conditions are     *)
(* met:                                                                       *)
(*                                                                            *)
(* Redistributions of source code must retain the above copyright notice,     *)
(* this list of conditions and the following disclaimer. Redistributions in   *)
(* binary form must reproduce the above copyright notice, this list of        *)
(* conditions and the following disclaimer in the documentation and/or        *)
(* other materials provided with the distribution. Neither the name of the    *)
(* ILP-WEB NETWORK nor the names of its contributors may be used to endorse   *)
(* or promote products derived from this software without specific prior      *)
(* written permission.                                                        *)
(*                                                                            *)
(* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS    *)
(* IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED      *)
(* TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A            *)
(* PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT         *)
(* HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,     *)
(* SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED   *)
(* TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR     *)
(* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF     *)
(* LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING       *)
(* NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS         *)
(* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.               *)
(******************************************************************************)
(******************************************************************************)
(* File: GPS.pas                                                              *)
(* Component(s): TGPS                                                         *)
(* Components for the management of the NMEA 0183 frames received on COM      *)
(* ports.                                                                     *)
(* Copyright © 2010 ILP-WEB NETWORK                                           *)
(* Author(s) : PLAIS Lionel (lionel.plais@ilp-web.net)                        *)
(******************************************************************************)
unit GPS;
{$D-}

interface

uses
  SysUtils, Classes, Windows, CPortTypes, CPort, Math, StrUtils, ConvUtils, StdConvs;

const
  // Maximum number of satellites referenced
  MAX_SATS = 12;
  // Characters starting and ending frames NMEA 0183
  MSG_START: String = '$';
  MSG_STOP: String = '*';

type
  // Satellite properties
  TSatellite = record
    Identification: Shortint;
    Elevation: 0..90;
    Azimut: Smallint;
    SignLevel: Smallint;
  end;
  // Array of satellites referenced
  TSatellites = array[1..MAX_SATS] of TSatellite;
  TGPSSatEvent = procedure(Sender: TObject; NbSat, NbSatUse: Shortint; Sats: TSatellites) of object;

  // GPS status informations
  TGPSDatas = record
    Latitude: Double;
    Longitude: Double;
    HeightAboveSea: Double;
    Speed: Double;
    UTCTime: TDateTime;
    Valid: Boolean;
    NbrSats: Shortint;
    NbrSatsUsed: Shortint;
  end;
  TGPSDatasEvent = procedure(Sender: TObject; GPSDatas: TGPSDatas) of object;

  // NMEA 0185's messages used
  TMsgGP = (
    msgGP,    // Unknown message
    msgGPGGA, // Global Positioning System Fix Data
    msgGPGLL, // Geographic position, Latitude and Longitude
    msgGPGSV, // Satellites in view
    msgGPRMA, // Recommended minimum specific GPS/Transit data Loran C
    msgGPRMC, // Recommended minimum specific GPS/Transit data
    msgGPZDA  // Date and time 
    );

  TGPS = class (TComponent)
  private
    // COM Port components
    FCOMPort: TComPort;
    FCOMDataPacket: TComDataPacket;

    // State of the TGPS component
    FConnected: Boolean;

    // COM Port parameters
    FPort: TPort;
    FBaudRate: TBaudRate;
    FDataBits: TDataBits;
    FStopBits: TStopBits;
    FParity: TComParity;
    FFlowControl: TComFlowControl;

    // GPS informations
    FSatellites: TSatellites;
    FGPSDatas: TGPSDatas;

    // Notifications
    FOnSatellitesChange: TGPSSatEvent;
    FOnGPSDatasChange: TGPSDatasEvent;
    FOnAfterOpen: TNotifyEvent;
    FOnAfterClose: TNotifyEvent;
    procedure CallOnSatellitesChange();
    procedure CallOnGPSDatasChange();

    procedure SetConnected(const Value: Boolean);

    procedure SetPort(const Value: TPort);
    procedure SetBaudRate(const Value: TBaudRate);
    procedure SetDataBits(const Value: TDataBits);
    procedure SetStopBits(const Value: TStopBits);
    procedure SetParity(const Value: TComParity);
    procedure SetFlowControl(const Value: TComFlowControl);

    // Packets interpreting
    procedure PacketRecv(Sender: TObject; const Str: String);

    // COM Port connection
    procedure COMPortAfterConnect(Sender: TObject);
    procedure COMPortAfterDisconnect(Sender: TObject);
  protected
    procedure DoOnSatellitesChange(NbSat, NbSatUse: Shortint;
      Sats: TSatellites); dynamic;
    procedure DoOnGPSDatasChange(GPSDatas: TGPSDatas); dynamic;
    procedure DoAfterClose(); dynamic;
    procedure DoAfterOpen(); dynamic;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    procedure Open();
    procedure Close();

    // GPS informations
    property Satellites: TSatellites read FSatellites;
    property GPSDatas: TGPSDatas read FGPSDatas;
  published
    // State of the TGPS component
    property Connected: Boolean read FConnected write SetConnected default False;

    // COM Port parameters
    property Port: TPort read FPort write SetPort;
    property BaudRate: TBaudRate read FBaudRate write SetBaudRate;
    property DataBits: TDataBits read FDataBits write SetDataBits;
    property StopBits: TStopBits read FStopBits write SetStopBits;
    property Parity: TComParity read FParity write SetParity;
    property FlowControl: TComFlowControl read FFlowControl write SetFlowControl;

    // Notifications
    property OnSatellitesChange: TGPSSatEvent
      read FOnSatellitesChange write FOnSatellitesChange;
    property OnGPSDatasChange: TGPSDatasEvent
      read FOnGPSDatasChange write FOnGPSDatasChange;
    property OnAfterOpen: TNotifyEvent read FOnAfterOpen write FOnAfterOpen;
    property OnAfterClose: TNotifyEvent read FOnAfterClose write FOnAfterClose;
  end;

const  
  // NMEA 0185's messages used
  LstMsgDiffGP: array[msgGPGGA..msgGPZDA] of String = (
    'GGA', // Global Positioning System Fix Data
    'GLL', // Geographic position, Latitude and Longitude
    'GSV', // Satellites in view
    'RMA', // Recommended minimum specific GPS/Transit data Loran C
    'RMC', // Recommended minimum specific GPS/Transit data
    'ZDA'  // Date and time 
    );

var
  // Number of satellites in view
  SatRef: Smallint = 0;

procedure Register;

// Return the NMEA 0185's message type by its name
function IndexMsgGP(StrMsgGP: String): TMsgGP;
// Convert an angle string to its value
function StrCoordToAngle(Point: Char; Angle: String): Double;
// Convert a time string to its value
function StrTimeToTime(const Time: String): TDateTime;
// Convert an integer string to its value
function StrToInteger(const Str: String): Integer;
// Convert an real string to its value
function StrToReal(const Str: String): Extended;

implementation

procedure Register;
begin
  RegisterComponents('GPS', [TGPS]);
end;

constructor TGPS.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  // Create ComPort component
  FCOMPort := TComPort.Create(Nil);

  // Get back the ComPort parameters
  with FCOMPort do
  begin
    Port := FPort;
    FBaudRate := BaudRate;
    FDataBits := DataBits;
    FStopBits := StopBits;
    FParity := Parity;
    FFlowControl := FlowControl;

    // Implements triggers
    OnAfterOpen := COMPortAfterConnect;
    OnAfterClose := COMPortAfterDisconnect;
  end;

  // Create data packet's manager component
  FCOMDataPacket := TComDataPacket.Create(Nil);
  with FCOMDataPacket do
  begin
    // Specify characters starting and ending frames NMEA 0183
    StartString := MSG_START;
    StopString := MSG_STOP;

    // Implements trigger for frames receiving
    OnPacket := PacketRecv;

    // Specify the ComPort used
    ComPort  := FCOMPort;
  end;
end;

destructor TGPS.Destroy();
begin
  // Close le ComPort connexion (trying…)
  Close();

  // Free components
  FCOMPort.Free();
  FCOMDataPacket.Free();

  inherited Destroy;
end;

procedure TGPS.Open();
begin
  // Open the ComPort connection
  FCOMPort.Open();
end;

procedure TGPS.Close();
begin
  // Close the ComPort connection
  FCOMPort.Close();
end;

procedure TGPS.CallOnSatellitesChange();
begin
  // Trigger the satellites changing procedure
  DoOnSatellitesChange(FGPSDatas.NbrSats, FGPSDatas.NbrSatsUsed, FSatellites);
end;

procedure TGPS.CallOnGPSDatasChange();
begin             
  // Trigger the GPS datas changing procedure
  DoOnGPSDatasChange(FGPSDatas);
end;

procedure TGPS.SetConnected(const Value: Boolean);
begin
  // Open or close the connection if the value change
  if not ((csDesigning in ComponentState)
    or (csLoading in ComponentState)) then
  begin
    if Value <> FConnected then
      if Value then
        Open()
      else
        Close();
  end
  else
    FConnected := Value;
end;

procedure TGPS.SetPort(const Value: TPort);
begin
  FCOMPort.Port := Value;
  FPort := FCOMPort.Port;
end;

procedure TGPS.SetBaudRate(const Value: TBaudRate);
begin
  FCOMPort.BaudRate := Value;
  FBaudRate := FCOMPort.BaudRate;
end;

procedure TGPS.SetDataBits(const Value: TDataBits);
begin
  FCOMPort.DataBits := Value;
  FDataBits := FCOMPort.DataBits;
end;

procedure TGPS.SetStopBits(const Value: TStopBits);
begin
  FCOMPort.StopBits := Value;
  FStopBits := FCOMPort.StopBits;
end;

procedure TGPS.SetParity(const Value: TComParity);
begin
  FCOMPort.Parity := Value;
  FParity := FCOMPort.Parity;
end;

procedure TGPS.SetFlowControl(const Value: TComFlowControl);
begin
  FCOMPort.FlowControl := Value;
  FFlowControl := FCOMPort.FlowControl;
end;

procedure TGPS.PacketRecv(Sender: TObject; const Str: String);
var
  Resultat: TStringList;
  MsgCorrect, TypeMsg: String;
  i: Integer;
begin
  Resultat := TStringList.Create();
  try
    // Split the message into different parts.
    MsgCorrect := AnsiReplaceStr('$' + Str, ',,', ' , , ');
    Resultat.Text := AnsiReplaceStr(
      LeftStr(MsgCorrect, Length(MsgCorrect) - 1), ',', #13#10);

    // Get the message type
    TypeMsg := MidStr(Resultat[0], 4, 3);

    // Retrieves data based on message type
    case IndexMsgGP(TypeMsg) of
      msgGPGGA:
      begin
        with FGPSDatas do
        begin
          UTCTime := StrTimeToTime(Resultat[1]);
          Latitude := StrCoordToAngle(Resultat[3][1], Resultat[2]);
          Longitude := StrCoordToAngle(Resultat[5][1], Resultat[4]);
          HeightAboveSea := StrToReal(Resultat[9]);
          NbrSatsUsed := StrToInteger(Resultat[7]);
        end;
        
        // Trigger change
        CallOnGPSDatasChange();
      end;
      msgGPGLL:
      begin
        with FGPSDatas do
        begin
          UTCTime := StrTimeToTime(Resultat[5]);
          Latitude := StrCoordToAngle(Resultat[2][1], Resultat[1]);
          Longitude := StrCoordToAngle(Resultat[4][1], Resultat[3]);
          Valid := AnsiSameText(Resultat[6], 'A');
        end;
        
        // Trigger change
        CallOnGPSDatasChange();
      end;
      msgGPGSV:
      begin
        // If there are satellites in referenced in the frame
        if Resultat.Count < 4 then
          FGPSDatas.NbrSats := 0
        else
          FGPSDatas.NbrSats := StrToInteger(Resultat[3]);

        if Resultat[2] = '1' then
        begin
          SatRef := 0;

          // Initiate satellites values
          for i := 1 to 12 do
            with FSatellites[i] do
            begin
              Identification := 0;
              Elevation := 0;
              Azimut := 0;
              SignLevel := 0;
            end;
        end;

        i := 4;

        // For each referenced satellites
        while (i + 4) <= (Resultat.Count) do
        begin
          with FSatellites[SatRef + 1] do
          begin
            Identification := StrToInteger(Resultat[i]);
            Elevation := StrToInteger(Resultat[i + 1]);
            Azimut := StrToInteger(Resultat[i + 2]);
            if Resultat[i + 3] <> '' then
              SignLevel := StrToInteger(Resultat[i + 3])
            else
              SignLevel := 0;
          end;
          Inc(i, 4);
          Inc(SatRef);
        end;

        // Trigger change
        CallOnSatellitesChange();
      end;
      msgGPRMA:
      begin
        with FGPSDatas do
        begin
          Latitude := StrCoordToAngle(Resultat[3][1], Resultat[2]);
          Longitude := StrCoordToAngle(Resultat[5][1], Resultat[4]);
          Valid := AnsiSameText(Resultat[1], 'A');
          Speed := Convert(StrToReal(Resultat[6]), duNauticalMiles,
            duKilometers);
        end;
        
        // Trigger change
        CallOnGPSDatasChange();
      end;
      msgGPRMC:
      begin
        with FGPSDatas do
        begin
          UTCTime := StrTimeToTime(Resultat[1]);
          Latitude := StrCoordToAngle(Resultat[4][1], Resultat[3]);
          Longitude := StrCoordToAngle(Resultat[6][1], Resultat[5]);
          Valid := AnsiSameText(Resultat[2], 'A');
          Speed := Convert(StrToReal(Resultat[7]), duNauticalMiles,
            duKilometers);
        end;
        
        // Trigger change
        CallOnGPSDatasChange();
      end;
      msgGPZDA:
      begin
        FGPSDatas.UTCTime := StrTimeToTime(Resultat[1]);
        
        // Trigger change
        CallOnGPSDatasChange();
      end;
    end;
  finally
    Resultat.Free();
  end;
end;

procedure TGPS.COMPortAfterConnect(Sender: TObject);
begin
  FConnected := True;
  DoAfterOpen();
end;

procedure TGPS.COMPortAfterDisconnect(Sender: TObject);
begin
  FConnected := False;
  DoAfterClose();
end;

procedure TGPS.DoOnSatellitesChange(NbSat, NbSatUse: Shortint;
  Sats: TSatellites);
begin
  if Assigned(FOnSatellitesChange) then
    FOnSatellitesChange(Self, NbSat, NbSatUse, Sats);
end;

procedure TGPS.DoOnGPSDatasChange(GPSDatas: TGPSDatas);
begin
  if Assigned(FOnGPSDatasChange) then
    FOnGPSDatasChange(Self, GPSDatas);
end;

procedure TGPS.DoAfterClose();
begin
  if Assigned(FOnAfterClose) then
    FOnAfterClose(Self);
end;

procedure TGPS.DoAfterOpen();
begin
  if Assigned(FOnAfterOpen) then
    FOnAfterOpen(Self);
end;
                              
// Return the NMEA 0185's message type by its name
function IndexMsgGP(StrMsgGP: String): TMsgGP;
var
  i: TMsgGP;
begin
  Result := msgGP;
  for i := msgGPGGA to msgGPZDA do
    if AnsiSameText(LstMsgDiffGP[i], StrMsgGP) then
    begin
      Result := i;
      Break;
    end;
end;
                                            
// Convert an angle string to its value
function StrCoordToAngle(Point: Char; Angle: String): Double;
var
  PosPt: Shortint;
  FrmNmb: TFormatSettings;
  DegresStr, MinutsStr: String;
  Degres: Smallint;
  Minuts: Double;
begin
  // -> http://msdn.microsoft.com/library/0h88fahh
  GetLocaleFormatSettings($0409, FrmNmb);

  if Trim(Angle) <> '' then
  begin
    PosPt := Pos(FrmNmb.DecimalSeparator, Angle);

    DegresStr := LeftStr(Angle, PosPt - 3);
    Degres := StrToInt(DegresStr);
    MinutsStr := MidStr(Angle, PosPt - 2, Length(Angle));
    Minuts := StrToFloat(MinutsStr, FrmNmb);
    Minuts := Minuts * (10 / 6);

    Result := Degres + (Minuts / 100);

    // Put the sign
    if Point in ['S', 'W'] then
      Result := -Result;
  end
  else
    Result := 0;
end;
                                
// Convert a time string to its value
function StrTimeToTime(const Time: String): TDateTime;
var
  TimeCorr: String;
begin
  if Trim(Time) <> '' then
  begin
    TimeCorr := Format('%s:%s:%s', [LeftStr(Time, 2),
      MidStr(Time, 3, 2), MidStr(Time, 5, 2)]);
    Result := StrToTime(TimeCorr);
  end
  else
    Result := 0;
end;
                               
// Convert an integer string to its value
function StrToInteger(const Str: String): Integer;
begin
  try
    if Trim(Str) <> '' then
      Result := StrToInt(Trim(Str))
    else
      Result := 0;
  except
    Result := 0;
  end;
end;
                      
// Convert an real string to its value
function StrToReal(const Str: String): Extended;
var
  FrmNmb: TFormatSettings;
begin
  try
    // -> http://msdn.microsoft.com/library/0h88fahh
    GetLocaleFormatSettings($0409, FrmNmb);
    if Trim(Str) <> '' then
      result := StrToFloat(Trim(Str), FrmNmb)
    else
      Result := 0;
  except
    Result := 0;
  end;
end;

end.
