function [ii] = computeIntegralImage(PaddedImg,Ds,t1,t2)

[m,n] = size(PaddedImg);  

m1 = m - 2*Ds;  
n1 = n - 2*Ds; 

ii = zeros(m1,n1); 

Dist2 = (PaddedImg(1+Ds:end-Ds,1+Ds:end-Ds) - PaddedImg(1+Ds+t1:end-Ds+t1,1+Ds+t2:end-Ds+t2)).^2;  

for j=1:n1
    for i=1:m1        
         if i==1 && j==1  
             ii(i,j)=Dist2(i,j);  
         elseif i==1 && j~=1  
             ii(i,j)=ii(i,j-1)+Dist2(i,j);   
         elseif i~=1 && j==1  
             ii(i,j)=ii(i-1,j)+Dist2(i,j);  
         else  
             ii(i,j)=Dist2(i,j)+ii(i-1,j)+ii(i,j-1)-ii(i-1,j-1);  
         end 
     end  
end

ii = padarray(ii,[1,1],0,'pre');

end