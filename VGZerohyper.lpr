program VGZerohyper;

{$mode objfpc}{$H+}

{ Raspberry Pi 3 Application                                                   }
{  Add your program code below, add additional units to the "uses" section if  }
{  required and create new units by selecting File, New Unit from the menu.    }
{                                                                              }
{  To compile your program select Run, Compile (or Run, Build) from the menu.  }

uses
  RaspberryPi,
  OpenVG,
  VGShapes,
  GlobalConfig,
  GlobalConst,
  GlobalTypes,
  Platform,
  Threads,
  Framebuffer,
  Mouse,
  Touch,
  GPIO,
  I2C,
  HyperPixel,
  DispmanX,
  cogwarebootimage,
  SysUtils;
const
  HYPERPIXEL_FRAMEBUFFER = 'BCM2835 Framebuffer (Main LCD)';
  HYPERPIXEL_MODEL = HYPERPIXEL21_ROUND;

var
  Width, Height : longint;
  BootImage : VGImage;
  Angle : integer;
  Direction : integer;
  FramebufferDevice:PFramebufferDevice;
  FramebufferProperties:TFramebufferProperties;
  ScreenWidth:LongWord;
  ScreenHeight:LongWord;
  existingmatrix : array[1..9] of VGFloat;
  existingmatrix1 : array[1..9] of VGFloat;

  function LoadBootScreen(ImageW, ImageH : integer) : VGImage;
begin
  Result := vgCreateImage(VG_sARGB_8888, ImageW, ImageH, VG_IMAGE_QUALITY_BETTER);

  vgImageSubData(Result, @cogwareblob[1], ImageW*4, VG_sABGR_8888, 0, 0, ImageW, ImageH);
end;

procedure DisplayBootScreen(BootImage : VGImage; Width, Height, ImageW, ImageH : integer);
var
  existingmatrix : array[1..9] of VGFloat;

  begin
  VGShapesBackground(0, 0, 0);
  vgSeti(VG_MATRIX_MODE, VG_MATRIX_IMAGE_USER_TO_SURFACE);
  vgGetMatrix(@existingmatrix[1]);

  //move up onto screen so we can see it, and centre it.
  vgTranslate(0, 310);
  vgScale(1.0, -1.0);
  vgDrawImage(BootImage);

  vgLoadMatrix(@existingmatrix[1]);

  vgSeti(VG_MATRIX_MODE, VG_MATRIX_PATH_USER_TO_SURFACE);
end;
begin
   {Write boot image, this shows up for maybe .2 of a second before drive is ready}
   VGShapesSetLayer(0);
   VGShapesInit(Width,Height);
   BootImage := LoadBootScreen(480, 140);
   VGShapesStart(Width, Height);
   DisplayBootScreen(BootImage, Width, Height, 480, 140);
   VGShapesEnd;
  {Initiallize Display}
  HyperPixelInitialize(HYPERPIXEL_MODEL);
  FramebufferDevice:=FramebufferDeviceFindByDescription(HYPERPIXEL_FRAMEBUFFER);
  FramebufferDeviceGetProperties(FramebufferDevice,@FramebufferProperties);
  ScreenWidth:=FramebufferProperties.PhysicalWidth;
  ScreenHeight:=FramebufferProperties.PhysicalHeight;
  Sleep(100);
  {wait for drive to be ready}
  while not DirectoryExists('C:\') do
  begin
   {Sleep for a moment}
   Sleep(100);
  end;

  Direction :=  1;
  Angle := 90;
  VGShapesSetLayer(1);
  //write background on layer 1
  VGShapesInit(Width,Height,DISPMANX_FLAGS_ALPHA_FROM_SOURCE);
  VGShapesStart(Width, Height, false);
  // draw image JPEG only so far but others are easy to add
  VGShapesImage(0,0,Width,Height,'Ultibo.jpg');
  VGShapesEnd;

  VGShapesSetLayer(5);

  VGShapesInit(Width,Height,DISPMANX_FLAGS_ALPHA_FROM_SOURCE);

  while (true) do
  begin
    //logic of angle
    angle := angle + direction;
    if (Angle > 180) then
      Direction := -1
    else
    if (Angle < 0) then
      Direction := 1;
    sleep(10);
    VGShapesStart(Width, Height, true);
    //VGShapesStroke(0,255,0, 1);
    //VGShapesFill(0, 255, 0, 1);
    //vgshapestext(0, 0, 'Angle ' + inttostr(Angle), VGShapesSansTypeface, 25);


    vgSeti(VG_MATRIX_MODE, VG_MATRIX_PATH_USER_TO_SURFACE);
    vgGetMatrix(@existingmatrix1[1]);

    vgShapesTranslate(240,240);//basically move cursor to center of screen
    vgShapesRotate(Angle);//rotate entire matrix by angle
    VGShapesStroke(0,255,0, 1);
    VGShapesFill(0, 255, 0, 1);
    vgshapestext(0, 0, 'Angle ' + inttostr(Angle), VGShapesSansTypeface, 25);//write text
    VGShapesImage(0,235,480,10,'Ultibo1.jpg');//write image, although this does not rotate the image? i cant find why.

    VGShapesEnd;
    vgShapesRotate(-Angle);//reset angle since its teh absolute angle of the matrix
    vgLoadMatrix(@existingmatrix1[1]);
  end;



end.

