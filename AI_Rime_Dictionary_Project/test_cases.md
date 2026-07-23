# 测试用例

## 1. 普通中文不受影响

| 输入 | 预期 |
| --- | --- |
| `wo jintian chi fan` | 首选仍为“我今天吃饭” |
| `ai` | “爱、哎”等中文候选排在 `AI` 前面 |
| `model` 的拼音片段 | 不因未完成编码出现大量 AI 补全 |

## 2. AI 专业词完整匹配

| 输入 | 预期候选 |
| --- | --- |
| `comfyui` | `ComfyUI` |
| `controlnet` | `ControlNet` |
| `ipadapter` | `IP-Adapter` |
| `facedetailer` | `FaceDetailer` |
| `wan` | `Wan2.1`、`Wan2.2` |

## 3. 快捷码

| 输入 | 预期候选 |
| --- | --- |
| `ue5` | `Unreal Engine 5` |
| `i2v` | `image to video` |
| `t2v` | `text to video` |
| `3dcg` | `3D CG render` |
| `r16x9` | `16:9` |

快捷码只有完整输入后才出现，不应在输入 `u`、`ue` 时抢占普通候选。

## 4. 中英混输

目标句：

```text
我用 ComfyUI 生成 Wan2.1
```

操作：依次输入中文“我用”、完整编码 `comfyui`、中文“生成”、完整编码 `wan`，从低位候选中选择对应专有名词。

## 5. Prompt 输入

目标句：

```text
采用 Unreal Engine 5 cinematic lighting
```

操作：输入中文“采用”，再输入 `ue5` 与 `cgl`。

## 6. 标点直出

分别在半角和全角中文状态按 `Shift+2`：

- 预期：`@` 立即上屏。
- 不应：弹出符号候选并等待回车。

## 7. 英文规范写法

| 输入 | 预期候选 |
| --- | --- |
| `github` | `GitHub` |
| `githubdesktop` | `GitHub Desktop` |
| `vscode` | `VS Code` |
| `openai` | `OpenAI` |
| `davinciresolve` | `DaVinci Resolve` |

输入 `g`、`gith` 等未完成前缀时，不应展开一长串英文补全候选；完整输入 `git` 时只出现规范候选 `Git`。

## 8. 卸载恢复

1. 运行 `scripts/uninstall.ps1`。
2. 重新部署。
3. AI 候选消失。
4. 原有中文用户词频、Easy English 和外观设置保持不变。
