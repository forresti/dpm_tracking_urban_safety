
function demo_track_cars()
    load('detectionDetails.mat'); %contains 'detectionDetails' structure
    matches = track_cars(detectionDetails);
    %TODO: visualize matches
end

% out of the detected cars, reidentify (match) cars between pairs of images
% this uses convolution (correlation) to implement sliding L1 norm. 
% using a *sliding* norm seems important, since the detected bboxes vary in size. 
function matches = track_cars(detectionDetails)
    nImages = max(cell2mat({detectionDetails.img_id}));
    

end

