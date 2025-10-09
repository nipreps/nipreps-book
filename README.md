# NiPreps Book

NiPreps Book is a [Jupyter Book](https://jupyterbook.org) that accompanies the NiPreps
community workshops. The material walks readers through implementing a
head-motion–correction workflow for diffusion MRI (dMRI) data using tools from
[DIPY](https://dipy.org), [NiTransforms](https://nipy.org/nitransforms), and the
broader NiPreps ecosystem. Besides explaining the motivation behind the
"analysis-grade" data philosophy, the book provides hands-on notebooks that show
how to assemble reproducible preprocessing components.

## Get started

### Run it in your browser

If you prefer not to install anything locally, launch the notebooks in an
ephemeral Binder session:

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/nipreps/nipreps-book/main?urlpath=lab/tree/docs/notebook)

Binder sessions can take a few minutes to start and reset after inactivity.

### Build the book locally

This repository is configured with [pixi](https://prefix.dev/pixi) for
reproducible environments:

1. [Install pixi](https://prefix.dev/docs/pixi/installation).
2. Create the environment and install the dependencies:

   ```bash
   pixi install
   ```
3. Build the static HTML version of the book:

   ```bash
   pixi run build-book
   ```

The rendered site will be available under `docs/_build/html`. To explore the
notebooks interactively, launch JupyterLab with `pixi run serve` and open the
files inside `docs/notebook/`.

### Working with the tutorial dataset

Several chapters rely on a small diffusion MRI dataset. The helper module
`tutorial_data.py` automatically downloads the dataset to `data/` the first time
it is requested. If you already have a copy of the file, set the
`NIPREPS_TUTORIAL_DATA` environment variable to point to it before running the
notebooks.

## Repository layout

- `docs/` – Markdown content, notebook sources, and static assets for the book.
- `data/` – Cached example diffusion MRI dataset used throughout the tutorial.
- `binder/` – Configuration used to build the Binder environment.
- `pixi.toml` – Environment definition and common development tasks.
- `tutorial_data.py` – Utility functions for fetching the tutorial dataset.

## Contributing

Issues, feature requests, and pull requests are welcome! Please review the
open issues on GitHub and let us know how the material can be improved. When
submitting changes, follow the standard GitHub workflow and ensure the book
builds locally (`pixi run build-book`) before opening a pull request.

## Citation

If you use the material in your own work, please cite the
project as described in [CITATION.cff](CITATION.cff).
