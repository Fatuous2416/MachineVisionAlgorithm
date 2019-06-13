function model = proposal_train2(conf, dataset, model, opts)
%% try to find trained model
    cache_dir = fullfile(model.cache_name, 'train');
    save_model_path = fullfile(cache_dir, 'final');
    if exist(save_model_path, 'file')
        model.output_model_file = save_model_path;
        return;
    end
%% init  

    mkdir_if_missing(cache_dir);
    caffe_log_file_base = fullfile(cache_dir, 'caffe_log');
    caffe.init_log(caffe_log_file_base);
    
    caffe_solver = caffe.Solver(model.solver_def_file);
    % shared layer �κи� �����Ѵ�(conv1 ~ conv5 ����)
    % ���������� prototxt������ ���� �̸��� ���� layer�� ����
    % C:\Program Files\caffe-master\src\caffe\caffe\net.cpp ����
    caffe_solver.net.copy_from(model.init_net_file);
    
    % init log
    timestamp = datestr(datevec(now()), 'yyyymmdd_HHMMSS');
    mkdir_if_missing(fullfile(cache_dir, 'log'));
    log_file = fullfile(cache_dir, 'log', ['train_', timestamp, '.txt']);
    diary(log_file);   
    
    % set random seed
    prev_rng = seed_rand(conf.rng_seed);
    caffe.set_random_seed(conf.rng_seed);
    
    % set gpu/cpu
    if conf.use_gpu
        caffe.set_mode_gpu();
    else
        caffe.set_mode_cpu();
    end
    
    disp('conf:');
    disp(conf);
    
    opts.empty_image_sample_step = 1;
    opts.fg_image_ratio = 0.5;
%% making tran/val data
    fprintf('Preparing training data...');
    % ������ �̹������� anchor���� �����ϰ�, ground truth���� IoU�� ����Ͽ�,
    % �� anchor���� positive sample���� negative sample���� �Ѵٿ� ������ �ʴ����� �����Ѵ�.
    
    % proposal_prepare_image_roidb ������ anchor-->ground truth �� target�� ���ϴ� �ݸ�,
    % fast_rcnn_prepare_image_roidb ������ proposal_test ���� ������ proposal�� �̿���
    % proposal-->ground truth�� target�� ���Ѵ�.
    
    % bbox_means,stds �� �̿��� normalized target�� �̿��� training �Ѵ�.
    % weight�� �����Ҷ����� bbox_means,stds�� �̿��� ���� target�� ��������, weight�� ���������ν�
    % (snapshot �Լ�) test�ÿ� ������ weight�� ����Ҽ� �ֵ�����
    [image_roidb_train, bbox_means, bbox_stds] = proposal_prepare_image_roidb(conf, dataset.imdb_train, dataset.roidb_train, opts.empty_image_sample_step);
    fprintf('Done.\n');
    
    if opts.do_val
        fprintf('Preparing validation data...');
        [image_roidb_val] = proposal_prepare_image_roidb(conf, dataset.imdb_test, dataset.roidb_test, opts.empty_image_sample_step, bbox_means, bbox_stds);
        fprintf('Done.\n');
    end
   
    
%%  try to train/val with images which have maximum size potentially, to validate whether the gpu memory is enough  
    check_gpu_memory(conf, caffe_solver, opts.do_val);
     
