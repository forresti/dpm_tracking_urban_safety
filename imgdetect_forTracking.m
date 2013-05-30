function [ds, bs, trees, root_filters] = imgdetect_forTracking(im, model, thresh)
% Wrapper around gdetect.m that computes detections in an image.
%
% Return values (see voc-release5/gdetect/gdetect.m)
%
% Arguments
%   im        Input image
%   model     Model to use for detection
%   thresh    Detection threshold (scores must be > thresh)
%   root_filters(num_detections).f -- one root filter per detection

im = color(im);
pyra = featpyramid(im, model);
[ds, bs, trees] = gdetect(pyra, model, thresh);

%from_pos = true;
%dataid = 0; %not sure what this does -Forrest

%note: in the following, bboxes (bs) is unchanged from the bs produced by gdetect
[bs, count, root_filters] = get_detected_filters(pyra, model, bs, trees); %get root filter feature extractions

