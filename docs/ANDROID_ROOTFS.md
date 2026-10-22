# Android rootfs 配置与维护

Android 本地终端通过 PRoot 运行 Alpine Linux。默认用户、shell 和预装软件由仓库中的一份配置管理；完整环境随 APK 离线分发。普通 Flutter 构建消费已生成的镜像，只有显式运行镜像更新流程才会解析新的软件版本。

## 配置入口

编辑 `app_plugin/android_shell/android/src/main/assets/shell/rootfs-config.json`：

```json
{
  "schemaVersion": 1,
  "user": {
    "name": "gao",
    "uid": 1000,
    "gid": 1000,
    "home": "/home/gao",
    "shell": "/bin/zsh"
  },
  "packages": [
    "neovim", "bash", "zsh", "ripgrep", "gawk", "sed", "openssh", "openssl"
  ],
  "sourcePackages": ["lrzsz"]
}
```

`packages` 使用 Alpine 软件包名称，支持当前 Alpine 分支的 main/community 仓库。`sourcePackages` 当前支持仓库内审核过的 `lrzsz` 配方。用户名、数字身份和绝对路径会在构建及设备初始化时检查；默认用户不能是 root。

| 需要的命令 | 配置中的软件包 |
| --- | --- |
| `nvim` | `neovim` |
| `bash`、`zsh` | `bash`、`zsh` |
| `rg` | `ripgrep` |
| `awk` | `gawk` |
| `sed` | `sed` |
| `ssh` 及 OpenSSH 工具 | `openssh`，包含 SSH 客户端依赖 |
| `openssl` | `openssl` |
| `sz`、`rz` | `sourcePackages` 中的 `lrzsz` |

例如预装 `curl`，将 `"curl"` 加入 `packages`，然后运行下面的 `refresh`。移除预装软件时删除相应条目。修改默认 shell 时，同时保留提供该 shell 的软件包。四种架构都必须有对应软件包，否则更新会失败。

从清单移除软件，只改变新镜像的预装内容。已有设备采用增量迁移，保留用户已安装的软件，不会据此卸载软件。更换用户名时必须同时选择未占用的 UID/GID；如需独立主目录，还要修改 `home`。旧账户和数据不会自动搬迁。修改已存在账户的 UID/GID 或遇到身份冲突时会报错，需要先人工处理。

## 来源与锁文件

| 内容 | 来源或位置 |
| --- | --- |
| 基础系统 | Alpine Linux **3.21.3 minirootfs** |
| 基础镜像地址 | `https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/<arch>/alpine-minirootfs-3.21.3-<arch>.tar.gz` |
| 官方输入及 PRoot 组件锁 | `app_plugin/android_shell/scripts/android_artifacts.lock.json` |
| 构建配方、源码及补丁锁 | `app_plugin/android_shell/rootfs/`，其中 `sources.json` 固定下载地址与 SHA256 |
| 定制镜像锁 | `app_plugin/android_shell/rootfs/rootfs.lock.json` |
| 最终镜像 | `app_plugin/android_shell/android/src/main/assets/shell/<ABI>/rootfs.tgz` |
| 镜像内的实际版本清单 | `/etc/web-terminal/rootfs.json` |
| 镜像内的离线 APK 仓库 | `/opt/web-terminal/apks` |

`rootfs.lock.json` 分别记录配置、配方、官方基础镜像、全部下载输入和最终镜像的校验值，以及每个架构实际安装的软件版本。配置 SHA256 针对文件的原始 UTF-8 字节，因此仅调整 JSON 格式也需要重新生成镜像。不要手动修改校验值绕过检查。

原始 `android_artifacts.lock.json` 中的官方输入校验值保持独立，不能替换成定制镜像的校验值。升级 Alpine 基础版本时，需要更新官方版本、下载地址对应的校验值，并重新执行所有架构的更新和验收。

Alpine 3.21 没有提供 `lrzsz`，本项目从固定的 0.13.1 源码及 Debian 0.13.1-1 补丁构建本地 APK，保留许可证。编译器等构建依赖不会进入最终镜像。安装 `sz/rz` 提供命令本身；终端的 ZMODEM 传输交互需要单独实现和验证。