%% -------------------- Training -------------------- 

    proposal_generate_minibatch_fun = @proposal_generate_minibatch2;
    visual_debug_fun                = @proposal_visual_debug;

    % training
    shuffled_inds = [];
    train_results = [];
    val_results = [];
    iter_ = caffe_solver.iter();
    max_iter = caffe_solver.max_iter();
    
    top_val.lowest_error=1;
    top_val.corresponding_iter=0;
    while (iter_ < max_iter)
        caffe_solver.net.set_phase('train');

        % shuffled_inds���� �ϳ��� �̾� sub_db_inds�� �����Ѵ�.(sampling image)
        [shuffled_inds, sub_db_inds] = generate_random_minibatch(shuffled_inds, image_roidb_train, conf.ims_per_batch, opts.fg_image_ratio);        
        % sampling �� image���� mini-batch size���� anchor�� �̴´�.
        % �����δ� net_inputs{3}�� ���� 1�� ��찡 mini-batch sample�ΰ����� ����
        % positive sample�� net_inputs{2}�� ���� 1�� ����̴�.
        % negative sample�� net_inputs{3}�� ���� 1�� ��쿡�� net_inputs{2}�� ���� 1��
        % ��츦 ������ index
        [net_inputs, scale_inds] = proposal_generate_minibatch_fun(conf, image_roidb_train(sub_db_inds));
        
        caffe_solver.net.reshape_as_input(net_inputs);
        % ���� mini-batch �̹����� ����� �°� caffe.net�� reshape
        % one iter SGD update
        caffe_solver.net.set_input_data(net_inputs);% net_inputs�� �����͸� caffe.net.input layer(maybe gpu memory)�� ����
        caffe_solver.step(1);% forward, backward, update�� �Ѵ�.
        rst = caffe_solver.net.get_output();% accuracy,loss ���� ����
        rst = check_error(rst, caffe_solver);
        train_results = parse_rst(train_results, rst);
        % check_loss(rst, caffe_solver, net_inputs);

        % do valdiation per val_interval iterations
        if ~mod(iter_, opts.rpn_val_interval) 
            if opts.do_val
                val_results = do_validation(conf, caffe_solver, proposal_generate_minibatch_fun, image_roidb_val);
            end
            %err = 1-mean(val_results.accuracy_bg.data);
            err = mean(val_results.loss_cls.data);
            if(top_val.lowest_error>err)
                top_val.lowest_error=err;
                top_val.corresponding_iter=iter_;
            end
            show_state(iter_, train_results, val_results);% opts.val_interval(2000)���� val,train�� accuracy ����� ���
            train_results = [];
            diary; diary; % flush diary
            snapshot(conf, caffe_solver, bbox_means, bbox_stds, cache_dir, sprintf('iter_%d', iter_));
        end
        
        iter_ = caffe_solver.iter();% iter_ = iter_ + 1
    end
    % final validation
    if opts.do_val
        val_results=do_validation(conf, caffe_solver, proposal_generate_minibatch_fun, image_roidb_val);
    end
    err = mean(val_results.loss_cls.data);
    if(top_val.lowest_error>err)
        top_val.lowest_error=err;
        top_val.corresponding_iter=iter_;
    end
    show_state(iter_, train_results, val_results);% opts.val_interval(2000)���� val,train�� accuracy ����� ���
    diary; diary; % flush diary
    snapshot(conf, caffe_solver, bbox_means, bbox_stds, cache_dir, sprintf('iter_%d', iter_));
    %snapshot(conf, caffe_solver, bbox_means, bbox_stds, cache_dir, 'final');
    
    movefile(fullfile(cache_dir,sprintf('iter_%d', top_val.corresponding_iter)),fullfile(cache_dir,'final'));
    model.output_model_file=fullfile(cache_dir,'final');
    fprintf(sprintf('iter_%d is selected', top_val.corresponding_iter));
    
    diary off;
    caffe.reset_all(); 
    rng(prev_rng);
 
end

function val_results = do_validation(conf, caffe_solver, proposal_generate_minibatch_fun, image_roidb_val)
    val_results = [];

    caffe_solver.net.set_phase('test');
    for i = 1:length(image_roidb_val)
        [net_inputs, ~] = proposal_generate_minibatch_fun(conf, image_roidb_val(i));
        
        % Reshape net's input blobs
        caffe_solver.net.reshape_as_input(net_inputs);

        caffe_solver.net.forward(net_inputs);
        rst = caffe_solver.net.get_output();
        rst = check_error(rst, caffe_solver);  
        val_results = parse_rst(val_results, rst);
    end
