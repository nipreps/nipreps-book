"""Utilities for accessing shared tutorial datasets."""
from __future__ import annotations

import os
from pathlib import Path
from typing import Final

import requests

__all__ = ["ensure_tutorial_dwi_path", "load_tutorial_dmri_dataset"]

_DATA_URL: Final[str] = (
    "https://files.osf.io/v1/resources/8k95s/providers/osfstorage/68e5464a451cf9cf1fc51a53"
)
_DEFAULT_FILENAME: Final[str] = "dwi_full_brainmask.h5"
_ENV_VAR: Final[str] = "NIPREPS_TUTORIAL_DATA"


def _resolve_data_path(filename: str = _DEFAULT_FILENAME) -> Path:
    env_path = os.environ.get(_ENV_VAR)
    if env_path:
        return Path(env_path)

    cwd = Path.cwd().resolve()
    for directory in (cwd, *cwd.parents):
        if (directory / "pixi.toml").exists() or (directory / ".git").exists():
            return directory / "data" / filename

    return cwd / "data" / filename


def ensure_tutorial_dwi_path(filename: str = _DEFAULT_FILENAME) -> Path:
    """Return the path to the cached tutorial DWI dataset, downloading it if needed."""
    datapath = _resolve_data_path(filename)
    if not datapath.exists():
        datapath.parent.mkdir(parents=True, exist_ok=True)
        response = requests.get(_DATA_URL, allow_redirects=True, timeout=60)
        response.raise_for_status()
        datapath.write_bytes(response.content)
    return datapath


def load_tutorial_dmri_dataset(filename: str = _DEFAULT_FILENAME) -> Path:
    """Return the path to the cached tutorial DWI dataset."""
    return ensure_tutorial_dwi_path(filename)
