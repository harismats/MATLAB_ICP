% clc
clear

%% Load data.

% Load point cloud data.
inputFileName = fullfile("..","datasets","unrealDataset.mat");
load(inputFileName);

% Skip every other samples.
indices = 1:2:200;
ptClouds = ptCloudArr(indices);
%%

% Compute normals.
K = 6;
ptClouds(1).Normal = pcnormals(ptClouds(1), K);
ptClouds(2).Normal = pcnormals(ptClouds(2), K);

% Start evaluation
resultsForUnrealDataset = evaluateICPForSingleRegistration(ptClouds(2), ptClouds(1));

numRegistrations = numel(ptClouds)-1;
for i = 2:numRegistrations
    ptClouds(i+1).Normal = pcnormals(ptClouds(i+1), K);
    resultsForUnrealDataset = resultsForUnrealDataset + evaluateICPForSingleRegistration(ptClouds(i+1), ptClouds(i));
end

resultsForUnrealDataset = resultsForUnrealDataset./numRegistrations
%% Write out results.

Method = string(resultsForUnrealDataset.Properties.RowNames);
RMSE = resultsForUnrealDataset.RMSE;
TimeInSeconds = resultsForUnrealDataset.TimeInSeconds;
finalResults = table(Method, RMSE, TimeInSeconds);

outputFilename = fullfile("..","results","unrealDatasetResults.csv");
writetable(finalResults, outputFilename)