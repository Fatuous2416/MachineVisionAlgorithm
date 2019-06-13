%% 
%--------------Truing_Box---------------
%��  �ߣ��
%��  ˾��BJTU
%��  �ܣ�����Prior Box��
%��  �룺
%       priorbox        -----> Ĭ�Ͽ�
%       loc             -----> ������Ϣ��
%��  ����
%��  ע��Matlab 2016a��
%----------------------------------------

%%

function box = Truing_Box(priorbox, loc)

    % �������ά��    
    in_dims = ndims(priorbox);
    if(in_dims == 3)
        [height, width, depth] = size(priorbox);
    else
        error('��������ά��С��3ά�������������ݡ�');
    end
    
    box = zeros(height, width, depth);
    
    for k = 1: 4: depth
        
        cenx = 0.5 * (priorbox(:, :, k) + priorbox(:, :, k + 2));
        ceny = 0.5 * (priorbox(:, :, k + 1) + priorbox(:, :, k + 3));        
        width = priorbox(:, :, k + 2) - priorbox(:, :, k);
        height = priorbox(:, :, k + 3) - priorbox(:, :, k + 1);
        
        cenx = 0.1 * loc(:, :, k) .* width + cenx;
        ceny = 0.1 * loc(:, :, k + 1) .* height + ceny;
        width = exp(0.2 * loc(:, :, k + 2)) .* width;
        height = exp(0.2 * loc(:, :, k + 3)) .* height;
        
        box(:, :, k) = max(cenx - width / 2, 0);
        box(:, :, k + 1) = max(ceny - height / 2, 0);
        box(:, :, k + 2) = min(cenx + width / 2, 1);
        box(:, :, k + 3) = min(ceny + height / 2, 1);
    end