%�˽ű���Indian_Pine�������ű�
%�˽ű�������ݵĸ�ʽ���������/���������Ľ������С����
%���˽ű����һϵ��ͳ�ƹ���

%directed by: Xiangrong Zhang,associate professor, Xidian University
%created by: Jackson Lee,Xidian Universit, 2013.4.22
%contact: schmidt.liez@gmail.com
%--------------------------------------------------------------------------

%% Ԥչʾ���֣����漰������������
clc;
clear all;

IO_I; %�����Ѿ����룬indian_pines_corrected��145x145x200����ά����indian_pines_gt��145x145�ı�ǩ����0���ʾ����������
Sample_display; %��չʾû��Gabor�任��16���ź��������ߣ�ͼ��Ľṹ��Ϣ
Sample_Gabor100_show; %��ϸչʾ��1,0,0�������С������Ƶ����Ӧ
Sample_gaborshow_52; %��չʾ�����õ���52����С������״

%% ���㲿�֣�����gabor�������Ҵ洢���
clear all;
clc;   %���չʾ�����ɵı���������׼�������ռ䣬׼�����������
IO_I;
%Gabor_I_new;  %�õ�����52�ķ����Gabor����  ���˲����ʱ�ϳ�������Ԥ��ִ�У�
load Indian_pines_gaborall52;

%% ����������ѡ��ķ�����չʾ

%չʾÿ��С����ѡ������,ÿ�����ȡʮ��ƽ���������ʷֱ�Ϊ5%��10%��25%��50%��75%
random_rate=[0.05,0.1,0.25,0.5,0.75];
knn_result_gabor52alone=zeros(52,5);
for dir=1:52
    for rr=1:5
        accuracy=0;
        for time=1:10
            %���ÿһ��С�����з��࣬ȡ���ƽ��
            accuracy=accuracy+Kmeans_I_pixel(indian_pines_gaborall(:,:,:,dir),random_rate(rr),1);  %ʹ��Kmeans_I_pixel�ĵ��������������ö���С������
        end
        knn_result_gabor52alone(dir,rr)=accuracy/10;  %�õ�һ��С����һ�����������ϵ�ƽ����ȷ��
        fprintf('%0.2f',rr);
    end
    fprintf('\n');
    disp(knn_result_gabor52alone(dir,:));
end

save('knn_result_gabor52alone.mat','knn_result_gabor52alone');

%ʹ��ȫ��52�����ķ�������
knn_result_gaborall=zeros(1,5);
for rr=1:5
    accuracy=0;
    for kk=1:10
        accuracy=accuracy+Kmeans_I_pixel(indian_pines_gaborall,random_rate(rr)); %ʹ��ȫ���������з���
    end
    knn_result_gaborall(rr)=accuracy/10;
    fprintf('%0.2f\n',k);
end
save('knn_result_gaborall.mat','result52');


figure;
plot(knn_result_gabor52alone(:,1),'-b*');
hold on;
plot(knn_result_gabor52alone(:,2),'-rx');
hold on;
plot(knn_result_gabor52alone(:,3),'-k+');
hold on;
plot(knn_result_gabor52alone(:,4),'-cs');
hold on;
plot(knn_result_gabor52alone(:,5),'-m^');
hold on;
for k=1:5
    fplot(@(x)result_gaborall(k),[0,52,0,1],'--r');
    hold on;
end
title('52��С�����Եķ�������(ȡʮ��ƽ��)');
axis([0,52,0.5,1]);
legend('5%','10%','25%','50%','75%','ȫ�������ķ���ˮƽ');
clear dir rr accuracy time random_rate kk;
clear k x;



%% ����ѡ�񲿷�,�ֱ�ѡ��ͬ�Ĺ�ģ������3�Σ�������

%�ù��̽���������ѡ����ؽ������
for t=1:3
[indian_pines_gaborsel,f_sel_gt]=Feature_sel_I(3); 
fileName1=sprintf('indian_pines_gaborsel3_%s',num2str(t));   %�����ļ����ַ���
fileName2=sprintf('indian_pines_gaborsel3_%s_gt',num2str(t));
save(fileName1,'indian_pines_gaborsel');  %������
save(fileName2,'f_sel_gt');
[indian_pines_gaborsel,f_sel_gt]=Feature_sel_I(5);
fileName1=sprintf('indian_pines_gaborsel5_%s',num2str(t));   %�����ļ����ַ���
fileName2=sprintf('indian_pines_gaborsel5_%s_gt',num2str(t));
save(fileName1,'indian_pines_gaborsel');
save(fileName2,'f_sel_gt');
[indian_pines_gaborsel,f_sel_gt]=Feature_sel_I(10);
fileName1=sprintf('indian_pines_gaborsel10_%s',num2str(t));   %�����ļ����ַ���
fileName2=sprintf('indian_pines_gaborsel10_%s_gt',num2str(t));
save(fileName1,'indian_pines_gaborsel');
save(fileName2,'f_sel_gt');
end
clear t;
clc;  

%% ��������ѡ��ķ���

