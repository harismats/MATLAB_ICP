% clc
clear

%% Load data.

% Load point cloud data.
inputFileName = fullfile("..","datasets","outdoorDataset.mat");
load(inputFileName)
%%

% Compute normals.
K = 6;
ptClouds(1).Normal = pcnormals(ptClouds(1), K);
ptClouds(2).Normal = pcnormals(ptClouds(2), K);

% Start evaluation
resultsForOutdoorDataset = evaluateICPForSingleRegistration(ptClouds(2), ptClouds(1));

numRegistrations = numel(ptClouds)-1;
for i = 2:numRegistrations
    ptClouds(i+1).Normal = pcnormals(ptClouds(i+1), K);
    resultsForOutdoorDataset = resultsForOutdoorDataset + evaluateICPForSingleRegistration(ptClouds(i+1), ptClouds(i));
end

resultsForOutdoorDataset = resultsForOutdoorDataset./numRegistrations
%% Write out results.

Method = string(resultsForOutdoorDataset.Properties.RowNames);
RMSE = resultsForOutdoorDataset.RMSE;
TimeInSeconds = resultsForOutdoorDataset.TimeInSeconds;
finalResults = table(Method, RMSE, TimeInSeconds);

outputFilename = fullfile("..","results","outdoorDatasetResults.csv");
writetable(finalResults, outputFilename)