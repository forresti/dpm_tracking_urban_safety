function [ds, bs, trees, root_filters] = imgdetect_forrest(im, model, thresh)
% Wrapper around gdetect.m that computes detections in an image.
%   [ds, bs, trees, root_filters] = imgdetect(im, model, thresh)
%
% Return values (see gdetect.m)
%
% Arguments
%   im        Input image
%   model     Model to use for detection
%   thresh    Detection threshold (scores must be > thresh)
%   root_filters(num_detections).f -- one root filter per detection

im = color(im);
pyra = featpyramid(im, model);
[ds, bs, trees] = gdetect(pyra, model, thresh);

%write detected features (and related stuff) to file
from_pos = true;
dataid = 0; %not sure what this does


%from train.m -- trying to figure out how this fits into doing multiple calls to gdetect_write 
%[im, boxes] = croppos(im, pos(j).boxes);
%[pyra, model_dp] = gdetect_pos_prepare(im, model, boxes, fg_overlap);
%data(k).pyra = pyra;
%[ds, bs, trees] = gdetect_pos(data(k).pyra, model_dp, 1+num_fp, ...
%                               fg_box, fg_overlap, bg_boxes, 0.5);
%data(k).boxdata{b}.bs = bs;
%data(k).boxdata{b}.trees = trees;

%note: in the following, bboxes (bs) is unchanged from the bs produced by gdetect
[bs, count, root_filters] = gdetect_write_forrest(pyra, model, bs, trees, from_pos, dataid); %get root filter feature extractions

