program TTY5;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, Crt , laz_synapse, CustApp , Synaser
  { you can add units after this };

type

  { TMyApplication }

  TMyApplication = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
     constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
   end;

    const

  Version : string = '3.6';  // ALT-C change COM Port

{ TMyApplication }


  const

    Ascii : array [0..255] of string [5] =
    ('<NUL>','<SOH>','<STX>','<ETX>','<EOT>','<ENQ>','<ACK>','<BEL>',
     '<BS>','<HT>','<LF>','<VT>','<FF>','<CR>','<SO>','<SI>',
     '<DLE>','<DC1>','<DC2>','<DC3>','<DC4>','<NAK>','<SYN>','<ETB>',
     '<CAN>','<EM>','<SUB>','<ESC>','<FS>','<GS>','<RS>','<US>',
     ' ','!','"','#','$','%','&','''','(',')','*','+',',','-','.','/',
     '0','1','2','3','4','5','6','7','8','9',':',';','<','=','>','?',
     '@','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O',
     'P','Q','R','S','T','U','V','W','X','Y','Z','[','\',']','^','_',
     '`','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o',
     'p','q','r','s','t','u','v','w','x','y','z','{','|','}','~','<DEL>',
     '<128>','<129>','<130>','<131>','<132>','<133>','<134>','<135>',
     '<136>','<137>','<138>','<139>','<140>','<141>','<142>','<143>',
     '<144>','<145>','<146>','<147>','<148>','<149>','<150>','<151>',
     '<152>','<153>','<154>','<155>','<156>','<157>','<158>','<159>',
     '<160>','<161>','<162>','<163>','<164>','<165>','<166>','<167>',
     '<168>','<169>','<170>','<171>','<172>','<173>','<174>','<175>',
     '<176>','<177>','<178>','<179>','<180>','<181>','<182>','<183>',
     '<184>','<185>','<186>','<187>','<188>','<189>','<190>','<191>',
     '<192>','<193>','<194>','<195>','<196>','<197>','<198>','<199>',
     '<200>','<201>','<202>','<203>','<204>','<205>','<206>','<207>',
     '<208>','<209>','<210>','<211>','<212>','<213>','<214>','<215>',
     '<216>','<217>','<218>','<219>','<220>','<221>','<222>','<223>',
     '<224>','<225>','<226>','<227>','<228>','<229>','<230>','<231>',
     '<232>','<233>','<234>','<235>','<236>','<237>','<238>','<239>',
     '<240>','<241>','<242>','<243>','<244>','<245>','<246>','<247>',
     '<248>','<249>','<250>','<251>','<252>','<253>','<254>','<255>');

     var
       DoDebug : boolean ;
       l : boolean ;
       ttyPort : string[5];
       ttyBaud : integer ;
       ttylength : integer ;
       ttyparity : char ;
       ttystop : integer ;

{ ---------------------------------------------------------------------------
  TtyGetPars

  Procedure to handle alt-key combinations that are used to change the
  settings of the terminal emulation protocol.
  --------------------------------------------------------------------------- }

  procedure TtyGetPars (AltKey : char);

  var

    ParsInput : string[16];

  begin


    case AltKey of

      #23:                                                   { alt-I }
      begin
        if WhereX > 1 then Writeln;
        writeln;
        Write ('TTY:  port = ',ttyPort, ':  ');
        case TtyBaud of
          110: Write ('baudrate = 110        ');
          150: Write ('baudrate = 150        ');
          300: Write ('baudrate = 300        ');
          600: Write ('baudrate = 600        ');
          1200: Write ('baudrate = 1200       ');
          2400: Write ('baudrate = 2400       ');
          4800: Write ('baudrate = 4800       ');
          9600: Write ('baudrate = 9600       ');
          19200: Write ('baudrate = 19200      ');
          38400: Write ('baudrate = 38400      ');
          57600: Write ('baudrate = 57600      ');
          115200: Write ('baudrate = 115200     ');
        end;
        case TtyParity of
          'N': Writeln ('parity bit = none');
          'O': Writeln ('parity bit = odd');
          'E': Writeln ('parity bit = even');
          'M': Writeln ('parity bit = mark');
          'S': Writeln ('parity bit = space');
        end;
        Write ('V', Version);
        Write ('  flow = no     ');
        Write ('word length = ', intToStr(TtyLength), '       ');
        Writeln ('stop bits = ', ord(TtyStop)+1);
        writeln;
      end;

      #35:                                                   { alt-H }
      begin
        if WhereX > 1 then Writeln;
        Writeln  ('TTY:  ', ttyPort,'   Version ',Version);
        Write    ('   alt-B - Baudrate                      alt-I - info');
        Writeln;
        Write    ('   alt-C - COM-Port');
        Writeln;
        Write    ('   alt-H - help');
        Writeln;
        Writeln  ('   alt-D - debug');
        Write    ('   alt-X - exit');
        Writeln;
      end;

      #32:                                                  { alt-D }
      begin
        DoDebug := not DoDebug;
        if WhereX > 1 then Writeln;
        if DoDebug then
          Writeln ('TTY:  debug = on')
        else
          Writeln ('TTY:  debug = off');
      end;

      #45:                                                  { alt-X }
      begin
        if WhereX > 1 then Writeln;
        Writeln ('TTY:  exit');
        l := false;
      end;

      #46:                                                  { alt-C }
      begin
        if WhereX > 1 then Writeln;
        Writeln ('actual COM-Port: ',ttyport,':');
        Write ('COM-Port: Nr = ');
        Readln (ParsInput);
        ttyport := 'COM' + ParsInput;
        Writeln ('New COM-Port: ',ttyport,':');
      end;

      #48:                                                  { alt-B }
      begin
        if WhereX > 1 then Writeln;
        Write ('TTY:  baudrate = ');
        Readln (ParsInput);
        if (ParsInput = '3') or (ParsInput = '300') then TtyBaud := 300
        else if (ParsInput = '6') or (ParsInput = '600') then TtyBaud := 600
        else if (ParsInput = '12') or (ParsInput = '1200') then TtyBaud := 1200
        else if (ParsInput = '24') or (ParsInput = '2400') then TtyBaud := 2400
        else if (ParsInput = '48') or (ParsInput = '4800') then TtyBaud := 4800
        else if (ParsInput = '96') or (ParsInput = '9600') then TtyBaud := 9600
        else if (ParsInput = '192') or (ParsInput = '19200') then TtyBaud := 19200
        else if (ParsInput = '384') or (ParsInput = '38400') then TtyBaud := 38400
        else
          Writeln ('      baudrate = 300,600,1200,2400,4800,9600,19200,38400');
        writeln ('Baudrate: ',ttyBaud);
      end;

    end;  { case ChKey }
  end;  { procedure TtyGetPars }

procedure TMyApplication.DoRun;
var
  ErrorMsg: String;

  ser: TBlockSerial;
  ChCom, ChKey : char;

begin
     Writeln('  ELEKTERMINAL Emulator  Version '+ Version);

  ser:=TBlockSerial.Create;

  // quick check parameters
  ErrorMsg:=CheckOptions('h', 'help');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('h', 'help') then begin
    WriteHelp;
    Terminate;
    Exit;
  end;

  { add your program here }

    l:= true;
    DoDebug := false;
    TtyPort := 'COM3';
    ttyBaud := 38400;
    ttylength := 8 ;
    ttyparity := 'N' ;
    ttystop := SB1 ;

    Writeln;
    TtyGetPars (#35); 				{ display help }

    ser.Connect(ttyPort);                       //ComPort
    Sleep(100);
    ser.config(ttyBaud, 8, 'N', SB1, False, False);
    writeln;
    Write('Device: ' + ser.Device + '   Status: ' + ser.LastErrorDesc); // +' '+

    writeln;
    TtyGetPars (#23); 				{ display status }

     ser.purge;

    repeat

    if ser.CanReadEx(0) then
      begin
        ChCom := CHR(ser.recvByte (0));

         if not DoDebug then			{ terminal mode }

          case ChCOM of
          ' '..'~':                             { all printable characters }
          begin
            write (ChCom);
          end ;

          #13:			                { <CR> }
            begin
               ClrEol ;
               GotoXY (1, WhereY)  ;
            end  ;
          #12:			                { <FF> }
            begin
              ClrScr  ;
              GotoXY (1, 1) ;
            end ;
          #10:	                                { <LF> }
            begin
              if (WhereY <= 16) then
                 GotoXY (WhereX, WhereY + 1)
              else
                 Writeln;
            end ;
          #26:                                  { <SUB> }
            begin
              gotoxy (1, WhereY) ;
              clreol;
            end;
          #28:	                                { <FS> }
            Begin
            GotoXY (1,1) ;
            end ;
          #11:	                                { <VT> }
             begin
             if (WhereY > 1) then
               GotoXY (WhereX, WhereY - 1) ;
             end ;
          #29:                                  { <GS> }
            begin
              gotoxy (1, WhereY) ;
            end;
          #08:
            begin				{ <BS> }
  	      if (WhereX > 1) then
                GotoXY (WhereX - 1, WhereY)
              else if (WhereY > 1) then
              GotoXY ( 64, WhereY - 1) ;
              end  ;
          #09:		                        { <HT> (tab) }
            begin
  	      if (WhereX < 64) then
                Gotoxy ( WhereX+1, WhereY)
            else
              GotoXY (1 , WhereY + 1) ;
            end ;
          end
        else { debug mode }
          write (ASCII[ord(ChCom)]) ;
     end;

        if KeyPressed then
        begin
          ChKey := ReadKey;

          case ChKey of
               #1..#7,#9..#12,#14..#30, #32..#127:     // printable chrs & ctrl-codes
               begin
                    ser.sendByte (byte(ChKey))  ;
               end ;
               #13:  ser.sendbyte ($0D) ;              // CR&LF
               #08:
                    Begin
                           ser.purge;
                           ser.Sendbyte($7F);
                    end;
               #0:                                     // ALT-x
               begin
                    ChKey := ReadKey;
                    case ChKey of
                    'K':   ser.sendByte ($08)  ;
                    'H':   ser.sendByte ($0B)  ;
                    'M':   ser.sendByte ($09)  ;
                    'P':   ser.sendByte ($0A)  ;
                    'Q':   ser.sendByte ($01)  ;
                    'I':   ser.sendByte ($12)  ;
                    'R':   ser.sendByte ($16)  ;
                    'S':   ser.sendByte ($07)  ;
                    'G':   ser.sendByte ($1C)  ;
                    #14:
                    Begin
                           ser.purge;
                           ser.Sendbyte($7F);
                    end;
                    #23,#32,#35,#45:   TtyGetPars (ChKey);
                    #46, #48:
                    Begin
                      TtyGetPars (ChKey);
                      ser.closeSocket;
                      sleep(100);
                      ser.Connect(ttyPort);           // set new ComPort
                      Sleep(100);
                      ser.config(ttyBaud, 8, 'N', SB1, False, False);
                      writeln;
                      Write('Device: ' + ser.Device + '   Status: ' + ser.LastErrorDesc);

                      writeln;
                    end;

                    end;
               end ;
          end;
        end   ;

    until l=False;

    ser.free;
    Sleep(100);

    Writeln('Program beendet! ');

    sleep(2000);

  // stop program loop
  Terminate;
end;

constructor TMyApplication.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor TMyApplication.Destroy;
begin
  inherited Destroy;
end;

procedure TMyApplication.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ', ExeName, ' -h');
end;

var
  Application: TMyApplication;

{$R *.res}

begin
  Application:=TMyApplication.Create(nil);
  Application.Title:='TTY9600';
  Application.Run;
  Application.Free;
end.

