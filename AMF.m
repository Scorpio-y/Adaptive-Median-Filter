%% 基于自适应中值滤波器对图像去噪处理
clear all;
close all;
clc;
img=rgb2gray(imread('Lena.jpg'));       %将原图转成灰度图像
figure;imshow(img,[]);title('原图');     %显示原始图像
[m n]=size(img);            %m,n为图像的行数和列数
img=imnoise(img,'salt & pepper',0.2);   %加入20%的椒盐噪声
figure;imshow(img,[]);title('加入20%的椒盐噪声');     %显示加入椒盐噪声后的图像

%% 图像边缘扩展
%为保证边缘的像素点可以被采集到，必须对原图进行像素扩展。
%一般设置的最大滤波窗口为7，所以只需要向上下左右各扩展3个像素即可采集到边缘像素。
Nmax=3;        %确定最大向外扩展为3像素，即最大窗口为7*7
imgn=zeros(m+2*Nmax,n+2*Nmax);      %新建一个扩展后大小的全0矩阵
imgn(Nmax+1:m+Nmax,Nmax+1:n+Nmax)=img;  %将原图覆盖在imgn的正中间
%下面开始向外扩展，即把边缘的像素向外复制
imgn(1:Nmax,Nmax+1:n+Nmax)=img(1:Nmax,1:n);                 %扩展上边界
imgn(1:m+Nmax,n+Nmax+1:n+2*Nmax)=imgn(1:m+Nmax,n+1:n+Nmax);    %扩展右边界
imgn(m+Nmax+1:m+2*Nmax,Nmax+1:n+2*Nmax)=imgn(m+1:m+Nmax,Nmax+1:n+2*Nmax);    %扩展下边界
imgn(1:m+2*Nmax,1:Nmax)=imgn(1:m+2*Nmax,Nmax+1:2*Nmax);       %扩展左边界
% figure;imshow(uint8(imgn));
re=imgn;        %扩展之后的图像

%% 得到不是噪声点的中值
for i=Nmax+1:m+Nmax
    for j=Nmax+1:n+Nmax
        r=1;                %初始向外扩张1像素，即滤波窗口大小为3
        while r~=Nmax+1    %当滤波窗口小于等于7时（向外扩张元素小于4像素）
            W=imgn(i-r:i+r,j-r:j+r);
            W=sort(W(:));           %对窗口内灰度值排序，排序结果为一维数组
            Imin=min(W(:));         %最小灰度值
            Imax=max(W(:));         %最大灰度值
            Imed=W(ceil((2*r+1)^2/2));      %灰度中间值
            if Imin<Imed && Imed<Imax       %如果当前窗口中值不是噪声点，那么就用此次的中值为替换值
               break;
            else
                r=r+1;              %否则扩大窗口，继续判断，寻找不是噪声点的中值
            end          
        end
        
 %% 判断当前窗口内的中心像素是否为噪声，是就用前面得到的中值替换，否则不替换       
        if Imin<imgn(i,j) && imgn(i,j)<Imax         %如果当前这个像素不是噪声，原值输出
            re(i,j)=imgn(i,j);
        else                                        %否则输出邻域中值
            re(i,j)=Imed;
        end
    end
end
%显示加入椒盐噪声的图像通过自适应中值滤波器后的结果
figure;imshow(re(Nmax+1:m+Nmax,Nmax+1:n+Nmax),[]);