% @return detection info, indexed as detectionDetails(img, detectionID)
function detectionDetails = demo_sensys_dataset()
    load('sensys_models/car_final.mat');
    inputDir = './Dir_2_Lane_3_285';
    outputDir = [inputDir '_detections'];
    unix(['mkdir -p ' outputDir]); %create directory if it doesn't already exist

    files = dir([inputDir '/*.jpg']);
    files = files(1:5:length(files)); %skip all but 1 out of every 5 images
    detectionDetails = [];
    img_id = 1;
    for img = files'
        display(img.name)
        inImgName = [inputDir '/' img.name];
        [pathstr, name, ext] = fileparts(inImgName);

        im = imread(inImgName);
        %note: can tune model.thresh to vary precision/recall tradeoff
        [dets, boxes, trees, root_filters] = imgdetect_forTracking(im, model, model.thresh);

        nms_thresh = 0.3; %for neighboring detections, this is the max allowed bounding box percent overlap (for non-maximal suppression)
        outputDir_nms_thresh = [outputDir '_nms_' num2str(nms_thresh)];
        unix(['mkdir -p ' outputDir_nms_thresh]); %create directory if it doesn't already exist
        outImgName =  [outputDir_nms_thresh '/' img.name];
        outCsvName = [outputDir_nms_thresh '/' name '.csv'];

        current_detectionDetails = postprocess_and_vis(nms_thresh, dets, boxes, root_filters, im, img_id, img.name, outImgName, outCsvName, model); 
        detectionDetails = [detectionDetails current_detectionDetails] 
        save('detectionDetails.mat', 'detectionDetails');
        img_id = img_id + 1;
    end
end

%Output data structure -- detectionDetails:
%           img_name
%           img_id
%           bbox
%           bbox_hog_descriptor
%           dpm_hog_descriptor
%           dpm_orientation_id

% @return detectionDetails struct for all detections in the current image
% write to file: bounding boxes in CSV format and images with bboxes displayed
function detectionDetails = postprocess_and_vis(nms_thresh, dets, boxes, root_filters, im, img_id, img_name, outImgName, outCsvName, model)
    detectionDetails = [];
    %try % do nonmax suppression and display detected objects
        top = nms(dets, nms_thresh); %nonmax suppression (precision vs recall tradeoff)
        theBoxes = reduceboxes(model, boxes);
        rootBoxes = int32(theBoxes(:, 1:4)); %bounding box for whole objects -- ignore part filters. (1:4 is x1 y1 x2 y2 for root box)
        [rootBoxes, top] = removeContainedBboxes(rootBoxes, top);
        root_filters = root_filters(top);
        components_used = dets(top, 5); %component (orientation and associated sub-model) ID
 
        for i=1:length(rootBoxes(:,1))
            dpm_hog_descriptor = model_get_root_filter(components_used(i), model);
            detectionDetails = [detectionDetails struct('img_name', img_name, 'img_id', img_id, 'bbox', rootBoxes(i,:), 'bbox_hog_descriptor', root_filters(i).f, 'dpm_hog_descriptor', dpm_hog_descriptor, 'dpm_orientation_id', components_used(i))];
        end

        csvwrite(outCsvName, rootBoxes);
        showboxes(im, rootBoxes); %doesn't need for the image to already be displayed.
        print(gcf, '-djpeg90', '-r0', outImgName);
    %catch %no detections above nms threshold
    %    display('no detections')
    %    image(im);
    %    print(gcf, '-djpeg90', '-r0', outImgName);
    %end
end

%get HOG descriptor for a specific DPM model component
%   modified from visualizemodel.m
function filter = model_get_root_filter(componentIdx, model)
    rhs = model.rules{model.start}(componentIdx).rhs;
    layer = 1;
    rootIdx = -1;
    % assume the root filter is first on the rhs of the start rules
    if model.symbols(rhs(1)).type == 'T' % handle case where there's no deformation model for the root
      rootIdx = model.symbols(rhs(1)).filter;
    else % handle case where there is a deformation model for the root
      rootIdx = model.symbols(model.rules{rhs(1)}(layer).rhs).filter;
    end
    filter = model_get_block(model, model.filters(rootIdx));
end

%when a larger bounding box fully contains a smaller box, remove the larger box
%param boxes: [x1 y1 x2 y2; x1 y1 x2 y2; ...] -- input ALL boxes, not just the top ones.
function [boxes, top] = removeContainedBboxes(boxes, top)
    newBoxes = [];
    newTop = [];
    for i=top' %only keep box "i" if it doesn't contain an other box
        containsOtherBoxes = 0;
        for j=top'
            if i ~= j
                x1_i = boxes(i,1); y1_i = boxes(i,2); x2_i = boxes(i,3); y2_i = boxes(i,4);
                x1_j = boxes(j,1); y1_j = boxes(j,2); x2_j = boxes(j,3); y2_j = boxes(j,4);
                if(x1_i < x1_j && x2_i > x2_j && y1_i < y1_j && y2_i > y2_j)
                    containsOtherBoxes = 1; %i contains j, and possibly other boxes too
                end
            end
        end
        if containsOtherBoxes == 0
            newBoxes = [newBoxes; boxes(i,1:4)];
            newTop = [newTop; i];
        end
    end
    boxes = newBoxes;
    top = newTop;
end


