Tree is a recursive directory listing command that produces a depth indented listing of files.

# Installation

To install `tree`, simply use homebrew:

```shell
brew install tree
```

# Usage

Running `tree` in your current directory, returns a tree of your directory structure, included the nested
directories and files. It will look like this:

```shell
$ tree

.
├── Apps
│   ├── Octave.md
│   ├── README.md
│   ├── Settings.md
│   ├── araxis-merge.jpg
│   ├── beyond-compare.png
│   ├── delta-walker.jpg
│   ├── filemerge.png
│   └── kaleidoscope.png
├── CONTRIBUTING.md
├── Cpp
│   └── README.md
├── Docker
│   └── README.md
├── Git
│   ├── README.md
│   └── gitignore.md
└── Go
    └── README.md

5 directories, 14 files
```

To limit the recursion you can pass an -L flag and specify the maximum depth tree will use when searching.

```shell
tree -L 1
```

will output:

```shell
.
├── Apps
├── CONTRIBUTING.md
├── Cpp
├── Docker
├── Git
└── Go

5 directories, 1 files
```

To store the output to a file, simply add the `-o` flag, followed by the name of the file you want to write to.

## Formatting issues

If the output is strange, consider adding the `--charset` option, followed by either `ascii` or `unicode`.
