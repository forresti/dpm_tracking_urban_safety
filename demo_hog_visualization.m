function demo_to_profile()
    close all hidden %get rid of old figures
    startup;

    load('cachedir/forrest_models_car_with_nighttime_bg/2007/car_final.mat'); %voc-release5 model trained on Sensys data
    %load('cachedir/forrest_models/2007/car_forrest_final.mat')
    %load('VOC2007/car_final');
    %test('000034.jpg', model, -0.3);
    test('Dir_2_Lane_3_285/1360028304-13704.jpg', model, model.thresh);
end
 
function test(imname, model, thresh)
    im = imread(imname); % load image
    size(im)
    
    %[bs, ds, trees] = imgdetect(im, model, thresh);
    [ds, bs, trees, root_filters] = imgdetect_forrest(im, model, thresh); % detect objects

    top = nms(ds, 0.3)
    bs = reduceboxes(model, bs(top,:));
    figure(1000); %img with bboxes is figure num 1000. (so that HOG figure indexing can start from 1)
    showboxes(im, bs(:,1:4));
    %root_filters(top).f
    components_used = ds(:, 5); %component (orientation and associated sub-model) ID

    figID = 1;
    for i=top'
        figure(figID)
        size(root_filters(i).f) %interesting to know
        w = foldHOG(root_filters(i).f); %convert 32-deep HOG features into a few orientation bins
        visualizeHOG(w)

        figure(figID+100) %so it's easy to find the corresponding figures
        vis_model_root_filter(components_used(i), model) 

        figID = figID+1;
    end
end

%visualize root filter for a specific component
function vis_model_root_filter(componentIdx, model)
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

