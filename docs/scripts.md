# Utility Scripts

[![en](https://img.shields.io/badge/lang-en-red.svg)](./scripts.md)
[![kr](https://img.shields.io/badge/lang-kr-blue.svg)](./scripts-KR.md)

- Additional utility scripts are provided under `scripts` directory.
- **Currently following scripts are provided:**
    - `setup.sh`, `clone.sh`, `reset.sh`, `clean.sh`

## Script Information

### `setup.sh`

- **Feature:**
    - **Setup the development environment.**
        - Initial update and upgrade of the system
        - Check and installation of NVIDIA drivers
        - Installation of Docker and NVIDIA Container Toolkit
        - **Installation of common dependencies and tools:**
            - **Common dependencies**: Curl, GPG, OpenSSL, Wget
            - **Development Tools**: Git, Neovim, VSCode
            - **VSCode Extensions**: Copilot, Docker, Python, Remote Development
- **Requirement:**
    - `sudo` permission (Ask when required).
- **Input Arguments**
    - None
- **Example:**

```bash
./scripts/setup.sh
```

### `clone.sh`

- **Feature:**
    - Clone the required repositories and create directory structure.
        - Cloning the following repositories:
            - [JOCIIIII/PX4-SITL-Runner (main)](https://github.com/JOCIIIII/PX4-SITL-Runner.git)
        - Creating the following directory structure:
            - `Airsim_Binary`
- **Input Arguments**
    - `ALL`: Clone all the repositories and create directories.
    - `DIR`: Create directories only.
    - `REPO`: Clone repositories only.
- **Example:**
```bash
./scripts/clones.sh ALL
```

- **Note:**
    - This will also be applied to `reset.sh` and `clean.sh`.
    - Behavior of `clones.sh` script can be modified by editing the variable defined in `scripts/include/envDef.sh`.
        - **Resources to be cloned/created are defined as following format:**
            - **Directory: `DIR_DICT`. Dictionary with key-value pair of directory name and path.**
                - Key: Identifier for the directory.
                - Value: Path to the directory.
            - **Repository: `REPO_DICT`. Dictionary with key-value pair of repository name and URL.**
                - Key: Identifier for the repository.
                - Value: Array of Strings.
                    - Index 0: Directory to clone the repository.
                    - Index 1: URL of the repository.
                    - Index 2: Branch to checkout. (Optional, defaults to "")

> Bash does not support array as a value in dictionary. For workaround, the array is encoded as a BASE64 string.<br/>

- Example of modifying `DIR_DICT` and `REPO_DICT`:

```bash
declare -A DIR_DICT
    # AIRSIM_BINARY
    DIR_DICT["AIRSIM_BINARY"]=${DEV_DIR}/Airsim_Binary
    DIR_DICT["MORE_DIR_01"]=${DEV_DIR}/More_Dir_01

...

declare -A REPO_DICT
    # PX4_SITL_RUNNER
    PX4_SITL_RUNNER=(
        ${DEV_DIR}/PX4-SITL-Runner
        "https://github.com/JOCIIIII/PX4-SITL-Runner.git"
        ""
    )
    # ANOTHER_REOP
    ANOTHER_REPO=(
        ${DEV_DIR}/Another_Repo
        "https://github.com/whoami/Another_Repo.git"
        "main"
    )
    REPO_DICT["PX4_SITL_RUNNER"]=$(printf '%s\0' "${PX4_SITL_RUNNER[@]}" | openssl enc -a)
    REPO_DICT["ANOTHER_REPO"]=$(printf '%s\0' "${ANOTHER_REPO[@]}" | openssl enc -a)
```


### `reset.sh`

- **Function:**
    - Reset the development resources to initial state. (Contents in directories will be deleted)
- **Input Arguments**
    - `ALL`: Reset all the resources.
    - `DIR`: Reset directories only.
    - `REPO`: Reset repositories only.
- **Example:**
```bash
./scripts/reset.sh ALL
```

> Behavior of `reset.sh` script can be modified by editing the variable defined in `scripts/include/envDef.sh`.<br/>
> Check the note of `clone.sh` for more information.

### `clean.sh`

- **Function:**
    - Delete all resources downloaded by `clone.sh`.
- **Input Arguments**
    - `ALL`: Delete all the resources.
    - `DIR`: Delete directories only.
    - `REPO`: Delete repositories only.
- **Example:**
```bash
./scripts/clean.sh ALL
```

> Behavior of `clean.sh` script can be modified by editing the variable defined in `scripts/include/envDef.sh`.<br/>
> Check the note of `clone.sh` for more information.

---
