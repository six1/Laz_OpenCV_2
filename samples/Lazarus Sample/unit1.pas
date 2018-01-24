unit Unit1;

{.$I OpenCV.inc}
{$MODE Delphi}

interface


uses
  windows, Classes, SysUtils, FileUtil, Forms,
  Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, Spin
  , ocv.comp.Types
  , ocv.comp.ImageOperation
  , ocv.comp.Source
  , ocv.comp.Proc
  , ocv.highgui_c
  , ocv.core_c
  , ocv.core.types_c
  , ocv.imgproc_c
  , ocv.imgproc.types_c
  , ocv.objdetect_c
  , uResourcePaths, ocv.comp.View
  , intfgraphics
  ;

type TWebCamSource = record
     name:string;
     protocol:integer; // 0=ippHTTP, 1=ippHTTPS, 2=ippRTSP
     ip:string;
     port:integer;
     url:string;
     user:string;
     pass:string;
end;

type
  TClassifierCascade = record
    HaarClassifier:pCvHaarClassifierCascade;
    color:TCvScalar;
  end;

const
   MAX_COUNT = 500;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    CheckBox1: TCheckBox;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    ComboBox4: TComboBox;
    ComboBox5: TComboBox;
    Label1: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    ocvCameraSource1: TocvCameraSource;
    ocvFileSource1: TocvFileSource;
    ocvImageOperation1: TocvImageOperation;
    ocvIPCamSource1: TocvIPCamSource;
    ocvView1: TocvView;
    OpenDialog1: TOpenDialog;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Shape5: TShape;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox4Change(Sender: TObject);
    procedure ComboBox5Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ocvImageOperation1AfterEachOperation(PrevOperation, Operation,
      NextOperation: TObject; const IplImage: IocvImage;
      Var ContinueTransform: Boolean);
    procedure RadioButton1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    VideoSource:TObject;
    ClassifierCascade:array of TClassifierCascade;
    function detect_and_draw2(var image: IocvImage):IocvImage;
  public

  end;


var
  Form1: TForm1;


implementation

{$R *.lfm}

{ TForm1 }

const
   WebCamSource: array[0..12] of TWebCamSource =
     (                                     // Protocol: 0=ippHTTP, 1=ippHTTPS, 2=ippRTSP
      (name:'Local CAM';                      protocol:2; ip:'192.168.1.71';     port:80;   url:'ch0_0.264';       user:'';        pass:''  ),
      (name:'Serbia, Vojvodina, Novi Pazar';  protocol:0; ip:'93.87.72.254';     port:8090; url:'mjpg/video.mjpg'; user:'';        pass:''),
      (name:'Italy, Campania, Naples';        protocol:0; ip:'93.63.211.151';    port:80;   url:'mjpg/video.mjpg'; user:'';        pass:''),
      (name:'Lisboa Lours';                   protocol:0; ip:'95.94.100.34';     port:85;   url:'mjpg/video.mjpg'; user:'';        pass:''),
      (name:'Barber Shop England, Nottingham';protocol:0; ip:'81.149.36.95';     port:8082; url:'mjpg/video.mjpg'; user:'';        pass:''),
      (name:'Wisconsin, Milwaukee';           protocol:0; ip:'192.206.48.49';    port:80;   url:'mjpg/video.mjpg'; user:'';        pass:''),
      (name:'New Jersey, Hoboken';            protocol:0; ip:'108.30.103.113:83';port:80;   url:'mjpg/video.mjpg'; user:'';        pass:''),
      (name:'Miami, Naples';                  protocol:0; ip:'173.165.209.17';   port:80;   url:'mjpg/video.mjpg'; user:'';        pass:''),
      (name:'California, Rancho Cucamonga';   protocol:0; ip:'166.165.35.32';    port:80;   url:'mjpg/video.mjpg'; user:'';        pass:''),
      (name:'Moscow';                         protocol:0; ip:'195.189.181.205';  port:80;   url:'mjpg/video.mjpg'; user:'';        pass:''),
      (name:'Midtjylland, Tranbjerg Denmark'; protocol:0; ip:'62.242.189.219';   port:80;   url:'mjpg/video.mjpg'; user:'';        pass:''),
      (name:'Milano';                         protocol:0; ip:'92.223.183.218';   port:8082; url:'mjpg/video.mjpg'; user:'';        pass:''),
      (name:'Espirito Santo, Alegre Brasil';  protocol:0; ip:'138.118.33.201';   port:80;   url:'mjpg/video.mjpg'; user:'';        pass:'')
     );


