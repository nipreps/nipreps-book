About dMRIPRep
==============

In his 2019 ISMRM talk on the state of consensus in diffusion MRI preprocessing, Jelle Veraart polled the polled the developers of some major software packages.

![preprocessing_consensus](../images/veraart-2019.png)
[Image Processing: Possible Guidelines for the Standardization & Clinical Applications](https://www.ismrm.org/19/program_files/MIS15.htm)

This led us to create a roadmap for *dMRIPrep*'s development
![dmriprep_workflow](../images/figure1.svg)

*dMRIPrep* is part of the NiPreps organization
- robust
- easy to use
- reproducible
- "glass box" architecture
- regular maintenance and upgrading of methods
![nipreps_chart](../images/nipreps-chart.svg)

![contributors](../images/contributors.png)

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
├── dmriprep                    # contains all code
│   ├── __about__.py
│   ├── __init__.py
│   ├── _version.py
│   ├── cli/                    # contains code for adjusting the command line arguments
│   ├── config
│   │   ├── __init__.py
│   │   ├── reports-spec.yml
│   │   └── testing.py
│   ├── conftest.py
│   ├── data/                   # contains sample data that can be used to create function tests
│   ├── interfaces              # contains Nipype interfaces that act as building blocks for individual tasks
│   │   ├── __init__.py
│   │   ├── images.py
│   │   ├── reports.py
│   │   └── vectors.py
│   ├── utils                   # contains functions called by interfaces
│   │   ├── __init__.py
│   │   ├── bids.py
│   │   ├── images.py
│   │   ├── misc.py
│   │   ├── tests/
│   │   └── vectors.py
│   └── workflows               # contains workflows that are created by combining interfaces
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
├── docs/                       # contains code for building documentation
├── get_version.py
├── pyproject.toml
├── setup.cfg
├── setup.py
└── versioneer.py
```

Resources
---------
- [Contemporary Python Packaging by Chris Markiewicz](https://gist.github.com/effigies/9bbb424535d6a1d838d6325191c0a736)
- [Nipype Tutorials by Michael Notter](https://miykael.github.io/nipype_tutorial/)
