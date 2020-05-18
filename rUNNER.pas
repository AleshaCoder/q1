uses Graph3D;
uses module;
uses System.Media;

const
  AngleSpeed = Pi * 50 / 360;

var
  ///Препятствия
  Blocks: array[0..100] of Object3D;
  ///Дым
  EffectBlocks: array[0..9] of Object3D;
  ///Здания
  Buildings : array[0..29] of Object3D;
  ///Дорога
  Ground := Box(0, -45, -3, 5, 100, 5, colors.DarkGray);
  ///Игрок
  Player := Cube(0, 0, -5, 1, RainbowMaterial);
  ///Окно с рекордом
  Score := Text3D(-1.9, 45, 4.5, '', 0.3, 'Arial', Colors.Black);
  ///Кнопка
  StartButton := Box(0, 1, 1, 3, 0.5, 1, Colors.Red);
  ///Текст кнопки
  StartText := Text3D(0, 0.26, 0, 'Старт', 0.5, 'Arial', Colors.Black);
  ///Игрок 2, ибо паскаль говно и выдает не 3д модель, а ссылку на нее
  Bahh := FileModel3D(0, 0, 4.48, 'Car.stl', Colors.Black);
  ///Анимация дыма
  An1: array[0..9] of AnimationBase;
  ///Музыка
  Player1 := new System.Windows.Media.MediaPlayer;
  ///для проверки
  kl, kr, StartButtonClick, isBag: boolean;
  ///Разница по х между камерой и игроком
  razX := Camera.Position.X - Player.Position.X;
  ///Разница по у между камерой и игроком
  razY := Camera.Position.Y - Player.Position.Y;
  ///Растояние от игрока до камеры. Не используется
  dist := Sqrt(Sqr(razX) + Sqr(razY) + Sqr(Camera.Position.Z - Player.Position.Z));
  ///
  x1: real;
  ///Скорость передвижения игрока за кадр
  speed := 1.0;
  ///Переменная для подсчета рекорда
  scoren := 0.0;
  ///Переменная для того, чтобы игрок не вылетал за пределы трассы.
  taps: integer;
  
///Срабатывает при клике на кнопку старт
///Запускаем механизм движения игрока
///Убираем кнопку
///Запускаем анимацию дыма
procedure StartGame;
begin
  taps := 0;
  StartButton.AnimMoveOnZ(10, 1).AccelerationRatio(0.5, 0.5).Begin;
  StartButtonClick := true;
  SpeakAsync('Погнали');
  for var a1 := 0 to 9 do
  begin
    An1[a1] := EffectBlocks[a1].AnimMoveOn(Random(-0.2, 0.2), Random(0.7, 2), Random(0, 0.6), random(0.4, 0.7)).Forever;
    An1[a1].Begin;
  end;
end;


///Срабатывает при перемещении мышки, пока не нажата кнопка старта
///Меняет цвет кнопки при нахождении курсора на ней
procedure OnMM(x, y: real; mb: integer);
begin
  if mb = 0 then
    if (FindNearestObject(x, y) = StartButton) or (FindNearestObject(x, y) = StartText) then
    begin
      StartButton.Color := Colors.DarkOrange
    end
    else StartButton.Color := Colors.Red
  else exit;
end;

///Срабатывает при клике
///Если клик произведен по кнопке, то запускается игра
procedure OnMD(x, y: real; mb: integer);
begin
  if (FindNearestObject(x, y) = StartButton) or (FindNearestObject(x, y) = StartText) then
  begin
    OnMouseMove -= OnMM;
    StartGame;
  end;
end;

///Срабатывает при нажатии кнопок клавиатуры
///а - движение игрока влево
///d - движение игрока вправо
///space - ускорение
procedure OnKD(k: Key);
begin
  case k of
    Key.a, Key.Left: 
      begin
        if (kl = false) and (StartButtonClick) and (taps < 2) then
        begin
          taps += 1;
          Player.AnimMoveOnX(1, 0.2).Begin;
          Player.AnimRotate(OrtZ, 30, 0.2).AutoReverse.Begin;
        end;
        kl := true;
      end;
    Key.Space: speed*=1.2;
    Key.d, Key.Right: 
      begin
        if (kr = false) and (StartButtonClick) and (taps > -2) then 
        begin
          taps -= 1;
          Player.AnimMoveOnX(-1, 0.2).Begin;
          Player.AnimRotate(OrtZ, -30, 0.2).AutoReverse.Begin;
        end;
        kr := true;
      end;
  end;  
end;

///Срабатывает при отжатии кнопок клавиатуры
procedure OnKU(k: Key);
begin
  case k of
    Key.a, Key.Left: kl := false;
    Key.d, Key.Right: kr := false;
  end;  
end;

///Проверка соприкасания препятствий и их разделение
procedure IsBagInRand(g : Object3D; i : integer);
begin
   while isBag do
    begin
      isBag:=false;
      for var a2 :=0 to i do
      begin
        if (g.Y - Blocks[a2].Y < 2) and (g<>Blocks[a2]) and (g.X<>Blocks[a2].X) then
        begin
         isBag:=true;
        end;
      end;
      if isBag then g.Position := new Point3D(Random(-2, 2), (i + 2) * Random(-5, -40) / 1.5, 0);
    end;
end;

