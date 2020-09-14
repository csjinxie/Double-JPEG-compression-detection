function scaled = scale_data(data)

[samp_num, feat_dim] = size(data);

mins = min(data);
maxs = max(data);
rangs = maxs-mins;
rangs(rangs==0) = 1;
scaled = zeros(samp_num, feat_dim);

for i = 1 : feat_dim
    scaled(:,i) = (data(:,i)-mins(i))/rangs(i);
end

return;