clc; clear; close all;

% Select an image
[filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp;*.tif', 'Image Files (*.jpg, *.png, *.bmp, *.tif)'}, 'Select an Image');
if isequal(filename, 0)
    disp('User canceled the operation');
    return;
end

% Read and convert to grayscale if RGB
img = imread(fullfile(pathname, filename));
if size(img, 3) == 3
    img = rgb2gray(img);
end

% Add salt & pepper noise
noisy_img = imnoise(img, 'salt & pepper', 0.05);

% Window size
w = 3;
se = true(w);

% Median, Min, Max filters
median_filtered = medfilt2(noisy_img, [w w]);
min_filtered = ordfilt2(noisy_img, 1, se);
max_filtered = ordfilt2(noisy_img, w*w, se);

% Midpoint filter
midpoint_filtered = uint8((double(min_filtered) + double(max_filtered)) / 2);

% Alpha-trimmed mean filter
alpha = 0.25;
pad = floor(w/2);
padded = padarray(noisy_img, [pad pad], 'symmetric');
alpha_filtered = zeros(size(noisy_img));

for i = 1:size(noisy_img, 1)
    for j = 1:size(noisy_img, 2)
        window = double(padded(i:i+w-1, j:j+w-1));
        sorted_vals = sort(window(:));
        d = floor(alpha * numel(sorted_vals));  % number to trim
        trimmed = sorted_vals((d+1):(end-d));
        alpha_filtered(i,j) = mean(trimmed);
    end
end
alpha_filtered = uint8(alpha_filtered);

% Display results
figure;
subplot(2,3,1), imshow(img), title('Original Image');
subplot(2,3,2), imshow(noisy_img), title('Noisy Image');
subplot(2,3,3), imshow(median_filtered), title('Median Filtered');
subplot(2,3,4), imshow(min_filtered), title('Min Filtered');
subplot(2,3,5), imshow(max_filtered), title('Max Filtered');
subplot(2,3,6), imshow(midpoint_filtered), title('Midpoint Filtered');

% Save all outputs
[~, name, ~] = fileparts(filename);
imwrite(median_filtered, fullfile(pathname, [name, '_median_filtered.png']));
imwrite(min_filtered, fullfile(pathname, [name, '_min_filtered.png']));
imwrite(max_filtered, fullfile(pathname, [name, '_max_filtered.png']));
imwrite(midpoint_filtered, fullfile(pathname, [name, '_midpoint_filtered.png']));
imwrite(alpha_filtered, fullfile(pathname, [name, '_alpha_trimmed_filtered.png']));

disp('Filtered images saved in the same directory as the original image.');
