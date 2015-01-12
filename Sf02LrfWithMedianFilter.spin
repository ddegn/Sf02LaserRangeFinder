CON
{{      
  A program to test the SF02 Laser Rangefinder.

  By Duane Degn
  January 6, 2015

  MIT License

  For more infomation about this object see the following thread in the Parallax forums.

  http://forums.parallax.com/showthread.php/159636

  The code used to compute the median value was written by Phil Pilgrim. He based the code on
  work done by C.A.R. Hoare. For more information about Phil's code see the following thread:

  http://forums.parallax.com/showthread.php/142430-QuickMedian-Algorithm-in-Spin
  
}}  
CON

  _clkmode = xtal1 + pll16x                           
  _xinfreq = 5_000_000

  SR02_RX_PIN = 11 
  SR02_TX_PIN = 10
  
  DEBUG_BAUD = 115_200
  SR02_BAUD = 9_600 

  INVALID_READING = -999

  SAMPLES_TO_FILTER = 8
   
VAR

  long rangeInCentimeters
  long samplesToFilter[SAMPLES_TO_FILTER]
  
OBJ

  Pst[2] : "Parallax Serial Terminal"

PUB Setup

  Pst[0].Start(DEBUG_BAUD)
  Pst[1].StartRxTx(SR02_RX_PIN, SR02_TX_PIN, 0, SR02_BAUD)

  repeat
    Pst.Str(string(11, 13, "Press any key to begin."))
    result := Pst.RxCount
    waitcnt(clkfreq / 2 + cnt)
  until result

  Pst.RxFlush
  Pst.Clear
  Pst.Home  
   
  MainLoop
  
PUB MainLoop | inputCharacter

  repeat
    'Pst.Clear  ' Uncomment these two lines to have each reading displayed at top of screen.
    'Pst[0].Home
    Pst.Str(string(11, 13, "LRF Median Demo", 11, 13, 11, 13)) 
    rangeInCentimeters := FilterLrf(@samplesToFilter, SAMPLES_TO_FILTER)
    if rangeInCentimeters == INVALID_READING
      Pst[0].Str(string(11, 13, "Not Valid", 11, 13))
    else
      Pst.Str(string(11, 13, "Filtered Reading = "))
      Pst[0].Dec(rangeInCentimeters)
      Pst[0].Str(string(" cm", 11, 13))

    Pst.Str(string(11, 13, "Array size: "))
    Pst.Dec(SAMPLES_TO_FILTER)
    Pst.Str(string("  Comparisions: "))
    Pst.Dec(comparisons)
    Pst.Str(string("  Swaps: "))
    Pst.Dec(swaps)
    Pst.Str(string(11, 13, "Press any key to continue.", 11, 13))
    result := Pst.CharIn
    Pst[0].ClearEnd
  
  
PUB FilterLrf(arrayPtr, sampleToFilter) | sampleIndex, finalIndex

  finalIndex := sampleToFilter - 1

  repeat sampleIndex from 0 to finalIndex
    long[arrayPtr][sampleIndex] := ReadLrf

  result := long_median(arrayPtr, sampleToFilter)
 
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
  
VAR

  long comparisons, swaps

PUB long_median(addr, n) | k, first, last, i, j

  first~
  last := n - 1
  k := n >> 1
  repeat while (first < last)
    i := long_split(addr, long[addr][k], first, last, n)
    j := i & $ffff
    i >>= 16
    if (i =< k)
      first := i
    if (j => k)
      last := j
    Pst.Chars("-", 12)
    Pst.ClearEnd
    Pst.NewLine     
    '.debug rep "-"\12, #CR
  show(first, last, addr, n)
  return long[addr][k]

PUB long_split (addr, pivot, first, last, n) | t

  repeat
    show(first, last, addr, n)
    repeat while long[addr][first] < pivot
      first++
      comparisons++
    repeat while long[addr][last] > pivot
      last--
      comparisons++
    comparisons += 2
    if (first < last)
      t := long[addr][first]
      long[addr][first] := long[addr][last]
      long[addr][last] := t
      swaps++
      first++
      last := last - 1 #> first
  while first < last
  return first << 16 | (last #> first) 

PUB show(first, last, addr, n) | i

  repeat i from 0 to n - 1
    Pst.Char(" ")
    if long[addr][i] < 100
      Pst.Char(" ")
    if long[addr][i] < 10
      Pst.Char(" ")
    Pst.Dec(long[addr][i])
 
  Pst.ClearEnd
  Pst.PositionX(first * 4)
  Pst.Char("|")
  Pst.PositionX(last * 4 + 4)
  Pst.Char("|")
  Pst.PositionX((n >> 1)* 4)
  Pst.Char("[")
  Pst.MoveRight(3)
  Pst.Char("]")
  Pst.NewLine

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