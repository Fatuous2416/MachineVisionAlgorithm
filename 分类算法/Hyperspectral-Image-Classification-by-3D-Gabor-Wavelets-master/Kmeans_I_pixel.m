function [ correct_rate,label_gt ] =Kmeans_I_pixel( sample,sample_rate,varargin )
%Kmeans_I_pixel��indian_pinesͼ���е����������k��ֵ���࣬ά��Ϊ200xnά(nΪѡ��ķ�����)
%�������һ��16�࣬������������
%�ڲ���׼ȷ��ʱʱ���ã�Ҳ��ֱ�Ӷ�ȫ��Gabor��������
%����������sample����a��x,y,b,dir���ṹ��һ��Ϊ145x145x200x(ѡȡ�ķ�����),sample_rateΪ����sample��ѡȡ�ı���
%���ش�����error_rate��1x1��,�ͷ����ǩ����label_gt(145x145)
%����error����ȷ�������ʣ�Random_I���������������
%!!!!!!!vararginģʽ���ڶ�ÿ��С���ֱ���з�����������ʱʹ�ã���ʱdir=1
%�����������Ϊ145x145��ά��Ϊ200xn��nΪѡ��ķ�����),��ҪԤ������
%-------------------------------------------------------------------------

global indian_pines_gt;  %������׼��ǩ�������ڱȶ�
dir_num=min(size(sample));%��ȡ����ʹ��С���ķ�����Ŀ
if (nargin==3) %����С������ģʽ
    dir_num=1;
end

[sample_selected,sample_num]=Random_I(sample_rate);  %����Random_I������rate�����������������sample_selecedΪѡȡ�����ı�ǩ����145x145��sample_numΪÿ����������Ŀ1x16
distance=zeros(1,16);

%����ѡ��������ʼ��ÿ������
center=zeros(16,200,dir_num);
label_gt=zeros(145, 145);

for x=1:145
    for y=1:145
        if (sample_selected(x,y)==1)  %��ѡ�е�����
            label_gt(x,y)=indian_pines_gt(x,y);  %���÷���,ֱ��д��ǩ
            center(indian_pines_gt(x,y),:,:)=reshape(center(indian_pines_gt(x,y),:,:),200,dir_num)+reshape(sample(x,y,:,:),200,dir_num); 
        end
    end
end

for k=1:16
center(k,:,:)=reshape(center(k,:,:),200,dir_num)./sample_num(k);  %ƽ���õ�����
end

class_num=zeros(1,16);

for x=1:145
    for y=1:145
       %����ÿһ����
       if (indian_pines_gt(x,y)~=0  && ~sample_selected(x,y)) %���Ǳ�����,����������
       for kkk=1:16
           %������ÿһ�����ĵľ���
           temp1=reshape(center(kkk,:,:),200,dir_num);
           temp2=reshape(sample(x,y,:,:),200,dir_num);
           temp3=temp1-temp2;
           distance(kkk)=sum(sum(temp3.^2))/(200*dir_num);
       end
       label=find(distance==min(distance));  %��¼��С���������ı�ǩ��
       label_gt(x,y)=label;   %������ֵ��������ı�ǩ��ȥ
        %ȷ����һ�������(��Ȩƽ��)
       sum_temp=reshape(center(label,:,:),200,dir_num).*class_num(label)+reshape(sample(x,y,:,:),200,dir_num);
       class_num(label)=class_num(label)+1;  %������Ŀ+1
       center(label,:,:)=sum_temp./class_num(label);
       end
       %��һ��
    end
%     fprintf('%0.2f\n',x);
end

error_rate=Error_I(label_gt);
correct_rate=1-error_rate;



end