镜像必须使用 `.tgz` 后缀。Android 资源处理曾自动展开 `.tar.gz`，导致运行时找不到预期的 gzip 文件。

## 本地更新流程

以下命令均在仓库根目录执行，需要 Python 3、Docker 及能执行目标架构的 Linux 容器环境。镜像生成使用 Python 标准库。普通镜像校验不需要 Docker 或下载缓存。

| Android ABI | Alpine 架构 | 容器平台 |
| --- | --- | --- |
| `arm64-v8a` | `aarch64` | `linux/arm64` |
| `armeabi-v7a` | `armv7` | `linux/arm/v7` |
| `x86_64` | `x86_64` | `linux/amd64` |
| `x86` | `x86` | `linux/386` |

### 1. 准备构建环境

先确保 Git LFS 已下载镜像实体，再确认 Docker 能运行上述平台。Linux 主机可使用 binfmt/QEMU；GitHub 工作流会自动准备。macOS 可使用 Docker Desktop，或独立的 Colima 配置：

```sh
git lfs pull
colima start --profile web-terminal-rootfs --cpu 4 --memory 4 --disk 20
export DOCKER_CONTEXT=colima-web-terminal-rootfs
docker info
```

跨架构执行需要相应的 binfmt 解释器。必要时，在专用于构建的 Docker VM 中注册本项目 CI 固定版本的解释器：

```sh
docker run --privileged --rm \
  tonistiigi/binfmt@sha256:400a4873b838d1b89194d982c45e5fb3cda4593fbfd7e08a02e76b03b21166f0 \
  --install arm64,arm,amd64,386
```

解释器初始化可能联网，离线重建前应先完成。切换项目时可取消 `DOCKER_CONTEXT`，停止专用 Colima VM 以释放内存。

### 2. 修改清单并显式更新

```sh
python3 app_plugin/android_shell/scripts/build_rootfs.py refresh
```

该命令联网获取固定基础镜像、解析当前配置的软件及完整依赖、校验官方 APK 签名并保存输入。随后在禁止联网的容器中编译自建软件、正常执行 APK 安装脚本、创建账户并运行工具检查，生成四个镜像和最终锁文件。

开发时可只更新一个架构：

```sh
python3 app_plugin/android_shell/scripts/build_rootfs.py refresh --arch arm64-v8a
```

`--arch` 可以重复指定。配置或配方变化后，未重建的架构会被完整校验拒绝；合入前必须完成全部四个架构。

### 3. 保留输入并验证离线重建

缓存保存在 `build/android-rootfs/<ABI>/inputs/`，包含基础镜像、APK、仓库索引、构建依赖和固定源码。`build/` 不纳入 Git，需要另行归档：

```sh
tar -czf build/android-rootfs-inputs.tgz -C build/android-rootfs \
  arm64-v8a/inputs armeabi-v7a/inputs x86_64/inputs x86/inputs
python3 app_plugin/android_shell/scripts/build_rootfs.py build
```

`build` 校验锁定缓存，容器使用 `--network none`，不会重新解析上游版本；缺少或损坏输入、源码构建结果或最终镜像与锁不一致都会失败。它不会隐式退回在线更新。

在另一台机器上，检出匹配的配置、配方和锁文件，下载 Git LFS 镜像实体，然后恢复归档：

```sh
mkdir -p build/android-rootfs
tar -xzf /path/to/android-rootfs-inputs.tgz -C build/android-rootfs
python3 app_plugin/android_shell/scripts/build_rootfs.py build
```

把输入归档与对应 Git 提交、配置和锁一起长期保存。上游镜像站可能清理旧版 APK，只有保留下载输入才能保证未来还能离线重建。

### 4. 校验与审核

```sh
python3 app_plugin/android_shell/scripts/build_rootfs.py verify
python3 -m unittest discover \
  -s app_plugin/android_shell/scripts -p 'test_*.py' -v
```

校验在普通检出中运行，检查原始配置与配方哈希、四个最终镜像、嵌入的用户和软件清单、实际 APK 数据库及内置离线仓库。配置改变却未重建镜像时会失败。

审核时一起检查配置差异、配方/来源变更、各架构包版本和最终体积；四个 LFS 镜像、配置及 `rootfs.lock.json` 必须一起提交。预期外的软件升级需要先解释再接受。

### 5. 打包并检查真实 APK

