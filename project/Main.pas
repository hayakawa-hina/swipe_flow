unit Main;

interface //#################################################################### ��

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  Core, FMX.Controls.Presentation, FMX.StdCtrls, LUX, LUX.D2, FMX.ListBox,
  FMX.ScrollBox, FMX.Memo;
  const
    CheckBoxNum = 5;
    MaxControl  = 1024;

type
   TMouse = record
     public
       Drag         :Boolean;
       prevP        :TDouble2D;
       nowP         :TDouble2D;
     end;

  TForm3 = class(TForm)
    Timer1: TTimer;
    Force1: TCheckBox;
    Force2: TCheckBox;
    MG1range: TTrackBar;
    MG1curve: TTrackBar;
    Label3: TLabel;
    Label4: TLabel;
    MG2range: TTrackBar;
    MG2power: TTrackBar;
    Label6: TLabel;
    Force3: TCheckBox;
    Label2: TLabel;
    Label5: TLabel;
    Label7: TLabel;
    MFtimestep: TTrackBar;
    Label8: TLabel;
    MFpower: TTrackBar;
    Force4: TCheckBox;
    MRrange: TTrackBar;
    Label9: TLabel;
    Label10: TLabel;
    MRpower: TTrackBar;
    Image2: TImage;
    Force5: TCheckBox;
    Image1: TImage;
    Line1: TLine;
    F5Draw: TRadioButton;
    F5move: TRadioButton;
    OpenDialog1: TOpenDialog;
    ImageButton: TButton;
    Line2: TLine;
    ImageCheck: TCheckBox;
    Line3: TLine;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure ForceCheckBox(Num :Integer);
    procedure Force1Change(Sender: TObject);
    procedure Force2Change(Sender: TObject);
    procedure Force3Change(Sender: TObject);
    procedure Force4Change(Sender: TObject);
    procedure Force5Change(Sender: TObject);
    procedure F5DrawChange(Sender: TObject);
    procedure F5moveChange(Sender: TObject);
    procedure ImageButtonClick(Sender: TObject);
  private
    { private �錾 }
  public
    { public �錾 }
    _FluidSPH :TFluidSPH;
    M :TMouse;
    ForceType : array [1..CheckBoxNum] of TCheckBox;
    ForceCount :Integer;
    ForceCheck  :Integer;  //�I�����ꂽcheckbox
    Force3ms  :cardinal;

    F5point :array [0..MaxControl-1] of TDouble2D;
    Force5ms  :cardinal;
    F5count :Integer;

    ccount :Integer;

    BGpic :TBitmap;
    ImageName :String;
  end;

var
  Form3: TForm3;

implementation //############################################################### ��

uses MMSystem;

{$R *.fmx}

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public


//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&


procedure TForm3.FormCreate(Sender: TObject);
var
  i :Integer;
begin
     Image1.AutoCapture := True;
     Image1.Bitmap.SetSize( 800, 600 );

     M.Drag := false;

     _FluidSPH := TFluidSPH.Create;

     for i := 1 to CheckBoxNum do
        ForceType[i] := TCheckBox(FindComponent('Force' + IntToStr(i)));

     ForceCount := 0;
     ForceCheck := 0;


     ccount := 0;


     for i := 0 to MaxControl-1 do
       F5point[i] := TDouble2D.Create( 0, 0 );

     Image2.Bitmap.LoadFromFile( 'VeloMap2.png' );
     Image2.Bitmap.Map( TMapAccess.Read, _FluidSPH.D  );

     BGpic := TBitmap.Create;
     BGpic.LoadFromFile('ToLOVEru_app2.jpg');

end;

procedure TForm3.F5DrawChange(Sender: TObject);
begin
    if (F5Draw.IsChecked = true) and (ForceCheck = 5) then F5count := 0;
end;

procedure TForm3.F5moveChange(Sender: TObject);
var
  i:Integer;
begin
   if (F5move.IsChecked = false) then
   begin
        _FluidSPH.InitAttract;
   end;
end;

procedure TForm3.Force1Change(Sender: TObject);
begin
    ForceCount := 1;
    ForceCheckBox( 1 );
end;

procedure TForm3.Force2Change(Sender: TObject);
begin
    ForceCount := 2;
    ForceCheckBox( 2 );
end;

procedure TForm3.Force3Change(Sender: TObject);
begin
    ForceCount := 3;
    ForceCheckBox( 3 );
end;

procedure TForm3.Force4Change(Sender: TObject);
begin
    ForceCount := 4;
    ForceCheckBox( 4 );
end;

procedure TForm3.Force5Change(Sender: TObject);
begin
    ForceCount := 5;
    ForceCheckBox( 5 );
end;

procedure TForm3.ForceCheckBox(Num :Integer);
var
  i :Integer;
  c :Boolean;
begin

  if (ForceType[Num].IsChecked = true) and (ForceCount = Num) then
  begin
    ForceCheck := Num;
    for i := 1 to CheckBoxNum do
        if i <> Num then ForceType[i].IsChecked := false;
  end;

  c := false;
  for i := 1 to CheckBoxNum do  c := c or ForceType[i].IsChecked;
  if c = false then ForceCheck := 0;

end;


procedure TForm3.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
     M.prevP.X := X;
     M.prevP.Y := Y;
     M.nowP.X := X;
     M.nowP.Y := Y;
     M.Drag := true;
     if ForceCheck = 3 then Form3.Force3ms := timeGetTime;
     if ForceCheck = 5 then Form3.Force3ms := timeGetTime;
     //F5count := 0;
end;

procedure TForm3.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Single);
begin
  if M.Drag = true then
    begin
     M.nowP.X := X;
     M.nowP.Y := Y;

     if (F5Draw.IsChecked = true) and (ForceCheck = 5) then
     begin
       if (timeGetTime - Force5ms) > 25  then
       //if (timeGetTime - Force5ms) > 75  then
         begin
             F5point[F5count].X := X;
             F5point[F5count].Y := Y;
             F5count := F5count + 1;
             Force5ms := timeGetTime;
             //Label2.Text := 'F5point[' + IntToStr(F5count - 1) + ']  = ' + FloatToStr(X) + ' , ' + FloatToStr(Y);
         end;
      end;
    end;
end;

procedure TForm3.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
      M.Drag := false;
      Force3ms := 0;
      Force5ms := 0;
end;


procedure TForm3.ImageButtonClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    ImageName := OpenDialog1.FileName;
    BGpic.LoadFromFile(ImageName);
    //Label2.Text := ImageName;
  end;
end;

procedure TForm3.Timer1Timer(Sender: TObject);
begin

     _FluidSPH.RegistParticles;

     //SPH
     _FluidSPH.CalcDens( 30 );
     _FluidSPH.CalcPres( 30 );
     _FluidSPH.CalcVisc( 30 );
     _FluidSPH.CalcMouse( 30 );
     if (ForceCheck = 5) and (F5move.IsChecked = true) then
     begin
      _FluidSPH.RegistControl( 10 );
      _FluidSPH.CalcAttract( 10 );
     end;
     if ForceCheck <> 5 then _FluidSPH.InitAttract;
     _FluidSPH.CalcForc;


     _FluidSPH.Draw( Image1.Bitmap.Canvas );
end;

end. //######################################################################### ��
