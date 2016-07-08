unit LUX.D1;

interface //#################################################################### ■

uses LUX;

type //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【型】

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TdSingle

     TdSingle = record
     private
     public
       o :Single;
       d :Single;
       /////
       constructor Create( const o_,d_:Single );
       ///// 演算子
       class operator Positive( const V_:TdSingle ) :TdSingle;
       class operator Negative( const V_:TdSingle ) :TdSingle;
       class operator Add( const A_,B_:TdSingle ) :TdSingle;
       class operator Subtract( const A_,B_:TdSingle ) :TdSingle;
       class operator Multiply( const A_:Single; const B_:TdSingle ) :TdSingle;
       class operator Multiply( const A_:TdSingle; const B_:Single ) :TdSingle;
       class operator Multiply( const A_,B_:TdSingle ) :TdSingle;
       class operator Divide( const A_:TdSingle; const B_:Single ) :TdSingle;
       class operator Divide( const A_,B_:TdSingle ) :TdSingle;
       ///// 型変換
       class operator Implicit( const V_:Integer ) :TdSingle;
       class operator Implicit( const V_:Int64 ) :TdSingle;
       class operator Implicit( const V_:Single ) :TdSingle;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TdDouble

     TdDouble = record
     private
     public
       o :Double;
       d :Double;
       /////
       constructor Create( const o_,d_:Double );
       ///// 演算子
       class operator Positive( const V_:TdDouble ) :TdDouble;
       class operator Negative( const V_:TdDouble ) :TdDouble;
       class operator Add( const A_,B_:TdDouble ) :TdDouble;
       class operator Subtract( const A_,B_:TdDouble ) :TdDouble;
       class operator Multiply( const A_:Double; const B_:TdDouble ) :TdDouble;
       class operator Multiply( const A_:TdDouble; const B_:Double ) :TdDouble;
       class operator Multiply( const A_,B_:TdDouble ) :TdDouble;
       class operator Divide( const A_:TdDouble; const B_:Double ) :TdDouble;
       class operator Divide( const A_,B_:TdDouble ) :TdDouble;
       ///// 型変換
       class operator Implicit( const V_:Integer ) :TdDouble;
       class operator Implicit( const V_:Int64 ) :TdDouble;
       class operator Implicit( const V_:Double ) :TdDouble;
     end;

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

//const //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【定数】

//var //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【変数】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

function Pow2( const X_:TdSingle ) :TdSingle; overload;
function Pow2( const X_:TdDouble ) :TdDouble; overload;
           
function Pow3( const X_:TdSingle ) :TdSingle; overload;
function Pow3( const X_:TdDouble ) :TdDouble; overload;

function Roo2( const X_:TdSingle ) :TdSingle; overload;
function Roo2( const X_:TdDouble ) :TdDouble; overload;

function ArcCos_( const C_:TdSingle ) :TdSingle; overload;
function ArcCos_( const C_:TdDouble ) :TdDouble; overload;

function Abso( const V_:TdSingle ) :TdSingle; overload;
function Abso( const V_:TdDouble ) :TdDouble; overload;

function Sin_( const X_:TdSingle ) :TdSingle; overload;
function Sin_( const X_:TdDouble ) :TdDouble; overload;

function Cos_( const X_:TdSingle ) :TdSingle; overload;
function Cos_( const X_:TdDouble ) :TdDouble; overload;

function Tan_( const X_:TdSingle ) :TdSingle; overload;
function Tan_( const X_:TdDouble ) :TdDouble; overload;

function ArcTan_( const X_:TdSingle ) :TdSingle; overload;
function ArcTan_( const X_:TdDouble ) :TdDouble; overload;

function ArcSin_( const X_:TdSingle ) :TdSingle; overload;
function ArcSin_( const X_:TdDouble ) :TdDouble; overload;

implementation //############################################################### ■

uses System.Math;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TdSingle

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TdSingle.Create( const o_,d_:Single );
begin
     o := o_;
     d := d_;
end;

///////////////////////////////////////////////////////////////////////// 演算子

class operator TdSingle.Positive( const V_:TdSingle ) :TdSingle;
begin
     with Result do
     begin
          o := +V_.o;
          d := +V_.d;
     end;
end;

class operator TdSingle.Negative( const V_:TdSingle ) :TdSingle;
begin
     with Result do
     begin
          o := -V_.o;
          d := -V_.d;
     end;
end;

class operator TdSingle.Add( const A_,B_:TdSingle ) :TdSingle;
begin
     with Result do
     begin
          o := A_.o + B_.o;
          d := A_.d + B_.d;
     end;
