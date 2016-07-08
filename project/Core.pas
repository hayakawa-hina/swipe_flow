﻿unit Core;

interface //#################################################################### ■

uses System.Types, System.Classes, System.Math.Vectors, System.SysUtils,
     FMX.Types, FMX.Graphics,
     LUX, LUX.D2;

type //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【型】

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

     PParticle = ^TParticle;

     TParticle = record
     public
       Next :PParticle;
       Posi :TDouble2D;  //位置
       Velo :TDouble2D;  //速度
       Dens :Double;     //密度
       Pres :TDouble2D;  //圧力
       Visc :TDouble2D;
       Forc :TDouble2D;  //力
       Mass :Double;     //質量

       Mouse:TDouble2D;  //マウス外力
       Attract:TDouble2D;

       Lambda:Double;   //lambda_i
       tPosi:TDouble2D; //PBFの位置tmp
     end;

     TGrid = record
     public
       Head  :PParticle;
       Count :Integer;
     end;

     TCGrid = record
     public
       Head  :PParticle;
       Count :Integer;
       Count2:Integer;
       Alpha :Double;
     end;

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TFluidSPH

     TFluidSPH = class
     private
       ///// メソッド
     protected
       _EdgeParticles :array of TParticle;
       _EdgeParticleN :Integer;
       _FlowParticleN :Integer;
       _Grid          :array [ -5+0..60+5, -5+0..80+5 ] of TGrid;
       _CGrid         :array [0..1023] of TCGrid;

       prevForce  :TDouble2D;
       //_DivW          :Integer;
      // _DivH          :Integer;
       ///// アクセス
     public

       _FlowParticles :array of TParticle;

       var D :TBitmapData;

       constructor Create;
       destructor Destroy; override;
       ///// プロパティ
       //property DivW :Integer read _DivW;
       //property DivH :Integer read _DivH;
       ///// メソッド
       procedure Draw( const Canvas_:TCanvas );
       procedure MakeEdgeParticles;
       procedure MakeFlowParticles;
       procedure RegistParticles;
       procedure RegistControl( const H_:Double);
       procedure CalcDens( const H_:Double );
       procedure CalcVisc( const H_:Double );
       procedure CalcPres( const H_:Double );
       procedure CalcMouse( const H_:Double );
       procedure CalcAttract( const H_:Double);
       procedure CalcForc;
       procedure InitAttract;
     end;

//const //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【定数】

//var //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【変数】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

function Pow4( const X_:Double ) :Double; overload; inline;
function Pow5( const X_:Double ) :Double; overload; inline;
function Pow6( const X_:Double ) :Double; overload; inline;
function Pow8( const X_:Double ) :Double; overload; inline;

function KernelPoly6( const R_:TDouble2D; const H_:Double ) :Double;

function dKernelSpiky( const R_:TDouble2D; const H_:Double ) :TDouble2D;

function d2KernelViscosity( const R_:TDouble2D; const H_:Double ) :Double;

function sqrt2D( const R_:TDouble2D) :TDouble2D;

implementation //############################################################### ■

uses System.UITypes, System.Math, Main, MMSystem;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TFluidSPH

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

////////////////////////////////////////////////////////////////////////////////

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TFluidSPH.Create;
begin
     inherited;

     MakeEdgeParticles;
     MakeFlowParticles;
     prevForce := TDouble2D.Create( 0, 0 );
     //Form3.Image2.Bitmap.Map( TMapAccess.Read, D  );
end;

destructor TFluidSPH.Destroy;
begin

     Form3.Image2.Bitmap.Unmap( D );
     Form3.BGpic.Free;
     inherited;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TFluidSPH.Draw( const Canvas_:TCanvas );
var
   P :TParticle;
   var V :TDouble2D;
   c  :Integer;
   pic1 :Integer;
