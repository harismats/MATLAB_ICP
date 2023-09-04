% clc
clear

%% Load data.

% Load point cloud data.
inputFileName = fullfile("..","datasets","hiltiDataset.mat");
load(inputFileName)

%%

% Compute normals.
K = 6;
ptClouds(1).Normal = pcnormals(ptClouds(1), K);
ptClouds(2).Normal = pcnormals(ptClouds(2), K);

% Start evaluation
resultsForHiltiDataset = evaluateICPForSingleRegistration(ptClouds(2), ptClouds(1));

numRegistrations = numel(ptClouds)-1;
for i = 2:numRegistrations
    ptClouds(i+1).Normal = pcnormals(ptClouds(i+1), K);
    resultsForHiltiDataset = resultsForHiltiDataset + evaluateICPForSingleRegistration(ptClouds(i+1), ptClouds(i));
end

resultsForHiltiDataset = resultsForHiltiDataset./numRegistrations
%% Write out results.

Method = string(resultsForHiltiDataset.Properties.RowNames);
RMSE = resultsForHiltiDataset.RMSE;
TimeInSeconds = resultsForHiltiDataset.TimeInSeconds;
finalResults = table(Method, RMSE, TimeInSeconds);

outputFilename = fullfile("..","results","hiltiDatasetResults.csv");
writetable(finalResults, outputFilename)