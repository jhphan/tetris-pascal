Program Tetris;

Uses
   Graph,
   Crt,
   Drivers,
   WinFrame,
   Menus,
   HiScores,
   Bitmap;

Const
   HiScoreFile = 'HiTetris.Scr';
   MainMenu = 1;
   VLeft = 170;
   VTop = 20;
   VWidth = 15 * 20;
   VHeight = 15 * 30;
   bRed = 1;
   bBlue = 2;
   bGreen = 3;
   bYellow = 4;
   bPurple = 5;
   bGray = 6;
   kLeft = 75;
   kRight = 77;
   kRLeft = 51;
   kDown = 80;
   kUp = 72;
   kRRight = 52;
   kEsc = 1;
   kHelp = 59;
   kNew = 60;
   kPause = 61;
   kLevelUp = 63;
   kLevelDown = 64;
   kHeightUp = 65;
   kHeightDown = 66;
   BkSpc = 14;
   Enter = 28;

Type
   Piece = Record
              Blocks : Array[1 .. 4, 1 .. 4] of Byte;
           End;
Const
   BlockType   : Array[1 .. 7]
      of Piece = (
      (Blocks:
      ( (0, 0, 0, 0),
        (0, 1, 1, 0),
        (0, 1, 1, 0),
        (0, 0, 0, 0) )),
      (Blocks:
      ( (0, 1, 0, 0),
        (0, 1, 0, 0),
        (0, 1, 0, 0),
        (0, 1, 0, 0) )),
      (Blocks:
      ( (0, 1, 0, 0),
        (0, 1, 1, 0),
        (0, 0, 1, 0),
        (0, 0, 0, 0) )),
      (Blocks:
      ( (0, 0, 1, 0),
        (0, 1, 1, 0),
        (0, 1, 0, 0),
        (0, 0, 0, 0) )),
      (Blocks:
      ( (0, 1, 0, 0),
        (0, 1, 0, 0),
        (0, 1, 1, 0),
        (0, 0, 0, 0) )),
      (Blocks:
      ( (0, 0, 1, 0),
        (0, 0, 1, 0),
        (0, 1, 1, 0),
        (0, 0, 0, 0) )),
      (Blocks:
      ( (0, 0, 0, 0),
        (0, 1, 0, 0),
        (1, 1, 1, 0),
        (0, 0, 0, 0) )));

Var
   Device,
   Mode        : Integer;
   PurpleBlock,
   GrayBlock,
   RedBlock,
   BlueBlock,
   YellowBlock,
   GreenBlock  : Pointer;
   TPiece,
   NPiece,
   CurPiece    : Piece;
   Speed,
   Paused,
   SScore,
   Score,
   Level,
   Done,
   Died,
   Height,
   Lines,
   Result,
   NColor,
   NumFrames,
   CurColor,
   CurX, CurY  : Integer;
   Screen      : Array[0 .. 19, 0 .. 29] of Byte;
   KEvent      : TEvent;
{-------------------------------------------------------------------------}
Procedure LoadBlocks;
Begin
   RedBlock := GetPic('redb.pic');
   BlueBlock := GetPic('blueb.pic');
   YellowBlock := GetPic('yellowb.pic');
   GreenBlock := GetPic('greenb.pic');
   PurpleBlock := GetPic('purpleb.pic');
   GrayBlock := GetPic('grayb.pic');
End;
{-------------------------------------------------------------------------}
Procedure DefineMenus;
Begin
   SetMenu(1, 'Tetris', 100, 10, 4, 14, TriplexFont, SansSerifFont,
           5, 4, 1, 5);
      SetMItem(MainMenu, 1, 'Start Game');
      SetMItem(MainMenu, 2, 'High Scores');
      SetMItem(MainMenu, 3, 'About Tetris');
      SetMItem(MainMenu, 4, 'Tetris Help');
      SetMItem(MainMenu, 5, 'Exit Game');
