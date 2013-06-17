
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
            for bboxIdx2 = nextImgIndices

                %size(detectionDetails(bboxIdx2).bbox_hog_descriptor)

                %correlation = conv2( double(detectionDetails(bboxIdx1).bbox_hog_descriptor), ...
                %                     double(detectionDetails(bboxIdx2).bbox_hog_descriptor) );
                                     %flipud(fliplr(detectionDetails(bboxIdx2).bbox_hog_descriptor)) );

                correlation = conv2_withDepth( detectionDetails(bboxIdx1).bbox_hog_descriptor, ...
                                               detectionDetails(bboxIdx2).bbox_hog_descriptor );
                                               %flipud(fliplr(detectionDetails(bboxIdx2).bbox_hog_descriptor)) );
            end
        end 

        img_id
    end 

    
end

function convolved = conv2_withDepth(filter1, filter2)
    [height1 width1 depth1] = size(filter1);
    [height2 width2 depth2] = size(filter2);
    
    assert(depth1 == depth2, 'conv2_withDepth requires filters with equal depths');

    convs = []; %TODO: preallocate
    for depth=1:depth1
        convs(:,:,depth) = conv2(filter1(:,:,depth), filter2(:,:,depth));
    end
    %TODO: explore statistics of numbers in here. (none of the inputs in filter1,filter2 are less than 0, for example) 

    convolved = sum(convs,3);
end


