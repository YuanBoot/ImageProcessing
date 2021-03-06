close all;
clear;
clc;

TargetImg   = imread('image/pool_target.jpg');
SourceImg   = imread('image/bear.jpg');
SourceMask  = imbinarize(rgb2gray(imread('image/bear_mask.jpg')));%creates a binary image from image

SrcBoundry = bwboundaries(SourceMask); 
% Trace region boundaries in binary image
% BW must be a binary image where nonzero pixels belong to an object and 0-pixels constitute the background.


% figure, imshow(SourceImg), axis image
% hold on
% for k = 1:length(SrcBoundry)
%     boundary = SrcBoundry{k};
%     plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 1)
% end
% title('Source image intended area for cutting from');j

position_in_target = [10, 225];%xy
[TargetRows, TargetCols, ~] = size(TargetImg);

[row, col] = find(SourceMask);
% returns the linear indices corresponding to the nonzero entries of the array
% non-zero pixels' locations

% *********************

% get a smaller mask, precise mask
start_pos = [min(col), min(row)]; 
end_pos   = [max(col), max(row)];
frame_size  = end_pos - start_pos + 1;

% I can choose stop the programe and warn the user
% if (frame_size(1) + position_in_target(1) > TargetCols)
%     position_in_target(1) = TargetCols - frame_size(1);
% end
% 
% if (frame_size(2) + position_in_target(2) > TargetRows)
%     position_in_target(2) = TargetRows - frame_size(2);
% end

MaskTarget = zeros(TargetRows, TargetCols);

% ????????????
s = [TargetRows, TargetCols];
x = row - start_pos(2) + position_in_target(2);
y = col - start_pos(1) + position_in_target(1);

% IND = sub2ind(SIZ,I,J) 
% returns the linear index equivalent to the 
% row and column subscripts in the arrays I and J for a matrix of
% size SIZ. 

MaskTarget(sub2ind(s, x, y)) = 1;

% figure;
% imshow(MaskTarget);

% ***********************

TargBoundry = bwboundaries(MaskTarget);

% figure, imshow(TargetImg), axis image
% hold on
% for k = 1:length(TargBoundry)
%     boundary = TargBoundry{k};
%     plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 1)
% end
% title('Target Image with intended place for pasting Source');

% *********************

templt = [0 -1 0; -1 4 -1; 0 -1 0];
LaplacianSource = imfilter(double(SourceImg), templt, 'replicate');

VR = LaplacianSource(:, :, 1);
VG = LaplacianSource(:, :, 2);
VB = LaplacianSource(:, :, 3);

% *********************

TargetImgR = double(TargetImg(:, :, 1));
TargetImgG = double(TargetImg(:, :, 2));
TargetImgB = double(TargetImg(:, :, 3));

% put these gradient value in the target
% image by restriction of the mask
% VR(SourceMask(:)) get nonzero pixels in VR by the mask; 
% the size of VR and SourceMask should be equal to each other
% TargetImgR(logical(MaskTarget(:))) get nonzero pixels in VR by the mask; 
TargetImgR(logical(MaskTarget(:))) = VR(SourceMask(:)); 
TargetImgG(logical(MaskTarget(:))) = VG(SourceMask(:));
TargetImgB(logical(MaskTarget(:))) = VB(SourceMask(:));
% TargetImgR(logical(MaskTarget(:))) = 0; 
% TargetImgG(logical(MaskTarget(:))) = 0;
% TargetImgB(logical(MaskTarget(:))) = 0;

% 
TargetImgNew = cat(3, TargetImgR, TargetImgG, TargetImgB);
% figure, imagesc(uint8(TargetImgNew)), axis image, title('Target image with laplacian of source inserted');

% ********************* 

AdjacencyMat = calcAdjancency( MaskTarget );

% **********************

ResultImgR = MyPoissonSolver(TargetImgR, MaskTarget, AdjacencyMat, TargBoundry);
ResultImgG = MyPoissonSolver(TargetImgG, MaskTarget, AdjacencyMat, TargBoundry);
ResultImgB = MyPoissonSolver(TargetImgB, MaskTarget, AdjacencyMat, TargBoundry);

ResultImg = cat(3, ResultImgR, ResultImgG, ResultImgB);

figure;
imshow(uint8(ResultImg));
