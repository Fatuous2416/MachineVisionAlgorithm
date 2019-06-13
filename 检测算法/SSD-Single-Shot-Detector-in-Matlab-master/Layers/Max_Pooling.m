%% 
%---------------Max_Pooling--------------
%��  �ߣ��
%��  ˾��BJTU
%��  �ܣ����ػ���
%��  �룺
%       in_array    -----> �����ά���飨dim = 3����
%       window_size -----> �ػ����ڴ�С��
%       stride      -----> ������
%       padding     -----> �����������
%��  ����
%       out_array   -----> �����ά���飨dim = 3����
%��  ע��Matlab 2016a��
%----------------------------------------

%%

function out_array = Max_Pooling(in_array, window_size, stride, padding)
    
    % �������ά��    
    in_dims = ndims(in_array);
    if(in_dims == 3)
        [height, width, depth] = size(in_array);
    else
        error('��������ά��С��3ά�������������ݡ�');
    end
    
    % ���
    if(padding ~= 0)
        n_height = height + 2 * padding;
        n_width = width + 2 * padding;
    else
        n_height = height + mod(height, stride);
        n_width = width + mod(width, stride);
    end
    
    pad_in_array = zeros(n_height, n_width, depth);    
    pad_in_array(1 + padding: padding + width, 1 + padding: padding + height, :)...
        = in_array;
    
    % ȷ�������С
    o_height = floor((n_height - window_size) / stride + 1);
    o_width = floor((n_width - window_size) / stride + 1);
    out_array = zeros(o_height, o_width, depth);
    
    % im2col
    cidx = (0: window_size - 1)'; 
    ridx = 1: o_height;
    t = cidx(:, ones(o_height, 1)) + 1 + stride * (ridx(ones(window_size, 1),:) - 1);
    tt = zeros(window_size ^ 2, o_height);
    rows = 1: window_size;
    for a = 0: window_size - 1
        tt(a * window_size + rows, :) = t + n_height * a;
    end
    ttt = zeros(window_size ^ 2, o_height * o_width);
    cols = 1: o_height;
    for b = 0: o_width - 1
        ttt(:,b * o_height + cols) = tt + stride * n_height * b;
    end
    tttt = zeros(window_size ^ 2, o_height * o_width * depth);
    chanls = 1: o_height * o_width;
    for c = 0: depth - 1
        tttt(:, c * o_height * o_width + chanls) = ...
            ttt + n_height * n_width * c;
    end
    in_array_ = pad_in_array(tttt);  
    out_array = reshape(max(in_array_), o_height, o_width, depth);

    
%     % ���ڻ���
%     for i = 1 : stride: n_height - window_size + 1
%         for j = 1 : stride: n_width - window_size + 1
% 
%             % ��ȡͼ���
%             block = pad_in_array(i: i + window_size - 1, ...
%                 j: j + window_size - 1, :);
%             
%             for k = 1: depth
%                 out_array(1 + (i - 1) / stride, 1 + (j - 1) / stride, k) = ...
%                     max(max(block(:, :, k)));
%             end
%         end
%     end
end