```sh
flutter build apk --release
python3 app_plugin/android_shell/scripts/verify_apk_artifacts.py \
  build/app/outputs/flutter-apk/app-release.apk
```

APK 检查会比对真实打包的配置、四个压缩镜像及原生库依赖，防止 Android 资源合并改变镜像内容。普通 CI 和 Release 工作流也执行对应检查。

`setup_alpine_proot.py` 现在只更新锁定的 Termux PRoot 原生组件，不会重新下载或覆盖定制 rootfs。更新预装软件请使用 `build_rootfs.py`。

## GitHub Actions 流程

手动运行 **Build Android Rootfs**（`.github/workflows/android-rootfs.yml`）：

1. 修改配置后选择 `mode=refresh`，构建全部四个架构。
2. 下载 `android-rootfs-images`，将其中镜像、配置和锁按原仓库路径放回并审核。
3. 保存 `android-rootfs-inputs` 中的归档。GitHub artifact 保留期为 90 天，需要另存才能长期保留。
4. 在包含对应配置、配方和锁的提交上选择 `mode=build`，填写提供输入的成功工作流 run ID，可验证离线重建。
5. 审核后提交产物，走普通 APK 构建与发布流程。

工作流只上传供审核的产物，不会自动提交或发布。离线模式只接受数字 run ID，并使用当前仓库对应运行的输入 artifact；输出仍必须匹配当前检出的锁。

## 已安装设备的升级

已有环境继续使用原镜像版本标记，独立的配置迁移不会重新把整张镜像覆盖到当前目录。

初始化会先检查 UID/GID 冲突，再从 APK 镜像暂存的离线仓库补齐缺少的软件，随后添加或更新兼容账户、创建独立主目录和默认配置。软件安装通过现有 APK 包数据库完成，保留原有软件；需要的依赖可能按 apk 解析结果升级。发生冲突、缺包或安装失败时报告错误，不通过清空 rootfs 修复。

配置迁移标记为 `.web_terminal_config_sha256`。重复初始化会重新检查必需软件和账户，无须重复安装已存在的软件，也不会重写已有 rc 文件。没有镜像标记但已有内容的目录，以及不支持的镜像版本，都会拒绝覆盖。

升级现有手机时用兼容签名的 `adb install -r`，保留应用数据。验收应包含：

- 升级前保存已安装包记录，以及 `/root` 和其他用户主目录的文件校验值。
- 升级后验证 `id`、`whoami`、`pwd`、`HOME/USER/LOGNAME/SHELL` 和所有要求的命令。
- 比对旧账户、已安装软件及用户文件；重启后再次检查，确认迁移可重复执行。

升级前应确保原环境的包状态一致。若 apk 报告 `required by: world[某软件]`，但该软件并未安装，说明原来的软件清单已有未满足项。先在旧版管理员终端中正常补齐该软件及依赖，再升级；离线迁移不会删除用户的安装请求来绕过错误。不要用 `--force-broken-world` 修复这种情况，它可能从清单中丢弃未满足的请求。

原来的 `/root`、dotfiles 和现有符号链接保留。`gao` 使用独立的 `/home/gao`；需要继承旧配置时应明确复制或调整链接，不会自动把 `/root` 的绝对链接复制给新用户。

## 管理员维护会话

日常新终端默认是 `gao`。要执行 `apk add` 等系统维护：

1. 打开应用的 **Settings → Terminal → Environment Variables**。
2. 添加或临时修改 `WEB_TERMINAL_USER`，值设为 `root`。
3. 新建一个本地终端，执行 `id` 确认 UID 为 0；该会话的主目录是 `/root`。
4. 删除这条环境变量或改回 `gao`。随后新建的会话恢复默认身份；已打开的管理员终端保持原身份，可继续完成维护后退出。

当前环境变量设置影响新建终端。不要把它误认为现有会话里的 `export` 就能切换身份；已有进程不会因此改变 PRoot 启动参数。代码调用方也可使用 `Host.execute(..., root: true)` 显式执行维护命令。

管理员身份由新 PRoot 进程的 `-0` 参数建立。普通会话的 `su`/`sudo` 不作为切换入口。该身份是应用内的 Linux 用户模拟，不会赋予 Android 系统 root 权限。
