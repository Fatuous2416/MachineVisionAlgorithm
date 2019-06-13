%I = imread('CLRIS012.jpg');
clear;clc;
img = imread('D:\MATLABԴ����\DRIVE\test\images\01_test.tif');%CLRIS002.jpg');%
mask = imread('D:\MATLABԴ����\DRIVE\test\mask\01_test_mask.gif');
[lm,ln,lq]=size(img);
for q=1:3
for i=1:lm
   for j=1:ln
       if mask(i,j)== 0
           img(i,j,q)=img(i,j,q)&mask(i,j);
       end
   end
end
end
figure;
imshow(img);
img2=img(:,:,1);
%may=img;
img=rgb2hsv(img);
img1=img;
% %cform2lab = makecform('srgb2lab');
% %LAB = applycform(img, cform2lab);
% L = LAB(:,:,1);
% LAB(:,:,1) = adapthisteq(L);
% cform2srgb = makecform('lab2srgb');
% J = applycform(LAB, cform2srgb);
%figure;
img = img(:,:,1);
img3=img;
imshow(img);
%img=J;
%img=rgb2gray(J);

cluster_num = 2;%���÷�����
maxiter = 60;%����������
%-------------�����ʼ����ǩ----------------
%label = randi([1,cluster_num],size(img));
%-----------kmeans��Ϊ��ʼ��Ԥ�ָ�----------
label = kmeans(img(:),cluster_num);
label = reshape(label,size(img));
iter = 0;
b=label;
while iter < maxiter
    %-------�����������---------------
    %�����Ҳ��õ������ص��3*3����ı�ǩ��ͬ
    %�������Ϊ�������
    %------�ռ���������б�Ȱ˸�����ı�ǩ--------
    label_u = imfilter(label,[0,1,0;0,0,0;0,0,0],'replicate');
    label_d = imfilter(label,[0,0,0;0,0,0;0,1,0],'replicate');
    label_l = imfilter(label,[0,0,0;1,0,0;0,0,0],'replicate');
    label_r = imfilter(label,[0,0,0;0,0,1;0,0,0],'replicate');
    label_ul = imfilter(label,[1,0,0;0,0,0;0,0,0],'replicate');
    label_ur = imfilter(label,[0,0,1;0,0,0;0,0,0],'replicate');
    label_dl = imfilter(label,[0,0,0;0,0,0;1,0,0],'replicate');
    label_dr = imfilter(label,[0,0,0;0,0,0;0,0,1],'replicate');
    p_c = zeros(cluster_num,size(label,1)*size(label,2));
    %�������ص�8�����ǩ�����ÿһ�����ͬ����
    for i = 1:cluster_num
        label_i = i * ones(size(label));
        temp = ~(label_i - label_u) + ~(label_i - label_d) + ...
            ~(label_i - label_l) + ~(label_i - label_r) + ...
            ~(label_i - label_ul) + ~(label_i - label_ur) + ...
            ~(label_i - label_dl) +~(label_i - label_dr);
        p_c(i,:) = temp(:)/8;%�������
    end
    p_c(find(p_c == 0)) = 0.001;%��ֹ����0
    %---------------������Ȼ����----------------
    mu = zeros(1,cluster_num);
    sigma = zeros(1,cluster_num);
    %���ÿһ��ĵĸ�˹����--��ֵ����
    for i = 1:cluster_num
        index = find(label == i);%�ҵ�ÿһ��ĵ�
        data_c = double(img(index));
        mu(i) = mean(data_c);%��ֵ
        sigma(i) = var(data_c);%����
    end
    p_sc = zeros(cluster_num,size(label,1)*size(label,2));
%     for i = 1:size(img,1)*size(img,2)
%         for j = 1:cluster_num
%             p_sc(j,i) = 1/sqrt(2*pi*sigma(j))*...
%               exp(-(img(i)-mu(j))^2/2/sigma(j));
%         end
%     end
    %------����ÿ�����ص�����ÿһ�����Ȼ����--------
    %------Ϊ�˼������㣬��ѭ����Ϊ����һ�����--------
    for j = 1:cluster_num
        MU = repmat(mu(j),size(img,1)*size(img,2),1);
        p_sc(j,:) = 1/sqrt(2*pi*sigma(j))*...
            exp(-(double(img(:))-MU).^2/2/sigma(j));
    end 
    %�ҵ�����һ�����������Ϊ��ǩ��ȡ������ֵֹ̫С
    [~,label] = max(log(p_c) + log(p_sc));
    %�Ĵ�С������ʾ
    label = reshape(label,size(img));
    %---------��ʾ----------------
    %if ~mod(iter,6) 
        %figure;
        %n=1;
    %end
    %subplot(2,3,n);
    %imshow(label,[]);
    t=label;
    %title(['iter = ',num2str(iter)]);
    %pause(0.1);
    %n = n+1;
    iter = iter + 1;
end
m=numel(t);
x=length(find(t==1));
y=min(x,m-x);
figure;
imshow(t,[]);
BW0 = t;
%BW0 =bwareaopen(t, 50,26); %ɾ����ֵͼ��BW�����С��50�Ķ���Ĭ�������ʹ��8���򣬲����ɵ�

