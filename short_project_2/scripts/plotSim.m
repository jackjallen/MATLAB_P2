
figure; hold on
% title (['fingerprint offset list ', num2str(offsetListNum)])
ySim = Mxy(:)./Mxy(1);
plot(ySim,'x','MarkerSize',20)
y = zeros(3,(size(FPimages,4)/2));

sliceNumber = 1;

%% mean of rectangle covering most of the phantom
% for i = 1 : size((FPimages(25:35,25:35,sliceNumber,:)) ,4)/2
%     ROI = (FPimages(25:35,25:35,sliceNumber,i));
%     ROIimage(i,:) = ROI(:);
%     ROIimageMean(i) = mean(ROIimage(i,:));
%     ROIimageStd(i) = std(ROIimage(i,:));
% end
% % rectangle('position',[25 25 10 10])
% %
% normROIimageMean = squeeze(ROIimageMean/ROIimageMean(1));
% yImageROI = normROIimageMean;
% % plot(yImageROI(1:24),'^')
% errorbar(yImageROI(1:24),ROIimageStd/ROIimageMean(1),'^');

%% signal from each compartment
title (['Phantom: ',phantomName,', Offset list: ',num2str(offsetListNum),', compartment center coords list: ',num2str(compartmentCentersList)]);
for n = 1:plotNumCompartments
    for i = 1:(size(FPimages,4)/2)
        y(n,i) = squeeze(FPimages(compartmentCenters(n,1,compartmentCentersList),compartmentCenters(n,2,compartmentCentersList),sliceNumber,i,offsetListNum));
    end
    normStdBG = (std(background(:)))/y(n,1);
    y(n,:) = y(n,:)/y(n,1);
    % residuals = y(n,:) - ySim;
%     plot(y(n,1:(size(FPimages,4)/2)),'*')
    
    errorbar(y(n,:),repmat(normStdBG,1,24),'*' );
   
end
legend ('Simulated Signal', '1','2','3','4','5','6' )
xlabel 'TE indices'
ylabel 'signal (normalised to first measurement)'
savefig(['/Users/jallen/Documents/MATLAB/short_project_2/figures/compareSimwithData_Phantom_',phantomName,'__Offset_list_',num2str(offsetListNum),'_compartmentcentercoordslist:',num2str(compartmentCentersList),'.fig'])
%% figure; plot(residuals,'+')