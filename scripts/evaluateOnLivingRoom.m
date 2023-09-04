% clc
clear
close all

%% Load data.

% Load point cloud data.
inputFileName = fullfile("..","datasets","livingRoom.mat");
ld = load(inputFileName);

ptCloud = ld.livingRoomData{1};
ptCloudTformed  = ld.livingRoomData{2};

% Compute normals.
K = 6;
ptCloud.Normal = pcnormals(ptCloud, K);
ptCloudTformed.Normal = pcnormals(ptCloudTformed, K);
%% Evaluate ICP.

resultsForLivingRoomData = evaluateICPForSingleRegistration(ptCloudTformed, ptCloud)
%% Write out results.

Method = string(resultsForLivingRoomData.Properties.RowNames);
RMSE = resultsForLivingRoomData.RMSE;
TimeInSeconds = resultsForLivingRoomData.TimeInSeconds;
finalResults = table(Method, RMSE, TimeInSeconds);

outputFilename = fullfile("..","results","livingRoomResults.csv");
writetable(finalResults, outputFilename)