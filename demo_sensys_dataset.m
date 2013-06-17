%Output data structure -- detectionDetails:
%           img_name
%           img_id
%           bbox
%           bbox_hog_descriptor
%           dpm_hog_descriptor
%           dpm_orientation_id

% @return detection info, indexed as detectionDetails(img, detectionID)
function detectionDetails = demo_sensys_dataset()
    nms_thresh = 0.3; %for neighboring detections, this is the max allowed bounding box percent overlap (for non-maximal suppression)
    load('sensys_models/car_final.mat');
    inputDir = './Dir_2_Lane_3_285';
    outputDir = [inputDir '_detections'];
    unix(['mkdir -p ' outputDir]); %create directory if it doesn't already exist

    files = dir([inputDir '/*.jpg']);
    %files = files(1:5:length(files)); %skip all but 1 out of every 5 images
    detectionDetails = [];
    img_id = 1;
    for img = files'
        display(img.name)
        inImgName = [inputDir '/' img.name];
        [pathstr, name, ext] = fileparts(inImgName);

        im = imread(inImgName);
        %note: can tune model.thresh to vary precision/recall tradeoff
        [dets, boxes, trees, detected_root_filters] = imgdetect_forTracking(im, model, model.thresh);
        outImgName =  [outputDir '/' img.name];

        current_detectionDetails = postprocess_and_vis(nms_thresh, dets, boxes, detected_root_filters, im, img_id, img.name, outImgName, model); 
        detectionDetails = [detectionDetails current_detectionDetails] 
        save('detectionDetails.mat', 'detectionDetails');
        img_id = img_id + 1;
    end
end

% @return detectionDetails struct for all detections in the current image
% write to file: bounding boxes in CSV format and images with bboxes displayed
function detectionDetails = postprocess_and_vis(nms_thresh, dets, boxes, detected_root_filters, im, img_id, img_name, outImgName, model)
    detectionDetails = [];
    try % do nonmax suppression and display detected objects
        top = nms(dets, nms_thresh); %nonmax suppression (precision vs recall tradeoff)
        theBoxes = reduceboxes(model, boxes);
        rootBoxes = int32(theBoxes(:, 1:4)); %bounding box for whole objects -- ignore part filters. (1:4 is x1 y1 x2 y2 for root box)
        [rootBoxes, top] = remove_contained_bboxes(rootBoxes, top);
        detected_root_filters = detected_root_filters(top);
        components_used = dets(top, 5); %component (orientation and associated sub-model) ID
 
        for bbox_id=1:length(rootBoxes(:,1))
            model_root_filter = get_model_root_filter(components_used(bbox_id), model);
            detectionDetails = [detectionDetails struct('img_name', img_name, 'img_id', img_id, 'bbox_id', bbox_id, 'bbox', rootBoxes(bbox_id,:), 'bbox_hog_descriptor', detected_root_filters(bbox_id).f, 'dpm_hog_descriptor', model_root_filter, 'dpm_orientation_id', components_used(bbox_id))];
        end

        showboxes_forTracking(im, rootBoxes); %doesn't need for the image to already be displayed.
        print(gcf, '-djpeg90', '-r0', outImgName);
    catch %no detections above nms threshold
        display('no detections')
        image(im);
        print(gcf, '-djpeg90', '-r0', outImgName);
    end
end

