%��Indian_Pine�еĵ����GaborС���任�����Ҵ洢�������
%�任��Ϊ12x12��ȡÿ�����ģ�6,6��Ϊ���ı任�㣩�����ܹ��ɴ��ı�Ե��ȥ����ÿ������һ�����G����һ��GaborС����Gabor��Ӧ
%�����ĵ��Ǳ����㣬�򲻲���˴μ���
%�𲨶ν��б任
%��������Indian_Pine.m�����У�ʹ��֮ǰ����Ҫ����IO������ͼ�����
%�����������
%sigma=1

clc;
global indian_pines_gaborall;
%52�������С��

for dir=1:52
    indian_pines_gaborall(1:145,1:145,1:200,dir)=G_I(dir);   %indian_pines_gaborall�洢���е�gabor���������ݽṹΪ��x,y,b,dir��
    fprintf('band %2.0f is completed!\n',dir);
end

%MΪ���������ݽṹ����1x52������
%M{dir}��ʾ��Ӧdir�����Gabor��Ӧ����145x145x200��������
%M{dir}(x,y,:)��1x200�������������е�m������ʾ��һ���� �ڸ��������� ����һ�������С�� ����Ӧ����˷���
%���������з�����������ѡ��
save('indian_pines_gaborall.mat','indian_pines_gaborall');

clear dir; %�������