end;

class operator TdSingle.Subtract( const A_,B_:TdSingle ) :TdSingle;
begin
     with Result do
     begin
          o := A_.o - B_.o;
          d := A_.d - B_.d;
     end;
end;

class operator TdSingle.Multiply( const A_:Single; const B_:TdSingle ) :TdSingle;
begin
     with Result do
     begin
          o := A_ * B_.o;
          d := A_ * B_.d;
     end;
end;

class operator TdSingle.Multiply( const A_:TdSingle; const B_:Single ) :TdSingle;
begin
     with Result do
     begin
          o := A_.o * B_;
          d := A_.d * B_;
     end;
end;

class operator TdSingle.Multiply( const A_,B_:TdSingle ) :TdSingle;
begin
     with Result do
     begin
          o := A_.o * B_.o;
          d := A_.d * B_.o + A_.o * B_.d;
     end;
end;

class operator TdSingle.Divide( const A_:TdSingle; const B_:Single ) :TdSingle;    
begin
     with Result do
     begin
          o := A_.o / B_;
          d := A_.d / B_;
     end;
end;

class operator TdSingle.Divide( const A_,B_:TdSingle ) :TdSingle;
begin
     with Result do
     begin
          o := A_.o / B_.o;
          d := ( A_.d * B_.o - A_.o * B_.d ) / Pow2( B_.o );
     end;
end;

///////////////////////////////////////////////////////////////////////// 型変換

class operator TdSingle.Implicit( const V_:Integer ) :TdSingle;
begin
     with Result do
     begin
          o := V_;
          d := 0;
     end;
end;

class operator TdSingle.Implicit( const V_:Int64 ) :TdSingle;
begin
     with Result do
     begin
          o := V_;
          d := 0;
     end;
end;

class operator TdSingle.Implicit( const V_:Single ) :TdSingle;
begin
     with Result do
     begin
          o := V_;
          d := 0;
     end;
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TdDouble

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TdDouble.Create( const o_,d_:Double );
begin
     o := o_;
     d := d_;
end;

///////////////////////////////////////////////////////////////////////// 演算子

class operator TdDouble.Positive( const V_:TdDouble ) :TdDouble;
begin
     with Result do
     begin
          o := +V_.o;
          d := +V_.d;
     end;
end;

class operator TdDouble.Negative( const V_:TdDouble ) :TdDouble;
begin
     with Result do
     begin
          o := -V_.o;
          d := -V_.d;
     end;
end;

class operator TdDouble.Add( const A_,B_:TdDouble ) :TdDouble;
begin
     with Result do
     begin
          o := A_.o + B_.o;
          d := A_.d + B_.d;
     end;
end;

class operator TdDouble.Subtract( const A_,B_:TdDouble ) :TdDouble;
begin
     with Result do
     begin
          o := A_.o - B_.o;
          d := A_.d - B_.d;
     end;
end;

class operator TdDouble.Multiply( const A_:Double; const B_:TdDouble ) :TdDouble;
begin
     with Result do
     begin
          o := A_ * B_.o;
          d := A_ * B_.d;
     end;
end;

class operator TdDouble.Multiply( const A_:TdDouble; const B_:Double ) :TdDouble;
begin
     with Result do
     begin
          o := A_.o * B_;
          d := A_.d * B_;
     end;
end;

class operator TdDouble.Multiply( const A_,B_:TdDouble ) :TdDouble;
begin
     with Result do
     begin
          o := A_.o * B_.o;
          d := A_.d * B_.o + A_.o * B_.d;
     end;
end;

class operator TdDouble.Divide( const A_:TdDouble; const B_:Double ) :TdDouble;    
begin
     with Result do
     begin
          o := A_.o / B_;
          d := A_.d / B_;
     end;
end;

class operator TdDouble.Divide( const A_,B_:TdDouble ) :TdDouble;
begin
     with Result do
     begin
          o := A_.o / B_.o;
          d := ( A_.d * B_.o - A_.o * B_.d ) / Pow2( B_.o );
     end;
end;

///////////////////////////////////////////////////////////////////////// 型変換

class operator TdDouble.Implicit( const V_:Integer ) :TdDouble;
begin
     with Result do
     begin
          o := V_;
          d := 0;
     end;
end;

class operator TdDouble.Implicit( const V_:Int64 ) :TdDouble;
begin
     with Result do
     begin
          o := V_;
          d := 0;
     end;
end;

class operator TdDouble.Implicit( const V_:Double ) :TdDouble;
begin
     with Result do
     begin
          o := V_;
          d := 0;
     end;
