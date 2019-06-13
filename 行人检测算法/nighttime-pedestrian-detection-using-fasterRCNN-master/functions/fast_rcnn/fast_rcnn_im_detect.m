function [pred_boxes, scores] = fast_rcnn_im_detect(conf, caffe_net, im, boxes, max_rois_num_in_gpu)
% [pred_boxes, scores] = fast_rcnn_im_detect(conf, caffe_net, im, boxes, max_rois_num_in_gpu)
% --------------------------------------------------------
% Fast R-CNN
% Reimplementation based on Python Fast R-CNN (https://github.com/rbgirshick/fast-rcnn)
% Copyright (c) 2015, Shaoqing Ren
% Licensed under The MIT License [see LICENSE for details]
% --------------------------------------------------------

    [im_blob, rois_blob, ~] = get_blobs(conf, im, boxes);
    
    % When mapping from image ROIs to feature map ROIs, there's some aliasing
    % (some distinct image ROIs get mapped to the same feature ROI).
    % Here, we identify duplicate feature ROIs, so we only compute features
    % on the unique subset.
    [~, index, inv_index] = unique(rois_blob, 'rows');
    % boxes�� scale �Ǳ� ���� rois �̰�, rois_blob�� scale ������ rois ��ǥ
    rois_blob = rois_blob(index, :);
    boxes = boxes(index, :);
    % ���° image�� rois������ ǥ���ϴ� ù��° ������ ��� 0�� �־ �� �̹��������� rois ���� ǥ��
    % 1�� �־��� ������ �ؿ��� 1�� �������ν� 0�� �ǵ��� �ϱ����ؼ�
    rois_blob = [ones(length(index),1), rois_blob];
    
    % permute data into caffe c++ memory, thus [num, channels, height, width]
    im_blob = im_blob(:, :, [3, 2, 1], :); % from rgb to brg
    im_blob = permute(im_blob, [2, 1, 3, 4]);
    im_blob = single(im_blob);
    
    rois_blob = rois_blob - 1; % to c's index (start from 0)
    rois_blob = permute(rois_blob, [3, 4, 2, 1]);
    rois_blob = single(rois_blob);
    
    net_inputs = {im_blob, rois_blob};

    % Reshape net's input blobs
    caffe_net.reshape_as_input(net_inputs);
    output_blobs = caffe_net.forward(net_inputs);

    % use softmax estimated probabilities
    scores = output_blobs{2};
    scores = squeeze(scores)';

    % Apply bounding-box regression deltas
    box_deltas = output_blobs{1};
    box_deltas = squeeze(box_deltas)';
      
    
    % scaled roi, unscaled target���� training �����Ƿ�,
    % test�� scaled roi�� ������ unscaled target�� ���´�.
    % ����, unscaled roi�� boxes�� unscaled target�� box_deltas�� pred�� ����
    pred_boxes = fast_rcnn_bbox_transform_inv(boxes, box_deltas);
    pred_boxes = clip_boxes(pred_boxes, size(im, 2), size(im, 1));

    % Map scores and predictions back to the original set of boxes
    scores = scores(inv_index, :);
    pred_boxes = pred_boxes(inv_index, :);
    
    % remove scores and boxes for back-ground
    % multi-class�� ��쿡�� �ʿ��ѵ�
%     pred_boxes = pred_boxes(:, 5:end);
%     scores = scores(:, 2:end);
end

function [data_blob, rois_blob, im_scale_factors] = get_blobs(conf, im, rois)
    [data_blob, im_scale_factors] = get_image_blob(conf, im);
    rois_blob = get_rois_blob(conf, rois, im_scale_factors);
end

function [blob, im_scales] = get_image_blob(conf, im)
    [ims, im_scales] = arrayfun(@(x) prep_im_for_blob(im, conf.image_means, x, conf.test_max_size), conf.test_scales, 'UniformOutput', false);
    im_scales = cell2mat(im_scales);
    blob = im_list_to_blob(ims);    
end

function [rois_blob] = get_rois_blob(conf, im_rois, im_scale_factors)
    [feat_rois, levels] = map_im_rois_to_feat_rois(conf, im_rois, im_scale_factors);
    rois_blob = feat_rois;
    %rois_blob = single([levels, feat_rois]); % ���� �ϳ� �߰��Ǵµ� ���ʿ��غ���
end

function [feat_rois, levels] = map_im_rois_to_feat_rois(conf, im_rois, scales)
    im_rois = single(im_rois);
    
    if length(scales) > 1
        widths = im_rois(:, 3) - im_rois(:, 1) + 1;
        heights = im_rois(:, 4) - im_rois(:, 2) + 1;
        
        areas = widths .* heights;
        scaled_areas = bsxfun(@times, areas(:), scales(:)'.^2);
        [~, levels] = min(abs(scaled_areas - 224.^2), [], 2); 
    else
        levels = ones(size(im_rois, 1), 1);
    end
    
    feat_rois = round(bsxfun(@times, im_rois-1, scales(levels))) + 1;
end

function boxes = clip_boxes(boxes, im_width, im_height)
    % x1 >= 1 & <= im_width
    boxes(:, 1:4:end) = max(min(boxes(:, 1:4:end), im_width), 1);
    % y1 >= 1 & <= im_height
    boxes(:, 2:4:end) = max(min(boxes(:, 2:4:end), im_height), 1);
    % x2 >= 1 & <= im_width
    boxes(:, 3:4:end) = max(min(boxes(:, 3:4:end), im_width), 1);
    % y2 >= 1 & <= im_height
    boxes(:, 4:4:end) = max(min(boxes(:, 4:4:end), im_height), 1);
end
    