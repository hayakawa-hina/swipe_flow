unit LUX;

interface //#################################################################### ■

uses System.SysUtils, System.UITypes, System.Math.Vectors,
     FMX.Graphics, FMX.Types3D, FMX.Controls3D, FMX.Objects3D;

type //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【型】

     PPByte = ^PByte;

     TArray2<TValue_> = array of TArray <TValue_>;
     TArray3<TValue_> = array of TArray2<TValue_>;

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HMatrix3D

     HMatrix3D = record helper for TMatrix3D
     private
       ///// アクセス
       function GetTranslate :TPoint3D; inline;
       procedure SetTranslate( const Translate_:TPoint3D ); inline;
     public
       ///// プロパティ
       property Translate :TPoint3D read GetTranslate write SetTranslate;
       ///// 定数
       class function Identity :TMatrix3D; static;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HBitmapData

     HBitmapData = record helper for TBitmapData
     private
       ///// アクセス
       function GetColor( const X_,Y_:Integer ) :TAlphaColor; inline;
       procedure SetColor( const X_,Y_:Integer; const Color_:TAlphaColor ); inline;
     public
       ///// プロパティ
       property Color[ const X_,Y_:Integer ] :TAlphaColor read GetColor write SetColor;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TRay3D

     TRay3D = record
     private
     public
       Pos :TVector3D;
       Vec :TVector3D;
       /////
       constructor Create( const Pos_,Vec_:TVector3D );
     end;

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HControl3D

     HControl3D = class helper for TControl3D
     private
       ///// アクセス
       function Get_SizeX :Single; inline;
       procedure Set_SizeX( const _SizeX_:Single ); inline;
       function Get_SizeY :Single; inline;
       procedure Set_SizeY( const _SizeY_:Single ); inline;
       function Get_SizeZ :Single; inline;
       procedure Set_SizeZ( const _SizeZ_:Single ); inline;
       ///// メソッド
       procedure RecalcFamilyAbsolute; inline;
     protected
       property _SizeX :Single read Get_SizeX write Set_SizeX;
       property _SizeY :Single read Get_SizeY write Set_SizeY;
       property _SizeZ :Single read Get_SizeZ write Set_SizeZ;
       ///// アクセス
       function GetAbsolMatrix :TMatrix3D; inline;
       procedure SetAbsoluteMatrix( const AbsoluteMatrix_:TMatrix3D ); virtual;
       function GetLocalMatrix :TMatrix3D; virtual;
       procedure SetLocalMatrix( const LocalMatrix_:TMatrix3D ); virtual;
       ///// メソッド
       procedure RecalcChildrenAbsolute;
     public
       ///// プロパティ
       property AbsoluteMatrix :TMatrix3D read GetAbsolMatrix write SetAbsoluteMatrix;
       property LocalMatrix    :TMatrix3D read GetLocalMatrix write SetLocalMatrix;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HCustomMesh

     HCustomMesh = class helper for TCustomMesh
     private
     protected
       ///// アクセス
       function GetMeshData :TMeshData; inline;
     public
       ///// プロパティ
       property MeshData :TMeshData read GetMeshData;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TProxyObject

     TProxyObject = class( FMX.Controls3D.TProxyObject )
     private
     protected
       ///// メソッド
       procedure Render; override;
     public
     end;

const //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【定数】

      Pi2 = 2 * Pi;
      Pi3 = 3 * Pi;
      Pi4 = 4 * Pi;

      P2i = Pi / 2;
      P3i = Pi / 3;
      P4i = Pi / 4;

//var //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【変数】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

function Pow2( const X_:Integer ) :Integer; inline; overload;
function Pow2( const X_:Single ) :Single; inline; overload;
function Pow2( const X_:Double ) :Double; inline; overload;

function Pow3( const X_:Integer ) :Integer; inline; overload;
function Pow3( const X_:Single ) :Single; inline; overload;
function Pow3( const X_:Double ) :Double; inline; overload;

function Roo2( const X_:Single ) :Single; inline; overload;
function Roo2( const X_:Double ) :Double; inline; overload;

function Roo3( const X_:Single ) :Single; inline; overload;
function Roo3( const X_:Double ) :Double; inline; overload;

function ClipRange( const X_,Min_,Max_:Integer ) :Integer; inline; overload;
function ClipRange( const X_,Min_,Max_:Single ) :Single; inline; overload;
function ClipRange( const X_,Min_,Max_:Double ) :Double; inline; overload;

function MinI( const A_,B_,C_:Single ) :Integer; inline; overload;
function MinI( const A_,B_,C_:Double ) :Integer; inline; overload;

