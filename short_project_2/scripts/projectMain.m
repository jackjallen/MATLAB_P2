%% ONBI short project 2 - Magnetic Resonance Fingerprinting
% Author: Jack Allen
% Supervisor: Prof. Peter Jezzard
% Start Date: 13th July 2015
%% 1. Initialise
clear all
close all

%Are you working on jalapeno00 or locally?
% workingdir = '/home/fs0/jallen/Documents/MATLAB/short_project_2';
workingdir = '/Users/jallen/Documents/MATLAB/short_project_2';
addpath(genpath(workingdir)); % sometimes causes MATLAB to freeze

savingdir = '/Users/jallen/Documents/short_project_2';
addpath(genpath(savingdir)); 

% If working on jalapeno00, uncomment the following lines:
% addpath(genpath('/Applications/fsl/'))
% addpath(genpath('/usr/local/fsl/bin'))
% addpath(genpath('/opt/fmrib/fsl/etc/matlab'))

%% 2. Read in the images
%which phantom is the data from? ('sphereD170' or 'Jack'?)
phantomName = 'sphereD170';

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
    [TEImageInfo, TIImageInfo, FPImageInfo(:,offsetListNum), TEimages, TIimages, FPimages(:,:,:,:,offsetListNum), TE, TI] = readData(phantomName, offsetListNum, [savingdir,'/Data/'] );
    save([savingdir,'/MAT-files/images/',phantomName,'_list',num2str(offsetListNum),'TEimages.mat'],'TEimages')
    save([savingdir,'/MAT-files/images/',phantomName,'_list',num2str(offsetListNum),'TIimages.mat'],'TIimages')
    save([savingdir,'/MAT-files/images/',phantomName,'_list',num2str(offsetListNum),'FPimages.mat'],'FPimages')
    save([savingdir,'/MAT-files/images/',phantomName,'_list',num2str(offsetListNum),'TE.mat'],'TE')
    save([savingdir,'/MAT-files/images/',phantomName,'_list',num2str(offsetListNum),'TI.mat'],'TI')
end
offsetListNum = 3;

%% 3. Select a ROI and a sample of the background, to calculate SNR
[SNR, signal, background] = calcSNR(TEimages,TE,'showFigure');

%% 4. find signals at sample pixels
compartmentCenters = setCompartmentCenters(phantomName);
plotCompartmentCenterTCs(compartmentCenters,TEimages, TIimages, TE, TI)

%% 5. plot positions of sample pixels for TE and TR images
plotNumCompartments = 6;
sliceNumber = 2;
%%
run('plotSamplePixels_TE_TR.m')
%%
run('visualiseImages.m')

