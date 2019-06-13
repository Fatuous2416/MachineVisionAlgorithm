function [ indian_pines_sample_gt, num_class_rate ] = Random_I( rate )
%�˺����������ѡȡһ��������indian_pine����
%����rateΪѡȡ�ı���,���indian_pines_sample_gtΪ�������ϵı�ǩ,Ϊ145x145����num_classΪÿһ��ĸ���(16x1)
%��ִ��IO.m�����ⲿ��������ⲻ�����������������ļ�

%ͳ��ÿ�������ĸ���
global indian_pines_gt;
indian_pines_sample_gt=zeros(145,145);
num_class=zeros(1,16);
for k=1:145 
    for kk=1:145
        if (indian_pines_gt(k,kk))
        num_class(indian_pines_gt(k,kk))=num_class(indian_pines_gt(k,kk))+1;
        end
    end
end

num_class_rate=fix(num_class.*rate);  %ȷ��ÿһ��������Ҫѡȡ�ĸ���

for k=1:16
    %��ÿ��������������ȡ����������Ϊѡ�����������
    temp=randperm(num_class(k));
    r=[];
    r=temp(1:num_class_rate(k));
    num_class_rate(k)=length(unique(r));
    order(k,:)={r};  %order�洢������ѡȡ���������

    
end


sample_record=zeros(1,16);  %������������¼�������ֵĴ���

    for kk=1:145
        for kkk=1:145  %����ǩ��������Ӧ�����������Ķ�Ϊ1
            if (indian_pines_gt(kk,kkk)) %���Ǳ�����
                tag=sample_record(indian_pines_gt(kk,kkk));%�����д��������ֵ����
                if (any(tag==order{indian_pines_gt(kk,kkk),:})) %�˺�Ϊ���ѡ�е�����
                    indian_pines_sample_gt(kk,kkk)=1;
                end
                sample_record(indian_pines_gt(kk,kkk))=sample_record(indian_pines_gt(kk,kkk))+1;
            end
        end
    end
  
    
end