///Перемещение препятствий вперед. Ооочень оптимально по сравнению с пересозданием объектов. 
procedure ReloadBlocks(g: Object3D);
begin
  //g.Scale(0.07);
  g.Y -= Random(400, 800);
  g.X := Random(-2, 2);
   IsBagInRand(g,29);
end;

///Первая загрузка сцены
procedure LoadLevel;
begin
  for var a1 := 0 to 29 do
  begin
    Blocks[a1] := FileModel3D(Random(-2, 2), (a1 + 2) * Random(-5, -40) / 1.5, 0, 'Car.stl', RandomColor);
    Blocks[a1].Scale(0.07);
    Blocks[a1].Z -= 0.52;
    Blocks[a1].Rotate(OrtZ, 180);
    IsBagInRand(Blocks[a1], a1);

   // Buildings[a1] := FileModel3D(-5,(a1 + 2) * Random(-5, -40) / 1.5, 0, 'Shop.obj', ImageMaterial('Hotel.png',1,1));
    //Buildings[a1].Color:=Colors.Blue;
    //Buildings[a1].Rotate(OrtX,90);
  end;
  for var a1 := 0 to 9 do
  begin
    EffectBlocks[a1] := Cube(-0.3, 0.44, 4.7, 0.1, Colors.Gray);
    Player.AddChild(EffectBlocks[a1]);
  end;
  Bahh.Rotate(OrtZ, 180);
  Bahh.Scale(0.07);
  //Bahh.Z-=0.52*2;
  View3D.ShowViewCube := false;
  View3D.ShowCoordinateSystem := false;
  View3D.ShowGridLines := false;
  Camera.Position := new Point3D(0, 6, 2);
  Camera.LookDirection := new Vector3D(0, -6, -2);
  Score.Rotate(OrtX, 5);
  Player.AddChild(Bahh);
  Ground.AddChild(Score);
  StartButton.AddChild(StartText);
  x1 := 1.0; 
end;

///Перезагрузка сцены после поражения
procedure ReloadLevel;
begin
  OnMouseMove += OnMM;
  for var a1 := 0 to 29 do
  begin
    Blocks[a1].Position := new Point3D(Random(-2, 2), (a1 + 2) * Random(-5, -40) / 1.5, 0);
    Blocks[a1].Z -= 0.52;
    IsBagInRand(Blocks[a1],a1);
  end;
  for var a1 := 0 to 9 do
  begin
    EffectBlocks[a1].Position := new Point3D(-0.3, 0.44, 4.7);
  end;
  Player.Position := new Point3D(0, 0, -5);
  Ground.Position := new Point3D(0, -45, -3);
  Camera.Position := new Point3D(0, 6, 2);
  Camera.LookDirection := new Vector3D(0, -6, -2);
  x1 := 1.0; 
  speed := 1;
  scoren := 0;
  StartButton.AnimMoveOnZ(-10, 1).AccelerationRatio(0.5, 0.5).Begin;
end;


///Механизм движения игрока
procedure Moving;
begin
  Player.MoveOn(0, -x1 * AngleSpeed * speed, 0);
  Camera.MoveOn(0, -x1 * AngleSpeed * speed, 0);
  Ground.MoveOn(0, -x1 * AngleSpeed * speed, 0);
end;

begin
  //Музыка
  Player1.Open( new System.Uri('C:\PABCWork.NET\My projects\rUNNER/Fon.mp3', System.UriKind.Absolute));
  Player1.Play();
  Player1.volume := 0.1;
  //
  
  LoadLevel;
  
  OnKeyDown := OnKD;
  OnKeyUp := OnKU; 
  OnMouseDown := OnMD;
  OnMouseMove := OnMM;
  
  //Адское ядро. Покадровая смена всего
  BeginFrameBasedAnimationTime(dt -> begin
    if StartButtonClick then
    begin
      Bahh.AnimRotate(OrtY, Random(-0.258, 0.25), dt).AutoReverse.Begin;
      View3D.Title := 'Score: ' + scoren.ToString;
      View3D.SubTitle := 'Speed:  ' + speed.ToString;
      scoren += speed / 10;
      Score.Text := Round(scoren).ToString;
      
      //Проверка нахождения препятствий за камерой для их перезагрузки
      //Проверка столкновения игрока с препятствиями      
      for var qq := 0 to 29 do
      begin
        if (Camera.Position.Y < Blocks[qq].Y) then
          ReloadBlocks(Blocks[qq]);
        if (Abs(Player.X - Blocks[qq].X) < 0.9) and (Abs(Player.Y - Blocks[qq].Y) < 1) then
        begin
          SpeakAsync('Бабах');
          StartButtonClick := false;
          for var a1 := 0 to 9 do
          begin
            An1[a1].Pause;
            EffectBlocks[a1].Position := new Point3D(random(-0.45, 0.45), 0.5, -0.45);
          end;
          var qqq := (Blocks[qq].AnimScale(1, 0.4, ReloadLevel) + Blocks[qq].AnimScale(0.07, 0.1));
          qqq.Begin;
        end;
      end;
      
      //Движение игрока
      Moving;
    end;
  end);
  
  //Посекундное ускорение скорости
  while true do
  begin
    if StartButtonClick then
    begin
      Sleep(1000);
      speed += 0.01;
    end;
  end;
end.