# Tools

## markdownlint-cli

When you have a project with markdown (`.md`) files, or when building documentation sites based on markdown files (e.
g., with Mkdocs), you can use [markdownlint-cli](https://github.com/igorshubovych/markdownlint-cli) to improve your
markdown code.

Install with homebrew:

```bash
brew install markdownlint-cli
```

It uses a default ruleset to check your files, but you can also tweak that ruleset by including a `.markdownlint.
yml` or `.markdownlint.jsonc` file in your project's root. In this file you can change the ruleset. See this [yml
file](https://github.com/DavidAnson/markdownlint/blob/main/schema/.markdownlint.yaml) for an example. This file also
explains the rules and their behaviour.

### template

I use the following `.markdownlint.yml` template:

```yaml
---
default: true

# MD003/heading-style/header-style - Heading style
MD003:
  style: atx

# MD004/ul-style - Unordered list style
MD004:
  style: asterisk

# MD007/ul-indent - Unordered list indentation
MD007:
  indent: 4

# MD013/line-length - Line length
MD013: false

# MD025/single-title/single-h1 - Multiple top-level headings
# in the same document
MD025: false

# MD030/list-marker-space - Spaces after list markers
MD030:
  ul_multi: 1
  ol_multi: 2

# MD035/hr-style - Horizontal rule style
MD035:
  style: ---

# MD046/code-block-style - Code block style
MD046: false
```

## pre-commit

[pre-commit](https://pre-commit.com) helps you implement checks before committing code. You install it through pip or
poetry: `poetry add
pre-commit`. Subsequently, you create a `.pre-commit-config.yml` file where you include the checks that must be
performed.

Set up the pre-commit hooks for your project:

```bash
pre-commit install
```

Now, every time you commit code, the pre-commit hook will check your code based on the checks included in your
config file.

Manually trigger a pre-commit check:

```bash
pre-commit run --all-files
```

# plugins

There are alot of plugins that you can use when building a doc site with Mkdocs and Material theme. Some of them are
listed below.

## markdown_extensions

### admonitions

[Admonitions](https://squidfunk.github.io/mkdocs-material/reference/admonitions/), also known as call-outs, are an
excellent choice for including side content without significantly
interrupting the document flow. Material for MkDocs provides several types of admonitions and allows for the
inclusion and nesting of arbitrary content.

To enable this extension, add the following to `mkdocs.yml`:

```yaml
markdown_extensions:
  - admonition
  - pymdownx.details
  - pymdownx.superfences
```

Admonitions follow a simple syntax: a block starts with !!!, followed by a single keyword used as a type qualifier.
The content of the block follows on the next line, indented by four spaces:

!!! note
    This is a dummy block of type 'note'.

!!! note "Custom title"
    This is a dummy block of type 'note' with a custom title.

??? info
    This is a collapsable dummy block of type 'info'.

!!! bug
    This is a dummy block of type 'bug'.

You can do all kinds of stuff with this extension. Check the url above for all the variation you can use.