function MaxI( const Vs_:array of Single ) :Integer; overload;
function MaxI( const Vs_:array of Double ) :Integer; overload;

function LoopMod( const X_,Range_:Integer ) :Integer; overload;
function LoopMod( const X_,Range_:Int64 ) :Int64; overload;

function FileToBytes( const FileName_:string ) :TBytes;

implementation //############################################################### ■

uses System.Classes, System.Math,
     FMX.Types;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HMatrix3D

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

function HMatrix3D.GetTranslate :TPoint3D;
begin
     with Result do
     begin
          X := m41;
          Y := m42;
          Z := m43;
     end;
end;

procedure HMatrix3D.SetTranslate( const Translate_:TPoint3D );
begin
     with Translate_ do
     begin
          m41 := X;
          m42 := Y;
          m43 := Z;
     end;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

class function HMatrix3D.Identity :TMatrix3D;
begin
     with Result do
     begin
          m11 := 1;  m12 := 0;  m13 := 0;  m14 := 0;
          m21 := 0;  m22 := 1;  m23 := 0;  m24 := 0;
          m31 := 0;  m32 := 0;  m33 := 1;  m34 := 0;
          m41 := 0;  m42 := 0;  m43 := 0;  m44 := 1;
     end;
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HBitmapData

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

function HBitmapData.GetColor( const X_,Y_:Integer ) :TAlphaColor;
begin
     Result := GetPixel( X_, Y_ );
end;

procedure HBitmapData.SetColor( const X_,Y_:Integer; const Color_:TAlphaColor );
begin
     SetPixel( X_, Y_, Color_ );
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TRay3D

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TRay3D.Create( const Pos_,Vec_:TVector3D );
begin
     Pos := Pos_;
     Vec := Vec_;
end;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HControl3D

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

/////////////////////////////////////////////////////////////////////// アクセス

function HControl3D.Get_SizeX :Single;
begin
     Result := FWidth;
end;

procedure HControl3D.Set_SizeX( const _SizeX_:Single );
begin
     FWidth := _SizeX_;
end;

function HControl3D.Get_SizeY :Single;
begin
     Result := FHeight;
end;

procedure HControl3D.Set_SizeY( const _SizeY_:Single );
begin
     FHeight := _SizeY_;
end;

function HControl3D.Get_SizeZ :Single;
begin
     Result := FDepth;
end;

procedure HControl3D.Set_SizeZ( const _SizeZ_:Single );
begin
     FDepth := _SizeZ_;
end;

/////////////////////////////////////////////////////////////////////// メソッド

procedure HControl3D.RecalcFamilyAbsolute;
begin
     RecalcAbsolute;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

function HControl3D.GetAbsolMatrix :TMatrix3D;
begin
     Result := Self.GetAbsoluteMatrix;
end;

procedure HControl3D.SetAbsoluteMatrix( const AbsoluteMatrix_:TMatrix3D );
begin
     FAbsoluteMatrix := AbsoluteMatrix_;

     FInvAbsoluteMatrix := FAbsoluteMatrix.Inverse;

     if Assigned( FParent ) and ( FParent is TControl3D )
     then FLocalMatrix := FAbsoluteMatrix * TControl3D( FParent ).AbsoluteMatrix.Inverse
     else FLocalMatrix := FAbsoluteMatrix;

     FRecalcAbsolute := False;

     RecalcChildrenAbsolute;
end;

function HControl3D.GetLocalMatrix :TMatrix3D;
begin
     Result := FLocalMatrix;
end;

procedure HControl3D.SetLocalMatrix( const LocalMatrix_:TMatrix3D );
begin
     FLocalMatrix := LocalMatrix_;

     RecalcAbsolute;
end;

/////////////////////////////////////////////////////////////////////// メソッド

procedure HControl3D.RecalcChildrenAbsolute;
var
   F :TFmxObject;
begin
     if Assigned( Children ) then
     begin
          for F in Children do
          begin
               if F is TControl3D then TControl3D( F ).RecalcFamilyAbsolute;
          end;
     end;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HCustomMesh

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

function HCustomMesh.GetMeshData :TMeshData;
begin
     Result := Self.FData;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TProxyObject

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// メソッド

procedure TProxyObject.Render;
var
   M :TMatrix3D;
   SX, SY, SZ :Single;
