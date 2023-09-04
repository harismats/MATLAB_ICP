% clc
clear
close all

%% Load data

% Load point cloud data.
inputFileName = fullfile("..","datasets","teapot.mat");
load(inputFileName);

% Compute normals.
K = 6;
ptCloud.Normal = pcnormals(ptCloud, 6);

% Create a transform object with 30 degree rotation along z -axis and
% translation [5,5,10].
theta = pi/6;
A = [cos(theta) sin(theta) 0 0; ...
    -sin(theta) cos(theta) 0 0; ...
            0         0  1 0; ...
            5         5 10 1];
tform = affine3d(A);

% Transform the point cloud.
ptCloudTformed = pctransform(ptCloud,tform);

%% Define containers to store results.

resultsForTeapot = evaluateICPForSingleRegistration(ptCloudTformed, ptCloud)
%% Write out results

Method = string(resultsForTeapot.Properties.RowNames);
RMSE = resultsForTeapot.RMSE;
TimeInSeconds = resultsForTeapot.TimeInSeconds;
finalResults = table(Method, RMSE, TimeInSeconds);

outputFilename = fullfile("..","results","teapotResults.csv");
writetable(finalResults, outputFilename)