end

function [shuffled_inds, sub_inds] = generate_random_minibatch(shuffled_inds, image_roidb, ims_per_batch, fg_image_ratio)

    % shuffle training data per batch
    if isempty(shuffled_inds)
        
        if ims_per_batch == 1
            % image_roidb ù��°�� bbox�� sparse matrix�� ������ ���� image_roidb(1)��
            % full�� �ٲ��ָ� �� kjh
            if(issparse( image_roidb(1).bbox_targets{1} ))
                image_roidb(1).bbox_targets{1}=full(image_roidb(1).bbox_targets{1});
            end
            empty_image_inds = arrayfun(@(x) sum(x.bbox_targets{1}(:, 1)==1) == 0, image_roidb, 'UniformOutput', true);
            nonempty_image_inds = ~empty_image_inds;
            empty_image_inds = find(empty_image_inds);
            nonempty_image_inds = find(nonempty_image_inds);
            
            if fg_image_ratio == 1 % ��� training image�� human�� �ϳ� �̻� �����ϵ���
                shuffled_inds = nonempty_image_inds;
            else
                if length(nonempty_image_inds) > length(empty_image_inds)
                    empty_image_inds = repmat(empty_image_inds, ceil(length(nonempty_image_inds) / length(empty_image_inds)), 1);
                    empty_image_inds = empty_image_inds(1:length(nonempty_image_inds));
                else
                    % ���� non-empty image�� �����ϸ� �ڽ��� �����ؼ� empty image ������ŭ �����.
                    nonempty_image_inds = repmat(nonempty_image_inds, ceil(length(empty_image_inds) / length(nonempty_image_inds)), 1);
                    nonempty_image_inds = nonempty_image_inds(1:length(empty_image_inds));
                end
                % empty image�� (1-fg_image_ratio) ��ŭ�� random���� ��������,
                % non-empty image�� (fg_image_ratio)��ŭ �����´�.
                empty_image_inds = empty_image_inds(randperm(length(empty_image_inds), round(length(empty_image_inds) * (1 - fg_image_ratio))));
                nonempty_image_inds = nonempty_image_inds(randperm(length(nonempty_image_inds), round(length(nonempty_image_inds) * fg_image_ratio)));
                
                shuffled_inds = [nonempty_image_inds; empty_image_inds];
            end
            
            shuffled_inds = shuffled_inds(randperm(size(shuffled_inds, 1)));
            shuffled_inds = num2cell(shuffled_inds, 2);
            
        else
            
            % make sure each minibatch, contain half (or half+1) gt-nonempty
            % image, and half gt-empty image
            empty_image_inds = arrayfun(@(x) sum(x.bbox_targets{1}(:, 1)==1) == 0, image_roidb, 'UniformOutput', true);
            nonempty_image_inds = ~empty_image_inds;
            empty_image_inds = find(empty_image_inds);
            nonempty_image_inds = find(nonempty_image_inds);
            
            empty_image_per_batch = floor(ims_per_batch / 2);
            nonempty_image_per_batch = ceil(ims_per_batch / 2);
            
            % random perm
            lim = floor(length(nonempty_image_inds) / nonempty_image_per_batch) * nonempty_image_per_batch;
            nonempty_image_inds = nonempty_image_inds(randperm(length(nonempty_image_inds), lim));
            nonempty_image_inds = reshape(nonempty_image_inds, nonempty_image_per_batch, []);
            if numel(empty_image_inds) >= lim
                empty_image_inds = empty_image_inds(randperm(length(nonempty_image_inds), empty_image_per_batch*lim/nonempty_image_per_batch));
            else
                empty_image_inds = empty_image_inds(mod(randperm(lim, empty_image_per_batch*lim/nonempty_image_per_batch), length(empty_image_inds))+1);
            end
            empty_image_inds = reshape(empty_image_inds, empty_image_per_batch, []);
            
            % combine sample for each ims_per_batch
            empty_image_inds = reshape(empty_image_inds, empty_image_per_batch, []);
            nonempty_image_inds = reshape(nonempty_image_inds, nonempty_image_per_batch, []);
            
            shuffled_inds = [nonempty_image_inds; empty_image_inds];
            shuffled_inds = shuffled_inds(:, randperm(size(shuffled_inds, 2)));
            
            shuffled_inds = num2cell(shuffled_inds, 1);
        end
    end
    
    if nargout > 1
        % generate minibatch training data
        sub_inds = shuffled_inds{1};
        assert(length(sub_inds) == ims_per_batch);
        shuffled_inds(1) = [];
    end