begin
     if Assigned( SourceObject ) then
     begin
          with SourceObject do
          begin
               M  := AbsoluteMatrix;
               SX := _SizeX;
               SY := _SizeY;
               SZ := _SizeZ;

               AbsoluteMatrix := Self.AbsoluteMatrix;
               _SizeX         := Self._SizeX;
               _SizeY         := Self._SizeY;
               _SizeZ         := Self._SizeZ;

               RenderInternal;

               AbsoluteMatrix := M;
               _SizeX         := SX;
               _SizeY         := SY;
               _SizeZ         := SZ;
          end;
     end;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

function Pow2( const X_:Integer ) :Integer;
begin
     Result := Sqr( X_ );
end;

function Pow2( const X_:Single ) :Single;
begin
     Result := Sqr( X_ );
end;

function Pow2( const X_:Double ) :Double;
begin
     Result := Sqr( X_ );
end;

////////////////////////////////////////////////////////////////////////////////

function Pow3( const X_:Integer ) :Integer;
begin
     Result := X_ * X_ * X_;
end;

function Pow3( const X_:Single ) :Single;
begin
     Result := X_ * X_ * X_;
end;

function Pow3( const X_:Double ) :Double;
begin
     Result := X_ * X_ * X_;
end;

////////////////////////////////////////////////////////////////////////////////

function Roo2( const X_:Single ) :Single;
begin
     Result := Sqrt( X_ );
end;

function Roo2( const X_:Double ) :Double;
begin
     Result := Sqrt( X_ );
end;

////////////////////////////////////////////////////////////////////////////////

function Roo3( const X_:Single ) :Single;
begin
     Result := Power( X_, 1/3 );
end;

function Roo3( const X_:Double ) :Double;
begin
     Result := Power( X_, 1/3 );
end;

////////////////////////////////////////////////////////////////////////////////

function ClipRange( const X_,Min_,Max_:Integer ) :Integer;
begin
     if X_ < Min_ then Result := Min_
                  else
     if X_ > Max_ then Result := Max_
                  else Result := X_;
end;

function ClipRange( const X_,Min_,Max_:Single ) :Single;
begin
     if X_ < Min_ then Result := Min_
                  else
     if X_ > Max_ then Result := Max_
                  else Result := X_;
end;

function ClipRange( const X_,Min_,Max_:Double ) :Double;
begin
     if X_ < Min_ then Result := Min_
                  else
     if X_ > Max_ then Result := Max_
                  else Result := X_;
end;

////////////////////////////////////////////////////////////////////////////////

function MinI( const A_,B_,C_:Single ) :Integer;
begin
     if A_ <= B_ then
     begin
          if A_ <= C_ then Result := 1
                      else Result := 3;
     end
     else
     begin
          if B_ <= C_ then Result := 2
                      else Result := 3;
     end;
end;

function MinI( const A_,B_,C_:Double ) :Integer;
begin
     if A_ <= B_ then
     begin
          if A_ <= C_ then Result := 1
                      else Result := 3;
     end
     else
     begin
          if B_ <= C_ then Result := 2
                      else Result := 3;
     end;
end;

////////////////////////////////////////////////////////////////////////////////

function MaxI( const Vs_:array of Single ) :Integer;
var
   I :Integer;
   V0, V1 :Single;
begin
     Result := 0;  V0 := Vs_[ 0 ];

     for I := 1 to High( Vs_ ) do
     begin
          V1 := Vs_[ I ];

          if V1 > V0 then
          begin
               Result := I;  V0 := V1;
          end
     end
end;

function MaxI( const Vs_:array of Double ) :Integer;
var
   I :Integer;
   V0, V1 :Double;
begin
     Result := 0;  V0 := Vs_[ 0 ];

     for I := 1 to High( Vs_ ) do
     begin
          V1 := Vs_[ I ];

          if V1 > V0 then
          begin
               Result := I;  V0 := V1;
          end
     end
end;

////////////////////////////////////////////////////////////////////////////////

function LoopMod( const X_,Range_:Integer ) :Integer;
begin
     Result := X_ mod Range_;  if Result < 0 then Inc( Result, Range_ );
end;

function LoopMod( const X_,Range_:Int64 ) :Int64;
begin
     Result := X_ mod Range_;  if Result < 0 then Inc( Result, Range_ );
end;

////////////////////////////////////////////////////////////////////////////////

function FileToBytes( const FileName_:string ) :TBytes;
begin
     with TMemoryStream.Create do
     begin
          try
             LoadFromFile( FileName_ );

             SetLength( Result, Size );

             Read( Result, Size );

          finally
                 Free;
          end;
     end;
end;

//############################################################################## □

initialization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 初期化

     Randomize;

finalization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 最終化

end. //######################################################################### ■
