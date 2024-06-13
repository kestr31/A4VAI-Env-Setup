# A4-VAI 개발환경 구성

[![en](https://img.shields.io/badge/lang-en-red.svg)](./setupEnvironment.md)
[![kr](https://img.shields.io/badge/lang-kr-blue.svg)](./setupEnvironment-KR.md)

## 사전 요구사항

- **다음 사양을 갖춘 PC:**
    - 64비트 x86 프로세서
    - NVIDIA GPU
        - 최소 드라이버 요구사항: Linux 450.80.02 이상
        - Turing (RTX 20) 이후의 아키텍처의 기기를 권장합니다.
    - 16 GB 이상의 RAM
    - 512 GB 이상의 여유 디스크 공간
        - SSD의 사용을 권장합니다.
    - 인터넷 연결
- **Ubuntu Linux, 버전 18.04 이상**
    - 권장사항: Ubuntu 20.04 LTS 이상
- **Non-Headless 환경**
    - 일반잔적인 데스크탑 환경을 사용하는 것이 좋습니다.
    - Wayland는 권장하지 않습니다. 가급적 X11을 사용하세요.

## 환경 설정

- **설정 절차의 대부분은 스크립트로 자동화되어 있습니다.**
    - `scripts/setup.sh`를 사용하면 개발환경 구성에 필요한 SW 들을 설치할 수 있습니다.
- **스크립트가 수행하는 작업은 다음과 같습니다:**
    - 시스템 초기 업데이트 및 업그레이드 (`apt update`, `apt upgrade`)
    - NVIDIA 하드웨어 및 드라이버 설치 여부 확인 및 설치
    - Docker 및 NVIDIA Container Toolkit 설치
    - **기본 패키지 및 개발 도구 설치:**
        - **기본 패키지**: Curl, GPG, OpenSSL, Wget
        - **개발 도구**: Git, Neovim, VSCode
        - **VSCode 확장 프로그램**: Copilot, Docker, Python, Remote Development
- 스크립트를 실행하는 데 `sudo` 권한이 필요합니다.
    - 또는 `root` 사용자로 실행할 수는 있습니다 (비권장).

> `setup.sh`는 WSL2 또는 컨테이너화된 환경에서 실행되지 않도록 작성했습니다.<br/>s
> 해당 환경들에서는 스크립트가 종료되도록 작성했고, 버그로 인해 스트립트가 실행되더라도 설정이 완료되지 않을 수 있습니다.

- `setup.sh`는 아래와 같이 실행하면 됩니다:
- **`sudo`로 스크립트를 실행하지 마세요. 스크립트가 필요하면 `sudo` 권한을 요청합니다.**
    - 스크립트를 `sudo`로 실행하면 VSCode 확장 프로그램 설치 시 문제가 발생할 수 있습니다.

```bash
./scripts/setup.sh
```

> NVIDIA 드라이버 설치 후 시스템이 재부팅되니 **<U>스크립트를 실행하기 전에 작업을 저장하세요</U>**.<br/>
> 재부팅 후 스크립트를 다시 실행하여 설정을 완료하세요.
## 리소스 획득

- 스크립트 `scripts/clones.sh`를 사용하면 개발에 필요한 리소스를 다운로드할 수 있습니다.
    - 이 스크립트는 도커 볼륨 마운트를 위한 폴더를 만들어주기도 합니다.
- **기본 상태의 스크립트가 수행하는 작업은 다음과 같습니다:**
    - Git 저장소 Clone:
        - [JOCIIIII/PX4-SITL-Runner (main)](https://github.com/JOCIIIII/PX4-SITL-Runner.git)
    - 폴더 생성:
        - `Airsim_Binary`

> `clones.sh` 스크립트가 수행하는 작업은 `scripts/include/envDef.sh`에 정의된 변수를 편집하여 수정할 수 있습니다.

- `clones.sh`는 아래와 같이 실행하면 됩니다:

```bash
./scripts/clones.sh
```

## 추가 도구

- 개발 편의성을 위한 추가 스크립트들은 `scripts` 경로 내에 있습니다.
- 해당 스크립트들의 사용과 관련해서는 [`scripts.md`](./scripts.md)를 참고하세요.

---

> 본 문서는 ChatGPT 4o를 이용해 `setupEnvironment.md`를 번역한 문서입니다.