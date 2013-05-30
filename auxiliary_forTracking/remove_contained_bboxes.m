%when a larger bounding box fully contains a smaller box, remove the larger box
%param boxes: [x1 y1 x2 y2; x1 y1 x2 y2; ...] -- input ALL boxes, not just the top ones.
function [boxes, top] = remove_contained_bboxes(boxes, top)
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