End;
{-------------------------------------------------------------------------}
Procedure DefineWindows;
Begin
   NumFrames := 5;
   SetFrame(1, 9, 0, SolidFill, 1, 10, 20, 150, 50);
      SetItem(1, 1, 5, -5, TriplexFont, 6, 10, 'Tetris');
   SetFrame(2, 9, 0, SolidFill, 0, 10, 100, 150, 100);
   SetFrame(3, 9, 0, SolidFill, 8, 10, 230, 150, 205);
      SetItem(3, 1, 5, 5, SansSerifFont, 2, 14, 'Score:');
      SetItem(3, 2, 20, 25, SansSerifFont, 2, 14, '0');
      SetItem(3, 3, 5, 55, SansSerifFont, 2, 14, 'Lines:');
      SetItem(3, 4, 20, 75, SansSerifFont, 2, 14, '0');
      SetItem(3, 5, 5, 105, SansSerifFont, 2, 14, 'Level:');
      SetItem(3, 6, 20, 125, SansSerifFont, 2, 14, '0');
      SetItem(3, 7, 5, 155, SansSerifFont, 2, 14, 'Height:');
      SetItem(3, 8, 20, 175, SansSerifFont, 2, 14, '0');
   SetFrame(4, 9, 0, SolidFill, 0, VLeft - 2, VTop - 2, VWidth + 4, VHeight + 4);
   SetFrame(5, 9, 0, SolidFill, 2, 490, 300, 110, 45);
      SetItem(5, 1, 5, 0, TriplexFont, 1, 12, 'F1 : Help');
      SetItem(5, 2, 5, 20, TriplexFont, 1, 12, 'ESC : Menu');
End;
{-------------------------------------------------------------------------}
Procedure DrawStatus;
Begin
   EraseFrame(3);
   DrawFrame(3);
End;
{-------------------------------------------------------------------------}
Procedure DrawBackGround;
Var Fill, Color : Integer;
Begin
   Fill := Round(Random(10)) + 1;
   Color := Round(Random(15));
   If Color = 9 Then Color := 1;
   SetFillStyle(Fill, Color);
   FloodFill(2, 2, 9);
End;
{-------------------------------------------------------------------------}
Procedure DrawBlock(X, Y, Color : Integer);
Begin
   If Color = bRed Then PutImage(X, Y, RedBlock^, CopyPut);
   If Color = bBlue Then PutImage(X, Y, BlueBlock^, CopyPut);
   If Color = bGreen Then PutImage(X, Y, GreenBlock^, CopyPut);
   If Color = bYellow Then PutImage(X, Y, YellowBlock^, CopyPut);
   If Color = bPurple Then PutImage(X, Y, PurpleBlock^, CopyPut);
   If Color = bGray Then PutImage(X, Y, GrayBlock^, CopyPut);
   If Color = 0 Then Bar(X, Y, X + 15, Y + 15);
End;
{-------------------------------------------------------------------------}
Procedure DrawPiece(pX, pY, pC : Integer; P : Piece);
Var X, Y : Byte;
Begin
   For X := 1 To 4 Do
      For Y := 1 To 4 Do
         If P.Blocks[X, Y] = 1 Then DrawBlock(VLeft + (PX + X - 1) * 15, VTop + (pY + Y - 1) * 15, pC);
End;
{-------------------------------------------------------------------------}
Procedure GetRandomPiece;
Begin
   CurColor := NColor;
   CurPiece := NPiece;
   NColor := Round(Random(6)) + 1;
   NPiece := BlockType[Round(Random(7)) + 1];
End;
{-------------------------------------------------------------------------}
Procedure DrawNext;
Begin
   EraseFrame(2);
   DrawFrame(2);
   DrawPiece(-8, 7, NColor, NPiece);
End;
{-------------------------------------------------------------------------}
Procedure DrawView;
Var C : Integer;
Begin
   For C := 1 To NumFrames Do
    Begin
      EraseFrame(C);
      DrawFrame(C);
    End;
