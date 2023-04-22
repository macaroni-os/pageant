unit uutils;

// ===============================================
// utils unit for pageant
// ===============================================
// classes
// TPropertyBeautifyer: parser used to beautify json content

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;


type

  { TPropertyBeautifyer }

  TPropertyBeautifyer = class(TObject)

  private
    FCurrIdent: integer;
    FCurrIdentPrefix: string;
    FIdent: integer;
    FOutputText: string;
    FIndex: integer;
    FText: string;
    procedure SetCurrIdent(AValue: integer);
  private
    function GetChar: char;
    function PreviewChar: char;
    function GetDraftUntil(const AValue: char): string;

    procedure AddChar(const AValue: char);
    procedure AddString(const AValue: string);

    property Index: integer read FIndex write FIndex;
    property Ident: integer read FIdent write FIdent;
    property CurrIdent: integer read FCurrIdent write SetCurrIdent;
  public
     constructor Create(const AValue: string);
     destructor Destroy; override;

     function Parse: string;

  public
     property Text: string read FText write FText;
     property OutputText: string read FOutputText write FOutputText;
  end;


implementation

const
   LEX_SPACE      = #32;
   LEX_NEST_GROUP = '?';
   LEX_NEST_BEGIN = '(';
   LEX_NEST_END   = ')';


{ TPropertyBeautifyer }

procedure TPropertyBeautifyer.SetCurrIdent(AValue: integer);
begin
  FCurrIdent:=AValue;

  if FCurrIdent = 0 then
     FCurrIdentPrefix:=''
  else
     FCurrIdentPrefix:=StringOfChar(' ', FCurrIdent * Ident);

end;

function TPropertyBeautifyer.GetChar: char;
begin
  inc(FIndex);
  result := FText[Index];
end;

function TPropertyBeautifyer.PreviewChar: char;
begin
  result :=#0;

  if FIndex < Length(FText) then
     result := FText[FIndex+1];
end;

function TPropertyBeautifyer.GetDraftUntil(const AValue: char): string;
var ch: char;
begin
   try
      ch:=#0;
      result :='';
      repeat
         ch:= GetChar;
         result += ch;
      until (ch = AValue);

      // get all spaces
      ch:=PreviewChar;
      while ch in [' '] do begin
         GetChar;
         ch:=PreviewChar;
      end;

   except
     on e: exception do begin
        result:='ERROR:' + LineEnding + e.Message;
     end;
   end;
end;

procedure TPropertyBeautifyer.AddChar(const AValue: char);
begin
  FOutputText+=AValue;
  if CurrIdent > 0 then
     if AValue = LineEnding then
        AddString(FCurrIdentPrefix);
end;

procedure TPropertyBeautifyer.AddString(const AValue: string);
begin
   FOutputText+=AValue;
end;

constructor TPropertyBeautifyer.Create(const AValue: string);
begin
   FText:=AValue;
   FIdent:=3;
end;

destructor TPropertyBeautifyer.Destroy;
begin
  inherited Destroy;
end;

function TPropertyBeautifyer.Parse: string;
var totchars: Integer;
    ch: Char;
begin
   // init
   result := '';
   FIndex:=0;
   FOutputText:='';
   totchars:=Length(FText);
   CurrIdent:=0;

   try

      try
         while FIndex < totchars do begin
            ch := GetChar;
            case ch of
               LEX_SPACE: AddChar(LineEnding);

               LEX_NEST_GROUP: begin
                  AddChar(ch);
                  AddString( GetDraftUntil(LEX_NEST_BEGIN) );
                  CurrIdent:=CurrIdent+1;
                  AddChar( LineEnding );
               end;

               LEX_NEST_END: begin
                  SetLength(FOutputText, Length(FOutputText)-(CurrIdent * Ident));
                  CurrIdent:=CurrIdent-1;
                  // if LeftStr(FOutputText, CurrIdent * Ident) = FCurrIdentPrefix then
                  //    FOutputText:=copy(FOutputText,1,Length(FOutputText)-(CurrIdent * Ident));
                  AddChar(ch);
               end;
            else
               AddChar(ch);
            end;

         end; // while
      except
        on e: exception do begin
           FOutputText:='ERROR:' + LineEnding + e.Message;
        end;
      end;

   finally
     result:=OutputText;
   end;

end;

end.

