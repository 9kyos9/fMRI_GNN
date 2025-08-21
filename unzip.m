

clear all;
clc;

base_data_path = '/Volumes/Sandisk/AD_fMRI_GNN/AD_output_bids';

file_pattern = '*.gz';

search_subfolders = true;

gz_files_to_unzip = {};

if search_subfolders

    fprintf('Searching for %s files in %s and its subfolders...\n', file_pattern, base_data_path);

    try
        dir_struct = dir(fullfile(base_data_path, '**', file_pattern));
        for i = 1:length(dir_struct)

            if ~dir_struct(i).isdir
                gz_files_to_unzip{end+1} = fullfile(dir_struct(i).folder, dir_struct(i).name);
            end
        end
    catch 
        warning('Recursive dir search failed. Falling back to manual recursion. Consider updating MATLAB for "dir(..., ''recurse'')".');

        dir_struct = dir(fullfile(base_data_path, file_pattern));
        for i = 1:length(dir_struct)
            if ~dir_struct(i).isdir
                gz_files_to_unzip{end+1} = fullfile(dir_struct(i).folder, dir_struct(i).name);
            end
        end
    end
else

    fprintf('Searching for %s files in %s...\n', file_pattern, base_data_path);
    dir_struct = dir(fullfile(base_data_path, file_pattern));
    for i = 1:length(dir_struct)
        if ~dir_struct(i).isdir
            gz_files_to_unzip{end+1} = fullfile(dir_struct(i).folder, dir_struct(i).name);
        end
    end
end


if isempty(gz_files_to_unzip)
    fprintf('No .gz files found matching the pattern "%s" in "%s". Script aborted.\n', file_pattern, base_data_path);
    return; 
end

fprintf('Found %d .gz files to unzip.\n', length(gz_files_to_unzip));


for k = 1:length(gz_files_to_unzip)
    current_gz_file = gz_files_to_unzip{k};
    
    fprintf('Unzipping: %s ... ', current_gz_file);
    
    try
        gunzip(current_gz_file);


        fprintf('Done.\n');
        
    catch ME
        fprintf(2, 'FAILED! Error: %s\n', ME.message);
    end
end

fprintf('--- .gz file unzipping complete! ---\n');