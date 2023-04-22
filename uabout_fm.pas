unit uabout_fm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons;

type

  { TfmAbout }

  TfmAbout = class(TForm)
    BitBtn1: TBitBtn;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private

  public

  end;


implementation

{$R *.lfm}

{ TfmAbout }

procedure TfmAbout.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction:=caFree;
end;

end.

