%չʾ16���gabor����
%��Ҫ������Gabor_new.m�ļ������ɰ�������Gabor������Ϣ��M_g����
%�����������չʾ��֮�󲻹��ɵ��ù�ϵ��֮���ޱ�������

% g_feature=zeros(52,16);
% for dir=1:52
%     g_number=zeros(1,16);
%     for x=1:145
%         for y=1:145
%             if(indian_pines_gt(x,y)~=0)
%                 g_feature(dir,indian_pines_gt(x,y))=g_feature(dir,indian_pines_gt(x,y))+mean(M_g{dir}(x,y,:));
%                 g_number(indian_pines_gt(x,y))=g_number(indian_pines_gt(x,y))+1;   %��¼�����ĵ���
%             end
%         end
%     end
%     g_feature(dir,:)=g_feature(dir,:)./g_number;
% end

x=1:52;
plot(x,g_feature(:,1),'*');

