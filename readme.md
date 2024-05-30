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

TODO - Add instructions on how to depend on this repository with Nix Flakes (version pinning).

### Development Guide

To develop and test the PowerShell modules in this repository, follow the steps below:

```sh
git clone $repositoryUrl
cd powershell_modules

nix develop

code .
```

#### VSCode Setup

1. **Install the PowerShell Extension**: Install the `PowerShell` extension in VSCode to enable syntax highlighting, IntelliSense, and debugging support for PowerShell scripts.

2. **Update the PowerShell Path**: If you dont do this, the PowerShell formatter will not work. Add the following to your `settings.json`:

```SH
which pwsh
```

```json
{
    "powershell.powerShellExePath": "$pathToPwsh"
}
```