%���ֱ�Ӳ���������
load indian_pines_gaborsel3_1;
load indian_pines_gaborsel3_1_gt;
load indian_pines_gaborsel3_2;
load indian_pines_gaborsel3_2_gt;
load indian_pines_gaborsel3_3;
load indian_pines_gaborsel3_3_gt;
load indian_pines_gaborsel5_1;
load indian_pines_gaborsel5_1_gt;
load indian_pines_gaborsel5_2;
load indian_pines_gaborsel5_2_gt;
load indian_pines_gaborsel5_3;
load indian_pines_gaborsel5_3_gt;
load indian_pines_gaborsel10_1;
load indian_pines_gaborsel10_1_gt;
load indian_pines_gaborsel10_2;
load indian_pines_gaborsel10_2_gt;
load indian_pines_gaborsel10_3;
load indian_pines_gaborsel10_3_gt;


%������ѡ��Ľ�����з���
knn_result_sel=zeros(9,5);
for rr=1:5
    accuracy=0;
    for kk=1:10
        accuracy=accuracy+Kmeans_I_pixel(indian_pines_gaborsel3_1,random_rate(rr)); %ʹ��ȫ���������з���
    end
    knn_result_sel(1,rr)=accuracy/10;
    fprintf('%0.2f\n',k);
end
for rr=1:5
    accuracy=0;
    for kk=1:10
        accuracy=accuracy+Kmeans_I_pixel(indian_pines_gaborsel3_2,random_rate(rr)); %ʹ��ȫ���������з���
    end
    knn_result_sel(2,rr)=accuracy/10;
    fprintf('%0.2f\n',k);
end
for rr=1:5
    accuracy=0;
    for kk=1:10
        accuracy=accuracy+Kmeans_I_pixel(indian_pines_gaborsel3_3,random_rate(rr)); %ʹ��ȫ���������з���
    end
    knn_result_sel(3,rr)=accuracy/10;
    fprintf('%0.2f\n',k);
end
for rr=1:5
    accuracy=0;
    for kk=1:10
        accuracy=accuracy+Kmeans_I_pixel(indian_pines_gaborsel5_1,random_rate(rr)); %ʹ��ȫ���������з���
    end
    knn_result_sel(4,rr)=accuracy/10;
    fprintf('%0.2f\n',k);
end
for rr=1:5
    accuracy=0;
    for kk=1:10
        accuracy=accuracy+Kmeans_I_pixel(indian_pines_gaborsel5_2,random_rate(rr)); %ʹ��ȫ���������з���
    end
    knn_result_sel(5,rr)=accuracy/10;
    fprintf('%0.2f\n',k);
end
for rr=1:5
    accuracy=0;
    for kk=1:10
        accuracy=accuracy+Kmeans_I_pixel(indian_pines_gaborsel5_3,random_rate(rr)); %ʹ��ȫ���������з���
    end
    knn_result_sel(6,rr)=accuracy/10;
    fprintf('%0.2f\n',k);
end
for rr=1:5
    accuracy=0;
    for kk=1:10
        accuracy=accuracy+Kmeans_I_pixel(indian_pines_gaborsel10_1,random_rate(rr)); %ʹ��ȫ���������з���
    end
    knn_result_sel(7,rr)=accuracy/10;
    fprintf('%0.2f\n',k);
end
for rr=1:5
    accuracy=0;
    for kk=1:10
        accuracy=accuracy+Kmeans_I_pixel(indian_pines_gaborsel10_2,random_rate(rr)); %ʹ��ȫ���������з���
    end
    knn_result_sel(8,rr)=accuracy/10;
    fprintf('%0.2f\n',k);
end
for rr=1:5
    accuracy=0;
    for kk=1:10
        accuracy=accuracy+Kmeans_I_pixel(indian_pines_gaborsel10_3,random_rate(rr)); %ʹ��ȫ���������з���
    end
    knn_result_sel(9,rr)=accuracy/10;
    fprintf('%0.2f\n',k);
end

save('knn_result_sel.mat','knn_result_sel');

%% ����ѡ��Ľ����δ��ѡ��Ľ���Ա�

load knn_result_gaborall;
load knn_result_sel.mat;
%��δ��ѡ�������������
for k=1:5
    fplot(@(x)knn_result_gaborall(k),[1,5,0.65,1],'--r');
    hold on;
end
set(gca,'XTickLabel',{'0.05','','0.1','','0.25','','0.5','','0.75'});  %����x����ʾ����
xlabel('��������');
ylabel('��ȷ��');
title('����ѡ��ǰ�����ȷ�ʶԱ�');
hold on;

%������ѡ��������ķ�����ȷ������
x=1:5;
plot(x,knn_result_gaborsel,'--x');
hold on;

%% SVM����

%����ԭʼ���ε�SVM����
clear all;
IO_I;
accuracy=zeros(1,4);
sample_rate=[0.05,0.1,0.25,0.5];

for k=1:4
    for kk=1:10  %ʮ��ȡƽ��
        accuracy(k)=accuracy(k)+SVM_I_perdir(sample_rate(k),indian_pines_gt,indian_pines_corrected);
    end
    accuracy(k)=accuracy(k)./10;
end
save('svm_accuracy_spec.mat','acccuracy');
disp(accuracy);

