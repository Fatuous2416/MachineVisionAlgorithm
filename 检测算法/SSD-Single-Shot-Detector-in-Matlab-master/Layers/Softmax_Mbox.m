%% 
%--------------Softmax_Mbox--------------
%��  �ߣ��
%��  ˾��BJTU
%��  �ܣ�����ά��һ����
%��  �룺
%       in_array    -----> �����ά���飨dim = 3����
%       class       -----> �������
%��  ����
%       out_array   -----> �����ά���飨dim = 3����
%��  ע��Matlab 2016a��
%----------------------------------------

%%

function out_array = Softmax_Mbox(in_array, class)

    % �������ά��    
    in_dims = ndims(in_array);
    if(in_dims == 3)
        [height, width, depth] = size(in_array);
    else
        error('��������ά��С��3ά�������������ݡ�');
    end
    
    % ��ʼ��out_array
    out_array = zeros(height, width, depth);
    
    % ����1��2ά���������
    for i = 1: height
        for j = 1: width
            for k = 1: round(depth / class)
                vector = in_array(i, j, (k - 1) * class + 1: k * class);
                vector = reshape(vector, 1, size(vector, 3));
                softnorm = sum(exp(vector));
                out_array(i, j, (k - 1) * class + 1: k * class) = ...
                    exp(in_array(i, j, (k - 1) * class + 1: k * class)) / softnorm;
            end
        end
    end