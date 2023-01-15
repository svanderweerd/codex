---
title: Setting up Python
---

This page describes the setup of Python on a Macbook.

# Managing Python environments

Although Python is pre-installed on MacBooks, you don't want to use the system's version or any single Python
version to manage your Python apps. You will install a lot of packages, and ideally you want them segregated based
on use case i.e. project. Hence, we will make use of [Pyenv](https://github.com/pyenv/pyenv), which we can install
using Homebrew:

```shell
brew install pyenv
```

## Adding pyenv to your shell environment

After install pyenv, you need to add it to your shell environment so that your shell (`zsh`) is able to find the
package. To setup the shell environment, run the following in your shell:

```shell
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc
```

## Install Python versions

To install other Python versions, simply use `pyenv install <Python version>`. In the example below we install
Python 3.10.6:

```shell
pyenv install 3.10.6
```

* `pyenv install -l` returns a list of all Python version you can install.
* Python version that you install, are located in the `/Users/<user>/.pyenv/versions` directory.

## Switch between Python versions

Use `pyenv versions` to see which Python versions you have installed. Simply switch to an installed version by using
the commands:

* `pyenv shell <version>` -- select for the current shell that you have active.
* `pyenv local <version>` -- automatically select whenever you are in the current directory.
* `pyenv global <version>` -- set a global (i.e., default) Python version for your MacBook user.

# Dependency & Package management

We have used several package managers (conda, pip, mamba, miniconda) but we are currently sticking with [Poetry]
(<https://python-poetry.org>).

## Poetry & Pyenv

If you are having trouble ensuring Poetry uses the correct Python version, check out [this](<https://github>.
com/python-poetry/poetry/issues/5252) Github issue, which goes into more detail.
