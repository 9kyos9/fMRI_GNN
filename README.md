# Multi-Atlas Based Graph Neural Network for Alzheimer's Disease Prediction Using rs-fMRI Data
This is a repository for Dissertation Project at KCL


## Dataset Availability

The dataset used for this study was obtained from the Alzheimer's Disease Neuroimaging Initiative (ADNI) database ([adni.loni.usc.edu](http://adni.loni.usc.edu)).
Due to the Data Use Agreement with the Alzheimer's Disease Neuroimaging Initiative (ADNI), the raw data used in this project cannot be shared publicly. To access the data, please visit the ADNI website and apply for access directly.


## Project Structure
The file structure of this project is as follows.

```bash
├── README.md
├── script
│   ├── conn_ad_preprocessing_template.m
│   ├── conn_ad_preprocessing_template.m
│   └── unzip.m
├── notebooks
│   ├── fMRIGCN_w_knngraph_ensemble_hyperparametertuning_nestedCV.ipynb
│   └── fMRIGCN_w_knngraph_ensemble_no_hyperparametertuning.ipynb
└──  src
    ├── ROI_AALExtraction.py
    └── ROI_SchaeferExtraction.py

``` 

- **script/**: Contains MATLAB scripts for preprocessing the raw fMRI data using the CONN Toolbox.

- **src/**: Contains Python modules for feature extraction. These scripts are used to extract regional time series and generate functional connectivity (FC) matrices based on various brain atlases (e.g., AAL, Schaefer).

- **notebooks/**: Contains Jupyter notebooks for the main analysis pipeline, which includes graph construction, GNN model training, and evaluation.
    - `fMRIGCN_w_knngraph_ensemble_hyperparametertuning_nestedCV.ipynb`: Implements the full GNN ensemble model with a robust hyperparameter tuning process using Nested Cross-Validation.
    - `fMRIGCN_w_knngraph_ensemble_no_hyperparametertuning.ipynb`: Implements the same pipeline but without hyperparameter tuning. These two notebooks are provided to directly compare and demonstrate the impact of hyperparameter tuning on model performance.
    - **Note on Model Implementation**: As the single-atlas models are the building blocks for the final ensemble model, they are implemented within both notebooks. Upon execution, the notebooks will output the evaluation results for the individual single-atlas models and the final ensemble model, allowing for a comprehensive performance comparison.