begin
     with Canvas_ do
     begin
          BeginScene;


          Clear( TAlphaColors.DkGray );

          if Form3.ImageCheck.IsChecked = true then
          begin
            pic1 := Round(400 - 600 * Form3.BGpic.Width / Form3.BGpic.Height / 2);
            Form3.Image1.Bitmap.Canvas.DrawBitmap( Form3.BGpic,
                            TRectF.Create(0, 0, Form3.BGpic.Width, Form3.BGpic.Height),
                            TRectF.Create(pic1, 0, 800 - pic1, 600), 1);
          end;
          //Fill.Color := TAlphaColors.Black;


          for P in _EdgeParticles do
          begin
               with P do
               begin
                    Fill.Color := $FF000000 + $00010101 * Round( 255 * ClipRange( Dens*100, 0, 1 ) );

                    //V := Velo.Unitor;
                    //Fill.Color := D.GetPixel( Round( (200) * ( 1.0   ) ), Round( (200) * ( 1.0 ) ) );

                    FillEllipse( TRectF.Create( Posi.X-5, Posi.Y-5, Posi.X+5, Posi.Y+5 ), 1 );
               end;
          end;

          //Fill.Color := TAlphaColors.Red;
          c := 0;
          for P in _FlowParticles do
          begin
               with P do
               begin
                    //Fill.Color := $FF000000 + $00010101 * Round( 255 * ClipRange( Dens*100, 0, 1 ) );

                    V := Velo;

                    //if c = 0 then
                      //Form3.Label2.Text := 'V = ' + FloatToStr(V.X) + ' , ' + FloatToStr(V.Y);
                    //c := 1;
                    V := V / 15;
                    //if V.X >= 1 then V.X := 0.9;
                    //if V.Y >= 1 then V.Y := 0.9;

                    Fill.Color := D.GetPixel( Round( (200) * ( 1 + V.X  ) ), Round( (200) * ( 1 + V.Y ) ) );

                    FillEllipse( TRectF.Create( Posi.X-5, Posi.Y-5, Posi.X+5, Posi.Y+5 ), 1 );
               end;
          end;

          EndScene;
     end;
end;

procedure TFluidSPH.MakeEdgeParticles;
//-----------------------------------
     procedure MakeFence( const M_:Integer );
     var
        X, Y :Integer;
        P :TParticle;
     begin
          P.Mass := 1;

          for X := 0 to ( 800 - 2 * M_ ) div 10 do
          begin
               P.Posi := TDouble2D.Create( M_ + 10 * X,       M_ );

               _EdgeParticles := _EdgeParticles + [ P ];

               P.Posi := TDouble2D.Create( M_ + 10 * X, 600 - M_ );

               _EdgeParticles := _EdgeParticles + [ P ];
          end;

          for Y := 1 to ( 600 - 2 * M_ ) div 10 - 1  do
          begin
               P.Posi := TDouble2D.Create(       M_, M_ + 10 * Y );

               _EdgeParticles := _EdgeParticles + [ P ];

               P.Posi := TDouble2D.Create( 800 - M_, M_ + 10 * Y );

               _EdgeParticles := _EdgeParticles + [ P ];
          end;
     end;
//-----------------------------------
begin
     _EdgeParticles := [];

     MakeFence( 05 );
     MakeFence( 15 );
     MakeFence( 25 );
     MakeFence( 35 );
     MakeFence( 45 );

     _EdgeParticleN := Length( _EdgeParticles );
end;

procedure TFluidSPH.MakeFlowParticles;
const
     DW :Integer = 17;
     DH :Integer = 17;
var
   X, Y :Integer;
   P :TParticle;
begin
     _FlowParticles := [];

     P.Mass := 1;

     for Y := 0 to DH do
     begin
          for X := 0 to DW do
          begin
               P.Posi := TDouble2D.Create( 300 + 10 * X, 200 + 10 * Y )
                       + TDouble2D.Create( 0.001 * Random, 0.001 * Random );

               _FlowParticles := _FlowParticles + [ P ];
          end;
     end;

     _FlowParticleN := Length( _FlowParticles );
end;

procedure TFluidSPH.RegistParticles;
//---------------------------------
     procedure Regist( var P_:TParticle );
     var
        X, Y :Integer;
     begin
          X := Floor( P_.Posi.X / 10 );
          Y := Floor( P_.Posi.Y / 10 );

          with _Grid[ Y, X ] do
          begin
               P_.Next := Head;

               Head := @P_;

               Inc( Count );
          end;
     end;
//---------------------------------
var
   X, Y, I :Integer;
   P :TParticle;
begin
     for Y := -5 to 60+5 do
     begin
          for X := -5 to 80+5 do _Grid[ Y, X ].Count := 0;
     end;

     for I := 0 to _EdgeParticleN-1 do
     begin
       Regist( _EdgeParticles[ I ] );
     end;
     for I := 0 to _FlowParticleN-1 do
     begin
       Regist( _FlowParticles[ I ] );
     end;
