function [ indian_pines_gaborsel,f_sel_gt ] = Feature_sel_I( opt_num)
%�˺���ʹ��˳��ǰ������������ѡ��
%����Ϊ��Ҫѡ����������Ŀ��Ҳ�ɸ�Ϊ�������η���Ĳ�ֵ��ֵ��
%�˺�����indian_pine.m�е��ã���Ҫ��������IO.m������󣬲��Ҿ���gabor_I�õ�ȫ��gabor����
%����һ������indian_pines_gaborsel����indian_pines_gaborall�ڷ���ά�ϵļ򻯾���
%��������f_sel������洢��ѡ���ķ������

%�������������������˺������ԭʼ��indian_pines_gaborall���������ع������в���������ѡ��Ĳ���Ӧ�ڴ˺���֮ǰִ��
%------------------------------------------------------------------------

global indian_pines_gaborall;  %�����������ݵ�gabor��������

f_sel=[];
f_ori=1:52;
t=0;  %�������������ѡ�������ĸ���
indian_pines_gaborsel=zeros(145,145,200,1); %����ѡ��֮���gabor���󣬽ṹ��indian_pines_gaborall��ͬ��145x145x200xopt_num���һλ������ά������������
accuracy=zeros(1,52);  %��¼ÿ�ֲ�����ϵ�ƽ����ȷ��
while(t<opt_num)
   
    for k=1:52  %�������������δѡ�������ĸ���
        if(find(k==f_ori))
            indian_pines_test=indian_pines_gaborsel;
            indian_pines_test(:,:,:,t+1)=indian_pines_gaborall(:,:,:,k); %��ԭʼ�������е�һ�����������Ѿ��õ��Ľ�����ϣ��õ�һ������gabor����
            time=3;  %ƽ������
            for ti=1:time %ʮ�η���ȡƽ��,ȡ25%������
                if (t==0)  %��һ��ѡ����Ҫ3������
                    accuracy(k)=accuracy(k)+Kmeans_I_pixel(indian_pines_test,0.25,1);
                else
                    accuracy(k)=accuracy(k)+Kmeans_I_pixel(indian_pines_test,0.25);
                end
            end
            fprintf('%0.2f\n',k);
        end
    end
    accuracy=accuracy./time;   %�õ�ƽ��ֵ
    order=find(accuracy==max(accuracy)); %�õ���һ����������
    accuracy(order)=0;  %��������׼ȷ������Ϊ0����������´�ѡ��
    t=t+1;  %ÿѡ��һ������order��t++
    f_sel(t)=order; %��ѡ�������������ǩ��������gabor������
    indian_pines_gaborsel(:,:,:,t)=indian_pines_gaborall(:,:,:,order); 
    f_ori(order)=[];  %��������ԭʼ��ǩ��������Ƴ�
fprintf('%0.2f th feature generated:No.%0.2f\n',t,order);
end

disp('feature selection complete!\n');
save('indian_pines_gaborsel.mat','indian_pines_gaborsel');