end

function rst = check_error(rst, caffe_solver)

    cls_score = caffe_solver.net.blobs('proposal_cls_score_reshape').get_data();
    labels = caffe_solver.net.blobs('labels_reshape').get_data();
    labels_weights = caffe_solver.net.blobs('labels_weights_reshape').get_data();
    
    accurate_fg = (cls_score(:, :, 2) > cls_score(:, :, 1)) & (labels == 1);
    accurate_bg = (cls_score(:, :, 2) <= cls_score(:, :, 1)) & (labels == 0);
    accurate = accurate_fg | accurate_bg;
    accuracy_fg = sum(accurate_fg(:) .* labels_weights(:)) / (sum(labels_weights(labels == 1)) + eps);
    accuracy_bg = sum(accurate_bg(:) .* labels_weights(:)) / (sum(labels_weights(labels == 0)) + eps);
    
    rst(end+1) = struct('blob_name', 'accuracy_fg', 'data', accuracy_fg);
    rst(end+1) = struct('blob_name', 'accuracy_bg', 'data', accuracy_bg);
end

function check_gpu_memory(conf, caffe_solver, do_val)
%%  try to train/val with images which have maximum size potentially, to validate whether the gpu memory is enough  

    % generate pseudo training data with max size
    im_blob = single(zeros(max(conf.scales), conf.max_size, 3, 3));% conf.ims_per_batch -->3 (0628)
    
    anchor_num = size(conf.anchors, 1);
    output_width = conf.output_width_map.values({size(im_blob, 1)});
    output_width = output_width{1};
    output_height = conf.output_width_map.values({size(im_blob, 2)});
    output_height = output_height{1};
    labels_blob = single(zeros(output_width, output_height, anchor_num, conf.ims_per_batch));
    labels_weights = labels_blob;
    bbox_targets_blob = single(zeros(output_width, output_height, anchor_num*4, conf.ims_per_batch));
    bbox_loss_weights_blob = bbox_targets_blob;

    net_inputs = {im_blob, labels_blob, labels_weights, bbox_targets_blob, bbox_loss_weights_blob};
    
     % Reshape net's input blobs
    caffe_solver.net.reshape_as_input(net_inputs);

    % one iter SGD update
    caffe_solver.net.set_input_data(net_inputs);
    caffe_solver.step(1);

    if do_val
        % use the same net with train to save memory
        caffe_solver.net.set_phase('test');
        caffe_solver.net.forward(net_inputs);
        caffe_solver.net.set_phase('train');
    end
end

