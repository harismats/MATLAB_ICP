function results = evaluateICPForSingleRegistration(ptCloudTformed, ptCloud)
    
    methods = string.empty;
    rmses = [];
    ts = [];
    %%
    methods(end+1) = "MATLAB's pointToPoint";
    tic
    [~, ~, rmses(end+1)] = pcregistericp(ptCloudTformed ,ptCloud,...
        "Metric","pointToPoint");
    ts(end+1) = toc;
    %% 
    methods(end+1) = "MATLAB's pointToPoint with Extrapolate";
    tic
    [~, ~, rmses(end+1)] = pcregistericp(ptCloudTformed ,ptCloud,...
        "Metric","pointToPoint","Extrapolate",true);
    ts(end+1) = toc;
    %%
    methods(end+1) = "Open3D's pointToPoint";
    tic
    [~, ~, rmses(end+1)] = pcregistericp(ptCloudTformed,ptCloud,...
        "Metric","pointToPoint","Acceleration",true,"MaxIterations",30);
    ts(end+1) = toc;
    %%
    methods(end+1) = "MATLAB's pointToPlane";
    tic
    [~, ~, rmses(end+1)] = pcregistericp(ptCloudTformed ,ptCloud,...
        "Metric","pointToPlane");
    ts(end+1) = toc;
    %%
    methods(end+1) = "MATLAB's pointToPlane with Extrapolate";
    tic
    [~, ~, rmses(end+1)] = pcregistericp(ptCloudTformed ,ptCloud,...
        "Metric","pointToPlane", "Extrapolate", true);
    ts(end+1) = toc;
    %%
    methods(end+1) = "Open3D's pointToPlane";
    tic
    [~, ~, rmses(end+1)] = pcregistericp(ptCloudTformed,ptCloud,...
        "Metric","pointToPlane","Acceleration",true,"MaxIterations",30);
    ts(end+1) = toc;
    
    %% Write out results
    Method = methods';
    RMSE = rmses';
    TimeInSeconds = ts';
    results = table(RMSE, TimeInSeconds, RowNames=Method);
end