End;
{-------------------------------------------------------------------------}
Procedure ErasePiece;
Var X, Y : Byte;
Begin
   SetFillStyle(SolidFill, 0);
   For X := 1 To 4 Do
      For Y := 1 To 4 Do
         If CurPiece.Blocks[X, Y] = 1 Then DrawBlock(VLeft + (CurX + X - 1) * 15, VTop + (CurY + Y - 1) * 15, 0);
End;
{-------------------------------------------------------------------------}
Procedure RotatePiece(Dir : Byte);
Var X, Y : Byte;
    XM, YM,
    OX, OY : Integer;
Begin
   If Dir = 1 Then
    Begin
      XM := 3;
      YM := 0;
    End
   Else If Dir = 0 Then
    Begin
      XM := 0;
      YM := 3;
    End;
   OX := XM;
   OY := YM;
   TPiece := CurPiece;
   For X := 1 To 4 Do
    Begin
      For Y := 1 To 4 Do
       Begin
         CurPiece.Blocks[X, Y] := TPiece.Blocks[X + XM, Y + YM];
         If Dir = 1 Then
          Begin
            XM := XM - 1;
            YM := YM - 1;
          End
         Else If Dir = 0 Then
          Begin
            XM := XM + 1;
            YM := YM - 1;
          End
       End;
      If Dir = 1 Then
       Begin
         OX := OX - 1;
         OY := OY + 1;
       End
      Else If Dir = 0 Then
       Begin
         OX := OX - 1;
         OY := OY - 1;
       End;
      XM := OX;
      YM := OY;
    End;
End;
{-------------------------------------------------------------------------}
Procedure DefScreen;
Var X, Y, Pos : Byte;
Begin
   Pos := 30;
   For Y := 0 To 29 Do
    Begin
      For X := 0 To 19 Do
       Begin
         If Height >= Pos
            Then Screen[X, Y] := Round(Random(7));
       End;
      Pos := Pos - 1;
    End;
End;
{-------------------------------------------------------------------------}
Procedure DrawScreen;
Var X, Y : Byte;
Begin
   SetFillStyle(SolidFill, 0);
   For X := 0 To 19 Do
    Begin
      For Y := 0 To 29 Do
       Begin
         DrawBlock(VLeft + X * 15, VTop + Y * 15, Screen[X, Y]);
       End;
    End;
End;
{-------------------------------------------------------------------------}
Procedure ResetScreen;
Var X, Y : Byte;
Begin
   For X := 0 To 19 Do
    Begin
      For Y := 0 To 29 Do
       Begin
         Screen[X, Y] := 0;
       End;
    End;
End;
{-------------------------------------------------------------------------}
Function ValidMove : Byte;
Var X, Y : Byte;
Begin
   ValidMove := 1;
   For X := 1 To 4 Do
    Begin
      For Y := 1 To 4 Do
       Begin
         If (CurPiece.Blocks[X, Y] = 1) And ((Screen[CurX + X - 1, CurY + Y - 1] > 0) Or ((CurY + Y - 1) > 29)
            Or ((CurX + X - 1) > 19) Or ((CurX + X - 1) < 0)) Then
          Begin
            ValidMove := 0;
            Exit;
          End;
       End;
    End;
End;
{-------------------------------------------------------------------------}
Procedure MovePiece;
Var X, Y : Byte;
Begin
   CurY := CurY + 1;
   If ValidMove = 0 Then
    Begin
      CurY := CurY - 1;
      Done := 1;
    end;
End;
{-------------------------------------------------------------------------}
Procedure StorePiece;
Var X, Y : Byte;
Begin
   For X := 1 To 4 Do
    Begin
      For Y := 1 To 4 Do
       Begin
         If CurPiece.Blocks[X, Y] = 1 Then
          Begin
            Screen[CurX + X - 1, CurY + Y - 1] := CurColor;
          End;
       End;
    End;