function model_path = snapshot(conf, caffe_solver, bbox_means, bbox_stds, cache_dir, file_name)
% proposal_bbox_pred layer�� weight���� mean�� std�� ���ϰ� ���Ͽ� �ϵ��ũ�� save�Ѵ�.(������ ���ְ� ������
% ������ �н��߱� ������) �׸��� ���� weight��(weight_back)�� ����� ������� �����.
% conv1~relu5~proposal_bbox_pred ������ weight�� ����
    anchor_size = size(conf.anchors, 1);
    bbox_stds_flatten = repmat(reshape(bbox_stds', [], 1), anchor_size, 1);
    bbox_means_flatten = repmat(reshape(bbox_means', [], 1), anchor_size, 1);
    
    % merge bbox_means, bbox_stds into the model
    bbox_pred_layer_name = 'proposal_bbox_pred';
    weights = caffe_solver.net.params(bbox_pred_layer_name, 1).get_data();
    biase = caffe_solver.net.params(bbox_pred_layer_name, 2).get_data();
    weights_back = weights;
    biase_back = biase;
    
    % wx+b = (y-m)/s , where w:weight x:input b:bias y:output m:mean s:sigma
    % (sw)x+sb+m = y , y�� normalize �Ǳ����� target
    weights = bsxfun(@times, weights, permute(bbox_stds_flatten, [2, 3, 4, 1])); % weights = weights * stds; 
    biase = biase .* bbox_stds_flatten + bbox_means_flatten; % bias = bias * stds + means;
    
    caffe_solver.net.set_params_data(bbox_pred_layer_name, 1, weights);
    caffe_solver.net.set_params_data(bbox_pred_layer_name, 2, biase);
    
    model_path = fullfile(cache_dir, file_name);
    caffe_solver.net.save(model_path);
    fprintf('Saved as %s\n', model_path);
    
    % restore net to original state
    caffe_solver.net.set_params_data(bbox_pred_layer_name, 1, weights_back);
    caffe_solver.net.set_params_data(bbox_pred_layer_name, 2, biase_back);
end

function show_state(iter, train_results, val_results)
    fprintf('\n------------------------- Iteration %d -------------------------\n', iter);
    fprintf('Training : err_fg %.3g, err_bg %.3g, loss (cls %.3g + reg %.3g)\n', ...
        1 - mean(train_results.accuracy_fg.data), 1 - mean(train_results.accuracy_bg.data), ...
        mean(train_results.loss_cls.data), ...
        mean(train_results.loss_bbox.data));
    if exist('val_results', 'var') && ~isempty(val_results)
        fprintf('Testing  : err_fg %.3g, err_bg %.3g, loss (cls %.3g + reg %.3g)\n', ...
            1 - mean(val_results.accuracy_fg.data), 1 - mean(val_results.accuracy_bg.data), ...
            mean(val_results.loss_cls.data), ...
            mean(val_results.loss_bbox.data));
    end
end

function check_loss(rst, caffe_solver, input_blobs)
    im_blob = input_blobs{1};
    labels_blob = input_blobs{2};
    label_weights_blob = input_blobs{3};
    bbox_targets_blob = input_blobs{4};
    bbox_loss_weights_blob = input_blobs{5};
    
    regression_output = caffe_solver.net.blobs('proposal_bbox_pred').get_data();
    % smooth l1 loss
    regression_delta = abs(regression_output(:) - bbox_targets_blob(:));
    regression_delta_l2 = regression_delta < 1;
    regression_delta = 0.5 * regression_delta .* regression_delta .* regression_delta_l2 + (regression_delta - 0.5) .* ~regression_delta_l2;
    regression_loss = sum(regression_delta.* bbox_loss_weights_blob(:)) / size(regression_output, 1) / size(regression_output, 2);
    
    confidence = caffe_solver.net.blobs('proposal_cls_score_reshape').get_data();
    labels = reshape(labels_blob, size(labels_blob, 1), []);
    label_weights = reshape(label_weights_blob, size(label_weights_blob, 1), []);
    
    confidence_softmax = bsxfun(@rdivide, exp(confidence), sum(exp(confidence), 3));
    confidence_softmax = reshape(confidence_softmax, [], 2);
    confidence_loss = confidence_softmax(sub2ind(size(confidence_softmax), 1:size(confidence_softmax, 1), labels(:)' + 1));
    confidence_loss = -log(confidence_loss);
    confidence_loss = sum(confidence_loss' .* label_weights(:)) / sum(label_weights(:));
    
    results = parse_rst([], rst);
    fprintf('C++   : conf %f, reg %f\n', results.loss_cls.data, results.loss_bbox.data);
    fprintf('Matlab: conf %f, reg %f\n', confidence_loss, regression_loss);
end