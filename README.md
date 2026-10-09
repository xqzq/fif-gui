# FiF GUI — 实验性维护版

基于 [1z2y3x4w5/fif_gui](https://github.com/1z2y3x4w5/fif_gui) 的 Python 桌面工具，整合浏览器操作、YourTTS 语音合成、虚拟音频输出及本地进度记录。

> **状态：实验性源码预览版。** 本地 TTS 合成、音频输出和 GUI 构建已测试；当前账号尚无教师任务，因此真实任务解析、浏览器录音接收、评分及提交整条链路尚未验证。请勿把程序的“完成”日志视为平台已保存成绩的证明。

## 功能

- Tkinter GUI 和命令行入口。
- 正常浏览器登录，允许用户手动完成验证码和进入口语系统。
- 教师任务列表读取与 Dry-run；空列表时可在 GUI 保留浏览器检查。
- Coqui YourTTS 合成、参考 WAV 录制/转换/检查。
- Windows 指定音频输出设备；Linux 包含实验性 PulseAudio 支持。
- 关卡粒度进度文件、已完成跳过、跨次运行的失败计数。

这不是 FiF 官方项目，也不是通用自主练习/题库客户端。

## 上游与许可

代码源自上述上游项目并有本地修改；版权及 MIT 条款见 [LICENSE](LICENSE)。上游相关资料见 [THIRD_PARTY.md](THIRD_PARTY.md)。模型、PyTorch、浏览器和 VB-CABLE 驱动不包含在此仓库中，各自按原项目条款分发。

## 环境要求

- 推荐 Windows 11、64 位 Python **3.12**，含 Tkinter。
- CPU 路径已做本地合成测试；CUDA 路径未验证。
- 安装依赖和首次下载模型需要网络及数 GB 磁盘空间。
- Windows 浏览器录音链路需要另行安装及配置虚拟音频设备。
- Linux 未做整机验证；macOS 的音频后端未实现。

## 快速开始

克隆自己的仓库后，在项目根目录运行以下命令。将 `YOUR_ACCOUNT` 替换为实际 GitHub 用户名。

```powershell
git clone https://github.com/YOUR_ACCOUNT/fif-gui.git
cd fif-gui
powershell -File .\setup.ps1
```

安装脚本默认通过 `py -3.12` 建立 `.venv`，安装 CPU 版 PyTorch、依赖和 Chromium。也可以明确指定 Python 路径：

```powershell
powershell -File .\setup.ps1 -Python "C:\Path\To\Python312\python.exe"
```

脚本不会安装系统音频驱动、修改系统默认音频设备或重启系统。它会保留已有配置，安装失败则停止。CPU PyTorch 由安装时解析，依赖没有完整锁定；新环境遇兼容问题请附上 `pip check` 和脱敏版本信息。

### 准备音色

选择自己的录音或有权使用的参考音色，保存到 `draft/target_voice.wav`。可以使用命令行工具：

```powershell
.\.venv\Scripts\python.exe src\voice_tool.py record draft\target_voice.wav --seconds 15
.\.venv\Scripts\python.exe src\voice_tool.py check draft\target_voice.wav
```

或使用模型自带说话人生成参考音频（首次会下载模型）：

```powershell
.\.venv\Scripts\python.exe src\voice_tool.py probe
.\.venv\Scripts\python.exe src\voice_tool.py builtin draft\target_voice.wav
```

转换已有音频：

```powershell
.\.venv\Scripts\python.exe src\voice_tool.py convert input.wav draft\target_voice.wav
```

有 FFmpeg 时优先使用它；纯 Python WAV 转换仅为简易回退，不等同于高质量重采样。WAV 检查只检查格式及粗略音量指标，无法判断音频是否为清晰人声。

### 配置与启动

安装脚本会从 [配置模板](config.example.json) 创建本地 `config.json`。填写账号后启动：

```powershell
.\run.bat
```

首次保持 **Dry-run 开启、无头模式关闭**。在弹出的浏览器中完成登录和验证码，并进入 FiF 口语。程序等待凭据最多 180 秒。

**账号密码以明文保存在本地配置。** 配置、音频、进度和日志已加入 `.gitignore`，但这不等同于加密；不要把这些文件、token、浏览器存储状态上传 GitHub 或贴到 Issue。

### Windows 音频路由

从 [VB-Audio 官方网站](https://vb-audio.com/Cable/)自行安装 VB-CABLE，按安装器提示决定是否重启：

```text
程序输出设备：CABLE Input
           ↓ 虚拟音频线
浏览器麦克风：CABLE Output
```

仅发现设备或播放函数返回，不能证明浏览器已接收到有效录音。应在浏览器手动检查麦克风来源和电平。当前后端在匹配失败时可能回退到其他输出设备，首次使用必须核对设备日志。

### CLI 与进度

```powershell
# 只读任务和文本，不播放或提交
.\.venv\Scripts\python.exe src\cli.py --dry-run

# 查看或清除本地进度
.\.venv\Scripts\python.exe src\cli.py --stats
.\.venv\Scripts\python.exe src\cli.py --reset-failed
```

GUI 是当前优先入口。CLI `--run` 与 GUI 的规则/预检尚未完全统一，不建议作为默认入口。重试计数限制的是后续运行，不代表会在当前运行中自动重试。

## 当前已知限制

1. 教师未布置任务时返回空列表是正常情况；当前主要针对教师任务接口。
2. 接口、选择器、题型结构可能随平台更新变化；`bank_type` 的默认值未在真实任务中核实。
3. 评分结束检测是启发式，缺少服务器保存成功的可靠确认；本地断点 `done` 不能替代平台成绩检查。
4. GUI 的停止是协作式，通常要等当前关卡返回；部分后台线程仍直接访问 Tk 控件，尚需线程安全改造。
5. `level_type_rules` 目前未真正覆盖基于 `qcontent` 的解析逻辑，请勿依赖该设置强制切换题型。
6. 本仓库保留较旧 Playwright 依赖作为兼容基线，升级后需重新验证登录和录音流程。
7. 当前安装脚本没有在全新机器上从零完整验收；历史本机安装测试不等于任意环境保证。

## 开发与测试

纯离线测试使用 mock，不需要账号、模型、音频驱动或网络：

```powershell
python -m unittest discover -s tests -v
```

GitHub Actions 在 Windows / Python 3.12 下运行这些测试和语法编译，不自动访问 FiF。

## 仓库结构

```text
src/              GUI、CLI、浏览器连接器、TTS、音频和进度模块
tests/            离线单元测试
.github/          CI、问题模板和 PR 模板
config.example.json
setup.ps1         CPU 环境安装入口
run.bat           Windows 启动入口
```

## 发布到 GitHub

详见 [PUBLISHING.md](PUBLISHING.md)。请先以预发布/实验性版本发布，并保留上述验证边界。
