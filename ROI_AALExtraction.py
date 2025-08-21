import os
import numpy as np
import pandas as pd
from nilearn import datasets
from nilearn.image import load_img
from nilearn.maskers import NiftiLabelsMasker
from nilearn.connectome import ConnectivityMeasure

# AAL Atlas Download and load
print("AAL Atlas Downloading...")
aal_atlas = datasets.fetch_atlas_aal()
atlas_filename = aal_atlas.maps
labels = aal_atlas.labels
print(f"AAL Atlas file: {atlas_filename}")
print(f"AAL ROI number: {len(labels)}")

# Finding subject files
base_data_dir = '/Volumes/Sandisk/AD_fMRI_GNN/CN_bids/'
print(f"Searching .. '{base_data_dir}'...")

subject_paths = [
    os.path.join(root, file)
    for root, _, files in os.walk(base_data_dir)
    for file in files
    if file.startswith('dswausub-') and file.endswith('.nii')
]
subject_paths.sort()

if not subject_paths:
    print(f"Error: Cannot Find a file in '{base_data_dir}' with 'dswausub-'.")
    exit()

print(f"Total subject number: {len(subject_paths)}")
print(f"First 5 files directory:\n" + "\n".join(subject_paths[:5]))

# ouput directory
output_dir = '/Volumes/Sandisk/AD_fMRI_GNN/CN_conn_roi_data/aal'
os.makedirs(output_dir, exist_ok=True)

# NiftiLabelsMasker 
masker = NiftiLabelsMasker(
    labels_img=atlas_filename,
    labels=labels,
    standardize='zscore',
    memory='nilearn_cache',
    verbose=1,
    resampling_target='data'
)


connectome_measure = ConnectivityMeasure(kind='correlation', standardize='zscore')


for fmri_img_path in subject_paths:
    sub_id = os.path.splitext(os.path.basename(fmri_img_path))[0]  
    print(f"\n--- Processing Subject: {sub_id} ---")

    if not os.path.exists(fmri_img_path):
        print(f"Warning: Cannot Find {fmri_img_path}. Skipping...")
        continue

    # fMRI data loading
    fmri_img = load_img(fmri_img_path)
    print(f"Loaded fMRI image shape: {fmri_img.shape}")

    # ROI BOLD time series 추출
    print("ROI BOLD time series extracting...")
    time_series = masker.fit_transform(fmri_img)
    print(f"Extracted ROI time series shape: {time_series.shape}")

    # Time series DataFrame 
    roi_labels = labels[1:]  # 'Background' 
    roi_df = pd.DataFrame(time_series, columns=roi_labels)
    output_csv_path = os.path.join(output_dir, f'{sub_id}_roi.csv')
    roi_df.to_csv(output_csv_path, index=False)
    print(f"ROI BOLD Time Series Saved: '{output_csv_path}'")

    # connectivity matrix calculation and saving
    print("AAL FC Matrix...")
    connectivity_matrix = connectome_measure.fit_transform([time_series])[0]
    connectivity_df = pd.DataFrame(connectivity_matrix, index=roi_labels, columns=roi_labels)
    output_conn_csv_path = os.path.join(output_dir, f'{sub_id}_connectivity_matrix.csv')
    connectivity_df.to_csv(output_conn_csv_path, index=True)
    print(f"Connectivity Matrix Saved: '{output_conn_csv_path}'")

print("\n Complete for all subjects.")
