# 安装、启用与卸载

## 环境

- Windows 11
- 小狼毫 0.17.x 或兼容版本
- 当前输入方案：`luna_pinyin_simp`

## 一键安装

在项目目录打开 PowerShell：

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\install.ps1
```

脚本只写入 `%APPDATA%\Rime`：

1. 在用户目录创建带时间戳的备份文件夹。
2. 复制本项目的词库、方案和配置片段。
3. 如果没有 `luna_pinyin_simp.custom.yaml`，使用项目模板创建。
4. 如果已有该文件，保留原文件备份，并加入 AI 翻译器设置。
5. 调用已安装的小狼毫 `WeaselDeployer.exe /deploy`。

安装完成后继续使用“朙月拼音·简化字”，不需要切换到新的输入方案。

## 手动安装

将以下文件复制到 `%APPDATA%\Rime`：

```text
ai_creator.dict.yaml
ai_creator.schema.yaml
ai_creator.yaml
ai_punctuation.yaml
ai_shortcuts.dict.yaml
ai_shortcuts.yaml
ai_models.dict.yaml
ai_nodes.dict.yaml
image_prompt.dict.yaml
video_prompt.dict.yaml
storyboard.dict.yaml
writing.dict.yaml
english_terms.dict.yaml
```

如果尚无 `luna_pinyin_simp.custom.yaml`，将 `luna_pinyin_simp.custom.template.yaml` 复制并改名。已有配置时，不要直接覆盖；参考模板把相应节点合并到原有 `patch:` 下。

最后右键小狼毫托盘图标，选择“应用配置”（官方版本中叫“重新部署”）。

## 卸载与恢复

运行：

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\uninstall.ps1
```

卸载脚本删除 AI 词库文件，并从最近一次安装备份恢复原来的 `luna_pinyin_simp.custom.yaml`，不会删除用户词库。

## 调整候选位置

在 `luna_pinyin_simp.custom.yaml` 中修改：

```yaml
ai_creator/initial_quality: -2.0
```

- 数值越低，AI 候选越靠后。
- 建议范围：`-3.0` 到 `-1.0`。
- 不建议设为正数，否则 `AI`、`model` 等词可能干扰普通中文。

## 英文候选的使用方式

保持中文模式，连续输入完整英文编码，例如 `github`、`vscode`、`davinciresolve`，再选择规范英文候选。按 Shift 切到纯英文模式时，字符由应用程序直接接收，不经过 Rime 词典，因此不会学习大小写或提供 `GitHub` 候选。

英文翻译器关闭了前缀补全和造句，并使用低初始质量。扩充几百条词对运行性能影响很小；首次重新部署会多编译一份小词典。
