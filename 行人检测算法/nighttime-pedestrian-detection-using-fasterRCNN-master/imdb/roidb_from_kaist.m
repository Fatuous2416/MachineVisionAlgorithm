function roidb = roidb_from_kaist(imdb, flip)
% roidb = roidb_from_caltech(imdb, flip)
%   Package the roi annotations into the imdb. 
%
%   Inspired by Ross Girshick's imdb and roidb code.

% AUTORIGHTS
% ---------------------------------------------------------
% Copyright (c) 2014, Ross Girshick
% 
% This file is part of the R-CNN code and is available 
% under the terms of the Simplified BSD License provided in 
% LICENSE. Please retain this notice and LICENSE if you use 
% this file (or any portion of it) in your project.
% ---------------------------------------------------------

roidb.name = imdb.name;

anno_path = ['./datasets/kaist/' roidb.name '/annotations'];
% prop_path = ['./datasets/caltech/' roidb.name '/proposals'];

addpath(genpath('D:\imageSet\code3.2.1'));
addpath(genpath('D:\imageSet\toolbox'));
% lbls�� gt, ilbls�� ignore, squarify�� �°� bounding box�� reshape
pLoad={'lbls',{'person'},'ilbls',{'people','person?','cyclist'},'squarify',{3,.41}};
% height�� 50<height<inf ����
pLoad = [pLoad 'hRng',[50 inf], 'vRng',[1 1] ]; % reasonable setting

if flip
    cache_file = ['./imdb/cache/roidb_kaist_' imdb.name '_flip'];
else
    cache_file = ['./imdb/cache/roidb_kaist_' imdb.name];
end
cache_file = [cache_file, '.mat'];
try
  load(cache_file);
catch
  roidb.name = imdb.name;

  fprintf('Loading region proposals...');
%   regions = [];

  regions = [];
  
%   if exist(prop_path, 'dir')
%       regions = load_proposals(imdb, prop_path, pLoad);
%   end
  
  fprintf('done\n');
  if isempty(regions)
      fprintf('Warrning: no windows proposal is loaded !\n');
      regions.boxes = cell(length(imdb.image_ids), 1);
  end
  
  height = imdb.sizes(1,1);
  width = imdb.sizes(1,2);
  files=bbGt('getFiles',{anno_path});% annotation ���� �̸����� ��� files�� ����
  num_gts = 0;
  num_gt_no_ignores = 0;
  for i = 1:length(files)
      tic_toc_print('%d / %d\n', i, length(files));
      [~,gts]=bbGt('bbLoad',files{i},pLoad); % gts: [nx5] array containg ground truth bbs [x y w h ignore]
      ignores = gts(:,end);
      num_gts  = num_gts + length(ignores);
      num_gt_no_ignores  = num_gt_no_ignores + (length(ignores)-sum(ignores));
      
      if flip
          % for ori
          x1 = gts(:,1);
          y1 = gts(:,2);
          x2 = gts(:,1) + gts(:,3);
          y2 = gts(:,2) + gts(:,4);
          gt_boxes = [x1 y1 x2 y2];
          roidb.rois(i*2-1) = attach_rois(regions.boxes{i}, gt_boxes, ignores);
          
          % for flip
          x1_flip = width - gts(:,1) - gts(:,3);
          y1_flip = y1;
          x2_flip = width - gts(:,1);
          y2_flip = y2;
          gt_boxes_flip = [x1_flip y1_flip x2_flip y2_flip];
          roidb.rois(i*2) = attach_rois(regions.boxes{i}, gt_boxes_flip, ignores);
          

      else
          % for ori
          x1 = gts(:,1);
          y1 = gts(:,2);
          x2 = gts(:,1) + gts(:,3);
          y2 = gts(:,2) + gts(:,4);
          gt_boxes = [x1 y1 x2 y2]; % [xmin, ymin, xmax, ymax]
          roidb.rois(i) = attach_rois(regions.boxes{i}, gt_boxes, ignores); 
      end
%       if 1
%           % debugging visualizations
%           im = imread(imdb.image_at(i));
%           t_boxes = roidb.rois(i).boxes;
%           for k = 1:size(t_boxes, 1)
%               showboxes(im, t_boxes(k,1:4));
%               title(sprintf('%s, ignore: %d\n', imdb.image_ids{i}, roidb.rois(i).ignores(k)));
%               pause;
%           end
%       end
  end
  

  fprintf('Saving roidb to cache...');
  save(cache_file, 'roidb', '-v7.3');
  fprintf('done\n');
  
  fprintf('num_gt / num_ignore %d / %d \n', num_gt_no_ignores, num_gts);
end


% ------------------------------------------------------------------------
function rec = attach_rois(boxes, gt_boxes, ignores)
% ------------------------------------------------------------------------

%           gt: [2108x1 double]
%      overlap: [2108x20 single]
%      dataset: 'voc_2007_trainval'
%        boxes: [2108x4 single]
%         feat: [2108x9216 single]
%        class: [2108x1 uint8]


all_boxes = cat(1, gt_boxes, boxes);
gt_classes = ones(size(gt_boxes, 1), 1); % set pedestrian label as 1
num_gt_boxes = size(gt_boxes, 1);

num_boxes = size(boxes, 1);

rec.gt = cat(1, true(num_gt_boxes, 1), false(num_boxes, 1));
rec.overlap = zeros(num_gt_boxes+num_boxes, 1, 'single');
for i = 1:num_gt_boxes
  rec.overlap(:, gt_classes(i)) = ...
      max(rec.overlap(:, gt_classes(i)), boxoverlap(all_boxes, gt_boxes(i, :)));
end
rec.boxes = single(all_boxes);
rec.feat = [];
rec.class = uint8(cat(1, gt_classes, zeros(num_boxes, 1)));

rec.ignores = ignores;
