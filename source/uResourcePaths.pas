unit uResourcePaths;

{$WRITEABLECONST ON}

interface

Const
  cResourceMedia = 'resource\media\';
  cResourceFaces = 'resource\faces\';
  cResourceFaceDetect = 'resource\facedetectxml\';
  cResourceResultDefault = 'resource\result\';


type
  {$I ..\resource\facedetectxml\ocvHaarCascadeType.inc}
  {$I ..\resource\facedetectxml\haarcascade.inc}
  {.$R ..\resource\facedetectxml\haarcascade.rc}

function cResourceResult: AnsiString;

implementation

uses
  SysUtils;


function cResourceResult: AnsiString;
begin
  if DirectoryExists(cResourceResultDefault) then
    Result := cResourceResultDefault
  else
    Result := '';
end;

end.
