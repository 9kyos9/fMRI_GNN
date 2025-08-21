NSUBJECTS = 105;
base_dir = '/Volumes/Sandisk/AD_fMRI_GNN/AD_bids';

cwd = pwd;  

sub_folders = dir(fullfile(base_dir, 'sub-*'));
sub_names = {sub_folders.name};
length(sub_names)

if length(sub_names) ~= NSUBJECTS
    error('피험자 폴더 수와 NSUBJECTS 변수가 일치하지 않습니다.');
end

FUNCTIONAL_FILE = cell(NSUBJECTS, 1);
STRUCTURAL_FILE = cell(NSUBJECTS, 1);


for nsub = 1:NSUBJECTS
    current_sub_dir = fullfile(base_dir, sub_names{nsub});
    

    found_func_files = conn_dir(fullfile(current_sub_dir, 'func','sub-*_task-rest_bold.nii'));
    if ischar(found_func_files)
        found_func_files = cellstr(found_func_files);
    end
    found_func_files = found_func_files(cellfun(@(f) isempty(strfind(f, '._')), found_func_files));
    
    if length(found_func_files) ~= 1
        error('Subject %s: expected exactly one functional file, found %d', sub_names{nsub}, length(found_func_files));
    end
    FUNCTIONAL_FILE{nsub} = char(found_func_files); 

    found_anat_files = conn_dir(fullfile(current_sub_dir, 'anat', 'sub-*_T1w.nii'));
    if ischar(found_anat_files)
        found_anat_files = cellstr(found_anat_files);
    end
    found_anat_files = found_anat_files(cellfun(@(f) isempty(strfind(f, '._')), found_anat_files));
    
    if length(found_anat_files) ~= 1
        error('Subject %s: expected exactly one anatomical file, found %d', sub_names{nsub}, length(found_anat_files));
    end
    STRUCTURAL_FILE{nsub} = char(found_anat_files); 

    

end

FUNCTIONAL_FILE
STRUCTURAL_FILE

if rem(length(FUNCTIONAL_FILE),NSUBJECTS),error('mismatch number of functional files %n', length(FUNCTIONAL_FILE));end
if rem(length(STRUCTURAL_FILE),NSUBJECTS),error('mismatch number of anatomical files %n', length(FUNCTIONAL_FILE));end
nsessions=length(FUNCTIONAL_FILE)/NSUBJECTS;
FUNCTIONAL_FILE=reshape(FUNCTIONAL_FILE,[nsessions, NSUBJECTS]);
STRUCTURAL_FILE={STRUCTURAL_FILE{1:NSUBJECTS}};
disp([num2str(size(FUNCTIONAL_FILE,1)),' sessions']);
disp([num2str(size(FUNCTIONAL_FILE,2)),' subjects']);
TR=3; % Repetition time


% CONN-SPECIFIC SECTION: RUNS PREPROCESSING/SETUP/DENOISING/ANALYSIS STEPS

clear batch;
batch.filename=fullfile(cwd,'ad_preprocessing_template.mat');           

% SETUP & PREPROCESSING step                  
batch.Setup.isnew=1;
batch.Setup.nsubjects=NSUBJECTS;
batch.Setup.RT=TR;                                        % TR (seconds)
batch.Setup.functionals=repmat({{}},[NSUBJECTS,1]);       
for nsub=1:NSUBJECTS,for nses=1:nsessions,batch.Setup.functionals{nsub}{nses}{1}=FUNCTIONAL_FILE{nses,nsub}; end; end
batch.Setup.structurals=STRUCTURAL_FILE;                 
nconditions=nsessions;                                  
if nconditions==1
    batch.Setup.conditions.names={'rest'};
    for ncond=1,for nsub=1:NSUBJECTS,for nses=1:nsessions,              batch.Setup.conditions.onsets{ncond}{nsub}{nses}=0; batch.Setup.conditions.durations{ncond}{nsub}{nses}=inf;end;end;end     
else
    batch.Setup.conditions.names=[{'rest'}, arrayfun(@(n)sprintf('Session%d',n),1:nconditions,'uni',0)];
    for ncond=1,for nsub=1:NSUBJECTS,for nses=1:nsessions,              batch.Setup.conditions.onsets{ncond}{nsub}{nses}=0; batch.Setup.conditions.durations{ncond}{nsub}{nses}=inf;end;end;end    
    for ncond=1:nconditions,for nsub=1:NSUBJECTS,for nses=1:nsessions,  batch.Setup.conditions.onsets{1+ncond}{nsub}{nses}=[];batch.Setup.conditions.durations{1+ncond}{nsub}{nses}=[]; end;end;end
    for ncond=1:nconditions,for nsub=1:NSUBJECTS,for nses=ncond,        batch.Setup.conditions.onsets{1+ncond}{nsub}{nses}=0; batch.Setup.conditions.durations{1+ncond}{nsub}{nses}=inf;end;end;end 
end
batch.Setup.preprocessing.steps='default_mni';
batch.Setup.preprocessing.sliceorder='interleaved (Philips)';
batch.Setup.done=1;
batch.Setup.overwrite='Yes';


conn_batch(batch); 
clear batch;
batch.filename=fullfile(cwd,'ad_preprocessing_template.mat');          

% DENOISING step
% CONN Denoising                          
batch.Denoising.filter=[0.01, 0.1];               
batch.Denoising.done=1;
batch.Denoising.overwrite='Yes';


% FIRST-LEVEL ANALYSIS step
% CONN Analysis                                  
batch.Analysis.done=1;
batch.Analysis.overwrite='Yes';

% Run all analyses
conn_batch(batch);

% CONN Display
% launches conn gui to explore results
conn
conn('load',fullfile(cwd,'ad_preprocessing_template.mat'));
conn gui_results

lk
