clc
clear
close all

load(fullfile("..","datasets","bunny.mat"))

ptCloud = bunny;

bunny = pcdownsample(bunny, "random", 0.25);

% Compute normals.
K = 6;
bunny.Normal = pcnormals(bunny, 6);

tform = rigidtform3d([0 0 60], ...   % [rx, ry, rz] in degrees
                    [0.3 0.4 0.5]); % [tx, ty, tz] in meters
ptCloudTformed = pctransform(bunny, tform);

%% Align Two Point Clouds Using ICP Algorithm

fig = figure;
fig.WindowState = 'maximized';
tiledlayout(2,3);
% showResults({ptCloud, ptCloudTformed}, "Before Registration")

% Apply the pointToPoint icp registration
tic
[tform4, regPtCloud4, rmse4] = pcregistericp(ptCloudTformed ,ptCloud,"Tolerance",[0.01 0.1],...
    "Metric","pointToPoint","MaxIterations",20);
t4 = toc;
titleText = "MATLAB's pointToPoint" + newline + "RMSE = " + rmse4 + " | " + "Time = " + t4;
showResults({ptCloud, regPtCloud4}, titleText)

% Apply the pointToPoint icp registration
tic
[tform5, regPtCloud5, rmse5] = pcregistericp(ptCloudTformed ,ptCloud,"Tolerance",[0.01 0.1],...
    "Metric","pointToPoint","Extrapolate",true,Verbose=false, MaxIterations = 20);
t5 = toc;
titleText = "MATLAB's pointToPoint with Extrapolate" + newline + "RMSE = " + rmse5 + " | " + "Time = " + t5;
showResults({ptCloud, regPtCloud5}, titleText)

% Apply the pointToPoint icp registration
tic
[tform2, regPtCloud2, rmse2] = pcregistericp(ptCloudTformed,ptCloud,"Tolerance",[0.01 0.1],...
    "Metric","pointToPoint","Acceleration",true,"MaxIterations",20);
t2 = toc;
titleText = "Open3D's pointToPoint" + newline + "RMSE = " + rmse2 + " | " + "Time = " + t2;
showResults({ptCloud, regPtCloud2}, titleText)

% Apply the pointToPlane icp registration
tic
[tform6, regPtCloud6, rmse6] = pcregistericp(ptCloudTformed ,ptCloud,"Tolerance",[0.01 0.1],...
    "Metric","pointToPlane","MaxIterations",20);
t6 = toc;
titleText = "MATLAB's pointToPlane" + newline + "RMSE = " + rmse6 + " | " + "Time = " + t6;
showResults({ptCloud, regPtCloud6}, titleText)

% Apply the pointToPlane icp registration
tic
[tform7, regPtCloud7, rmse7] = pcregistericp(ptCloudTformed ,ptCloud,"Tolerance",[0.01 0.1],...
    "Metric","pointToPlane", "Extrapolate", true,"MaxIterations",20);
t7 = toc;
titleText = "MATLAB's pointToPlane with Extrapolate" + newline + "RMSE = " + rmse7 + " | " + "Time = " + t7;
showResults({ptCloud, regPtCloud7}, titleText)

% Apply the pointToPlane icp registration
tic
[tform3, regPtCloud3, rmse3] = pcregistericp(ptCloudTformed,ptCloud,"Tolerance",[0.01 0.1],...
    "Metric","pointToPlane","Acceleration",true,"MaxIterations",20);
t3 = toc;
titleText = "Open3D's pointToPlane" + newline + "RMSE = " + rmse3 + " | " + "Time = " + t3;
showResults({ptCloud, regPtCloud3}, titleText)


function showResults(ptClouds, titleText)
    nexttile
    pcshowpair(ptClouds{1}, ptClouds{2});
    legend({'fixed','moving'},'Color','White')
    title(titleText)
end