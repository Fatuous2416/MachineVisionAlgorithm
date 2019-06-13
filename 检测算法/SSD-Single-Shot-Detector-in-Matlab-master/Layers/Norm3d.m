%% 
%-----------------Norm3d-----------------
%��  �ߣ��
%��  ˾��BJTU
%��  �ܣ�����ά��һ����
%��  �룺
%       in_array    -----> �����ά���飨dim = 3����
%��  ����
%       out_array   -----> �����ά���飨dim = 3����
%��  ע��Matlab 2016a��
%----------------------------------------

%%

function out_array = Norm3d(in_array)

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
            vector = in_array(i, j, :);
            vector = reshape(vector, 1, size(vector, 3));
            
            % �������ά��ÿ������ͼ���ص�2����
            
            norm_vec = norm(vector, 2);
            
            % ��һ��
            if(norm_vec ~= 0)
                out_array(i, j, :) = 10 * in_array(i, j, :) / norm_vec;
            end
        end
    end
end
        