%����ÿ�������SVM����

clear all;
IO_I;
load indian_pines_gaborall52;
load indian_pines_gaborall52;
global indian_pines_gaborall;
accuracy=zeros(4,52);
sample_rate=[0.05,0.1,0.25,0.5];

for k=1:4
    for kk=1:52  
        for kkk=1:10
        accuracy(k,kk)=accuracy(k,kk)+SVM_I_perdir_52(sample_rate(k),indian_pines_gt,kk);
        end
    end
end
accuracy=accuracy./10;

save('svm_accuracy_perband.mat','accuracy');


%���������򻯺�ķ��ࣨ����9�����ݼ���)

accuracy=zeros(9,5);
sample_rate=[0.05,0.1,0.25,0.5,0.75];
load indian_pines_gaborsel3-1;
for k=1:5
    for kk=1:10
        accuracy(1,k)=accuracy(2,k)+SVM_I_perdir_sel(sample_rate(k),indian_pines_gt,indian_pines_gaborsel);
    end
    disp(k);
end

load indian_pines_gaborsel3-2;
for k=1:5
    for kk=1:10
        accuracy(2,k)=accuracy(2,k)+SVM_I_perdir_sel(sample_rate(k),indian_pines_gt,indian_pines_gaborsel);
    end
    disp(k);
end

load indian_pines_gaborsel3-3;
for k=1:5
    for kk=1:10
        accuracy(3,k)=accuracy(2,k)+SVM_I_perdir_sel(sample_rate(k),indian_pines_gt,indian_pines_gaborsel);
    end
    disp(k);
end

load indian_pines_gaborsel5-1;
for k=1:5
    for kk=1:10
        accuracy(4,k)=accuracy(2,k)+SVM_I_perdir_sel(sample_rate(k),indian_pines_gt,indian_pines_gaborsel);
    end
    disp(k);
end

load indian_pines_gaborsel5-2;
for k=1:5
    for kk=1:10
        accuracy(5,k)=accuracy(2,k)+SVM_I_perdir_sel(sample_rate(k),indian_pines_gt,indian_pines_gaborsel);
    end
    disp(k);
end

load indian_pines_gaborsel5-3;
for k=1:5
    for kk=1:10
        accuracy(6,k)=accuracy(2,k)+SVM_I_perdir_sel(sample_rate(k),indian_pines_gt,indian_pines_gaborsel);
    end
    disp(k);
end

load indian_pines_gaborsel10-1;
for k=1:5
    for kk=1:10
        accuracy(7,k)=accuracy(2,k)+SVM_I_perdir_sel(sample_rate(k),indian_pines_gt,indian_pines_gaborsel);
    end
    disp(k);
end

load indian_pines_gaborsel10-2;
for k=1:5
    for kk=1:10
        accuracy(8,k)=accuracy(2,k)+SVM_I_perdir_sel(sample_rate(k),indian_pines_gt,indian_pines_gaborsel);
    end
    disp(k);
end

load indian_pines_gaborsel10-3;
for k=1:5
    for kk=1:10
        accuracy(9,k)=accuracy(2,k)+SVM_I_perdir_sel(sample_rate(k),indian_pines_gt,indian_pines_gaborsel);
    end
    disp(k);
end
accuracy=accuracy./10;
%������
save('svm_accuracy_sel.mat','accuracy');
clc;
clear all;
%% SVM��KNN�Ƚ�

%ʹ��ȫ��52������SVM��������
load svm_accuracy_perband.mat;
figure;

x=[1:52];
plot(x,accuracy(1,:),'-*b');
hold on;
plot(x,accuracy(2,:),'-*c');
hold on;
plot(x,accuracy(3,:),'-*g');
hold on;
plot(x,accuracy(4,:),'-*r');
hold on;


title('SVM��52��С�����Եķ�������(ȡʮ��ƽ��)');
axis([0,52,0,1]);
legend('5%','10%','25%','50%');
clear x;


%SVM��KNN������ѡ��֮��ıȽ�
load knn_result_gaborsel;
load svm_accuracy_sel;

knn(1,:)=sum(knn_result_gaborsel(1:3,:));
knn(2,:)=sum(knn_result_gaborsel(4:6,:));
knn(3,:)=sum(knn_result_gaborsel(7:9,:));

svm(1,:)=sum(accuracy(1:3,:));
svm(2,:)=sum(accuracy(4:6,:));
svm(3,:)=sum(accuracy(7:9,:));
knn=knn./3;
svm=svm./3;

x=[1:5];
figure;
plot(x,knn(1,:),'-*k');
hold on;
plot(x,svm(1,:),'-sr');
hold on;
plot(x,knn(2,:),'-*k');
hold on;
plot(x,knn(3,:),'-*k');
hold on;
plot(x,svm(2,:),'-sr');
hold on;
plot(x,svm(3,:),'-sr');
hold on;

title('��������ѡ���SVM��KNN�ķ��������Ƚ�');
axis([1,5,0.65,1]);
set(gca,'XTickLabel',{'0.05','','0.1','','0.25','','0.5','','0.75'});
legend('knn','svm');
clear k x knn svm;