%I=imread('D:\����\978-7-302-46774-8MATLAB�����㷨����\Intelligent algorithm\10\s10_4\rice_noise.tif');
BW1=edge(BW0,'Roberts',0.04);    	%Roberts����
BW2=edge(BW0,'Sobel',0.04);    	%Sobel����
BW6=edge(b,'Sobel',0.04);    	%Sobel����
BW3=edge(BW0,'Prewitt',0.04);        	%Prewitt����
BW4=edge(BW0,'LOG',0.004);         	% LOG����
BW5=edge(BW0,'Canny',0.04);         	% Canny����
figure;
subplot(2,3,1),
imshow(BW0,[])
title('�ָ��ͼ��')
subplot(2,3,2),
imshow(BW1,[])
title('Roberts ')
subplot(2,3,3),
imshow(BW2)
title(' Sobel ')
subplot(2,3,4),
imshow(BW3)
title(' Prewitt ')
subplot(2,3,5),
imshow(BW4)
title(' LOG ')
subplot(2,3,6),
imshow(BW5)
title('Canny ')
g1=length(find(BW1==1))/2;
g2=length(find(BW2==1))/2;
g3=length(find(BW3==1))/2;
g4=length(find(BW4==1))/2;
g5=length(find(BW5==1))/2;
g6=length(find(BW6==1))/2;
h1=y/g1
h2=y/g2
h3=y/g3
h4=y/g4
h5=y/g5
h6=y/g6


% % clear all; close all; clc;
% % 
% % img=double(imread('lena.jpg'));
% % imshow(img,[]);
[m n]=size(img);

img=sqrt(img);      %٤��У��

%���������Ե
fy=[-1 0 1];        %������ֱģ��
fx=fy';             %����ˮƽģ��
Iy=imfilter(img,fy,'replicate');    %��ֱ��Ե
Ix=imfilter(img,fx,'replicate');    %ˮƽ��Ե
Ied=sqrt(Ix.^2+Iy.^2);              %��Եǿ��
Iphase=Iy./Ix;              %��Եб�ʣ���ЩΪinf,-inf,nan������nan��Ҫ�ٴ���һ��


%��������cell
step=16;                %step*step��������Ϊһ����Ԫ
step1=m/step;
step2=n/step;
orient=9;               %����ֱ��ͼ�ķ������
jiao=360/orient;        %ÿ����������ĽǶ���
Cell=cell(1,1);              %���еĽǶ�ֱ��ͼ,cell�ǿ��Զ�̬���ӵģ�����������һ��
ii=1;                      
jj=1;
for i=1:step1:m          %��������m/step���������������i=1:step:m-step
    ii=1;
    for j=1:step2:n      %ע��ͬ��
        tmpx=Ix(i:i+step1-1,j:j+step2-1);
        tmped=Ied(i:i+step1-1,j:j+step2-1);
        tmped=tmped/sum(sum(tmped));        %�ֲ���Եǿ�ȹ�һ��
        tmpphase=Iphase(i:i+step1-1,j:j+step2-1);
        Hist=zeros(1,orient);               %��ǰstep*step���ؿ�ͳ�ƽǶ�ֱ��ͼ,����cell
        for p=1:step1
            for q=1:step2
                if isnan(tmpphase(p,q))==1  %0/0��õ�nan�����������nan������Ϊ0
                    tmpphase(p,q)=0;
                end
                ang=atan(tmpphase(p,q));    %atan�����[-90 90]��֮��
                ang=mod(ang*180/pi,360);    %ȫ��������-90��270
                if tmpx(p,q)<0              %����x����ȷ�������ĽǶ�
                    if ang<90               %����ǵ�һ����
                        ang=ang+180;        %�Ƶ���������
                    end
                    if ang>270              %����ǵ�������
                        ang=ang-180;        %�Ƶ��ڶ�����
                    end
                end
                ang=ang+0.0000001;          %��ֹangΪ0
                Hist(ceil(ang/jiao))=Hist(ceil(ang/jiao))+tmped(p,q);   %ceil����ȡ����ʹ�ñ�Եǿ�ȼ�Ȩ
            end
        end
        Hist=Hist/sum(Hist);    %����ֱ��ͼ��һ��
        Cell{ii,jj}=Hist;       %����Cell��
        ii=ii+1;                %���Cell��y����ѭ������
    end
    jj=jj+1;                    %���Cell��x����ѭ������
end

%��������feature,2*2��cell�ϳ�һ��block,û����ʽ����block
[m n]=size(Cell);
feature=cell(1,(m-1)*(n-1));
for i=1:m-1
   for j=1:n-1           
        f=[];
        f=[f Cell{i,j}(:)' Cell{i,j+1}(:)' Cell{i+1,j}(:)' Cell{i+1,j+1}(:)'];
        feature{(i-1)*(n-1)+j}=f;
   end
end

%���˽�����feature��Ϊ����
%������Ϊ����ʾ��д��
l=length(feature);
f=[];
for i=1:l
    f=[f;feature{i}(:)'];  
end 
figure
mesh(f)