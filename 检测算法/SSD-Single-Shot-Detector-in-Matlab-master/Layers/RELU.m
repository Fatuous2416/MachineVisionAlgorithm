%% 
%------------------RELU------------------
%��  �ߣ��
%��  ˾��BJTU
%��  �ܣ�RELU�������
%��  �룺
%       in_array    -----> �����ά���飨dim = 3����
%��  ����
%       out_array   -----> �����ά���飨dim = 3����
%��  ע��Matlab 2016a��
%----------------------------------------

%%

function out_array = RELU(in_array)
    out_array = max(0, in_array);
end