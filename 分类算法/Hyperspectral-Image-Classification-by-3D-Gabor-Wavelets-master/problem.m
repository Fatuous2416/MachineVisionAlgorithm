function [ cen ] = Center_I(F_sel)
%Center_I ȷ��ÿһ������ģ�����k��ֵ����
%ȫ�ֱ��� M_g��ͼ�������Gabor����1x52��
%�������F_sel��ʾ��ѡ�е�����1xn�����cen��ʾ�������
%��kmeans_I��������,145x145x200ά����������

global indian_pines_gaborall;


cen=zeros(1,145,145,200);  %cen�ĵ�һά����Ϊ���ݣ�����Ϊ�������ݽṹ���������
for k=1:2
    if(find(F_sel==k))
        cen=cen+indian_pines_gaborall(k,:,:,:);   %������������ڱ�ѡ��Χ�����ۼ�
    end
end

cen=cen./length(F_sel);

end

