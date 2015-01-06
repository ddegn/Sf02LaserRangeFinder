CON
{{      
  A program to test the SF02 Laser Rangefinder.

  By Duane Degn
  January 6, 2015

  MIT License

  For more infomation about this object see the following thread in the Parallax forums.

  http://forums.parallax.com/showthread.php/159636
  
}}  
CON

  _clkmode = xtal1 + pll16x                           
  _xinfreq = 5_000_000

  SR02_RX_PIN = 11 
  SR02_TX_PIN = 10
  
  DEBUG_BAUD = 115_200
  SR02_BAUD = 9_600 

  INVALID_READING = -999
  
VAR

  long rangeInCentimeters
  
OBJ

  Pst[2] : "Parallax Serial Terminal"

PUB Setup

  Pst[0].Start(DEBUG_BAUD)
  Pst[1].StartRxTx(SR02_RX_PIN, SR02_TX_PIN, 0, SR02_BAUD)

  MainLoop
  
PUB MainLoop | inputCharacter

  repeat  
    rangeInCentimeters := ReadLrf
    Pst[0].Home
    if rangeInCentimeters == INVALID_READING
      Pst[0].Str(string("Not Valid", 11, 13))
    else
      Pst[0].Dec(rangeInCentimeters)
      Pst[0].Str(string(" cm", 11, 13))
    Pst[0].ClearEnd
    Pst[0].ClearBelow
  
PUB ReadLrf | validFlag, inputCharacter

  Pst[1].Char("D")
  validFlag := 0  
  repeat
    inputCharacter := Pst[1].CharIn
    case inputCharacter
      "0".."9":
        result := (result * 10) + (inputCharacter - "0")
        validFlag := 1
  while inputCharacter <> 13
      
  if validFlag == 0
    result := INVALID_READING
      
DAT {{Terms of Use: MIT License

  Permission is hereby granted, free of charge, to any person obtaining a copy of this
  software and associated documentation files (the "Software"), to deal in the Software
  without restriction, including without limitation the rights to use, copy, modify,
  merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to miso so, subject to the following
  conditions:

  The above copyright notice and this permission notice shall be included in all copies
  or substantial portions of the Software.

  The software is provided "as is", without warranty of any kind, express or implied,
  including but not limited to the warranties of mechantability, fitness for a
  particular purpose and non-infringement. In no even shall the authors or copyright
  holders be liable for any claim, damages or other liability, whether in an action of
  contract, tort or otherwise, arising from, out of or in connection with the software
  or the use of other dealing in the software.
  
}}   