procedure TForm1.ComboBox1Change(Sender: TObject);
begin
    // Load Classifier from File
//  ClassifierCascade[(Sender as TCombobox).Tag].HaarClassifier := cvLoad( PChar(extractfilepath(application.ExeName)+ cResourceFaceDetect + CascadeRecourse[ TocvHaarCascadeType((Sender as TCombobox).ItemIndex-1)].FileName ));

    // Load Classifier from res
    ClassifierCascade[(Sender as TCombobox).Tag].HaarClassifier := ocvLoadHaarCascade( TocvHaarCascadeType((Sender as TCombobox).ItemIndex-1));
end;

procedure TForm1.ComboBox4Change(Sender: TObject);
begin
  // maybe, it's better to cut VideoSource before?
  ocvImageOperation1.OperationClass := TocvImageOperationClass(ComboBox4.Items.Objects[ComboBox4.ItemIndex]);
end;

procedure TForm1.ComboBox5Change(Sender: TObject);
begin
  ocvIPCamSource1.Enabled:=false;
  application.ProcessMessages;
  ocvIPCamSource1.IP:=WebCamSource[ Combobox5.ItemIndex].ip;
  ocvIPCamSource1.Port:=WebCamSource[ Combobox5.ItemIndex].port;
  ocvIPCamSource1.URI:=WebCamSource[ Combobox5.ItemIndex].url;
  ocvIPCamSource1.Protocol:=TocvIPProtocol( WebCamSource[Combobox5.ItemIndex].protocol);
  ocvIPCamSource1.UserName:= WebCamSource[Combobox5.ItemIndex].user;
  ocvIPCamSource1.Password:= WebCamSource[Combobox5.ItemIndex].pass;
  if Checkbox1.Checked and Radiobutton2.Checked then begin
    Timer1.enabled:=true;
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  ocvCameraSource1.Enabled:=false;
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  ocvCameraSource1.Enabled:=Checkbox1.Checked and Radiobutton1.Checked;
  if Checkbox1.Checked and Radiobutton2.Checked then begin
    Timer1.Enabled:=true;
    VideoSource:=ocvIPCamSource1;
  end else
    ocvIPCamSource1.Enabled:=false;
  ocvFileSource1.Enabled:=Checkbox1.Checked and Radiobutton3.Checked;
  Button1.Enabled:=Checkbox1.Checked and Radiobutton3.Checked;
  if ocvCameraSource1.Enabled then
    VideoSource:=ocvCameraSource1
  else
  if ocvFileSource1.Enabled then
    VideoSource:=ocvFileSource1;
  ocvImageOperation1.VideoSource:=(VideoSource as TocvCaptureSource);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
    OpenDialog1.InitialDir:=extractfilepath( application.ExeName);
    ocvFileSource1.Enabled:=false;
    if OpenDialog1.Execute then begin
      ocvFileSource1.FileName:=OpenDialog1.FileName;
      ocvFileSource1.Enabled:=true;
    end;
end;


procedure TForm1.FormCreate(Sender: TObject);
var
  i:integer;
  flName:string;
