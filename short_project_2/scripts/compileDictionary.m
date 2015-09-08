function [signalDictionary] = compileDictionary(fingerprintLists, offsetListNums, dictionaryParams, nTimeCoursePts, freqOffset, nSlices, background)

%% DICTIONARY

signalDictionary = zeros(numel(dictionaryParams(1,:)), numel(dictionaryParams(2,:)), numel(dictionaryParams(3,:)) , nTimeCoursePts, numel(offsetListNums));

for offsetListNum = offsetListNums;
originalFA1s = fingerprintLists(:,3,offsetListNum);
originalFA2s = fingerprintLists(:,4,offsetListNum);


tic
for i = 1:sum(dictionaryParams(1,:)>0)
    
    %vary T1
    T1 = dictionaryParams(1,i);
    
    for j = 1:sum(dictionaryParams(2,:)>0)
        
        % vary T2
        T2 = dictionaryParams(2,j);
        
        for k = 1:sum(dictionaryParams(3,:)>0)
            
            % apply B1 variation range
            fingerprintLists(:,3,offsetListNum) = originalFA1s*(dictionaryParams(3,k));
            fingerprintLists(:,4,offsetListNum) = originalFA2s*(dictionaryParams(3,k));
            
            
                
 [~, signalDictionary(i,j,k,:,offsetListNum), ~, ~] =  SimBloch(T1, T2, fingerprintLists(:,:,offsetListNum), 'dontPlot', freqOffset, nSlices);
            
            %% add noise to the simulated signals
           
%             SNR = 0.655*squeeze(signalDictionary(i,j,k,:))/std(background(:));
%             for tPt = 1:size(signalDictionary,4)
%                 signalDictionary(i,j,k,tPt) =  awgn(signalDictionary(i,j,k,tPt),SNR(tPt));
%             end
            
        end
    end
    
    disp(['compiling dictionary for offset list ', num2str(offsetListNum),': ',num2str( (i/numel(dictionaryParams(1,:)))*100) , ' percent complete'])
end
toc
%%
% figure;
% hold
% plot(Mxy,'-.*')
% for i = 1:numel(dictionaryParams(1,:))
%     for j = 1:numel(dictionaryParams(2,:))
% plot(squeeze(signalDictionary(i,j,:)),'-^')
%     end
% end

end

end
