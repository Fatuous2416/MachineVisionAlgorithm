function [ accuracy ] = SVM_I_perdir_sel( sample_rate,indian_pines_gt,data_set )


% �˺������ڶ���������SVM����
%����sample����rateΪ����������indian_pines_gtΪ��׼��ǩ��data_setΪ���ݼ�

[sample_gt,~] = Random_I(sample_rate);

test_pos=1;
train_pos=1;

indian_pines_corrected_svm = normalizing(data_set, 0, 1);



for k=1:145
    for kk=1:145
        if(sample_gt(k,kk)==1)  %��ѡ�е���������Ϊtrain
            trainlabels(train_pos)=indian_pines_gt(k,kk);
            traindata(train_pos,:,:)=indian_pines_corrected_svm(k,kk,:,:);
            train_pos=train_pos+1;
        else
            if(indian_pines_gt(k,kk)~=0)  %��Ϊtest,����
                testlabels(test_pos)=indian_pines_gt(k,kk);
                testdata(test_pos,:,:)=indian_pines_corrected_svm(k,kk,:,:);
                test_pos=test_pos+1;
            end
        end
    end
end

disp('svm ready');

% bestacc = 0;    % ������ʶ����
% for cc = 5:10
%     for gg = -5:5
%         acc = svmtrain(trainlabels, traindata,'-h 0');   % 5�۽�����֤ c��ȡֵ��Χ[2^5--2^10] g��ȡֵ��Χ[2^(-5)--2^5]
%         if acc > bestacc
%             bestacc = acc;
%             bestc = cc;      % �洢���c
%             bestg = gg;      % �洢���g
%         end
%         disp(gg);
%     end
% end

% acc = svmtrain(trainlabels, traindata, ['-c ', num2str(2^5), ' -g ',  num2str(2^5),' -v 5']);   % 5�۽�����֤ c��ȡֵ��Χ[2^5--2^10] g��ȡֵ��Χ[2^(-5)--2^5]
% if acc > bestacc
%     bestacc = acc;
%     bestc = 5;      % �洢���c
%     bestg = 5;
%     % train with best c and g
% end


bestc = 1000;
bestg = 0.01;

model = svmtrain(trainlabels', traindata, ['-c ', num2str(2^bestc), ' -g ',  num2str(2^bestg)]);
[result, ~, ~] = svmpredict(testlabels', testdata, model);
accuracy = sum(result==testlabels')/length(result);

end