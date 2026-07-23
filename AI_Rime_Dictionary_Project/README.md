# AI 创作者专用 Rime 中英混输词库

这是一套面向 Windows 11 小狼毫的本地词库扩展。它不是新的输入法，而是在现有的“朙月拼音·简化字”中增加一个低权重、仅完整匹配的 AI 创作专业词翻译器。

## 设计目标

- 保留正常中文输入和原有用户词频。
- AI 专业词默认低于中文候选，不让 `AI` 抢占“爱、哎”等常用候选。
- 支持 ComfyUI、生成模型、节点、图像提示词、视频生成、漫剧分镜、小说创作，以及 GitHub、开发工具和常用数字工作流英文词汇。
- 支持 `ue5`、`i2v`、`t2v`、`3dcg` 等完整快捷码。
- 完全离线运行；除安装时复制文件外，不修改小狼毫程序目录或 Windows 系统文件。
- 安装前自动备份，能够一键卸载并恢复。

## 文件结构

```text
AI_Rime_Dictionary_Project/
├── README.md
├── installation.md
├── test_cases.md
├── 测试包说明.md
├── 测试安装配置.cmd
├── 恢复原配置.cmd
├── custom_phrase.txt
├── ai_creator.dict.yaml
├── ai_creator.schema.yaml
├── ai_creator.yaml
├── ai_punctuation.yaml
├── ai_shortcuts.dict.yaml
├── ai_shortcuts.yaml
├── ai_models.dict.yaml
├── ai_nodes.dict.yaml
├── image_prompt.dict.yaml
├── video_prompt.dict.yaml
├── storyboard.dict.yaml
├── writing.dict.yaml
├── english_terms.dict.yaml
├── luna_pinyin_simp.custom.template.yaml
└── scripts/
    ├── launch-test.ps1
    ├── build-test-package.ps1
    ├── install.ps1
    └── uninstall.ps1
```

## 候选排序原则

普通中文由朙月拼音主翻译器产生，初始质量保持不变。AI 词库使用：

- `enable_completion: false`：不做前缀补全，只有完整编码匹配才出现。
- `enable_sentence: false`：不使用 AI 词库拼造句子。
- `initial_quality: -2.0`：普通中文候选优先。
- 快捷码使用单独标签，只有完整快捷码才触发，质量为 `0.5`。

例如输入 `ai` 时，“爱、哎”等中文候选应在 `AI` 之前；输入 `comfyui` 时可直接选择 `ComfyUI`。

## 英文词库与性能

`english_terms.dict.yaml` 独立保存英文扩展，当前重点覆盖 GitHub、AI 平台、开发工具、图像视频软件和常用工作流。输入完整的 `github` 后会出现规范写法 `GitHub`。

这一级别的扩充不会造成可感知的输入延迟：Rime 部署时会把 YAML 编译为二进制词典，日常输入不会逐行扫描源文件；同时本项目关闭前缀补全和造句，只查询完整编码。增加几百条词主要只会让首次重新部署稍慢一点。应避免一次加入数万条低质量通用英文词并开启补全，那才容易增加部署时间并污染中文候选。

如果以后不需要英文扩展，只需从 `ai_creator.dict.yaml` 的 `import_tables` 中移除 `english_terms`，其他 AI 词库不受影响。

## 快速开始

以 PowerShell 运行：

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\install.ps1
```

安装脚本会复制词库、备份并更新 `luna_pinyin_simp.custom.yaml`，随后调用小狼毫部署工具。完整说明见 [installation.md](installation.md)。

从测试压缩包使用时，推荐解压到 D 盘后双击 `测试安装配置.cmd`。测试完成后双击 `恢复原配置.cmd`，原配置会从测试包旁边的 `_backups` 恢复。