end;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

function Pow2( const X_:TdSingle ) :TdSingle;
begin
     with X_ do
     begin
          Result.o := Pow2( o );
          Result.d := 2 * o * d;
     end;
end;

function Pow2( const X_:TdDouble ) :TdDouble;
begin
     with X_ do
     begin
          Result.o := Pow2( o );
          Result.d := 2 * o * d;
     end;
end;

////////////////////////////////////////////////////////////////////////////////

function Pow3( const X_:TdSingle ) :TdSingle;
begin
     with X_ do
     begin
          Result.o := Pow3( o );
          Result.d := 3 * Pow2( o ) * d;
     end;
end;

function Pow3( const X_:TdDouble ) :TdDouble;
begin
     with X_ do
     begin
          Result.o := Pow3( o );
          Result.d := 3 * Pow2( o ) * d;
     end;
end;

////////////////////////////////////////////////////////////////////////////////

function Roo2( const X_:TdSingle ) :TdSingle;
begin
     with X_ do
     begin
          Result.o := Roo2( o );
          Result.d := d / ( 2 * Roo2( o ) );
     end;
end;

function Roo2( const X_:TdDouble ) :TdDouble;
begin
     with X_ do
     begin
          Result.o := Roo2( o );
          Result.d := d / ( 2 * Roo2( o ) );
     end;
end;

////////////////////////////////////////////////////////////////////////////////

function ArcCos_( const C_:TdSingle ) :TdSingle;
begin
     with C_ do
     begin
          Result.o := ArcCos( o );
          Result.d := -d / Roo2( 1 - Pow2( o ) );
     end;
end;

function ArcCos_( const C_:TdDouble ) :TdDouble;
begin
     with C_ do
     begin
          Result.o := ArcCos( o );
          Result.d := -d / Roo2( 1 - Pow2( o ) );
     end;
end;

////////////////////////////////////////////////////////////////////////////////

function Abso( const V_:TdSingle ) :TdSingle;
begin
     if V_.o < 0 then Result := -V_;
end;

function Abso( const V_:TdDouble ) :TdDouble;
begin
     if V_.o < 0 then Result := -V_;
end;

////////////////////////////////////////////////////////////////////////////////

function Sin_( const X_:TdSingle ) :TdSingle;
begin
     with X_ do
     begin
          Result.o :=      Sin( o );
          Result.d := d * +Cos( o );
     end;
end;

function Sin_( const X_:TdDouble ) :TdDouble;
begin
     with X_ do
     begin
          Result.o :=      Sin( o );
          Result.d := d * +Cos( o );
     end;
end;

////////////////////////////////////////////////////////////////////////////////

function Cos_( const X_:TdSingle ) :TdSingle;
begin
     with X_ do
     begin
          Result.o :=      Cos( o );
          Result.d := d * -Sin( o );
     end;
end;

function Cos_( const X_:TdDouble ) :TdDouble;
begin
     with X_ do
     begin
          Result.o :=      Cos( o );
          Result.d := d * -Sin( o );
     end;
end;

////////////////////////////////////////////////////////////////////////////////

function Tan_( const X_:TdSingle ) :TdSingle;
begin
     with X_ do
     begin
          Result.o := Tan( o );
          Result.d := d / Pow2( Cos( o ) );
     end;
end;

function Tan_( const X_:TdDouble ) :TdDouble;
begin
     with X_ do
     begin
          Result.o := Tan( o );
          Result.d := d / Pow2( Cos( o ) );
     end;
end;

////////////////////////////////////////////////////////////////////////////////

function ArcTan_( const X_:TdSingle ) :TdSingle;
begin
     with X_ do
     begin
          Result.o := ArcTan( o );
          Result.d := d / ( 1 + Pow2( o ) );
     end;
end;

function ArcTan_( const X_:TdDouble ) :TdDouble;
begin
     with X_ do
     begin
          Result.o := ArcTan( o );
          Result.d := d / ( 1 + Pow2( o ) );
     end;
end;

////////////////////////////////////////////////////////////////////////////////

function ArcSin_( const X_:TdSingle ) :TdSingle;
begin
     with X_ do
     begin
          Result.o := ArcSin( o );
          Result.d := d / Roo2( 1 - Pow2( o ) );
     end;
end;

function ArcSin_( const X_:TdDouble ) :TdDouble;
begin
     with X_ do
     begin
          Result.o := ArcSin( o );
          Result.d := d / Roo2( 1 - Pow2( o ) );
     end;
end;

//############################################################################## □

initialization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 初期化

finalization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 最終化

end. //######################################################################### ■
