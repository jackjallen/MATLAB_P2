function plot_matched_maps(savingdir,phantomName,paramList,offsetListNum,dictionaryParams,mapType, ROI)
%% Author: Jack Allen
% jack.allen@jesus.ox.ac.uk
%
% Function to plot a map of parameters that have been assigned via the MRF method

%%
    load([savingdir,'/MAT-files/matches/T1/',phantomName,'list',num2str(offsetListNum),'paramList',num2str(paramList),'matchedT1.mat'])
    load([savingdir,'/MAT-files/matches/T2/',phantomName,'list',num2str(offsetListNum),'paramList',num2str(paramList),'matchedT2.mat'])
    load([savingdir,'/MAT-files/matches/BestMatch/',phantomName,'list',num2str(offsetListNum),'paramList',num2str(paramList),'bestMatch.mat'])
    load([savingdir,'/MAT-files/matches/M0/',phantomName,'list',num2str(offsetListNum),'paramList',num2str(paramList),'M0fit_grad.mat'])

    switch mapType
        case 'B1'
    % B1
    FA_fig = figure;
    set(FA_fig,'name',[phantomName,', List',num2str(offsetListNum),', B1 deviation'])
    imagesc(squeeze(matchedFAdev(:,:)));
    axis off
    colormap jet
    colorbar
    cFA = colorbar;
    cmin = min(dictionaryParams(3,1:sum(dictionaryParams(3,:) ~= 0))) - 0.1*min(dictionaryParams(3,1:(sum(dictionaryParams(3,:) ~= 0))));
    cmax = max(dictionaryParams(3,1:sum(dictionaryParams(3,:) ~= 0)));
    caxis([cmin,cmax])
    ylabel(cFA,'Fraction of B1')
    saveas(FA_fig, [savingdir,'/figures/',phantomName,'matchedFAdevIndoffsetlist',num2str(offsetListNum),'.png'])
    matlab2tikz('figurehandle',FA_fig,'filename',[savingdir,'/figures/',phantomName,'slice',num2str(sliceNumber),'FAlist',num2str(offsetListNum),'ParamList',num2str(paramList)],'height', '\figureheight', 'width', '\figurewidth')
   
    	case 'T1'
    % T1
    matchedT1_fig = figure;
    set(matchedT1_fig,'name',[phantomName,', List',num2str(offsetListNum),', T1'])
    imagesc(matchedT1(:,:))
    axis off
    colormap jet
    %title ([phantomName,', List',num2str(offsetListNum),', T1'])
    cT1 = colorbar;
    switch phantomName
        case 'sphereD170'
            cmin = min(dictionaryParams(1,1:sum(dictionaryParams(1,:) ~= 0))) - 0.1*min(dictionaryParams(1,1:(sum(dictionaryParams(1,:) ~= 0))));
            cmax = max(dictionaryParams(1,1:sum(dictionaryParams(1,:) ~= 0)))  
        case 'Jack'
            switch ROI
                case 'compartments'
                    cmax = compartmentT1s(2);
                    cmin = 50;
                case 'fullPhantom'
                    cmin = 50;
                    cmax = 300;
            end
    end
    cT1.YTick = [cmin : 10 : cmax];
    caxis([cmin,cmax])
    ylabel(cT1,'T1 (ms)')
    %saveas(matchedT1_fig, filenameT1 )
    %saveas(matchedT1_fig, [filename,'/',phantomName,'matchedT1offsetlist',num2str(offsetListNum),'-1.png'])
  %  matlab2tikz('figurehandle',matchedT1_fig,'filename',[savingdir,'/figures/',phantomName,'slice',num2str(sliceNumber),'T1list',num2str(offsetListNum)','ParamList',num2str(paramList)],'height', '\figureheight', 'width', '\figurewidth')
    
        case 'T2'
    %% T2
    matchedT2_fig = figure; imagesc(matchedT2(:,:))
    axis off
    set(matchedT2_fig,'name',[phantomName,', List',num2str(offsetListNum),', T2'])
    colormap jet
    %title ([phantomName,', List',num2str(offsetListNum),', T2'])
    cT2 = colorbar;
    switch phantomName
        case 'sphereD170'
            cmin = min(dictionaryParams(2,1:sum(dictionaryParams(2,:) ~= 0))) - 0.1*min(dictionaryParams(2,1:(sum(dictionaryParams(2,:) ~= 0))));
            cmax = max(dictionaryParams(2,1:sum(dictionaryParams(2,:) ~= 0))) ;
        case 'Jack'
            for i = 1:size(compartmentCenters(:,:,3),1)-1
                temp(i) = matchedT2(squeeze(compartmentCenters(i,1,2)),squeeze(compartmentCenters(i,2,2)))
            end
            cmin = min(temp);
            cmax = max(temp);
            cmin = 10;
            cmax = 110;
            
    end
    cT2.YTick = [cmin : 10 : cmax];
    caxis([cmin,cmax])
    ylabel(cT2,'T2 (ms)')
    saveas(matchedT2_fig, [savingdir,'/figures/',phantomName,'matchedT2offsetlist',num2str(offsetListNum),'.png'])
  %  matlab2tikz('figurehandle',matchedT2_fig,'filename',[savingdir,'/figures/',phantomName,'slice',num2str(sliceNumber),'T2list',num2str(offsetListNum),'ParamList',num2str(paramList)],'height', '\figureheight', 'width', '\figurewidth')

        case 'M0'
    %% M0
    M0fit_grad_fig = figure; imagesc(M0fit_grad(:,:));
    axis off
    set(M0fit_grad_fig,'name',[phantomName,', List',num2str(offsetListNum),', M0fit_grad'])
    colormap jet
    cM0fit_grad = colorbar;
    ylabel(cM0fit_grad,'M_{0}R [a.u.]')
    saveas(M0fit_grad_fig, [savingdir,'/figures/',phantomName,'M0fit_grad',num2str(offsetListNum),'.png'])
   % matlab2tikz('figurehandle',M0fit_grad_fig,'filename',[savingdir,'/figures/',phantomName,'slice',num2str(sliceNumber),'M0fit_grad',num2str(offsetListNum),'ParamList',num2str(paramList)],'height', '\figureheight', 'width', '\figurewidth')
    
    end
end