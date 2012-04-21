composite-decode
================

Composite video decoder

Urls
====

- Najboljši vir: 
  https://docs.google.com/open?id=14dwj5ERDFrDYs_hDrN4WXf3XDc9HMdZC6RCPWHsBG66jKPZchMHM7AH1T9qR
- http://martin.hinner.info/vga/pal.html

Signal details:
===============
- Fvz= 25Mhz
- sample_delta= 0.04*10^(-8)
- threshold_level= <-0.25

PAL details:
------------
- 625 lines
- 50Hz
- F=4.43361875Mhz=283,75 clocks/line * (625 lines * (50Hz/2)) + 25Hz(Guard period)
- Hsynch= 4.7uSec, 5.7uSec to color burst/back porch porch
- Color burst= 0.9uSec(predhodnji del) + 2.25uSec + zadni del = 5,7uSec
- Video= 51.95uSec

Plotting tips:
==============
- Signal might look wierd at first but hold 
  shift+ctrl and use you scroll bar to resize
  in x direction
