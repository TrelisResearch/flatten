# Flatten

Flatten is a tool for creating a repository structure file and a flattened repository file.

This is particularly useful for coding, e.g. with Cursor, where you can include your folder structure within a chat to ground the model.

## Installation

To use the Flatten tool, copy the flatten repo `fr.sh` script into your repository:

```
curl -O https://raw.githubusercontent.com/TrelisResearch/flatten/main/fr.sh
chmod +x fr.sh
```

## Usage

### Generate Repository Structure

To generate or update the repository structure file:

```
./fr.sh
```

This will create a `repo_structure.yaml` file in the current directory, containing the structure of your repository.

### Flatten Repository Contents

To generate the repository structure and flatten the contents of text files:

```
./fr.sh --ffc
```

This will create both `repo_structure.yaml` and `flattened_repo.txt` files. The latter will contain the contents of all text files in the repository.

## Features

- Ignores files and directories listed in `.gitignore` and `.flattenignore`
- Automatically excludes the `fr.sh` script itself from flattening
- Supports a wide range of text file formats commonly used in programming, including:
  - Web development (js, ts, jsx, tsx, vue, html, css, scss, less)
  - Backend languages (py, rb, php, java, go, rs, c, cpp, h, hpp, cs, swift, kt, scala)
  - Data formats (json, yaml, yml, xml, sql, graphql)
  - Scripting languages (sh, bash, zsh)
  - Other languages (r, m, f, f90, jl, lua, pl, pm, t, ps1, bat, asm, s, nim, ex, exs, clj, lisp, hs, erl, elm)
  - Documentation (md, txt)
- Skips binary files when flattening
- Includes text files from all directories in the repository

## Note

Ensure you run the script from the root of your repository for accurate results.