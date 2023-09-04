clc
clear
close all
%% Load data.
data.Unreal = iReadTable("unrealDatasetResults.csv");
data.Construction = iReadTable("constructionDatasetResults.csv");
data.Teapot = iReadTable("teapotResults.csv");
data.Hilti = iReadTable("hiltiDatasetResults.csv");
data.Outdoor = iReadTable("outdoorDatasetResults.csv");
data.Livingroom = iReadTable("livingRoomResults.csv");

%% Compute improvement ratios in speed and percentage difference in RMSE.

useExtrapolate = true;
[pointToPointRMSE, pointToPlaneRMSE] = extractRMSE(data, useExtrapolate)
[pointToPointTime, pointToPlaneTime] = extractTime(data, useExtrapolate)

useExtrapolate = false;
[pointToPointRMSEWithExtrapolate, pointToPlaneRMSEWithExtrapolate] = extractRMSE(data, useExtrapolate)
[pointToPointTimeWithExtrapolate, pointToPlaneTimeWithExtrapolate] = extractTime(data, useExtrapolate)

%% Generate plots.

p2pData = pointToPointRMSE.Improvement;
p2lData = pointToPlaneRMSE.Improvement;
plotData(p2pData, p2lData, "RMSE", "AccuracyWithoutExtrapolate")

p2pData = pointToPointTime.Improvement;
p2lData = pointToPlaneTime.Improvement;
plotData(p2pData, p2lData, "Speed", "SpeedWithoutExtrapolate")

p2pData = pointToPointRMSEWithExtrapolate.Improvement;
p2lData = pointToPlaneRMSEWithExtrapolate.Improvement;
plotData(p2pData, p2lData, "RMSE", "AccuracyWithExtrapolate")

p2pData = pointToPointTimeWithExtrapolate.Improvement;
p2lData = pointToPlaneTimeWithExtrapolate.Improvement;
plotData(p2pData, p2lData, "Speed", "SpeedWithExtrapolate")
%% Helper functions.

function data = iReadTable(csvFilename)

    rawData = readtable(csvFilename);

    RMSE = rawData.RMSE;
    TimeInSeconds = rawData.TimeInSeconds;
    data = table(RMSE, TimeInSeconds, RowNames=rawData.Method);
end

function [pointToPointRMSE, pointToPlaneRMSE] = extractRMSE(data, useExtrapolate)

    pointToPointRMSE = extractVariable(data, "RMSE", true, useExtrapolate);
    pointToPlaneRMSE = extractVariable(data, "RMSE", true, useExtrapolate);

    pointToPointImprovement = 100*(pointToPointRMSE.MATLAB-pointToPointRMSE.Open3D)./pointToPointRMSE.Open3D;
    pointToPlaneImprovement = 100*(pointToPointRMSE.MATLAB-pointToPointRMSE.Open3D)./pointToPlaneRMSE.Open3D;

    pointToPointRMSE = addvars(pointToPointRMSE, pointToPointImprovement, ...
        NewVariableNames="Improvement");
    pointToPlaneRMSE = addvars(pointToPlaneRMSE, pointToPlaneImprovement, ...
        NewVariableNames="Improvement");
end

function [pointToPointTime, pointToPlaneTime] = extractTime(data, useExtrapolate)

    pointToPointTime = extractVariable(data, "TimeInSeconds", true, useExtrapolate);
    pointToPlaneTime = extractVariable(data, "TimeInSeconds", true, useExtrapolate);

    pointToPointImprovement = pointToPointTime.MATLAB./pointToPointTime.Open3D;
    pointToPlaneImprovement = pointToPlaneTime.MATLAB./pointToPlaneTime.Open3D;

    pointToPointImprovement(pointToPointImprovement < 0) = -1/pointToPointImprovement(pointToPointImprovement < 0);
    pointToPlaneImprovement(pointToPlaneImprovement < 0) = -1/pointToPlaneImprovement(pointToPlaneImprovement < 0);

    pointToPointTime = addvars(pointToPointTime, pointToPointImprovement, ...
        NewVariableNames="Improvement");
    pointToPlaneTime = addvars(pointToPlaneTime, pointToPlaneImprovement, ...
        NewVariableNames="Improvement");
end

function var = extractVariable(data, varName, isPointToPoint, useExtrapolate)

    if isPointToPoint
        metric = "pointToPoint";
    else
        metric = "pointToPlane";
    end

    rowNameMATLAB = "MATLAB's " + metric;
    rowNameOpen3D = "Open3D's " + metric;
    
    if useExtrapolate
        rowNameMATLAB = rowNameMATLAB + " with Extrapolate";
    end

    datasets = fieldnames(data);
    numDatasets = length(datasets);
    varMATLAB = zeros(numDatasets,1);
    varOpen3D = zeros(numDatasets,1);
    for i = 1:numDatasets
        T = data.(datasets{i});
        varMATLAB(i) = T{rowNameMATLAB, varName};
        varOpen3D(i) = T{rowNameOpen3D, varName};
    end

    rowNames = ["Unreal engine", "Construction", "Teapot data", ...
      "Hilti dataset", "Outdoor scene", "Living room"];
    varNames = ["MATLAB", "Open3D"];
    var = table(varMATLAB, varOpen3D, VariableNames=varNames, ...
        RowNames=rowNames);
end

function plotData(p2pData, p2lData, datatype, outputFilename)

    datasetNames = ["Unreal engine", "Construction", "Teapot data", ...
      "Hilti dataset", "Outdoor scene", "Living room"];

    if datatype == "Speed"
        titleTxt = "Speed improvement shown as ratio: (MATLAB/Open3D)";
        ylabelTxt = "Ratio";
        ylimits = [0 7];
    else
        titleTxt = "Accuracy difference shown as percentage: (MATLAB-Open3D)/MATLAB";
        ylimits = [-30 5];
        ylabelTxt = "Percentage difference";
    end  

    f = figure(Position = [200 341 1079 540]);%[200 76 1542 805]);
    drawnow
    subplot(2,1,1)
    b = bar(p2pData, FaceColor = [0.4660 0.6740 0.1880]);
    set(gca, 'XTickLabel', datasetNames)
    subtitle("Point-to-Point ICP")
    title(titleTxt)
    ylim(ylimits)
    unit = appendUnits(datatype);
    showValues(b, unit)
    ylabel(ylabelTxt)
    xlabel("Dataset Names")
    
    subplot(2,1,2)
    b = bar(p2lData, FaceColor = [0.9290 0.6940 0.1250]);
    set(gca, 'XTickLabel', datasetNames)
    subtitle("Point-to-Plane ICP")
    ylim(ylimits)
    unit = appendUnits(datatype);
    showValues(b, unit)
    ylabel(ylabelTxt)
    xlabel("Dataset Names")

    saveas(f, outputFilename+".png")
    
    function unit = appendUnits(datatype)

        ylabels = get(gca, 'YTickLabel');
        if datatype == "Speed"
            unit = "x";
        else
            unit = "%";
        end
        set(gca, 'YTickLabel', strcat(ylabels, unit));
    end

    function showValues(b, unit)
        xtips = b.XEndPoints;
        ytips = b.YEndPoints-b.YEndPoints + 0.5;
        labels = string(round(b.YData,2))+unit;
        text(xtips,ytips,labels,'HorizontalAlignment','center',...
            'VerticalAlignment','bottom')
    end
end