End;
{-------------------------------------------------------------------------}
Procedure Down;
Begin
   Repeat
      CurY := CurY + 1;
   Until ValidMove = 0;
   CurY := CurY - 1;
End;
{-------------------------------------------------------------------------}
Procedure NewGame;
Var S : String;
Begin
   Score := 0;
   SetStrInt(3, 2, Score);
   SScore := 0;
   Lines := 0;
   SetStrInt(3, 4, Lines);
   CurX := 8;
   CurY := 1;
   GetRandomPiece;
   DrawStatus;
   ResetScreen;
   DefScreen;
   DrawScreen;
   DrawNext;
End;
{-------------------------------------------------------------------------}
Procedure Pause;
Begin
   If Paused = 1
      Then Paused := 0
      Else Paused := 1;
End;
{-------------------------------------------------------------------------}
Procedure LevelUp;
Var S : String;
Begin
   Level := Level + 1;
   If Level = 11
      Then Level := 10
      Else Speed := Speed - 20;
   SetStrInt(3, 6, Level);
   NewGame;
End;
{-------------------------------------------------------------------------}
Procedure LevelDown;
Var S : String;
Begin
   Level := Level - 1;
   If Level = 0
      Then Level := 1
      Else Speed := Speed + 20;
   SetStrInt(3, 6, Level);
   NewGame;
End;
{-------------------------------------------------------------------------}
Procedure HeightUp;
Var S : String;
Begin
   Height := Height + 1;
   If Height = 21 Then Height := 20;
   SetStrInt(3, 8, Height);
   NewGame;
End;
{-------------------------------------------------------------------------}
Procedure HeightDown;
Var S : String;
Begin
   Height := Height - 1;
   If Height = -1 Then Height := 0;
   SetStrInt(3, 8, Height);
   NewGame;
End;
{-------------------------------------------------------------------------}
Procedure CenterText(Y : Integer; Text : String);
Var X : Integer;
Begin
   X := (GetMaxX Div 2) - (TextWidth(Text) Div 2);
   OutTextXY(X, Y, Text);
