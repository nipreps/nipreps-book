# Before we start: How to follow this tutorial

This tutorial contains a mix of lecture-based and interactive components.
The interactive components can be executed in your personal computer locally or using the [Binder](https://jupyter.org/binder) service.
You are welcome to follow along however you like, whether you just want to listen or code along with us.
Each of the chapters involving code are actually Jupyter notebooks!

## <i class="fa fa-rocket" aria-hidden="true"></i> Using Binder

Clicking the Binder icon in the top right corner will launch an interactive computing environment with all of the necessary software packages pre-installed.

This is the easiest and quickest way to get started.

```{figure} ../images/binder_link.png
:name: binder_link

```

```{caution}
If using Binder, please be aware that the state of the computational environment it provides is not permanent.
If you are inactive for more than 10 minutes, the environment will timeout and all data will be lost.
If you would like to preserve any progress, please save the changed files to your computer.
```

## <i class="fas fa-hammer"></i> Local installation ("bare-metal")

If you would like to follow along using your own setup and you have a functional Python environment, you can:

```bash

# 1. clone this repository
git clone https://github.com/nipreps/nipreps-book

# 2. install the necessary python packages in your Python environment
cd nipreps-book && pip install -r requirements.txt

# 3. launch a Jupyter lab instance
jupyter lab

```

The image registration lesson requires an installation of [ANTs](https://github.com/ANTsX/ANTs).
Separate instructions can be found for [Linux/MacOS users](https://github.com/ANTsX/ANTs/wiki/Compiling-ANTs-on-Linux-and-Mac-OS) and [Windows users](https://github.com/ANTsX/ANTs/wiki/Compiling-ANTs-on-Windows-10).

## <i class="fab fa-docker"></i> Local installation ("docker containers")



```bash

docker run

```