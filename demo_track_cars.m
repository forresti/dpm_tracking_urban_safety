
function demo_track_cars()
    load('detectionDetails.mat'); %contains 'detectionDetails' structure
    matches = track_cars(detectionDetails);
    %TODO: visualize matches
end

% out of the detected cars, find corresponding (matching) cars between pairs of images
% this uses convolution (correlation) to implement sliding L1 norm. 
% using a *sliding* norm seems important, since the detected bboxes vary in size. 
function matches = track_cars(detectionDetails)
    nImages = max(cell2mat({detectionDetails.img_id}));
    matches = detectionDetails; %the output 'matches' structure contains all of the detectionDetails info, PLUS correspondences between car bboxes

    for img_id = 1:(nImages-1)
        currImgIndices = find(cell2mat({detectionDetails.img_id}) == img_id)
        nextImgIndices = find(cell2mat({detectionDetails.img_id}) == (img_id+1))

        matchScores = zeros([length(currImgIndices) length(nextImgIndices)]); %will contain max sliding-window match for each pair of filters in img_id and (img_id+1).

        for bboxIdx1 = currImgIndices %indexing into detectionDetails
            for bboxIdx2 = nextImgIndices %Should I actually index this as per-image bbox_id instead of global bbox_id?

                %size(detectionDetails(bboxIdx2).bbox_hog_descriptor)

                correlation = corr2_withDepth( detectionDetails(bboxIdx1).bbox_hog_descriptor, ...
                                               detectionDetails(bboxIdx2).bbox_hog_descriptor ); 
                                               % flip(filter2) happens inside corr2_withDepth()

                %TODO: decide how to index matchScores. Do I want to index by bbox_id within the image, or global bbox_id?
                %matchScores(...) = max(correlation);
            end
        end 
        img_id
    end 
end

% @param filter1, filter2 = X*Y*depth filters, where depth is equal for both filters.
% correlation, not convolution. flips filter2 before passing it into Matlab's conv2.
% we calculate correlation at each depth level (using 'full' conv2 setting), then elementwise sum all depth levels.
function convolved = corr2_withDepth(filter1, filter2)
    [height1 width1 depth1] = size(filter1);
    [height2 width2 depth2] = size(filter2);
    
    assert(depth1 == depth2, 'corr2_withDepth requires filters with equal depths');

    convs = []; %TODO: preallocate
    for depth=1:depth1
        convs(:,:,depth) = conv2( filter1(:,:,depth), fliplr(flipud(filter2(:,:,depth))) );
    end
    %TODO: explore statistics of numbers in here. (none of the inputs in filter1,filter2 are less than 0, for example) 

    keyboard

    convolved = sum(convs,3);
end