end;


procedure TFluidSPH.RegistControl( const H_:Double);
//---------------------------------
     function AttractKernel( const d_:Double ) :Double;
     var
      W :Double;
     begin
         if d_ >= (H_*sqrt(2)) then Result := 0;
         if d_ < (H_*sqrt(2)) then
         begin
         //Form3.Label2.Text := 'd = ' + FloatToStr(d_);
         Result := (315 / (64 * PI * power(H_*sqrt(2), 9))) * power((power(H_*sqrt(2), 2) - d_*d_), 3);
         end;
     end;

     function AttractKernel2( const d_:Double ) :Double;
     var
      W :Double;
     begin
         if d_ >= (H_*sqrt(2)) then Result := 0;
         if d_ <= (H_*sqrt(2) / 2) then Result := 1;
         if (d_ > (H_*sqrt(2) / 2)) and (d_ < (H_*sqrt(2))) then Result := 2 - 2 * d_ / (H_*sqrt(2));
     end;

     procedure Regist( const I:Integer );
     var
        C :Integer;
        R :TDouble2D;
        D :Double;
        MAXc2:Double;
     begin
          MAXc2 := 0;
          for C := 0 to _FlowParticleN-1 do
          begin
             R := (Form3.F5point[I] - _FlowParticles[ C ].Posi) / 10;
             if sqrt(R.X*R.X+R.Y*R.Y) < ( H_ *sqrt(2)) then
             begin
                with _CGrid[ I ] do
                begin
                  _FlowParticles[ C ].Next := Head;

                  Head := @_FlowParticles[ C ];

                  Inc( Count );

                  R := (Form3.F5point[ I ] - _FlowParticles[ C ].Posi) / 10;
                  D := sqrt(R.X*R.X + R.Y*R.Y);
                  Alpha := Alpha + AttractKernel(D);
                  //Alpha := Alpha + AttractKernel2(D);
                  //Form3.Label2.Text := 'Count = ' + FloatToStr(Count);

                  if sqrt(R.X*R.X+R.Y*R.Y) < ( H_ *sqrt(2) / 2) then
                  begin
                    Inc( Count2 );
                  end;
                end;
             end;
             //if MAXc2 < _CGrid[ I ].Count2 then MAXc2 := _CGrid[ I ].Count2;

          end;

          if _CGrid[ I ].Alpha >= 1.0 then _CGrid[ I ].Alpha := 1.0;

          //_CGrid[ I ].Alpha := (1.0 - _CGrid[ I ].Alpha );
          _CGrid[ I ].Alpha := (((1.0 - _CGrid[ I ].Alpha - 0.9) * 10) - 0.5) * (0.007 * (17*17 - 2.25 *  _CGrid[ I ].Count));
          Form3.Label2.Text := 'a = ' + FloatToStr(_CGrid[ I ].Alpha);
     end;
//---------------------------------
var
   X, Y, I :Integer;
   P :TParticle;
begin
     for I := 0 to Form3.F5count-1 do
      begin
        _CGrid[ I ].Count := 0;
        _CGrid[ I ].Count2 := 0;
        _CGrid[ I ].Alpha := 0.0;
      end;

     for I := 0 to Form3.F5count-1 do
       begin
         Regist( I );
         //Form3.Label2.Text := 'CGrid.Count = ' + FloatToStr(_CGrid[ I ].Count);
       end;
end;



procedure TFluidSPH.CalcDens( const H_:Double );
//---------------------------------------------
     procedure SumValue( var P_:TParticle );
     var
        X0, X1, Y0, Y1, X, Y, N :Integer;
        P :PParticle;
        R :TDouble2D;
     begin
          with P_ do
          begin
               X0 := Floor( ( Posi.X - H_ ) / 10 );
               Y0 := Floor( ( Posi.Y - H_ ) / 10 );
               X1 := Ceil ( ( Posi.X + H_ ) / 10 );
               Y1 := Ceil ( ( Posi.Y + H_ ) / 10 );

               Dens := 0;

               for Y := Y0 to Y1 do
               begin
                    for X := X0 to X1 do
                    begin
                         with _Grid[ Y, X ] do
                         begin
                              P := Head;
                              for N := 1 to Count do
                              begin
                                   R := P.Posi - Posi;

                                   Dens := Dens + P.Mass
                                                * KernelPoly6( R, H_ );

                                   P := P.Next;
                              end;
                         end;
                    end;
               end;
          end;
     end;
