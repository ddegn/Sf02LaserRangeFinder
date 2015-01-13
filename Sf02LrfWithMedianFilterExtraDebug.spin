CON
{{      
  A program to test the SF02 Laser Rangefinder.

  By Duane Degn
  January 12, 2015

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

  SAMPLES_TO_FILTER = 9
   
VAR

  long rangeInCentimeters
  long samplesToFilter[SAMPLES_TO_FILTER]
  
OBJ

  Pst[2] : "Parallax Serial Terminal"

PUB Setup

  Pst[0].Start(DEBUG_BAUD)
  Pst[1].StartRxTx(SR02_RX_PIN, SR02_TX_PIN, 0, SR02_BAUD)

  repeat
    Pst[0].Str(string(11, 13, "Press any key to begin."))
    result := Pst[0].RxCount
    waitcnt(clkfreq / 2 + cnt)
  until result

  Pst[0].RxFlush
  Pst[0].Clear
  Pst[0].Home  
   
  MainLoop
  
PUB MainLoop | inputCharacter

  repeat
    'Pst[0].Clear  ' Uncomment these two lines to have each reading displayed at top of screen.
    'Pst[0].Home
    Pst[0].Str(string(11, 13, "LRF Median Demo", 11, 13, 11, 13)) 
    rangeInCentimeters := FilterLrf(@samplesToFilter, SAMPLES_TO_FILTER)
    if rangeInCentimeters == INVALID_READING
      Pst[0].Str(string(11, 13, "Not Valid", 11, 13))
    else
      Pst[0].Str(string(11, 13, "Filtered Reading = "))
      Pst[0].Dec(rangeInCentimeters)
      Pst[0].Str(string(" cm", 11, 13))

    Pst[0].Str(string(11, 13, "Array size: "))
    Pst[0].Dec(SAMPLES_TO_FILTER)

    Pst[0].Str(string(11, 13, "Samples filtered = "))
    DisplayArray(@samplesToFilter, SAMPLES_TO_FILTER)
    Pst[0].Str(string(11, 13, "Press any key to continue.", 11, 13))
    result := Pst[0].CharIn
    Pst[0].ClearEnd
  
  
PUB FilterLrf(arrayAddress, sampleToFilter) | sampleIndex, finalIndex

  finalIndex := sampleToFilter - 1

  repeat sampleIndex from 0 to finalIndex
    long[arrayAddress][sampleIndex] := ReadLrf

  result := LongMedian(arrayAddress, sampleToFilter)
 
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

PUB LongMedian(arrayAddress, elements) | halfTheElements, toCompareIndex, {
} compareAgainstIndex, elementsLarger, elementsSmaller, maxIndex 

  maxIndex := elements - 1
  halfTheElements := elements / 2
  repeat toCompareIndex from 0 to maxIndex
    elementsLarger := 0
    elementsSmaller := 0   
    repeat compareAgainstIndex from 0 to maxIndex
      if long[arrayAddress][toCompareIndex] > long[arrayAddress][compareAgainstIndex]
        elementsSmaller++
        Pst[0].Str(string(11, 13, "samplesToFilter["))
        Pst[0].Dec(toCompareIndex)
        Pst[0].Str(string("]("))
        Pst[0].Dec(long[arrayAddress][toCompareIndex])
        Pst[0].Str(string(") > samplesToFilter["))
        Pst[0].Dec(compareAgainstIndex)
        Pst[0].Str(string("]("))
        Pst[0].Dec(long[arrayAddress][compareAgainstIndex])
        Pst[0].Str(string("), elementsSmaller = "))
        Pst[0].Dec(elementsSmaller)        
      elseif long[arrayAddress][toCompareIndex] < long[arrayAddress][compareAgainstIndex]
        elementsLarger++
        Pst[0].Str(string(11, 13, "samplesToFilter["))
        Pst[0].Dec(toCompareIndex)
        Pst[0].Str(string("]("))
        Pst[0].Dec(long[arrayAddress][toCompareIndex])
        Pst[0].Str(string(") < samplesToFilter["))
        Pst[0].Dec(compareAgainstIndex)
        Pst[0].Str(string("]("))
        Pst[0].Dec(long[arrayAddress][compareAgainstIndex])
        Pst[0].Str(string("), elementsLarger = "))
        Pst[0].Dec(elementsLarger)
    if elementsSmaller =< halfTheElements and elementsLarger =< halfTheElements
      return long[arrayAddress][toCompareIndex]
  
PUB DisplayArray(arrayAddress, elements)

  elements--
  repeat result from 0 to elements
    Pst[0].Dec(long[arrayAddress][result])
    if result == elements
      Pst[0].Char(11)
      Pst[0].Char(13)
    else
      Pst[0].Char(",")
      Pst[0].Char(" ")
      
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