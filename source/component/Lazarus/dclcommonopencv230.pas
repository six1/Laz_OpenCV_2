{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit dclCommonOpenCV230;

{$warn 5023 off : no warning about unused units}
interface

uses
  ocv.comp.Register, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('ocv.comp.Register', @ocv.comp.Register.Register);
end;

initialization
  RegisterPackage('dclCommonOpenCV230', @Register);
end.
