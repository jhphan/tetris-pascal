Unit WinFrame;

Interface
{=========================================================================}
Procedure SetFrame(Num, BordColor, BColor, BFill,
                    NItems, tX, tY, tW, tH : Integer);
Procedure SetItem(Frm, It, iX, iY, TStyle, TSize, TColor : Integer;
                  TStr : String);
Procedure SetStr(Frm, It : Integer; S : String);
Procedure SetStrInt(Frm, It, Num : Integer);
Procedure DrawFrame(Frm : Integer);
Procedure EraseFrame(Frm : Integer);
{=========================================================================}
Implementation
{=========================================================================}
Uses Graph;
Type
   Item = Record
             X, Y,
             TextStyle,
             TextSize,
             TextColor : Integer;
             TextStr   : String;
          End;
   Frame = Record
              BorderColor,
              BackColor,
              BackFillStyle,
              NumItems,
              X, Y,
              Width,
              Height         : Integer;
              Items          : Array[1 .. 10] Of Item;
           End;

Var
   Frames : Array[1 .. 10] of Frame;

{-------------------------------------------------------------------------}
Procedure SetItem;
Begin
   With Frames[Frm].Items[It] Do
    Begin
      X := iX;
      Y := iY;
      TextStyle := TStyle;
      TextSize := TSize;
      TextColor := TColor;
      TextStr := TStr;
    End;
End;
{-------------------------------------------------------------------------}
Procedure SetFrame(Num, BordColor, BColor, BFill,
                    NItems, tX, tY, tW, tH : Integer);
Begin
   With Frames[Num] Do
    Begin
      BorderColor := BordColor;
      BackColor := BColor;
      BackFillStyle := BFill;
      NumItems := NItems;
      X := tX;
      Y := tY;
      Width := tW;
      Height := tH;
    End;
End;
{-------------------------------------------------------------------------}
Procedure SetStr(Frm, It : Integer; S : String);
Begin
   Frames[Frm].Items[It].TextStr := S;
End;
{-------------------------------------------------------------------------}
Procedure SetStrInt(Frm, It, Num : Integer);
Var S : String;
Begin
   Str(Num, S);
   SetStr(Frm, It, S);
End;
{-------------------------------------------------------------------------}
Procedure DrawFrame(Frm : Integer);
Var C : Integer;
Begin
   With Frames[Frm] Do
    Begin
       SetColor(BorderColor);
       Rectangle(X, Y, X + Width, Y + Height);
       SetFillStyle(BackFillStyle, BackColor);
       FloodFill(X + 5, Y + 5, BorderColor);
       For C := 1 To NumItems Do
        Begin
          SetTextStyle(Items[C].TextStyle, HorizDir, Items[C].TextSize);
          SetColor(Items[C].TextColor);
          OutTextXY(X + Items[C].X, Y + Items[C].Y, Items[C].TextStr);
        End;
    End;
End;
{-------------------------------------------------------------------------}
Procedure EraseFrame(Frm : Integer);
Begin
   SetFillStyle(SolidFill, 0);
   With Frames[Frm] Do Bar(X, Y, X + Width, Y + Height);
End;
{=========================================================================}
End.