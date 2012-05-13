function [YUV_field]=chroma(Y,C,color_burst, sample_time)
    [m,n,field]=size(C);
    f=(1/sample_time)/2;
    [b,a] = butter(12,0.6/(3.58));
    YUV_field=zeros(m,n,3,field);

    for f=1:field
        YUV_field(:,:,1,f)=Y(:,:,f)*(255/max(max(Y(:,:,f))));
    end
    clear Y;

    for f=1:field
        for l=1:m
            U(l,:)=sin(2*pi*color_burst(l,2,f)*10^6*(0:sample_time:(n-1)*sample_time)+color_burst(l,3,f)*pi+pi).*C(l,:,f);
            V(l,:)=cos(2*pi*color_burst(l,2,f)*10^6*(0:sample_time:(n-1)*sample_time)+color_burst(l,3,f)*pi+pi).*C(l,:,f);
        end

        YUV_field(:,:,2,f)=U*(112/max(max(U)));
        YUV_field(:,:,3,f)=V*(157/max(max(V)));
    end
