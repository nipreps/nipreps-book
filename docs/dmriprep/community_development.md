# Community Development

https://nipreps.org/community/CONTRIBUTING/

TO DO: CREATE MINI LESSON TO DEMONSTATE EACH CONCEPT

## Joining the conversation

## Getting started with GitHub

The project can be found here: https://github.com/nipreps/dmriprep

dmriprep
├── CHANGES.rst
├── Dockerfile
├── LICENSE
├── MANIFEST.in
├── Makefile
├── README.rst
├── dmriprep                    # contains all code
│   ├── __about__.py
│   ├── __init__.py
│   ├── _version.py
│   ├── cli/                    # contains code for adjusting the command line arguments
│   ├── config
│   │   ├── __init__.py
│   │   ├── reports-spec.yml
│   │   └── testing.py
│   ├── conftest.py
│   ├── data/                   # contains sample data that can be used to create function tests
│   ├── interfaces              # contains Nipype interfaces that act as building blocks for individual tasks
│   │   ├── __init__.py
│   │   ├── images.py
│   │   ├── reports.py
│   │   └── vectors.py
│   ├── utils                   # contains functions called by interfaces
│   │   ├── __init__.py
│   │   ├── bids.py
│   │   ├── images.py
│   │   ├── misc.py
│   │   ├── tests/
│   │   └── vectors.py
│   └── workflows               # contains workflows that are created by combining interfaces
│       ├── __init__.py
│       ├── base.py
│       ├── dwi
│       │   ├── __init__.py
│       │   ├── base.py
│       │   ├── outputs.py
│       │   └── util.py
│       └── fmap
│           ├── __init__.py
│           └── base.py
├── docs/                       # contains code for building documentation
├── get_version.py
├── pyproject.toml
├── setup.cfg
├── setup.py
└── versioneer.py
```


### Understanding issues

### Making a change

```{code-cell} bash
git config --global user.name "Carl Jacobi"
git config --global user.email "carl.jacobi@gmail.com"
```

```{code-cell} bash
git clone https://github.com/carljacobi/dmriprep.git

cd dmriprep

git remote add upstream https://github.com/nipreps/dmriprep.git
```

```{code-cell} bash
git fetch upstream
git checkout master
git merge upstream/master
```

```{code-cell} bash
git fetch upstream

git checkout -b enh/hmc upstream/master
```