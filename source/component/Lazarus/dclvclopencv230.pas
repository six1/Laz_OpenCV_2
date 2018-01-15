{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit dclVCLOpenCV230;

{$warn 5023 off : no warning about unused units}
interface

uses
  ocv.comp.RegisterVCL, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('ocv.comp.RegisterVCL', @ocv.comp.RegisterVCL.Register);
end;

initialization
  RegisterPackage('dclVCLOpenCV230', @Register);
end.
