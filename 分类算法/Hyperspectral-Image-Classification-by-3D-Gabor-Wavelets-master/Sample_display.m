%չʾ16������ƽ����������
clear energy x %�����ϴ����ɵı���
xx=1:200;
for k=1:16
    energy(k,:)=Sample_show1(indian_pines_gt,indian_pines_corrected,k);
    x(k,:)=xx;
end
energy=energy';
 x=x';
plot(x,energy);
title('δ��Gabor�任��16������ƽ����������');
legend('Alfalfa','Corn-notill','Corn-mintill','Corn','grass-pasture','Grass-trees,','Grass-pasture mowed','Hay-wndrowed','Oats','Soybean-notill','soybean-mintill','Soybean-clean','Wheat','Woods','Building-Grass-trees-drivers','Stone-Steel-Towers');
xlabel('Ƶ�����');
ylabel('������ֵ');
clear k x xx;

                