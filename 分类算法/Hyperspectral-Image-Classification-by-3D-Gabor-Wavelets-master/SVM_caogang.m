function [ output_args ] = SVM_caogang( sample_rate,indian_pines_gt,indian_pines_corrected,band)
%�ܸյ�SVM�汾
% ��������Ϊ��������������׼��ǩ����ԭʼ��Ӧ���󣬲�����
[sample_gt,temp] = Random_I(sample_rate);

test_pos=1;
train_pos=1;

for k=1:length(band)
    data_set(:,:,k)=indian_pines_corrected(:,:,k);   
end
indian_pines_corrected_svm = normalizing(data_set, 0, 1);



for k=1:145
    for kk=1:145
        if(sample_gt(k,kk)==1)  %��ѡ�е���������Ϊtrain
            trainlabels(train_pos)=indian_pines_gt(k,kk);
            traindata(train_pos,:)=indian_pines_corrected_svm(k,kk,:);
            train_pos=train_pos+1;
        else
            if(indian_pines_gt(k,kk)~=0)  %��Ϊtest,����
                testlabels(test_pos)=indian_pines_gt(k,kk);
                testdata(test_pos,:)=indian_pines_corrected_svm(k,kk,:);
                test_pos=test_pos+1;
            end
        end
    end

end

disp('svm ready');

bestc = 1000;
bestg = 0.01;

model = svmtrain(trainlabels', traindata, ['-c ', num2str(2^bestc), ' -g ',  num2str(2^bestg)]);
[result, temp2, temp] = svmpredict(testlabels', testdata, model);
accuracy = sum(result==testlabels')/length(result);

end

