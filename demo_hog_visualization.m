
function demo_hog_visualization()
    close all hidden %get rid of old figures
    startup;
    load('sensys_models/car_final.mat');
    test('Dir_2_Lane_3_285/1360028304-13704.jpg', model, model.thresh);
end
 
function test(imname, model, thresh)

%run car detector on one image 
    im = imread(imname); % load image
    [ds, bs, trees, detected_root_filters] = imgdetect_forTracking(im, model, thresh); % detect objects
    top = nms(ds, 0.3)
    bs = reduceboxes(model, bs(top,:));
    figure(1000); %img with bboxes is figure num 1000. (so that HOG figure indexing can start from 1)
    showboxes(im, bs(:,1:4));
    components_used = ds(:, 5); %component (orientation and associated sub-model) ID

%visualize HOG filters extracted at the detection locations
    figID = 1;
    for i=top' %for each detected bounding box
      %visualize HOG features extracted from detected bounding box
        figure(figID)
        w = foldHOG(detected_root_filters(i).f); %convert 32-deep HOG features into a few orientation bins
        visualizeHOG(w)
    
      %visualize DPM model's internal filter that was used for this detection
        figure(figID+100) %so it's easy to find the corresponding figures
        model_root_filter = get_model_root_filter(components_used(i), model);
        w = foldHOG(model_root_filter);
        visualizeHOG(max(0, w))

        figID = figID+1;
    end
end

%visualize root filter for a specific component
function vis_root_filter(componentIdx, model)
    rhs = model.rules{model.start}(componentIdx).rhs;
    layer = 1;
    rootIdx = -1;
    % assume the root filter is first on the rhs of the start rules
    if model.symbols(rhs(1)).type == 'T' % handle case where there's no deformation model for the root
      rootIdx = model.symbols(rhs(1)).filter;
    else % handle case where there is a deformation model for the root
      rootIdx = model.symbols(model.rules{rhs(1)}(layer).rhs).filter;
    end

    w = foldHOG(model_get_block(model, model.filters(rootIdx)));
    visualizeHOG(max(0, w))
end

