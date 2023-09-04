% clc
clear

%% Load data.

% Load point cloud data.
inputFileName = fullfile("..","datasets","constructionDataset.mat");
load(inputFileName)

%%

% Compute normals.
K = 6;
ptClouds(1).Normal = pcnormals(ptClouds(1), K);
ptClouds(2).Normal = pcnormals(ptClouds(2), K);

% Start evaluation
resultsForConstructionData = evaluateICPForSingleRegistration(ptClouds(2), ptClouds(1));

numRegistrations = numel(ptClouds)-1;
for i = 2:numRegistrations
    ptClouds(i+1).Normal = pcnormals(ptClouds(i+1), K);
    resultsForConstructionData = resultsForConstructionData + evaluateICPForSingleRegistration(ptClouds(i+1), ptClouds(i));
end

resultsForConstructionData = resultsForConstructionData./numRegistrations
%% Write out results.

Method = string(resultsForConstructionData.Properties.RowNames);
RMSE = resultsForConstructionData.RMSE;
TimeInSeconds = resultsForConstructionData.TimeInSeconds;
finalResults = table(Method, RMSE, TimeInSeconds);

outputFilename = fullfile("..","results","constructionDatasetResults.csv");
writetable(finalResults, outputFilename)