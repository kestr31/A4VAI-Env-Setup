# 스크립트 도구

[![en](https://img.shields.io/badge/lang-en-red.svg)](./scripts.md)
[![kr](https://img.shields.io/badge/lang-kr-blue.svg)](./scripts-KR.md)

- 추가 스크립트 도구는 `scripts` 디렉토리 아래에 있습니다.
- **스크립트 목록:**
    - `setup.sh`, `clone.sh`, `reset.sh`, `clean.sh`

## 스크립트 정보

### `setup.sh`

- **기능:**
    - **개발 환경 설정.**
        - 시스템 초기 업데이트 및 업그레이드
        - NVIDIA 드라이버 확인 및 설치
        - Docker 및 NVIDIA Container Toolkit 설치
        - **공통 종속성과 도구 설치:**
            - **공통 종속성**: Curl, GPG, OpenSSL, Wget
            - **개발 도구**: Git, Neovim, VSCode
            - **VSCode 확장 프로그램**: Copilot, Docker, Python, Remote Development
- **요구사항:**
    - `sudo` 권한 (필요 시 요청).
- **입력 인자**
    - 없음
- **예시:**

```bash
./scripts/setup.sh
```

### `clone.sh`

- **기능:**
    - 필요한 리포지토리를 클론하고 디렉토리 구조 생성.
        - 다음 리포지토리를 클론:
            - [JOCIIIII/PX4-SITL-Runner (main)](https://github.com/JOCIIIII/PX4-SITL-Runner.git)
        - 다음 디렉토리 구조 생성:
            - `Airsim_Binary`
- **입력 인자**
    - `ALL`: 모든 리포지토리를 클론하고 디렉토리 생성.
    - `DIR`: 디렉토리만 생성.
    - `REPO`: 리포지토리만 클론.
- **예시:**

```bash
./scripts/clones.sh ALL
```

- **참고:**
    - 이는 `reset.sh` 및 `clean.sh`에도 적용됩니다.
    - `clones.sh` 스크립트의 동작은 `scripts/include/envDef.sh`에 정의된 변수를 편집하여 수정할 수 있습니다.
        - **클론/생성할 리소스는 다음 형식으로 정의됩니다:**
            - **디렉토리: `DIR_DICT`. 디렉토리 이름과 경로의 키-값 쌍으로 구성된 사전.**
                - 키: 디렉토리 식별자.
                - 값: 디렉토리 경로.
            - **리포지토리: `REPO_DICT`. 리포지토리 이름과 URL의 키-값 쌍으로 구성된 사전.**
                - 키: 리포지토리 식별자.
                - 값: 문자열 배열.
                    - 인덱스 0: 리포지토리를 클론할 디렉토리.
                    - 인덱스 1: 리포지토리 URL.
                    - 인덱스 2: 체크아웃할 브랜치. (선택 사항, 기본값은 "")

> Bash는 사전에서 값을 배열로 지원하지 않습니다. 해결 방법으로 배열을 BASE64 문자열로 인코딩합니다.<br/>

- `DIR_DICT` 및 `REPO_DICT` 수정 예시:

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

- **기능:**
    - 개발 리소스를 초기 상태로 재설정합니다. (디렉토리의 내용이 삭제됩니다)
- **입력 인자**
    - `ALL`: 모든 리소스를 재설정합니다.
    - `DIR`: 디렉토리만 재설정합니다.
    - `REPO`: 리포지토리만 재설정합니다.
- **예시:**

```bash
./scripts/reset.sh ALL
```

> `reset.sh` 스크립트의 동작은 `scripts/include/envDef.sh`에 정의된 변수를 편집하여 수정할 수 있습니다.<br/>
> 자세한 내용은 `clone.sh`의 주석을 확인하십시오.

### `clean.sh`

- **기능:**
    - `clone.sh`로 다운로드한 모든 리소스를 삭제합니다.
- **입력 인자**
    - `ALL`: 모든 리소스를 삭제합니다.
    - `DIR`: 디렉토리만 삭제합니다.
    - `REPO`: 리포지토리만 삭제합니다.
- **예시:**

```bash
./scripts/clean.sh ALL
```

> `clean.sh` 스크립트의 동작은 `scripts/include/envDef.sh`에 정의된 변수를 편집하여 수정할 수 있습니다.<br/>
> 자세한 내용은 `clone.sh`의 주석을 확인하십시오.

---

> 본 문서는 ChatGPT 4o를 이용해 `scripts.md`를 번역한 문서입니다.