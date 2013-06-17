
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

        matchScores = zeros([length(currImgIndices) length(nextImgIndices)])
        img_id
    end 

    
end

