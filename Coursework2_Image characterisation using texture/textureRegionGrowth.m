tic
% load image
filename = 'mosaic8.tif';
img = imread(filename);

% parameters
D = 2;
offset = [0 D; -D D; -D 0; -D -D];
%offset = [0 D];
numLevels = 8;
window_size = 7;
half_window = floor(window_size/2);
num_dim = 4;
filter_size = [15,15];

% convert to gray image
[num_row, num_col, num_channel] = size(img);
img_gray = rgb2gray(img);
img_gray = medfilt2(img_gray, filter_size);

% compute descriptors
img_texture = zeros(num_row, num_col, num_dim);
for row = 1:num_row
    for col = 1:num_col
        
        row_win = row-half_window:row+half_window;     
        col_win = col-half_window:col+half_window;
        
        row_win = max(1,row_win);  row_win = min(row_win,num_row);
        col_win = max(1,col_win);  col_win = min(col_win,num_col);
        window = img_gray(row_win,col_win);
        
        
        glcm = graycomatrix(window,'Offset', offset, 'NumLevels', numLevels,'Symmetric',true);
        stats = graycoprops(glcm);
        
        img_texture(row, col, 1) = mean(stats.Contrast)/((size(glcm,1)-1)^2);
        img_texture(row, col, 2) = (mean(stats.Correlation)+1)/2;
        img_texture(row, col, 3) = mean(stats.Energy);
        img_texture(row, col, 4) = mean(stats.Homogeneity);
    end
end
% figure(1);
% imshow(img_texture(:, :, 1),[]);
% figure(2);
% imshow(img_texture(:, :, 2),[]);
% figure(3);
% imshow(img_texture(:, :, 3),[]);
% figure(4);
% imshow(img_texture(:, :, 4),[]);

% add descriptors to image channels
img_texture = uint8(img_texture);
data = zeros(num_row, num_col, num_channel+num_dim);
for row = 1:num_row
    for col = 1:num_col
        for idx = 1:num_channel
        data(row,col,idx) = img(row,col,idx)/255;
        end
        idx_plus = num_channel+1;
        for idx = 1:num_dim
        data(row,col,idx_plus) = img_texture(row,col,idx);
        idx_plus = idx_plus + 1;
        end
    end
end

data = imgaussfilt(data, 2);
threshold = 0.85;
[ segmented_img ] = new_region_growth( data, threshold );
%figure;
%imshow(1-((double(segmented_img)-min(segmented_img(:)))/(max(segmented_img(:)-min(segmented_img(:))))));
toc
