object FDemo: TFDemo
  Left = 382
  Top = 247
  BorderStyle = bsDialog
  Caption = 'Demo GPS'
  ClientHeight = 237
  ClientWidth = 225
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object LBL_Latitude: TLabel
    Left = 8
    Top = 68
    Width = 41
    Height = 13
    Caption = 'Latitude:'
  end
  object LBL_Longitude: TLabel
    Left = 8
    Top = 88
    Width = 50
    Height = 13
    Caption = 'Longitude:'
  end
  object LBL_Altitude: TLabel
    Left = 8
    Top = 108
    Width = 38
    Height = 13
    Caption = 'Altitude:'
  end
  object LBL_NbSats: TLabel
    Left = 8
    Top = 152
    Width = 95
    Height = 13
    Caption = 'Number of satellites:'
  end
  object LBL_NbSatsUsed: TLabel
    Left = 8
    Top = 172
    Width = 121
    Height = 13
    Caption = 'Number of satellites used:'
  end
  object SHP_Connected: TShape
    Left = 140
    Top = 8
    Width = 21
    Height = 21
    Brush.Color = clGray
    Shape = stCircle
  end
  object Label1: TLabel
    Left = 8
    Top = 44
    Width = 74
    Height = 13
    Caption = 'GPS COM &Port:'
    FocusControl = CMB_COMPort
  end
  object LBL_Speed: TLabel
    Left = 8
    Top = 128
    Width = 34
    Height = 13
    Caption = 'Speed:'
  end
  object LBL_Time: TLabel
    Left = 8
    Top = 196
    Width = 51
    Height = 13
    Caption = 'UTC Time:'
  end
  object BTN_Start: TButton
    Left = 4
    Top = 4
    Width = 125
    Height = 29
    Caption = 'Start'
    Default = True
    TabOrder = 0
    OnClick = BTN_StartClick
  end
  object CMB_COMPort: TComComboBox
    Left = 88
    Top = 40
    Width = 133
    Height = 21
    ComProperty = cpPort
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = -1
    TabOrder = 1
    OnChange = CMB_COMPortChange
  end
  object CHK_Valid: TCheckBox
    Left = 8
    Top = 216
    Width = 209
    Height = 17
    Caption = 'Valide position'
    TabOrder = 2
    OnClick = CHK_ValidClick
  end
  object GPS1: TGPS
    BaudRate = br9600
    DataBits = dbEight
    StopBits = sbOneStopBit
    Parity.Bits = prNone
    FlowControl.OutCTSFlow = False
    FlowControl.OutDSRFlow = False
    FlowControl.ControlDTR = dtrDisable
    FlowControl.ControlRTS = rtsDisable
    FlowControl.XonXoffOut = False
    FlowControl.XonXoffIn = False
    OnGPSDatasChange = GPS1GPSDatasChange
    OnAfterOpen = GPS1AfterOpen
    OnAfterClose = GPS1AfterClose
    Left = 168
    Top = 80
  end
end
