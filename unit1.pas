unit Unit1; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Menus;

type

  { TForm1 }

  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    Memo: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    OpenDialog: TOpenDialog;
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form1: TForm1; 

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.MenuItem1Click(Sender: TObject);
begin
     Application.Terminate;
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
{
 Dlaczego liczby moga byc dowolnie dlugie? To bardzo proste!
 My w ogole nie traktujemy je jako liczby, tylko jako ciagi znakow.
 A ze String w Lazarusie moze byc niemalze dowolnie dlugi, mozemy miec dlugie ciagi
}

          function czy_palindrom(s: string): boolean;
          var
            i: Integer;
          begin
               // porownuje jednoczesnie znak ostatni i pierwszy
               // jak sie zgadza, bierze drugi od konca i drugi od poczatku i je sprawdza
               // i tak do konca stringa

               // string zaczyna sie od 1 i konczy na Length(s) !
               // nie zaczyna sie od zera!
               result := False;
               for i := 1 to Length(s) do
                  if s[i] <> s[Length(s)+1-i] then Exit;  // nie zgadzaja sie, a powinny
               result := True; // wszystko sie zgadza
          end;

var
   plik: system.Text;
   liczby: array of String = nil;       // liczby przeczytane w biezacej linijce
   temps: String = '';                  // bufor na aktualnie wczytywana liczbe
   linia: String;                       // aktualnie robiona linia
   tempc: Char;                         // tymczasowy char do czytania liczb
   tempi, tempk: Integer;                      // tymczasowe integery
   posortowane: boolean;                    // do kontroli sortowania babelkowego

   ts: String;                        // tymczasowy string do sortowania babelkowego

   palindromy: array of String = nil;   // palindromy znalezione w danej linijce

   nr_linii: Integer = 1;
begin

  if not OpenDialog.Execute then Exit;  // jesli user anulowal otwieranie, koniec

         // Otworz plik
  AssignFile(plik, OpenDialog.FileName);
  Reset(plik);

  while not Eof(plik) do                // dopoki jest cos w pliku do przeczytania...
  begin

      // ----------------------- PRZYGOTUJ TABELE Z LICZBAMI W TEJ LINIJCE

      Readln(plik, linia);                      // wczytaj linie
      for tempi := 1 to Length(linia) do           // dla kazdego znaku z linii...
      begin
          if linia[tempi] = ' ' then  // jesli to spacja...
          begin
            if temps = '' then  // nic do tej pory nie ma, nie interesuje nas spacja
              continue;
            // cos jest w buforze, dopisz to do listy
            tempk := Length(liczby);
            SetLength(liczby, tempk+1);
            liczby[tempk] := temps;
            temps := '';  // i wyczysc bufor
          end;

          if (linia[tempi] = '0') and (temps = '') then   // zero i bufor pusty
             continue;     // zero nie moze byc przeciez pierwsza cyfra

          if linia[tempi] in ['0'..'9'] then    // liczby!
             temps := temps + linia[tempi];
      end;

      // Ok, wyszlismy z petli ale linia wcale nie musiala sie konczyc spacja! Cos moze byc w buforze i musimy to dopisac!
      if temps <> '' then
      begin       // cos jednak bylo w buforze, dopiszmy to
        tempk := Length(liczby);
        SetLength(liczby, tempk+1);
        liczby[tempk] := temps;
        temps := '';  // i wyczysc bufor
      end;

      // ----------------------------- SPORZADZ LISTE PALINDROMOW W TEJ LINIJCE

      // Mamy przetworzyc te liczby ktore mamy w tablicy
      for tempi := 0 to Length(liczby)-1 do    // kazdej liczbie sprawdz...
           if czy_palindrom(liczby[tempi]) then
           begin                           // jesli to palindrom to zapisz do tablicy
             tempk := Length(palindromy);
             SetLength(palindromy, tempk+1);
             palindromy[tempk] := liczby[tempi];
           end;

      // ------------------------------ POSORTUJ ROSNACO WG DLUGOSCI
      // Do tego celu zastosojemy sortowanie bąbelkowe

      if Length(palindromy) > 1 then         // jesli jest co sortowac
      repeat
         posortowane := True;     // optymistycznie zakladamy ze posortowane
         for tempi := 1 to Length(palindromy)-1 do
         begin
             if Length(palindromy[tempi-1]) > Length(palindromy[tempi]) then        // jesli trzeba zamienic dwa obok siebie
             begin                      // to zrob to
               ts := palindromy[tempi-1];
               palindromy[tempi-1] := palindromy[tempi];
               palindromy[tempi] := ts;
               // niestety, lista nie okazala sie posortowana
               posortowane := False;
             end;
         end;
      until posortowane;


      // --------------------------------- WYPISZ PALINDROMY
      Memo.Lines.Append('Linijka nr '+IntToStr(nr_linii));

      if Length(palindromy) = 0 then                      // brak palindromow!
         Memo.Lines.Append('<BRAK PALINDROMOW>')
      else                        // sa palindromy, wypisz
          for tempi := 0 to Length(palindromy)-1 do
               Memo.Lines.Append(palindromy[tempi]);

      // wypisana, wyczysc teraz nasze tablice i jedziemy dalej
      SetLength(palindromy, 0);
      SetLength(liczby, 0);
      nr_linii := nr_linii + 1;
  end;

  CloseFile(plik);

end;

procedure TForm1.MenuItem3Click(Sender: TObject);
begin
     ShowMessage('Program wczytuje z pliku listę liczb naturalnych#13#10'+
                 'Po czym sprawdza czy są palindromami i wypisuje do pola Memo13#10'+
                 'I tak sobie to dziala');

end;

end.

