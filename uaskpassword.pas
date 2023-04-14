unit uAskPassword;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons;

type

  { TfmSudoPassword }

  TfmSudoPassword = class(TForm)
    Button1: TButton;
    Button2: TButton;
    cbRemember: TCheckBox;
    edPass: TEdit;
    StaticText1: TStaticText;
  private

  public

  end;


implementation

{$R *.lfm}

end.

