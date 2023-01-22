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

There are a couple of things that we have tried in the past when we wanted to setup a package & environment manager
for Python. For instance, we have tried conda, miniconda, mamba and poetry. Based on our experience with these
services, I have decided to stick with [Poetry](https://www.python-poetry.org).
A [Redditor](https://www.reddit.com/r/Python/comments/r6aqji/how_do_you_deploy_python_applications/) has the following
to say about it:

!!! note

    For larger projects package building and containerisation are preferred. Most people suggest the use of poetry
    and pyproject.toml (not setup.py, which is outdated) to build a package that is then uploaded to a private
    package server. This package is then installed into a docker container, which can be deployed.

    In general, Python applications should be packaged, as the use of packaging allows for richer metadata and more
    robust handling of dependencies as well as the ability to install the package directly at a later date if need be.

    No one has suggested the use of conda for deployment, which I was surprised by given its prevalence in the data
    science community.

Additionally, check out
this [article](https://blogs.sap.com/2022/05/08/why-you-should-use-poetry-instead-of-pip-or-conda-for-python-projects/)
on why you should use poetry over other package and dependency managers.

## Poetry & Pyenv

If you are having trouble ensuring Poetry uses the correct Python version, check
out [this](https://github.com/python-poetry/poetry/issues/5252) Github issue, which goes into more detail.
