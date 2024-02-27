Unit Menus;

Interface
{=========================================================================}
Procedure SetMenu(Mnu : Integer; T : String; iY, TColor, IColor, HLColor,
                  TFont, IFont, TSize, ISize, CPlace, NItems : Integer);
Procedure SetMItem(Mnu, It : Integer; S : String);
Procedure MoveHome(Mnu : Integer);
Procedure MoveMenu(Mnu, Dir : Integer);
Procedure DrawMenu(Mnu : Integer);
Function GetCurPlace(Mnu : Integer) : Integer;
{=========================================================================}
Implementation
{=========================================================================}
Uses Graph;
Type
   Menu = Record
            Title       : String;
            Y,
            TitleColor,
            ItemColor,
            HiLiteColor,
            TitleFont,
            ItemFont,
            TitleSize,
            ItemSize,
            CurPlace,
            NumItems    : Integer;
            Items       : Array [1 .. 10] of String;
         End;
Var
   Mnus : Array [1 .. 2] of Menu;
{-------------------------------------------------------------------------}
Procedure SetMenu(Mnu : Integer; T : String; iY, TColor, IColor, HLColor,
                  TFont, IFont, TSize, ISize, CPlace, NItems : Integer);
Begin
   With Mnus[Mnu] Do
    Begin
      Title := T;
      Y := iY;
      TitleColor := TColor;
      ItemColor := IColor;
      HiLiteColor := HLColor;
      TitleFont := TFont;
      ItemFont := IFont;
      TitleSize := TSize;
      ItemSize := ISize;
      CurPlace := CPlace;
      NumItems := NItems;
    End;
End;
{-------------------------------------------------------------------------}
Procedure SetMItem(Mnu, It : Integer; S : String);
Begin
   Mnus[Mnu].Items[It] := S;
End;
{-------------------------------------------------------------------------}
Procedure MoveHome(Mnu : Integer);
Begin
   Mnus[Mnu].CurPlace := 1;
End;
{-------------------------------------------------------------------------}
Procedure MoveMenu(Mnu, Dir : Integer);
Begin
   If Dir = 0 Then
    Begin
      Mnus[Mnu].CurPlace := Mnus[Mnu].CurPlace - 1;
      If Mnus[Mnu].CurPlace = 0 Then Mnus[Mnu].CurPlace := 1;
    End
   Else If Dir = 1 Then
    Begin
      Mnus[Mnu].CurPlace := Mnus[Mnu].CurPlace + 1;
      With Mnus[Mnu] Do If CurPlace > NumItems Then CurPlace := NumItems;
    End;
End;
{-------------------------------------------------------------------------}
Procedure CenterText(Y : Integer; S : String);
Var X : Integer;
Begin
   X := (GetMaxX Div 2) - (TextWidth(S) Div 2);
   OutTextXY(X, Y, S);
End;
{-------------------------------------------------------------------------}
Procedure DrawMenu(Mnu : Integer);
Var Count, CurY : Integer;
Begin
   With Mnus[Mnu] Do
    Begin
      SetTextStyle(TitleFont, HorizDir, TitleSize);
      SetColor(TitleColor);
      CenterText(Y, Title);
      CurY := Y + TextHeight(Title);
      SetTextStyle(ItemFont, HorizDir, ItemSize);
    End;
   For Count := 1 To Mnus[Mnu].NumItems Do
    Begin
      With Mnus[Mnu] Do
       Begin
         If Count = CurPlace
            Then SetColor(HiLiteColor)
            Else SetColor(ItemColor);
         CenterText(CurY, Items[Count]);
         CurY := CurY + TextHeight(Items[Count]);
       End;
    End;
End;
{-------------------------------------------------------------------------}
Function GetCurPlace(Mnu : Integer) : Integer;
Begin
   GetCurPlace := Mnus[Mnu].CurPlace;
End;
{-------------------------------------------------------------------------}
End.