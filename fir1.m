## Copyright (C) 2000 Paul Kienzle
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## usage: b = fir1(n, w [, type] [, window] [, noscale])
##
## Produce an order n FIR filter with the given frequency cutoff,
## returning the n+1 filter coefficients in b.  
##
## n: order of the filter (1 less than the length of the filter)
## w: band edges
##    strictly increasing vector in range [0, 1]
##    singleton for highpass or lowpass, vector pair for bandpass or
##    bandstop, or vector for alternating pass/stop filter.
## type: choose between pass and stop bands
##    'high' for highpass filter, cutoff at w
##    'stop' for bandstop filter, edges at w = [lo, hi]
##    'DC-0' for bandstop as first band of multiband filter
##    'DC-1' for bandpass as first band of multiband filter
## window: smoothing window
##    defaults to hamming(n+1) row vector
##    returned filter is the same shape as the smoothing window
## noscale: choose whether to normalize or not
##    'scale': set the magnitude of the center of the first passband to 1
##    'noscale': don't normalize
##
## To apply the filter, use the return vector b:
##       y=filter(b,1,x);
##
## Examples:
##   freqz(fir1(40,0.3));
##   freqz(fir1(15,[0.2, 0.5], 'stop'));  # note the zero-crossing at 0.1
##   freqz(fir1(15,[0.2, 0.5], 'stop', 'noscale'));

## TODO: Consider using exact expression (in terms of sinc) for the
## TODO:    impulse response rather than relying on fir2.
## TODO: Find reference to the requirement that order be even for
## TODO:    filters that end high.  Figure out what to do with the
## TODO:    window in these cases---duplicating the central value
## TODO:    like I currently do seems very reasonable.
function b = fir1(n, w, ftype, window, scale)

  if nargin < 2 || nargin > 5
    usage("b = fir1(n, w [, type] [, window] [, noscale])");
  endif
  
  ## interpret arguments
  if nargin==2
    ftype=[]; window=[]; scale=[];
  elseif nargin==3
    window=[]; scale=[];
    if !isstr(ftype), window=ftype; ftype=[]; endif
  elseif nargin==4
    scale=[];
    if isstr(window), scale=window; window=[]; endif
    if !isstr(ftype), window=ftype; ftype=[]; endif
  endif

  ## If single band edge, the first band defaults to a pass band
  ## to create a lowpass filter.  If multiple band edges, assume
  ## the first band is a stop band, so that the two band case defaults
  ## to a band pass filter.  Ick.
  ftype = tolower(ftype);
  if isempty(ftype), ftype = length(w)==1;
  elseif strcmp(ftype, 'low'), ftype = 1;
  elseif strcmp(ftype, 'high'), ftype = 0;
  elseif strcmp(ftype, 'pass'), ftype = 0;
  elseif strcmp(ftype, 'stop'), ftype = 1;
  elseif strcmp(ftype, 'dc-0'), ftype = 0;
  elseif strcmp(ftype, 'dc-1'), ftype = 1;
  elseif isstr(ftype)
    error(["fir1 invalid filter type ", ftype]);
  else
    error("fir1 filter type should be a string");
  endif

  ## scale the magnitude by default
  if isempty(scale) || strcmp(scale, 'scale'), scale = 1; 
  elseif strcmp(scale, 'noscale'), scale=0;
  else error("fir1 scale must be 'scale' or 'noscale'");
  endif

  ## use fir2 default filter
  if isempty(window) && isempty(scale), window = []; endif

  ## build response function according to fir2 requirements
  bands = length(w)+1;
  f = zeros(1,2*bands);
  f(1) = 0; f(2*bands)=1;
  f(2:2:2*bands-1) = w;
  f(3:2:2*bands-1) = w;
  m = zeros(1,2*bands);
  m(1:2:2*bands) = rem([1:bands]-(1-ftype),2);
  m(2:2:2*bands) = m(1:2:2*bands);

  ## Increment the order if the final band is a pass band.  Something
  ## about having a nyquist frequency of zero causing problems.
  if rem(n,2)==1 && m(2*bands)==1, 
    warning("n must be even for highpass and bandstop filters. Incrementing.");
    n=n+1; 
    if !isempty(window), 
      if rows(window) == 1
      	window = [window(1:n/2), window(n/2:n-1)];
      else
	window = [window(1:n/2); window(n/2:n-1)];
      endif
    endif
  endif

  ## compute the filter
  b = fir2(n, f, m, 512, 2, window);

  ## normalize filter magnitude
  if scale == 1
    ## find the middle of the first band edge
    if m(1) == 1, w_o = (f(2)-f(1))/2;
    else w_o = f(3) + (f(4)-f(3))/2;
    endif

    ## compute |h(w_o)|^-1
    renorm = 1/abs(polyval(b, exp(-1i*pi*w_o)));

    ## normalize the filter
    b = renorm*b;
  endif
endfunction

%!demo
%! freqz(fir1(40,0.3));
%!demo
%! freqz(fir1(15,[0.2, 0.5], 'stop'));  # note the zero-crossing at 0.1
%!demo
%! freqz(fir1(15,[0.2, 0.5], 'stop', 'noscale'));