begin
  ocvCameraSource1.Enabled:=false;

  // Create new Haar classifier array
  setlength(ClassifierCascade,3);

  // Load Cascades
  for i := 0 to Ord(High(TocvHaarCascadeType)) do begin
    flName:=CascadeRecourse[ TocvHaarCascadeType(i)].FileName;
    flname:=stringreplace(flname, 'haarcascade_','',[rfreplaceall]);
    flname:=stringreplace(flname, '.xml','',[rfreplaceall]);
    Combobox1.Items.add(flName);
  end;
  Combobox1.Items.Insert(0,'OFF');
  Combobox2.Items.Assign(Combobox1.Items);
  Combobox3.Items.Assign(Combobox1.Items);
  Combobox1.ItemIndex:=0;
  Combobox2.ItemIndex:=0;
  Combobox3.ItemIndex:=0;

  ClassifierCascade[0].HaarClassifier := cvLoad( PChar(extractfilepath(application.ExeName)+ cResourceFaceDetect + CascadeRecourse[ TocvHaarCascadeType(Combobox1.ItemIndex-1)].FileName ));
  ClassifierCascade[0].color:=CV_RGB(255,0,0);
  shape2.Brush.Color:=clred;
  ClassifierCascade[1].HaarClassifier := cvLoad( PChar(extractfilepath(application.ExeName)+ cResourceFaceDetect + CascadeRecourse[ TocvHaarCascadeType(Combobox2.ItemIndex-1)].FileName ));
  ClassifierCascade[1].color:=CV_RGB(0,255,0);
  shape3.Brush.Color:=cllime;
  ClassifierCascade[2].HaarClassifier := cvLoad( PChar(extractfilepath(application.ExeName)+ cResourceFaceDetect + CascadeRecourse[ TocvHaarCascadeType(Combobox3.ItemIndex-1)].FileName ));
  ClassifierCascade[2].color:=CV_RGB(255,255,0);
  shape4.Brush.Color:=clyellow;

  // Image Operations
  Combobox4.Items.Assign(GetRegisteredImageOperations);
  Combobox4.ItemIndex:=0;

  ocvImageOperation1.VideoSource:=ocvIPCamSource1;
  ocvImageOperation1.Enabled:=true;

 // Load WEB CAM Connection Parameters
 Combobox5.Items.Clear;
 for i := 0 to High(WebCamSource) do begin
   Combobox5.items.add(WebCamSource[i].name);
 end;
 Combobox5.ItemIndex:=0;

 // Load first Parameters
 ocvIPCamSource1.IP:=WebCamSource[ Combobox5.ItemIndex].ip;
 ocvIPCamSource1.Port:=WebCamSource[ Combobox5.ItemIndex].port;
 ocvIPCamSource1.URI:=WebCamSource[ Combobox5.ItemIndex].url;
 ocvIPCamSource1.Protocol:=TocvIPProtocol( WebCamSource[Combobox5.ItemIndex].protocol);

 ocvView1.VideoSource:=ocvImageOperation1;
end;


function TForm1.detect_and_draw2(var image: IocvImage):IocvImage;
var
  i,cc:integer;
  HaarRects:TocvRects;
begin
  for cc:=0 to high(ClassifierCascade) do begin
    if ClassifierCascade[cc].HaarClassifier <> nil then begin
      if ocvHaarCascadeTransform(image,
                               ClassifierCascade[cc].HaarClassifier ,
                               HaarRects,
                               cvSize(40, 40),
                               cvSize(0, 0),
                               false,
                               1.3,
                               2,
                               TocvHaarCascadeFlagSet([HAAR_SCALE_IMAGE, HAAR_DO_CANNY_PRUNING])
                               ) then
      begin
        for i := 0 to High(HaarRects) do
          cvRectangle(image.GetIplImage,
                      cvPoint(HaarRects[i].Left, HaarRects[i].Top),
                      cvPoint(HaarRects[i].Right, HaarRects[i].Bottom),
                      ClassifierCascade[cc].color,
                      2, 8, 0);
      end;
    end;
  end;
  result:=image;
end;


procedure TForm1.ocvImageOperation1AfterEachOperation(PrevOperation, Operation,
  NextOperation: TObject; const IplImage: IocvImage;
  Var ContinueTransform: Boolean);
var
  cp_IplImage:IocvImage;
begin
  // image manipulations
  cp_IplImage:= IplImage.Clone;
  ocvView1.DrawImage( detect_and_draw2( cp_IplImage));

  // without ocvView you can output the bitmap to an Image:
  // Image1.Picture.bitmap.assign(  detect_and_draw2( cp_IplImage).AsBitmap );

  Label1.visible:=false;
end;


procedure TForm1.RadioButton1Click(Sender: TObject);
begin
  CheckBox1Click(Self);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Timer1.enabled:=false;
  Label1.visible:=true;
  application.ProcessMessages;
  ocvIPCamSource1.Enabled:=true;
end;


end.

