function [ y_avg] = Sample_show1( indian_pines_gt,indian_pines_corrected,label )
%��һ�ֵ����ƽ��������200����,����ƽ������1x200����
x=1:200;
pos=1;
for kkk=1:145
    for kk=1:145
        if(indian_pines_gt(kkk,kk)==label)
            for k=1:200
                y(pos,k)=indian_pines_corrected(kkk,kk,k);
            end
            pos=pos+1;
        end
    end
end
pos=pos-1; %���һ��+1Ҫ��ȥ,yΪposx200�ľ���

for k=1:200
    y_avg(k)=mean(y(:,k));
end

clear k kk kkk;
end