//---------------------------------------------
var
   I :Integer;
begin
     for I := 0 to _EdgeParticleN-1 do SumValue( _EdgeParticles[ I ] );
     for I := 0 to _FlowParticleN-1 do SumValue( _FlowParticles[ I ] );
end;

procedure TFluidSPH.CalcVisc( const H_:Double );
//---------------------------------------------
     procedure SumValue( var P_:TParticle );
     var
        X0, X1, Y0, Y1, X, Y, N :Integer;
        P :PParticle;
        R :TDouble2D;
     begin
          with P_ do
          begin
               X0 := Floor( ( Posi.X - H_ ) / 10 );
               Y0 := Floor( ( Posi.Y - H_ ) / 10 );
               X1 := Ceil ( ( Posi.X + H_ ) / 10 );
               Y1 := Ceil ( ( Posi.Y + H_ ) / 10 );

               Visc := TDouble2D.Create( 0, 0 );

               for Y := Y0 to Y1 do
               begin
                    for X := X0 to X1 do
                    begin
                         with _Grid[ Y, X ] do
                         begin
                              P := Head;
                              for N := 1 to Count do
                              begin
                                   if P <> @P_ then
                                   begin
                                        R := P.Posi - Posi;

                                        Visc := Visc + P.Mass
                                                     * ( P.Velo - Velo ) / P.Dens
                                                     * d2KernelViscosity( P.Posi - Posi, H_ );
                                   end;

                                   P := P.Next;
                              end;
                         end;
                    end;
               end;
          end;
     end;
//---------------------------------------------
var
   I :Integer;
begin
     for I := 0 to _EdgeParticleN-1 do SumValue( _EdgeParticles[ I ] );
     for I := 0 to _FlowParticleN-1 do SumValue( _FlowParticles[ I ] );
end;

procedure TFluidSPH.CalcPres( const H_:Double );
//---------------------------------------------
     function PresFunc( const P_:Double ) :Double;
     begin
          Result := 1 * ( P_ - 0.1 );

          //if P_ > 0.01 then Result := 0.01 * 0.01 * ( Power( P_ / 0.1, 7 ) - 1 ) / 7
          //             else Result := 0;
     end;
     //----------------------------------------
     function PresFuncWCSPH( const P_:Double ) :Double;
     var
      B, Gamma :Double;
     begin
        B := 0.1 * power((abs(0.1 - P_) / 0.1), 2) / 7.15;//[Pa]
        Gamma := 7.15;

        Result := B * (power((P_ / 0.1), Gamma) - 1);
     end;

     procedure SumValue( var P_:TParticle );
     var
        X0, X1, Y0, Y1, X, Y, N :Integer;
        P :PParticle;
        R :TDouble2D;
     begin
          with P_ do
          begin
               X0 := Floor( ( Posi.X - H_ ) / 10 );
               Y0 := Floor( ( Posi.Y - H_ ) / 10 );
               X1 := Ceil ( ( Posi.X + H_ ) / 10 );
               Y1 := Ceil ( ( Posi.Y + H_ ) / 10 );

               Pres := TDouble2D.Create( 0, 0 );

               for Y := Y0 to Y1 do
               begin
                    for X := X0 to X1 do
                    begin
                         with _Grid[ Y, X ] do
                         begin
                              P := Head;
                              for N := 1 to Count do
                              begin
                                   if P <> @P_ then
                                   begin
                                        R := P.Posi - Posi;

                                          Pres := Pres - P.Mass
                                              * ( PresFunc( P.Dens ) + PresFunc( Dens ) ) / ( 2 * P.Dens )
                                              * dKernelSpiky( R, H_ );

                                    //Pres := Pres - P.Mass
                                     //         * ( PresFuncWCSPH( P.Dens ) + PresFuncWCSPH( Dens ) ) / ( 2 * P.Dens )
                                      //        * dKernelSpiky( R, H_ );
                                   end;
                                   P := P.Next;
                              end;
                         end;
                    end;
               end;
          end;
     end;
//---------------------------------------------
var
   I :Integer;
begin
     for I := 0 to _EdgeParticleN-1 do SumValue( _EdgeParticles[ I ] );
     for I := 0 to _FlowParticleN-1 do SumValue( _FlowParticles[ I ] );
