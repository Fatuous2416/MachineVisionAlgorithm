function [ ] = Random_svm_I( rate )
%�˺�������һ������rate������������libsvm��Ҫ��ʽ�Ĳ����ļ�

[sel_label,class_num]=Random_I(rate); %����random_I��������һ������������������labelΪѡ�б�ǩ��class_NUMΪÿ�������ĸ���

for x=1:145
    for y=1:145
        fid=fopen('svm_data','a');  %��/�����ļ������ļ�β����������
        if ( (sel_label==1)&&fid )
              %д������
            fclose(fid);
        end
    end
end

end

