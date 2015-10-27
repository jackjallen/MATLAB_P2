function [similarity, matchedT1, matchedT2, matchedFAdev, M0fit_grad, bestMatch, el] = calcSimilarity(data, signalDictionary, sliceNumber, dictionaryParams, workingdir)
% Author: Jack Allen.
% Institution: University of Oxford.
% Contact: jack.allen@jesus.ox.ac.uk
%
% Description: A function to calculate the similarity of a time course with
% each entry in a dictionary of time courses and find the best match. 

%% simularity measure
disp('calculating similarity: started')

%mask to exclude time course outside of ROI
load([workingdir,'/MAT-files/mask.mat'])
mask = reshape(mask,[64*64, 1]);

%time course of interest
data = reshape(data,[size(data,1)*size(data,2), 24]); 
%simulated signals
sd = reshape(signalDictionary, [ size(signalDictionary,1)*size(signalDictionary,2)*size(signalDictionary,3), 24]);

%initialise maps
similarity = zeros(size(data,1), size(sd,1) );
maxSimilarityScore = zeros(size(data,1),1);
bestMatch = zeros(size(data,1),size(data,2));
matchedT1 = zeros(size(data,1),1);
matchedT2 = zeros(size(data,1),1);
matchedFAdev = zeros(size(data,1),1);
M0fit_grad = zeros(size(data,1),1);

M0model = @(a,x) a*x;

tic

pp = parpool(4);
for data_i = 1:size(data,1)
    
    if mask(data_i,1) > 0
       parfor sd_i = 1:size(sd,1)
            similarity(data_i,sd_i) = dot(sd(sd_i,:), data(data_i,:))/(norm(sd(sd_i,:))*norm(data(data_i,:))) ;
       end
        TCsimilarity = similarity(data_i,:);
        TCsimilarity = reshape(TCsimilarity,[size(signalDictionary,1),size(signalDictionary,2),size(signalDictionary,3)]);
        %   find highest similarity score for TC of interest
        [maxSimilarityScore(data_i), bestSimulatedSignalIndex]  = max(TCsimilarity(:));  
        %Find the parameters associated with the best match          
        [bestT1ind, bestT2ind, bestFAdevInd] = ind2sub(size(TCsimilarity),bestSimulatedSignalIndex);
        %Assign the parameters to the timecourse of interest
        matchedT1(data_i) = max(dictionaryParams(1, bestT1ind));
        matchedT2(data_i) = max(dictionaryParams(2, bestT2ind));
        matchedFAdev(data_i) = max(dictionaryParams(3, bestFAdevInd)); 
        M0fit = fit(squeeze(bestMatch(data_i, :))', data(data_i,:)',M0model,'Upper',[6000],'Lower',[0],'StartPoint',[500] );
        M0fit_grad(data_i,1) = M0fit.a;
    
    end   
    disp(['calculating similarity: ',num2str( (data_i/size(data,1))*100) , ' percent complete'])
    
end

%reshape the assigned parameter maps into 2D form
matchedT1 = reshape(matchedT1, [sqrt(size(matchedT1)), sqrt(size(matchedT1))]);
matchedT2 = reshape(matchedT2, [sqrt(size(matchedT2)), sqrt(size(matchedT2))]);
matchedFAdev = reshape(matchedFAdev, [sqrt(size(matchedFAdev)), sqrt(size(matchedFAdev))]);
M0fit_grad = reshape(M0fit_grad, [sqrt(size(data,1)),sqrt(size(data,1))]);

%shutdown parpool
delete(pp)

el = toc;
end