## PowerShell Modules Repository

### Overview

This repository contains a collection of PowerShell modules that were previously scattered across various projects. By consolidating all scripts into a single repository and converting all `.ps1`
scripts to `.psm1` modules, we have achieved a more organized and maintainable codebase. This approach not only ensures consistent usage of scripts across projects but also facilitates version control
and dependency management.

### Purpose

The primary goals of this repository are:

-   **Centralization**: All PowerShell scripts are now located in one repository.
-   **Modularity**: Scripts have been converted to modules (`.psm1`) for better structure and reuse.
-   **Version Control**: Using this repository as a dependency in other projects ensures that you lock the version of the scripts, preventing duplication and ensuring consistency.
-   **Maintainability**: Bugs and updates are managed in one place, reducing the effort required to fix or enhance scripts across multiple projects.

### How to Use

Add this repository as a dependency in your `flake.nix` file to use the PowerShell modules in your project. The following steps demonstrate how to add this repository as a dependency in your project:

```code
inputs = {
    ...
    powershell_modules.url = "github:seventymx/powershell_modules";
    ...
}
```

Pass the `powershell_modules` output to the `shellHook` in your `flake.nix` file to set the `PSModulePath` environment variable:

```code
outputs = { self, nixpkgs, flake-utils, powershell_modules }:
    ...
```

```code
shellHook = ''
    export PSModulePath=${powershell_modules}
    ...
```

### Development Guide

To develop and test the PowerShell modules in this repository, follow the steps below:

```sh
git clone $repository_url
cd powershell_modules

nix develop

code .
```

#### Version Pinning

The version of the PowerShell modules in this repository is pinned to ensure that all projects using this repository as a dependency receive the same version of the modules. To update the version of
the PowerShell modules, update the `flake.lock` file and commit the changes.

```sh
nix flake update --update-input powershell_modules
```

#### VSCode Setup

1. **Install the PowerShell Extension**: Install the `PowerShell` extension in VSCode to enable syntax highlighting, IntelliSense, and debugging support for PowerShell scripts.

2. **Update the PowerShell Path**: Add the following to your workspace `settings.json` file to specify the path to the PowerShell executable:

```SH
which pwsh
```

```json
{
    "powershell.powerShellAdditionalExePaths": {
        "nix_pwsh": "$path_to_pwsh"
    }
}
```
