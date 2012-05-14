## Copyright (C) 1999 Paul Kienzle
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

## usage: [b, a] = zp2tf(z, p, g)
##
## Convert to transfer function f(x)=sum(b*x^n)/sum(a*x^n) from
## zero-pole-gain form f(x)=g*prod(1-z*x)/prod(1-p*x)

function [b, a] = zp2tf(z, p, g)
  if nargin != 3 || nargout != 2
    usage("[b, a] = zp2tf(z, p, g)");
  endif
  try cplxpair(z); catch error("zp2tf: could not pair complex zeros"); end
  try cplxpair(p); catch error("zp2tf: could not pair complex poles"); end
  b = g*real(poly(z));
  a = real(poly(p));
endfunction
