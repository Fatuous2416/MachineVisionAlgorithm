function anchors = proposal_generate_anchors(cache_name)
% anchors = proposal_generate_anchors(cache_name, varargin)
% --------------------------------------------------------
% Faster R-CNN
% Copyright (c) 2015, Shaoqing Ren
% Licensed under The MIT License [see LICENSE for details]
% --------------------------------------------------------

    % following "Is Faster R-CNN Doing Well for Pedestrian Detection?.pdf"
    start_h=40;
    ratio=0.41;
    scale=1.3;
    
    mkdir_if_missing(cache_name);
    anchor_cache_file = fullfile(cache_name, 'anchors');

    try
        ld                      = load(anchor_cache_file);
        anchors                 = ld.anchors;
    catch
        base_anchor = [1, 1, start_h*ratio, start_h];
        base_w = base_anchor(3) - base_anchor(1) + 1;
        base_h = base_anchor(4) - base_anchor(2) + 1;
        % base anchor�� ������ ã�´�.
        x_ctr = base_anchor(1) + (base_w - 1) / 2;
        y_ctr = base_anchor(2) + (base_h - 1) / 2;
        anchors=base_anchor;
        
        for i=1:8
            w=base_w*1.3^i;
            h=base_h*1.3^i;
            anchor = [x_ctr - (w - 1) / 2, y_ctr - (h - 1) / 2,...
                      x_ctr + (w - 1) / 2, y_ctr + (h - 1) / 2];
            anchors=[anchors; anchor];
        end
        
        anchors=round(anchors);
        save(anchor_cache_file, 'anchors');
    end
    
    %     visualize 9 anchors
%     xywh=[anchors(:,1),anchors(:,2),anchors(:,3)-anchors(:,1),anchors(:,4)-anchors(:,2)];
% 
%     xmin=min(anchors(:,1));
%     xmax=max(anchors(:,3));
%     ymin=min(anchors(:,2));
%     ymax=max(anchors(:,4));
% 
%     figure(1); 
%     hold on; 
%     enough_axis=[-200 200 -200 200];
%     axis(enough_axis)
%     for i=1:size(anchors,1)
%         rectangle('Position',xywh(i,:));
%     end
end

function anchors = ratio_jitter(anchor, ratios)
% base size�� ��������(1:1), ���μ��� ����(ratio)�� 1:2,2:1 anchor�� ����
% ���� ��Ī���� anchor�� ������ �ʴ´�.
    ratios = ratios(:);
    
    %base anchor�� w,h�� ���Ѵ�.
    w = anchor(3) - anchor(1) + 1;
    h = anchor(4) - anchor(2) + 1;
    % base anchor�� ������ ã�´�.
    x_ctr = anchor(1) + (w - 1) / 2;% ctr --> center
    y_ctr = anchor(2) + (h - 1) / 2;
    size = w * h;
    
    %���̸� �̿��Ͽ� w�� ���ϰ�, w�� ratio�� ���� h�� ���Ѵ�.
    size_ratios = size ./ ratios;
    ws = round(sqrt(size_ratios));
    hs = round(ws .* ratios);
    
    % 1 scale�� anchor 3���� ���Ѵ�.
    anchors = [x_ctr - (ws - 1) / 2, y_ctr - (hs - 1) / 2, x_ctr + (ws - 1) / 2, y_ctr + (hs - 1) / 2];
end

function anchors = scale_jitter(anchor, scales)
    scales = scales(:);

    w = anchor(3) - anchor(1) + 1;
    h = anchor(4) - anchor(2) + 1;
    x_ctr = anchor(1) + (w - 1) / 2;
    y_ctr = anchor(2) + (h - 1) / 2;

    ws = w * scales;
    hs = h * scales;
    
    % ������ �������� scale�� ���� w,h�� �����Ͽ� anchor�� ���Ѵ�.
    anchors = [x_ctr - (ws - 1) / 2, y_ctr - (hs - 1) / 2, x_ctr + (ws - 1) / 2, y_ctr + (hs - 1) / 2];
end

