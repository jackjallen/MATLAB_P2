%% ONBI short project 2 - Magnetic Resonance Fingerprinting
% Author: Jack Allen
% Supervisor: Prof. Peter Jezzard
% Start Date: 13th July 2015
%% 1. Initialise
clear all
close all
addpath(genpath('/Applications/fsl/'))
addpath(genpath('/usr/local/fsl/bin'))
addpath(genpath('/Users/jallen/Documents/MATLAB/short_project_2'))

%% 2. Read in the images
%which phantom is the data from? ('sphereD170' or 'Jack'?)
phantomName = 'Jack';

% Choose the offset list to use. List 2 is the original 'random' list of
% offsets. Lists 3:8 are variations on List2, as described below.
%
% 3: 1st TR offset = 10000
% 4: flip Angles = 90 and 180
% 5: TE offset = 20
% 6: TR offset = 1500, TE offset = 20, FA1 = 90
% 7: TR offset = 1500, TE offset = 20
% 8: TR offset = 15000

for offsetListNum = 2:8
[TEImageInfo, TIImageInfo, FPImageInfo(:,offsetListNum), TEimages, TIimages, FPimages(:,:,:,:,offsetListNum), TE, TI] = readData(phantomName, offsetListNum);
end
%% 3. Select a ROI and a sample of the background, to calculate SNR
[SNR signal background] = calcSNR(TEimages,TE,'showFigure');

%% 4. find signals at sample pixels
run('compartmentSignals.m')

%% 5. plot positions of sample pixels for TE and TR images
plotNumCompartments = 6;
run('plotSamplePixels_TE_TR.m')
%%
run('visualiseImages.m')

%% fit curves to calculate T1 and T2

[compartmentT1s, compartmentT2s, T2curves, T1curves, fittedCurve, goodness, output] = fitEvolutionCurves(TEimages, TIimages, TE(2:end)', TI(2:end), 'compartments', compartmentCenters);

%% 6. read in the list of timing offsets used for acquisition
run('readFingerprintOffsetList.m')

%% 7. simulate magnetisation evolution
%check bloch simulation by using properties of the phantom

% sphereD170 properties
T1 = 282.5;
T2 = 214.1;

freqOffset = 0;
nSlices = 2;
[M, Mxy,flipAngles, t0s] = SimBloch(T1, T2, fingerprintLists(:,:,offsetListNum), 'showPlot', freqOffset, nSlices);

%% 8. check signal simulation by plotting positions of sample pixels for the fingerprinting images
compartmentCentersList = 3;
run('plotSamplePixels.m')

% plot comparison of simulation with sampled pixels
run('plotSim.m')

%% 9. create dictionary

offsetListNums = offsetListNum
run('dictionary.m')

%% 10. check similarity and use dictionary to measure T1 and T2
run('matching.m')

%% plot and save the T1, T2 and FA deviation maps
for offsetListNum = 2:8
FA_fig = figure; imagesc(squeeze(matchedFAdevInd(:,:,offsetListNum)))
saveas(FA_fig, ['/Users/jallen/Documents/MATLAB/short_project_2/figures/matchedFAdevInd_offsetList',num2str(offsetListNum),'_phantomName_',phantomName])
matlab2tikz(['/Users/jallen/Documents/MATLAB/short_project_2/figures/matchedFAdevInd_offsetList',num2str(offsetListNum),'_phantomName_',phantomName])

matchedT1_fig = figure; imagesc(matchedT1(:,:,offsetListNum))
saveas(matchedT1_fig, ['/Users/jallen/Documents/MATLAB/short_project_2/figures/matchedT1_offsetList',num2str(offsetListNum),'_phantomName_',phantomName])
matlab2tikz(['/Users/jallen/Documents/MATLAB/short_project_2/figures/matchedT1_offsetList',num2str(offsetListNum),'_phantomName_',phantomName])

matchedT2_fig = figure; imagesc(matchedT2(:,:,offsetListNum))
saveas(matchedT2_fig, ['/Users/jallen/Documents/MATLAB/short_project_2/figures/matchedT2_offsetList',num2str(offsetListNum),'_phantomName_',phantomName])
matlab2tikz(['/Users/jallen/Documents/MATLAB/short_project_2/figures/matchedT2_offsetlist',num2str(offsetListNum),'_phantomName_',phantomName])
end