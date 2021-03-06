function [result] = fastNonLocalMeans(image, sigma, h, patchSize, searchWindowSize)

I=double(image);  
[m,n]=size(I);  
PaddedImg = padarray(I,[searchWindowSize+patchSize+1,searchWindowSize+patchSize+1],'symmetric');  
PaddedV = padarray(I,[searchWindowSize,searchWindowSize],'symmetric');  %

average=zeros(m,n);  
sweight=average;  
wmax=average;  
h2=h*h;  
d2=(2*patchSize+1)^2;  

StArray = zeros(2*searchWindowSize+1,2*searchWindowSize+1);

for t1 = -searchWindowSize:searchWindowSize  
    for t2 = -searchWindowSize:searchWindowSize  
        x = t1+searchWindowSize+1;
        y = t2+searchWindowSize+1;
        Sd = integralImgSqDiff(PaddedImg,searchWindowSize,t1,t2);
        StArray(x,y) = St;
    end
end

%{ 
I=double(I);  
[m,n]=size(I);  
PaddedImg = padarray(I,[Ds+ds+1,Ds+ds+1],'symmetric','both');  
PaddedV = padarray(I,[Ds,Ds],'symmetric','both');  %

average=zeros(m,n);  
sweight=average;  
wmax=average;  
h2=h*h;  
d2=(2*ds+1)^2;  

for t1=-Ds:Ds  
    for t2=-Ds:Ds  
        if(t1==0&&t2==0)  
            continue;  
        end  
        St=integralImgSqDiff(PaddedImg,Ds,t1,t2);  
        v = PaddedV(1+Ds+t1:end-Ds+t1,1+Ds+t2:end-Ds+t2);  
        w=zeros(m,n);  
        for i=1:m  
            for j=1:n  
                i1=i+ds+1;  
                j1=j+ds+1;  
                Dist2=St(i1+ds,j1+ds)+St(i1-ds-1,j1-ds-1)-St(i1+ds,j1-ds-1)-St(i1-ds-1,j1+ds); 
                Dist2=Dist2/d2;  
                w(i,j)=exp(-Dist2/h2);  
                sweight(i,j)=sweight(i,j)+w(i,j);  
                average(i,j)=average(i,j)+w(i,j)*v(i,j);  
            end  
        end  
        wmax=max(wmax,w);  
    end  
end  

average=average+wmax.*I;  
sweight=sweight+wmax;  
DenoisedImg=average./sweight;  
%}

function Sd = integralImgSqDiff(PaddedImg,Ds,t1,t2)  
%PaddedImg: 
%Ds:search window
%(t1,t2):offsets 
%Sd: integral image  
[m,n]=size(PaddedImg);  
m1=m-2*Ds;  %??????
n1=n-2*Ds;  %??????
Sd=zeros(m1,n1);

Dist2=(PaddedImg(1+Ds:end-Ds,1+Ds:end-Ds)-PaddedImg(1+Ds+t1:end-Ds+t1,1+Ds+t2:end-Ds+t2)).^2;

for i=1:m1  
    for j=1:n1  
         if i==1 && j==1  
             Sd(i,j)=Dist2(i,j);  
         elseif i==1 && j~=1  
             Sd(i,j)=Sd(i,j-1)+Dist2(i,j);   
         elseif i~=1 && j==1  
             Sd(i,j)=Sd(i-1,j)+Dist2(i,j);  
         else  
             Sd(i,j)=Dist2(i,j)+Sd(i-1,j)+Sd(i,j-1)-Sd(i-1,j-1);  
         end  
     end  
end 