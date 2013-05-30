%get HOG descriptor for a specific DPM model component
%   modified from voc-release5/vis/visualizemodel.m
function filter = get_model_root_filter(componentIdx, model)
    rhs = model.rules{model.start}(componentIdx).rhs;
    layer = 1;
    rootIdx = -1;
    % assume the root filter is first on the rhs of the start rules
    if model.symbols(rhs(1)).type == 'T' % handle case where there's no deformation model for the root
      rootIdx = model.symbols(rhs(1)).filter;
    else % handle case where there is a deformation model for the root
      rootIdx = model.symbols(model.rules{rhs(1)}(layer).rhs).filter;
    end
    filter = model_get_block(model, model.filters(rootIdx));
end

