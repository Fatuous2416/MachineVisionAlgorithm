function [ rate ] = Error_I( indian_pines_gt2 )
%�˺���ͳ�ƴ����ʣ�����k��ֵ����
%�������Ϊ�����������ɵı�ǩ����ȫ�ֱ���indian_pines_gtΪ��׼�ı�ǩ���󣬶�Ϊ145x145����
%�����ʼ��㷽����
%        �ִ�+1���ֶ�+0
%�ھ�ֵ�����е���

global indian_pines_gt;


rate=0;
for k=1:145
    for kk=1:145
        if (indian_pines_gt(k,kk)~=indian_pines_gt2(k,kk))
            rate=rate+1;
        end
    end
end

rate=rate/(145*145);

end

