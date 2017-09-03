' Program do testow nadajnika ATS100 rev.2.4
' PLL - MB15E03SL
' Mikrokontroler 89C51
' REF: 12.8 MHz , krok PLL: 12.5kHz , czestotliwosc nadajnika: 144.800 MHz
' http://sq5eku.blogspot.com
'
$regfile = "REG51.dat"
$crystal = 11059000                                           ' zegar 11.059 MHz

Dim Tmp As Byte                                               ' zmienna odcinania nadawania po jednej rundzie
Dim C As Byte
Dim A As Byte

In8 Alias P0.0                                                ' pin 37  Wejscie IN8 , pullup , wyzwolenie przez podanie L
In7 Alias P0.1                                                ' pin 36  Wejscie IN7 , pullup , wyzwolenie przez podanie L
In6 Alias P0.2                                                ' pin 35  Wejscie IN6 , pullup , wyzwolenie przez podanie L
In5 Alias P0.3                                                ' pin 34  Wejscie IN5 , pullup , wyzwolenie przez podanie L
In4 Alias P0.4                                                ' pin 33  Wejscie IN4 , pullup , wyzwolenie przez podanie L
In3 Alias P0.5                                                ' pin 32  Wejscie IN3 , pullup , wyzwolenie przez podanie L
In2 Alias P0.6                                                ' pin 31  Wejscie IN2 , pullup , wyzwolenie przez podanie L
In1 Alias P0.7                                                ' pin 30  Wejscie IN1 , pullup , wyzwolenie przez podanie L

Err2 Alias P1.0                                               ' pin 40  Wy. ERROR U7 , H=napiecie na wyjsciu OK L=brak napiecia na wyjsciu
Err1 Alias P1.3                                               ' pin 43  Wy. ERROR U5 , H=napiecie na wyjsciu OK L=brak napiecia na wyjsciu
Ptt1 Alias P1.4                                               ' pin 44  Przycisk S1 ptt , L=zalaczone PTT
Led2 Alias P1.5                                               ' pin 1   LED LockDetect H=zgaszona , L=swieci
Azw Alias P1.7                                                ' pin 3   Antyzwiecha

Vco Alias P2.2                                                ' pin 20  Zasilanie MB15E03SL i VCO , H=wylaczone L=zalaczone
Led1 Alias P2.3                                               ' pin 21  +8V wzm. w.cz. + LED TX , H=zgaszona , L=swieci

Ps Alias P3.2                                                 ' pin 8   Standby MB15E03 pin12 , H=standby L=PLL ON
Pa Alias P3.3                                                 ' pin 9   zasilanie PA H=wylaczone L=zalaczone
Le Alias P3.4                                                 ' pin 10  MB15E03 pin 11 (LE)
Data Alias P3.5                                               ' pin 11  MB15E03 pin 10 (DATA)
Clk Alias P3.6                                                ' pin 12  MB15E03 pin 9 (CLOCK)
Ld Alias P3.7                                                 ' pin 13  Lock Detect MB15E03SL pin14 , H=brak synchro L=synchro OK

Declare Sub Mb_r
Declare Sub Mb_na
Declare Sub Zegarek1
Declare Sub Zegarek2
Declare Sub Le_pulse

P0 = &B11111111
Ld = 1
Ps = 1
Led1 = 1
Led2 = 1
Vco = 1
Pa = 1
Ptt1 = 1
Err1 = 1
Tmp = 1
Azw = 1

Set Clk
Set Data
Set Le

'-------------------------------------------------------------  glowna petla
Do
Azw = 0
If Tmp = 0 Then
 If Ptt1 = 0 Then                                             ' jesli PTT wlaczone idz dalej
  Vco = 0
  Ps = 0
  Led1 = 0
  Waitms 10                                                   ' czekaj 10 ms az zalapie VCO
  Gosub Mb_r
  Delay
  Gosub Mb_na
  Waitms 50                                                   ' odczekaj 50ms na synchro PLL
   Pa = 0
   Tmp = 1
 End If
End If
If Tmp = 1 Then
 If Ptt1 = 1 Then
  Vco = 1
  Ps = 1
  Led1 = 1                                                    ' wylacz LED PTT
  Pa = 1
  Tmp = 0
 End If
End If

Azw = 1
Loop
End

'-------------------------------------------------------------  koniec glownej petli

Mb_r:
 Restore Dat
 For A = 1 To 19
 Read C
  If C = 1 Then
   Gosub Zegarek1
  Else
   Gosub Zegarek2
  End If
 Next A
 Gosub Le_pulse
Return

Mb_na:
 Restore Dat1
 For A = 1 To 19
 Read C
  If C = 1 Then
   Gosub Zegarek1
  Else
   Gosub Zegarek2
  End If
 Next A
 Gosub Le_pulse
Return

Zegarek1:
 Reset Data
 nop
 Reset Clk
 nop
 Set Clk
 nop
 Set Data
Return

Zegarek2:
 Reset Clk
 nop
 Set Clk
 nop
Return

Le_pulse:
 nop
 Reset Le
 nop
 Set Le
 nop
 Set Data
Return


Dat:
'
' 1 bit CS , 1 bit LDS , 1 bit FC , 1 bit SW , 14 bitowy dzielnik R = 2048 , 1 bitowy adres = 1:
'    |CS/LDS/FC/SW|  |------------------------R---------------------------| |adr|
'Data 1 , 0 , 1 , 1 , 0 , 0 , 1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 1       ' Zamieniamy miejscami SW / R / adr , 6.25kHz
Data 1 , 0 , 1 , 1 , 0 , 0 , 0 , 1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 1       ' Zamieniamy miejscami SW / R / adr , 12.5kHz
'
'
Dat1:
'
' 11 bitowy dzielnik N = 362 , 7 bitowy dzielnik A = 0 , 1 bitowy adres = 0
'    |--------------------N------------------|   |-----------A-----------|  |adr|
'Data 0 , 0 , 1 , 0 , 1 , 1 , 0 , 1 , 0 , 1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0       ' Zamieniamy miejscami N / A / adr (dla 6.25kHz)
Data 0 , 0 , 0 , 1 , 0 , 1 , 1 , 0 , 1 , 0 , 1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0       ' Zamieniamy miejscami N / A / adr (dla 12.5kHz)