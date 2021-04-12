# Community development

```{admonition} Objectives
- Discover how "open source" projects are organized (*NiPreps* in particular)
- Describe what a contribution is
- Learn where to get help before making a contribution
```

All *NiPreps* are open to community feedback and contributions.
Contributing to seemingly big projects can feel scary at first.
This lesson will help orient you to how an example *NiPreps* project is organized and how to begin making a contribution.

## Getting started with GitHub

For this example, let's take a look at the *dMRIPrep* repository found [here](https://github.com/nipreps/dmriprep).

```{figure} ../images/project_structure.png
:name: project_structure
```

The `README` is rendered on the main page of the project.
If a project were a home, the `README` would be the door mat.
It describes what the project does, who it is for, how to get started, and where to find key resources.

Below is a more detailed breakdown of the project as well as a brief description of any areas of importance.

```
dmriprep
├── CHANGES.rst
├── CONTRIBUTING.md
├── Dockerfile
├── LICENSE
├── MANIFEST.in
├── Makefile
├── README.rst
├── dmriprep                    # contains all code
│   ├── cli/                    # contains code for adjusting the command line arguments
│   ├── config/                 # contains configuration files
│   ├── data/                   # contains sample data that can be used for testing code
│   ├── interfaces/             # contains Nipype interfaces that act as building blocks for individual tasks
│   ├── utils/                  # contains functions called by NiPype interfaces
│   └── workflows               # contains NiPype workflows that are created by combining interfaces
│       ├── base.py
│       ├── dwi/
│       └── fmap/
├── docs/                       # contains code for building documentation
├── get_version.py
├── pyproject.toml
├── setup.cfg
├── setup.py
└── versioneer.py
```

## Checking the contributing guidelines

Before contributing to an open-source initiative, your first move *should* be checking how the project is seeking external feedback.
Typically, that is stated in a `CONTRIBUTING.md` file located in the project's root or `docs` folder.

All *NiPreps* projects share a common set of [contributing guidelines](https://nipreps.org/community/).

```{figure} ../images/contrib_guidelines.png
:name: contributing_guidelines
```

## Preparing a proposal for a new feature, documentation, or a bug fix

Impromptu contributions are typically difficult to absorb by projects involving several developers and/or with many users.
For this reason, its best to first browse through the project's [home page](https://github.com/nipreps/dmriprep).

There are two locations where you'll find details about ongoing and future work.
The [existing and past pull requests tab](https://github.com/nipreps/dmriprep/pulls) will give you an idea of what new features/bug fixes are currently in progress, and you can also check the requirements to get a pull request accepted by looking at closed (and "merged") pull requests.

Next to that tab, you'll find [the issue tracker tab](https://github.com/nipreps/dmriprep/issues/).
There, you should check that the feature you have in mind is not already in the works.
Opening a new issue, requesting feedback, and gauging interest are generally very welcome.

Head to [the new features page](https://nipreps.org/community/features/) to learn more about the process of proposing a new feature.

Once you get the 👍 from the project maintainers, you are ready to begin your contribution!

## Plan ahead

It's important to start off by defining the problem.
Have a clear aim for what you want your contribution to achieve.
While you are making changes, you might discover certain ideas that hadn't come to mind before.
However, it's important to stay on target and keep your contribution easily digestible.

## Making a change

From here, continue following the [Making a change secion](https://nipreps.org/community/CONTRIBUTING/#making-a-change) of the contributing guidelines.
This section goes into more detail on how to create a local copy of a GitHub project and use version control to keep track of your changes.

You can find a brief summary below:

Make sure your git credentials are configured.

```bash
git config --global user.name "Carl Jacobi"
git config --global user.email "carl.jacobi@gmail.com"
```

[Fork](https://docs.github.com/en/github/getting-started-with-github/fork-a-repo) the project of interest and [clone](https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository) your forked repository to your computer.

```bash
git clone https://github.com/carljacobi/dmriprep.git
```

To keep up with changes, add the "upstream" repository (the original repository that you forked) as a remote to your locally cloned repository.

```bash
cd dmriprep

git remote add upstream https://github.com/nipreps/dmriprep.git
```

Keep your fork up to date with the upstream repository.

```bash
git fetch upstream
git checkout master
git merge upstream/master
```