end;


procedure TFluidSPH.CalcMouse( const H_:Double );
  procedure SumValue( var P_:TParticle );
    var
    X0, Y0, X1, Y1, X, Y, N: Integer;
    P :PParticle;
    R, S, Rabs, Rate :TDouble2D;
    H_i :Double;
    begin
        with P_ do
        begin
            X0 := Floor((Form3.M.nowP.X - H_) / 10);
            Y0 := Floor((Form3.M.nowP.Y - H_) / 10);
            X1 := Ceil ((Form3.M.nowP.X + H_) / 10);
            Y1 := Ceil ((Form3.M.nowP.Y + H_) / 10);

            Mouse := TDouble2D.Create( 0, 0 );

            if Form3.M.Drag = true then
            begin
              for Y := Y0 to Y1 do
              begin
                for X := X0 to X1 do
                begin
                  with _Grid[Y, X] do
                  begin
                      P := Head;
                      for N := 1 to Count do
                      begin
                           if P <> @P_ then
                           begin

                              case Form3.ForceCheck of
                                1:
                                begin
                                    H_i := H_ * (Form3.MG1range.Value / 100 ) ;
                                    R := (Posi -  Form3.M.nowP) / 10;
                                    if (Abs(R.X) < H_i) and (Abs(R.Y) < H_i) then
                                    begin
                                      S := TDouble2D.Create( R.X  / Abs(R.X), R.Y / Abs(R.Y) );
                                      Rabs := TDouble2D.Create( power(Abs(R.X) / H_i, Form3.MG1curve.Value / 10), power(Abs(R.Y) / H_i, Form3.MG1curve.Value / 10) );
                                      Mouse :=  - (TDouble2D.Create( 1.0, 1.0 ) - Rabs) / power(10, 4);
                                      Mouse := TDouble2D.Create(Mouse.X * S.X, Mouse.Y * S.Y);
                                    end;
                                end;

                                2:
                                begin
                                    R := (Posi -  Form3.M.nowP) / 10;
                                    H_i := H_ * (Form3.MG2range.Value / 10 ) ;
                                    if (Abs(R.X) < H_i) and (Abs(R.Y) < H_i) then
                                    begin
                                      Mouse :=  - R / power(10, (4.0 + ( 1.0 - (Form3.MG2power.Value / 10 ))));
                                    end;
                                end;

                                3:
                                begin
                                   if (timeGetTime - Form3.Force3ms) > (50 + 20 * (Form3.MFpower.Value / 10)) then
                                     begin
                                       R := (Form3.M.nowP - Form3.M.prevP) / 10;
                                       Mouse := R / power(10, (4.3 + ( 1.0 - (Form3.MFpower.Value / 10 ))));
                                       Form3.M.prevP.X := Form3.M.nowP.X;
                                       Form3.M.prevP.Y := Form3.M.nowP.Y;
                                       Form3.Force3ms := timeGetTime;
                                       prevForce := Mouse;
                                     end else
                                     begin
                                       Mouse := prevForce;
                                     end;
                                end;

                                4:
                                begin
                                    R := (Posi -  Form3.M.nowP) / 10;
                                    H_i := H_ * (Form3.MRrange.Value / 10 ) ;
                                    if (Abs(R.X) < H_i) and (Abs(R.Y) < H_i) then
                                    begin
                                      Mouse :=  R / power(10, (4.0 + ( 1.0 - (Form3.MRpower.Value / 10 ))));
                                    end;
                                end;
                              end;
                           end;
                           P := P.Next;
                      end;
                  end;
                end;
              end;
            end;
        end;
    end;
var
   I :Integer;
begin
       for I := 0 to _EdgeParticleN-1 do SumValue( _EdgeParticles[ I ] );
       for I := 0 to _FlowParticleN-1 do SumValue( _FlowParticles[ I ] );
end;