End;
{-------------------------------------------------------------------------}
Procedure Help;
Begin
   ClearDevice;

   SetColor(10);
   SetTextStyle(TriplexFont, HorizDir, 4);
   CenterText(10, 'Tetris - Help');
   SetTextStyle(SansSerifFont, HorizDir, 2);
   SetColor(9);
   CenterText(50, '<F1> - Displays this help screen');
   SetColor(2);
   CenterText(70, '<F2> - Starts a new game');
   SetColor(3);
   CenterText(90, '<F3> - Pauses current game');
   SetColor(4);
   CenterText(110, '<F5> - Increases level');
   SetColor(5);
   CenterText(130, '<F6> - Decreases level');
   SetColor(6);
   CenterText(150, '<F7> - Increases Height');
   SetColor(7);
   CenterText(170, '<F8> - Decreases Height');
   SetColor(8);
   CenterText(190, '<ESC> - Ends the program');
   SetColor(9);
   CenterText(210, '''<'' or ''>'' or ''Up Arrow'' - Rotates pieces');
   SetColor(2);
   CenterText(230, '''Left or Right Arrows'' - Moves pieces');
   SetColor(3);
   CenterText(250, '''Down Arrow'' - Drops pieces');
   SetColor(10);
   CenterText(280, 'Press <Enter> to continue...');
   Readln;
   ClearDevice;
End;
{-------------------------------------------------------------------------}
Function HandleKey(Key : Byte) : Integer;
Begin
If Paused = 0 Then
 Begin
   If Key = kLeft Then
    Begin
      ErasePiece;
      CurX := CurX - 1;
      If ValidMove = 0 Then CurX := CurX + 1;
    End
   Else If Key = kRight Then
    Begin
      ErasePiece;
      CurX := CurX + 1;
      If ValidMove = 0 Then CurX := CurX - 1;
    End
   Else If (Key = kRLeft) Or (Key = kUp) Then
    Begin
      ErasePiece;
      RotatePiece(1);
      If ValidMove = 0 Then RotatePiece(0);
    End
   Else If Key = kRRight Then
    Begin
      ErasePiece;
      RotatePiece(0);
      If ValidMove = 0 Then RotatePiece(1);
    End
   Else If Key = kDown Then
    Begin
      ErasePiece;
      Down;
    End;
 End;
   If Key = kEsc Then
    Begin
      HandleKey := 1;
      Exit;
    End
   Else If Key = kNew Then NewGame
   Else If Key = kPause Then Pause
   Else If Key = kLevelUp Then LevelUp
   Else If Key = kLevelDown Then LevelDown
   Else If Key = kHeightUp Then HeightUp
   Else If Key = kHeightDown Then HeightDown
   Else If Key = kHelp Then
    Begin
      Help;
      DrawView;
      DrawScreen;
      DrawNext;
    End;
   HandleKey := 0;
End;
{-------------------------------------------------------------------------}
Procedure DeleteRow(Row : Byte);
Var X, Y : Byte;
Begin
   For Y := Row DownTo 1 Do
      For X := 0 To 19 Do
         Screen[X, Y] := Screen[X, Y - 1];
   For X := 0 To 19 Do
      Screen[X, 1] := 0;
   DrawScreen;
End;
{-------------------------------------------------------------------------}
Procedure CheckRows;
Var Comp, X, Y, Num : Byte;
    S : String;
Begin
   Y := 29;
   Num := 0;
   Repeat
      Comp := 1;
      For X := 0 To 19 Do
         If Screen[X, Y] = 0 Then Comp := 0;
      If Comp = 1
         Then
          Begin
            DeleteRow(Y);
            Num := Num + 1;
          End
         Else Y := Y - 1;
   Until Y = 1;
   If Num > 0 Then
    Begin
      Score := Score + 10 * Num * Num;
      SScore := SScore + 10 * Num * Num;
      If SScore >= 100 Then
       Begin
         Level := Level + 1;
         If Level = 11 Then
          Begin
            Level := 1;
            Height := Height + 4;
            If Height > 20 Then Height := 20;
            SetStrInt(3, 8, Height);
            ResetScreen;
            DefScreen;
            DrawView;
            DrawScreen;
            Speed := 500;
          End
         Else Speed := Speed - 20;
         SetStrInt(3, 6, Level);
         If Speed < 100 Then Speed := 100;
         SScore := 0;
         DrawBackGround;
       End;
      Lines := Lines + Num;
      SetStrInt(3, 4, Lines);
      SetStrInt(3, 2, Score);
      DrawStatus;
    End;
End;
{-------------------------------------------------------------------------}
Procedure Die;
Var X, Y : Integer;
Begin
   For X := 0 To 19 Do
      For Y := 0 To 29 Do
         If Screen[X, Y] > 0 Then Screen[X, Y] := bGray;
   DrawScreen;
   SetColor(10);
   SetTextStyle(TriplexFont, HorizDir, 5);
   OuttextXY(210, 200, 'Game Over');
   Readln;
End;
{-------------------------------------------------------------------------}
Procedure PlayGame;
Begin
   ResetScreen;
   DefScreen;
   DrawView;
   DrawScreen;
   Died := 0;
   Repeat
      GetRandomPiece;
      DrawNext;
      CurX := 8;
      CurY := 1;
      If ValidMove = 0 Then Died := 1;
      Done := 0;
      Repeat
         If Paused = 0 Then ErasePiece;
         GetKeyEvent(KEvent);
         If KEvent.What = evKeyDown
            Then
             Begin
               If HandleKey(KEvent.ScanCode) = 1
                    Then Exit;
             End
            Else If Paused = 0 Then MovePiece;
         If Paused = 0 Then
          Begin
            DrawPiece(CurX, CurY, CurColor, CurPiece);
            Delay(Speed);
          End;
      Until Done = 1;
      StorePiece;
      CheckRows;
   Until Died = 1;
   Die;
   ResetScreen;
   DrawScreen;
End;
{-------------------------------------------------------------------------}
Procedure DefaultVars;
Begin
   Level := 1;
   SetStrInt(3, 6, Level);
   Lines := 0;
   SetStrInt(3, 4, Lines);
   SScore := 0;
   Score := 0;
   SetStrInt(3, 2, Score);
   Height := 0;
   SetStrInt(3, 8, Height);
   Died := 0;
   Speed := 500;
   Paused := 0;
End;
{-------------------------------------------------------------------------}
Procedure ShowScores;
Begin
   ClearDevice;
   DrawScores(50, TriplexFont, 6, 10, SansSerifFont, 4, 4,
              'High Scores');
   Readln;
   ClearDevice;
End;
{-------------------------------------------------------------------------}
Procedure DoScore;
Var Place : Integer;
Begin
   Place := AddScore(Score);
   If Place > 0 Then
    Begin
      ShowScores;
    End;
   DrawView;
End;
{-------------------------------------------------------------------------}
Procedure AboutTetris;
Begin
   ClearDevice;
   SetTextStyle(TriplexFont, HorizDir, 5);
   SetColor(10);
   CenterText(100, 'Tetris');
   SetTextStyle(TriplexFont, HorizDir, 3);
   SetColor(13);
   CenterText(175, 'Tetris was invented by Alexey Pazhitnov');
   CenterText(225, 'It was originally programmed by Vadim Gerisimov');
   CenterText(275, 'This copy of Tetris was programmed by John Phan');
   SetTextStyle(SansSerifFont, HorizDir, 2);
   SetColor(4);
   CenterText(350, 'Press <Enter> to continue...');
   Readln;
   ClearDevice;
End;
{-------------------------------------------------------------------------}
Procedure DoMenu;
Var CP : Integer;
Begin
   DrawView;
   DrawMenu(MainMenu);
   Repeat
      GetKeyEvent(KEvent);
      If KEvent.What = evKeyDown Then
       Begin
         If KEvent.ScanCode = kUp Then
          Begin
            MoveMenu(1, 0);
            DrawMenu(MainMenu);
          End
         Else If KEvent.ScanCode = kDown Then
          Begin
            MoveMenu(1, 1);
            DrawMenu(MainMenu);
          End
         Else If KEvent.ScanCode = Enter Then
          Begin
            CP := GetCurPlace(MainMenu);
            If CP = 1 Then
             Begin
               DefaultVars;
               PlayGame;
               DoScore;
               DrawMenu(MainMenu);
             End
            Else If CP = 2 Then
             Begin
               ShowScores;
               DrawView;
               DrawMenu(MainMenu);
             End
            Else If CP = 3 Then
             Begin
               AboutTetris;
               DrawView;
               DrawMenu(MainMenu);
             End
            Else If CP = 4 Then
             Begin
               Help;
               DrawView;
               DrawMenu(MainMenu);
             End
            Else If CP = 5 Then
             Begin
               SaveScores(HiScoreFile);
               CloseGraph;
               Halt;
             End;
          End;
       End;
      KEvent.What := evNothing;
   Until (1<>1);
End;
{-------------------------------------------------------------------------}
Begin
   Randomize;
   DetectGraph(Device, Mode);
   InitGraph(Device, Mode, '');
   LoadBlocks;
   ReadScores(HiScoreFile);
   DefineWindows;
   DefineMenus;

   { Init random piece }
   NColor := Round(Random(4)) + 1;
   NPiece := BlockType[Round(Random(7)) + 1];

   DefaultVars;
   DoMenu;
End.