%% fit curves to calculate T1 and T2
ROI = 'fullPhantom';
[compartmentT1s, compartmentT2s, T2curves, T1curves, fittedCurve, goodness, output, F] = fitEvolutionCurves(phantomName,TEimages, TIimages, TE(2:end)', TI(2:end), ROI, compartmentCenters);

run('plotGoldStdT1T2.m')

%% 6. read in the list of timing offsets used for acquisition
run('readFingerprintOffsetList.m')
save([savingdir,'/MAT-files/fingerprintLists.mat'], 'fingerprintLists')

%% 7. simulate magnetisation evolution
%check bloch simulation by using properties of the phantom
load('fingerprintLists.mat')
% sphereD170 properties
T1 = 282.3;
T2 = 214.8;
%T1 = 600;
%T2 = 100;
%fingerprintLists(:,1,offsetListNum) = 50;
%fingerprintLists(:,2,offsetListNum) = 50;
% fingerprintLists(:,3,offsetListNum) = 90;
% fingerprintLists(:,4,offsetListNum) = 180;
freqOffset = 0;
nSlices = 2;
offsetListNum = 3;
nTimeCoursePts = 48;
nRepeats = 2;

[M, Mxy,flipAngles, imageTimes, t0s] = SimBloch(T1, T2, fingerprintLists(:,:,offsetListNum), 'showPlot', freqOffset, nSlices, nTimeCoursePts);

plotSimulatedSignal(M,Mxy,imageTimes)

%[M, Mxy,imageTimes,flipAngles, t0s] = SimBloch3(T1, T2, fingerprintLists(:,:,offsetListNum),nRepeats, freqOffset, nSlices,1);
%%
% 8. check signal simulation by plotting positions of sample pixels for the fingerprinting images
compartmentCentersList = 3;
clear FPimages
load ([phantomName,'_list',num2str(offsetListNum),'FPimages.mat'])
FPdata = reshape(squeeze(FPimages(:,:,1,:,offsetListNum)), [size(FPimages,1)*size(FPimages,2),size(FPimages,4)]);
run('plotSamplePixels.m')
%%
% plot comparison of simulation with sampled pixels
for n = 1:6
data(n,:) = FPimages(compartmentCenters(n,1,3),compartmentCenters(n,2,3),sliceNumber,:,offsetListNum);
end

plotSimComparison(Mxy,data,compartmentCenters,compartmentCentersList,nRepeats*nTimeCoursePts,sliceNumber,phantomName,workingdir)

savefig([workingdir,'/figures/compareSimwithData_Phantom_',phantomName,'__Offset_list_',num2str(offsetListNum),'_compartmentcentercoordslist:',num2str(compartmentCentersList),'.fig'])
matlab2tikz('figurehandle',simCom,'filename',[workingdir,'/DTC_report/',phantomName,'simCom',num2str(offsetListNum),'slice',num2str(sliceNumber)],'height', '\figureheight', 'width', '\figurewidth')
 
%% 9. create dictionary
load /Users/jallen/Documents/short_project_2/MAT-files/fingerprintLists.mat
%
paramList = 3;
[dictionaryParams, paramList] = setDictionaryParams(phantomName,paramList);
%
nTimeCoursePts = 24;
%%
for offsetListNum = 2:8;
    %%
    [signalDictionary, sdelT] = compileDictionary(fingerprintLists, offsetListNum, dictionaryParams, nTimeCoursePts, freqOffset, nSlices, phantomName, background);
    save([savingdir,'/MAT-files/dictionaries/',phantomName,'_list',num2str(offsetListNum),'paramList',num2str(paramList),'dictionary.mat'],'signalDictionary')
    save([savingdir,'/MAT-files/dictionaries/',phantomName,'_list',num2str(offsetListNum),'paramList',num2str(paramList),'signalDictionaryTime.mat'],'sdelT')
    
    pause(1)
end

%% 10. check similarity and use dictionary to measure T1 and T2

sliceNumber = 2 ;% slice to be analysed
clear data

% data = FPimages(compartmentCenters(1,1),compartmentCenters(1,2),:,:);

% for r = 1:size(compartmentCenters,1)
% data(r,1,sliceNumber,:) = FPimages(compartmentCenters(r,1),compartmentCenters(r,2),sliceNumber,:);
% end
%% SIMILARITY
for offsetListNum = 2:8;
    %%
    load([savingdir,'/MAT-files/images/',phantomName,'_list',num2str(offsetListNum),'FPimages.mat'])
    data = zeros(size(FPimages,1),size(FPimages,2), 24);
    %   data(r,c,sliceNumber,1:24) = squeeze(FPimages(r,c,sliceNumber,1:24,offsetListNum));
    data = squeeze(FPimages(:,:,sliceNumber,1:24,offsetListNum));
    
    disp(['offsetList',num2str(offsetListNum),', phantom:',phantomName])
    clear signalDictionary
    l = load([savingdir,'/MAT-files/dictionaries/',phantomName,'_list',num2str(offsetListNum),'paramList',num2str(paramList),'dictionary.mat']);
    signalDictionary = l.signalDictionary;
    [similarity, matchedT1, matchedT2, matchedFAdevInd, M0fit_grad, bestMatch, match_time] = calcSimilarity(data, signalDictionary(:,:,:,:,offsetListNum), sliceNumber, dictionaryParams, savingdir);
    
    save([savingdir,'/MAT-files/matches/similarity/',phantomName,'list',num2str(offsetListNum),'paramList',num2str(paramList),'similarity.mat'],'similarity')
    save([savingdir,'/MAT-files/matches/T1/',phantomName,'list',num2str(offsetListNum),'paramList',num2str(paramList),'matchedT1.mat'],'matchedT1')
    save([savingdir,'/MAT-files/matches/T2/',phantomName,'list',num2str(offsetListNum),'paramList',num2str(paramList),'matchedT2.mat'],'matchedT2')
    save([savingdir,'/MAT-files/matches/B1/',phantomName,'list',num2str(offsetListNum),'paramList',num2str(paramList),'matchedFAdevInd.mat'],'matchedFAdevInd')
    save([savingdir,'/MAT-files/matches/BestMatch/',phantomName,'list',num2str(offsetListNum),'paramList',num2str(paramList),'bestMatch.mat'],'bestMatch')
    save([savingdir,'/MAT-files/matches/MatchingTimes/',phantomName,'list',num2str(offsetListNum),'paramList',num2str(paramList),'compileDictionaryElapsedTime.mat'],'match_time')
    save([savingdir,'/MAT-files/matches/M0/',phantomName,'list',num2str(offsetListNum),'paramList',num2str(paramList),'M0fit_grad.mat'],'M0fit_grad')
   
end
%
%% visualise spread of matched T1s and T2s
% figure; hist(squeeze(matchedT1(offsetListNum,:)))
% figure;
% hist(squeeze(matchedT2(offsetListNum,:)))
% %
% figure; plot(squeeze(data(1,1,1,:)), '-*')
% hold on
% plot(squeeze(bestMatch(1,1,:))*data(1,1,1,1),'--.')

%% Once the similarity function has been run, plot and save the T1, T2 and FA deviation maps
run('plotAssignedMaps.m')

%%
for offsetListNum = 2:8
    plotMap(phantomName,'T1',offsetListNum, savingdir,compartmentCenters)
    plotMap(phantomName,'T2',offsetListNum, savingdir,compartmentCenters)
    plotMap(phantomName,'FAdevInd',offsetListNum, savingdir,compartmentCenters)
end

%%
%choose pixels and plot time courses for the fingerprinting images
plotTCs(FPimages,15:4:30, 37, 1, 2) % breaks if 2D array of points chosen

%%
for offsetListNum = 2:8
    load(['/Users/jallen/Documents/MATLAB/short_project_2/MAT-files/matches/Jacklist',num2str(offsetListNum),'paramList1scales.mat'])
    scalesFig = figure;
    for i = 1:size(compartmentCenters(:,1))
        plot(log10(squeeze(scales(compartmentCenters(i,1,3),compartmentCenters(i,2,3),:))),'.-')
        hold on
    end
    ylabel (['log_{10}(Scaling Factor)'])
    xlabel (['Image Index'])
    legend ({'Compartment 1', 'Compartment 2', 'Compartment 3', 'Compartment 4', 'Compartment 5', 'Compartment 6'},'Position',[0.35,0.6,0.25,0.1],'FontSize',8)  
    matlab2tikz('figurehandle',scalesFig,'filename',[savingdir,'/figures/',phantomName,'compartmentScales',num2str(offsetListNum)],'height', '\figureheight', 'width', '\figurewidth')
    
end