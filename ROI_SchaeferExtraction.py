import os
import numpy as np
import pandas as pd
from nilearn import datasets
from nilearn.image import load_img
from nilearn.maskers import NiftiLabelsMasker
from nilearn.connectome import ConnectivityMeasure

# Schaefer Atlas Download and load
print("\nSchaefer Atlas Downloading...")
schaefer_atlas = datasets.fetch_atlas_schaefer_2018(n_rois=200, yeo_networks=17, resolution_mm=1)
schaefer_atlas_filename = schaefer_atlas.maps
schaefer_labels = schaefer_atlas.labels
print(f"Schaefer Atlas file: {schaefer_atlas_filename}")
print(f"Schaefer ROI number: {len(schaefer_labels)}")

# Finding subject files
base_data_dir = '/Volumes/Sandisk/AD_fMRI_GNN/AD_bids/'
print(f"Searching ..'{base_data_dir}'...")

subject_files = [
    os.path.join(root, file)
    for root, _, files in os.walk(base_data_dir)
    for file in files
    if file.startswith('swausub-') and file.endswith('.nii')
]
subject_files.sort()

if not subject_files:
    print(f"Warning: Cannot Find a file in '{base_data_dir}' starts with 'swausub-'")
    exit()

print(f"Number of subjects: {len(subject_files)}")
print(f"First 5 Subjects' files (처음 5개): {subject_files[:5]}")

# Output directory
output_dir = '/Volumes/Sandisk/AD_fMRI_GNN/AD_roi_data/schaefer/'
os.makedirs(output_dir, exist_ok=True)

# NiftiLabelsMasker 
schaefer_masker = NiftiLabelsMasker(
    labels_img=schaefer_atlas_filename,
    labels=schaefer_labels,
    standardize='zscore',
    memory='nilearn_cache',
    verbose=1,
    resampling_target='data'
)

connectome_measure = ConnectivityMeasure(kind='correlation', standardize='zscore')

for fmri_img_path in subject_files:
    subject_id = os.path.splitext(os.path.basename(fmri_img_path))[0]  
    print(f"\n--- Processing Subject: {subject_id} ---")

    if not os.path.exists(fmri_img_path):
        print(f"Warning: {fmri_img_path} Cannot find a file. Skipping.")
        continue

    fmri_img = load_img(fmri_img_path)
    print(f"Loaded fMRI image shape: {fmri_img.shape}")

    # Schaefer atlas BOLD tioseries extraction
    print("Schaefer ROI BOLD time series extracting...")
    schaefer_time_series = schaefer_masker.fit_transform(fmri_img)
    schaefer_roi_labels = [label for label in schaefer_labels if label != 'Background']
    schaefer_df = pd.DataFrame(schaefer_time_series, columns=schaefer_roi_labels)
    print(f"Schaefer based extracted ROI time series shape: {schaefer_time_series.shape}")

    # time series CSV
    output_schaefer_csv_path = os.path.join(output_dir, f'{subject_id}_schaefer_roi_timeseries.csv')
    schaefer_df.to_csv(output_schaefer_csv_path, index=False)
    print(f"Schaefer ROI BOLD Time Series is saved in '{output_schaefer_csv_path}'.")

    # functional connectivity matrix
    print("Schaefer FC matrix calculating...")
    schaefer_connectivity_matrix = connectome_measure.fit_transform([schaefer_time_series]).squeeze()
    schaefer_connectivity_df = pd.DataFrame(
        schaefer_connectivity_matrix,
        index=schaefer_roi_labels,
        columns=schaefer_roi_labels
    )
    output_schaefer_conn_csv_path = os.path.join(output_dir, f'{subject_id}_schaefer_connectivity_matrix.csv')
    schaefer_connectivity_df.to_csv(output_schaefer_conn_csv_path, index=True)
    print(f"Schaefer Connectivity Matrix is saved in '{output_schaefer_conn_csv_path}'.")

print("\nFinished for all subjects.")
