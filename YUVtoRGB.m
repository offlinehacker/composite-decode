function RGB=YUVtoRGB(YUV)
	[a,b,c]=size(YUV);
	YuvToRgb=[1 0 1.13983 ; 1 -0.39465 -0.58060 ; 1 2.03211 0];
	a=300;
	b=500;
	% sem omejil da se hitrej izvede, se mi ful počas izvaja
	for i=1:a
		for j=1:b
			RGB(i,j,1)=YuvToRgb(1,1)*YUV(i,j,1)+YuvToRgb(1,2)*YUV(i,j,3);
			RGB(i,j,2)=YuvToRgb(2,1)*YUV(i,j,1)+YuvToRgb(2,2)*YUV(i,j,2)+YuvToRgb(2,2)*YUV(i,j,3);
			RGB(i,j,3)=YuvToRgb(3,1)*YUV(i,j,1)+YuvToRgb(3,2)*YUV(i,j,2);
		end
	end



