About dMRIPRep
==============

Introduce dMRIPrep based on OSR talk


Project Structure
-----------------

```
dmriprep
├── CHANGES.rst
├── Dockerfile
├── LICENSE
├── MANIFEST.in
├── Makefile
├── README.rst
├── dmriprep
│   ├── __about__.py
│   ├── __init__.py
│   ├── _version.py
│   ├── cli/
│   │   └── tests/
│   ├── config
│   │   ├── __init__.py
│   │   ├── reports-spec.yml
│   │   └── testing.py
│   ├── conftest.py
│   ├── data
│   │   ├── __init__.py
│   │   ├── boilerplate.bib
│   │   ├── flirtsch
│   │   │   ├── b02b0.cnf
│   │   │   ├── b02b0_1.cnf
│   │   │   ├── b02b0_2.cnf
│   │   │   ├── b02b0_4.cnf
│   │   │   └── b02b0_quick.cnf
│   │   └── tests
│   │       ├── THP
│   │       │   ├── CHANGES
│   │       │   ├── README
│   │       │   ├── dataset_description.json
│   │       │   └── sub-THP0005
│   │       │       ├── anat
│   │       │       │   ├── sub-THP0005_T1w.json
│   │       │       │   └── sub-THP0005_T1w.nii.gz
│   │       │       └── dwi
│   │       │           ├── sub-THP0005_dwi.bval
│   │       │           ├── sub-THP0005_dwi.bvec
│   │       │           ├── sub-THP0005_dwi.json
│   │       │           └── sub-THP0005_dwi.nii.gz
│   │       ├── bval
│   │       ├── bvec
│   │       ├── config.toml
│   │       ├── dwi.nii.gz
│   │       ├── dwi.tsv
│   │       └── dwi_mask.nii.gz
│   ├── interfaces
│   │   ├── __init__.py
│   │   ├── images.py
│   │   ├── reports.py
│   │   └── vectors.py
│   ├── utils
│   │   ├── __init__.py
│   │   ├── bids.py
│   │   ├── images.py
│   │   ├── misc.py
│   │   ├── tests/
│   │   └── vectors.py
│   └── workflows
│       ├── __init__.py
│       ├── base.py
│       ├── dwi
│       │   ├── __init__.py
│       │   ├── base.py
│       │   ├── outputs.py
│       │   └── util.py
│       └── fmap
│           ├── __init__.py
│           └── base.py
├── docs/
├── get_version.py
├── pyproject.toml
├── setup.cfg
├── setup.py
└── versioneer.py
```