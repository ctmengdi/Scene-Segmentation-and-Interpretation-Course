function [ segmented_img ] = new_region_growth( input_img, threshold )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

input_img = double(input_img);
label_value = 1;                       % Initialize the label value with 1

input_img = imgaussfilt(input_img, 1); % Smoothing the image

[num_row, num_column, num_channel] = size(input_img); % Get the size of input image

label_img = zeros(num_row, num_column);% Create an empty image for saving labels

% Go through all the pixels of input image
for row = 1:num_row
    for col = 1:num_column
        % Check if the pixel is labeled
        if label_img(row, col) == 0
            % Initialize the mean value
            mean = [];
            for chan = 1:num_channel
                mean(chan, :) = input_img(row, col, chan);
            end            
            pxl_num = 1;
            label_img(row, col) = label_value;
            queue = [row, col];       % Initialize the queue with first unlabeled pixel
            
            % Check all the pixels in the queue list
            while isempty(queue) ~= 1
                % Check the 3x3 neighbors
                for row_neigh = (queue(1,1)-1):(queue(1,1)+1)
                    for col_neigh = (queue(1,2)-1):(queue(1,2)+1)
                        % Avoid out-of-boundary issue
                        row_neigh = max(1,row_neigh);  row_neigh = min(row_neigh, num_row);
                        col_neigh = max(1,col_neigh);  col_neigh = min(col_neigh, num_column);
                        % Compute the difference between current pixel and mean value
                        diff_square = [];
                        for chan = 1:num_channel
                            diff_square(chan,:) = (input_img(row_neigh, col_neigh, chan)-mean(chan))^2;
                        end
                        diff = sqrt(double(sum(diff_square)));
                        % Label the pixel in the same region and put it in queue
                        if diff <= threshold && label_img(row_neigh, col_neigh) == 0
                            for chan = 1:num_channel
                                mean(chan,:) = (mean(chan)*pxl_num + input_img(row_neigh,col_neigh,chan))/(pxl_num+1);
                            end
                            pxl_num = pxl_num + 1;
                            label_img(row_neigh,col_neigh) = label_value;
                            queue = [queue; row_neigh, col_neigh];
                        end
                    end
                end
                queue(1,:) = [];         % Delete the pixel which has been checked
            end
            label_value = label_value+ 1;
        end
    end
end

%Show the number of regions
num_label = label_value-1;  
S = sprintf('The number of labels/regions is %i', num_label);
disp(S);

%Show the labeled image
figure;

%Comment this 2 lines if there's no pre-processing
subplot(1,2,1); imshow(uint8(input_img), []); title('smoothed image');
subplot(1,2,2);

segmented_img = imshow(label2rgb(label_img,'colorcube', 'k', 'shuffle'));
title('labeled image');

end

