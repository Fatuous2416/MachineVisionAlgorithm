%% 
%-----------Transform_Input-------------
%��  �ߣ��
%��  ˾��BJTU
%��  �ܣ��������ݴ���㡣
%��  �룺
%       in_img      -----> ����ͼ��dim = 3����
%       varargin    -----> �ɱ����롣
%                        |----> 2BGR��BGRת�����ء�
%                        |----> mean����ֵ��
%                        |----> resize��ͼ���С������
%��  ����
%       out_img     -----> ���ͼ��dim = 3����
%��  ע��Matlab 2016a��
%----------------------------------------

%%

function out_img = Transform_Input(in_img, varargin)

    % �����������
    if(mod(nargin, 2) == 0 && nargin > 7)
        error('������������������������');
    else
        BGR_flag = false;
        im_mean = [];
        im_size = [];
        for i = 1: 2: 5
            switch varargin{i}
                case '2BGR'
                    BGR_flag = varargin{i + 1};
                case 'mean'
                    im_mean = varargin{i + 1};
                case 'resize'
                    im_size = varargin{i + 1};
                otherwise
                    error('δ֪�ֶΣ���鿴������˵����')
            end
        end
    end
    
    % ��������ת����
    in_img = im2double(in_img);
    
    % ����ͼ��ߴ������
    if(~isempty(im_size))       
        out_img = imresize(255 * in_img, im_size);
    else
        out_img = in_img;
    end

    % RGB 2 BGR��
    if(BGR_flag == true)
        out_img = out_img(:,:, [3,2,1]);
    end

    % ����ֵ��
    if(~isempty(im_mean))
        if(BGR_flag == true)
            out_img(:, :, 1) = out_img(:, :, 1) - im_mean(3);
            out_img(:, :, 2) = out_img(:, :, 2) - im_mean(2);
            out_img(:, :, 3) = out_img(:, :, 3) - im_mean(1);
        else
            out_img(:, :, 1) = out_img(:, :, 1) - im_mean(1);
            out_img(:, :, 2) = out_img(:, :, 2) - im_mean(2);
            out_img(:, :, 3) = out_img(:, :, 3) - im_mean(3);
        end
    end
end