procedure TFluidSPH.CalcAttract( const H_:Double);
     function AttractKernel( const d_:Double ) :Double;
     var
      W :Double;
     begin
         if d_ >= (H_*sqrt(2)) then Result := 0;
         if d_ < (H_*sqrt(2)) then
         begin
         //Form3.Label2.Text := 'd = ' + FloatToStr(d_);
         Result := (315 / (64 * PI * power(H_*sqrt(2), 9))) * power((power(H_*sqrt(2), 2) - d_*d_), 3);
         end;
     end;

     function AttractSF( const P_:Double ) :Double;
     begin

     end;

     procedure SumValue( var P_:TParticle );
     var
        X0, X1, Y0, Y1, N, NN :Integer;
        P :PParticle;
        R :TDouble2D;
        D :Double;
        w_a, w_v:Double;
     begin
          with P_ do
          begin
              w_a := 1.0;
              w_v := 0.5;

              Attract := TDouble2D.Create( 0, 0 );

              for N := 0 to Form3.F5count-1 do
                begin

                   R := (Form3.F5point[N] - Posi) / 10;
                   D := sqrt(R.X*R.X + R.Y*R.Y);

                   if D <= (H_*sqrt(2)) then
                    begin
                         R := (Form3.F5point[N] - Posi) / 10;
                         D := sqrt(R.X*R.X + R.Y*R.Y);

                         //Form3.Label2.Text := 'd = ' + FloatToStr(D);
                         //Form3.Label2.Text := 'W = ' + FloatToStr(AttractKernel(D));


                         //Form3.Label2.Text := 'a = ' + FloatToStr(_CGrid[ N ].Alpha);

                         Attract := Attract + _CGrid[ N ].Alpha * (AttractKernel(D) * R / D);
                    end;
                end;
                //Form3.Label2.Text := 'Attract = (' + FloatToStr(Attract.X) + ', ' + FloatToStr(Attract.Y) + ')';
          end;
     end;
//---------------------------------------------
var
   I :Integer;
begin
       for I := 0 to _EdgeParticleN-1 do SumValue( _EdgeParticles[ I ] );
       for I := 0 to _FlowParticleN-1 do SumValue( _FlowParticles[ I ] );
end;

procedure TFluidSPH.InitAttract;
var
   I :Integer;
begin
   for I := 0 to _FlowParticleN-1 do _FlowParticles[ I ].Attract := TDouble2D.Create( 0, 0 );
end;


procedure TFluidSPH.CalcForc;
var
   I :Integer;
   Ex:TDouble2D;
begin
     for I := 0 to _FlowParticleN-1 do
     begin
          with _FlowParticles[ I ] do
          begin
               Ex := TDouble2D.Create( 0, 0.0001 );

               Forc := Attract + Mouse + Pres + Visc + Ex;
               Velo := Velo + Forc / Dens;
               Posi := Posi + Velo;

          end;
     end;
end;



//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

function Pow4( const X_:Double ) :Double;
begin
     Result := Pow2( Pow2( X_ ) );
end;

function Pow5( const X_:Double ) :Double;
begin
     Result := Pow2( X_ ) * Pow3( X_ );
end;

function Pow6( const X_:Double ) :Double;
begin
     Result := Pow2( Pow3( X_ ) );
end;

function Pow8( const X_:Double ) :Double;
begin
     Result := Pow2( Pow4( X_ ) );
end;

////////////////////////////////////////////////////////////////////////////////

function KernelPoly6( const R_:TDouble2D; const H_:Double ) :Double;
var
   R, R2, HR :Double;
begin
     R := R_.Size;

     if R < H_ then
     begin
          R2 := Pow2( R  );
          HR := Pow2( H_ ) - R2;

          Result := 4 / ( Pi * Pow8( H_ ) )
                  * Pow3( HR );
     end
     else Result := 0;
end;

function dKernelSpiky( const R_:TDouble2D; const H_:Double ) :TDouble2D;
var
   R, HR :Double;
begin
     R := R_.Size;

     if R < H_ then
     begin
          HR := H_ - R;

          Result := -30 / ( Pi * Pow5( H_ ) )
                  * Pow2( HR ) * R_ / R;
     end
     else Result := TDouble2D.Create( 0, 0 );
end;

function d2KernelViscosity( const R_:TDouble2D; const H_:Double ) :Double;
var
   R, HR :Double;
begin
     R := R_.Size;

     if R < H_ then
     begin
          HR := H_ - R;

          Result := 20 / ( 3 * Pi * Pow5( H_ ) )
                  * HR;
     end
     else Result := 0;
end;

function sqrt2D( const R_:TDouble2D) :TDouble2D;
begin
     Result := TDouble2D.Create(sqrt(R_.X), sqrt(R_.Y));
end;



//############################################################################## □

initialization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 初期化

finalization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 最終化

end. //######################################################################### ■
