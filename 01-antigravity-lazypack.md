# Anti-Gravity 懶人包 #01：服務連接與工作流程設定

> 版本：v1.7
> 更新日期：2026-06-24
> 語系偏好：繁體中文（Taiwan）

這份懶人包的目標，是讓 Anti-Gravity 使用者能安全連接 GitHub 與 Obsidian，並建立「開工 / 收工 / 新專案初始化」工作流程。NotebookLM 與 Firebase 的連線已由全域配置接管，本指引不重複設定。

本文件只放可公開教學的設定流程，不放任何個人帳號 token、密碼或敏感測試專案資訊。

---

## 先備條件

- [ ] 已安裝 Anti-Gravity 或可使用 MCP 的 AI 編碼助理
- [ ] 已安裝 Git
- [ ] 已安裝 GitHub CLI（`gh`）
- [ ] 已安裝 Node.js / npm
- [ ] 已安裝 Python 或 `uv`
- [ ] 有 GitHub 帳號
- [ ] 已有 Obsidian vault，或知道筆記本資料夾位置

Windows 快速檢查：

```powershell
git --version
gh --version
node --version
npm.cmd --version
python --version
```

### 快速自動化環境建置 (macOS / Linux)

本專案提供了一鍵設定腳本，可自動完成 GitHub CLI 登入檢查、第二大腦目錄建置、本地專案資料層初始化與全域軟連結建立：

```bash
./setup.sh
```

此腳本將協助您完成最基礎的環境連線與目錄建置（包含 `Clippings`、`知識庫` 等）。

---

## 一、連接 GitHub (必要前置)

在進行任何遠端技能載入、倉庫同步或軟連結建立前，必須確保 GitHub CLI 能正確連線。

### 登入 GitHub CLI

```powershell
gh auth status
gh auth login --web --git-protocol https
gh auth status
```

若登入流程卡住，請在可互動的終端機視窗完成瀏覽器授權，再回來驗證。

### 設定 Git 使用者

```powershell
git config --global user.name "你的名字"
git config --global user.email "your-email@example.com"
```

### 安全規則

- GitHub 與 GitHub Copilot 是不同服務；本流程只需要 GitHub 帳號、Git、GitHub CLI。
- 不把 GitHub token 寫進 Markdown、AGENTS、Obsidian 對外筆記或 repo。
- commit 前先檢查 diff，不要無差別提交。

---

## 二、建置第二大腦與連接 Obsidian

### 找到與建立 Vault

請先確認 Obsidian vault 的實體路徑。常見位置：

```text
/Users/<你>/Library/CloudStorage/GoogleDrive-.../我的雲端硬碟/secondbrain
C:\Users\<你>\OneDrive\文件\Secondbrain
```

使用 `./setup.sh` 腳本時，會在此路徑下為您自動建置以下必要目錄：
- `Clippings/`
- `知識庫/` (含 index.md 與 log.md)
- `每日筆記/`
- `Templates/`
- `專案庫/`

### 安裝 MCPVault

要讓 AI agent 讀寫第二大腦，需安裝 `mcpvault`：

```powershell
npm install -g @bitbonsai/mcpvault
```

在 macOS 下，可執行 `which mcpvault` 取得其絕對路徑；Windows 常見路徑為：

```text
C:\Users\<你>\AppData\Roaming\npm\mcpvault.cmd
```

### 註冊 Obsidian MCP

在您的 AI 助理的 MCP 設定檔（例如 `mcp_config.json` 或 `~/.gemini/config/` 下的配置）中加入 Obsidian MCP：

```json
{
  "mcp": {
    "obsidian": {
      "type": "local",
      "command": [
        "mcpvault",
        "/absolute/path/to/your/secondbrain"
      ],
      "enabled": true
    }
  }
}
```

完成後重啟 AI 助理，測試讀取二腦根目錄以驗證連線。

---

## 三、生圖

如果 AI 內建生圖工具（如 ImageGen），可直接用自然語言產生圖片，不需要把 OpenAI API key 寫進 repo。

建議提示格式：

```text
生成一張圖片：
用途：
尺寸比例：
主題：
畫面內容：
風格：
色彩：
文字：
限制：
輸出位置：
```

注意：
- 重要中文文字建議後製，生圖模型可能出字錯誤。
- 專案要引用的圖片請放在專案 `assets/` 或 Obsidian 附件資料夾。

---

## 四、開工 / 收工 / 新專案初始化工作流程 (Symlinks 與自動化)

在執行任何全域技能之前，**必須優先執行 `./setup.sh` 以建立軟連結 (Symlink) 指向 `codex_symlink`**。軟連結建立成功後，AI 助理才能在新電腦中自動載入以下兩個**互相呼應與關聯**的核心全域技能：
- **個人助手設定 (`arry-assistant`)**：載入您的跨專案偏好、偏好記憶與個人助手資料層。
- **專案初始化工作模式 (`project-init-sync`)**：建立標準雙層資料結構與工作規則。

接著，即可安全地使用這些技能來執行開工、收工與新專案初始化。

### 開工

當您說「開工」時，AI 應：

1. 讀取專案根目錄的 `AGENTS.md` 或同等規則檔。
2. 讀取 Obsidian 專案駕駛艙。
3. 執行 `git status` 與最近 commit 檢查。
4. 回報目前狀態與建議下一步。
5. 不自動 pull、commit 或 push。

### 收工

當您說「收工」時，AI 應：

1. 檢查是否有敏感資料：API key、token、憑證、學生真名。
2. 更新 Obsidian 專案駕駛艙：完成事項、下一步、踩坑。
3. 只有固定規則或路徑改變時才更新 `AGENTS.md`。
4. 執行 `git status` 與 diff 檢查.
5. 只 stage 本次相關檔案，不使用無差別 `git add .`。
6. 產生 commit message，確認後 commit / push。
7. 回報 Obsidian、規則檔與 GitHub 同步結果。

### 新專案初始化

當您說「新專案初始化」時，AI 應先問清楚：

- 專案名稱
- 用途
- 工作資料夾
- 是否建立 GitHub repo
- repo 公開或私有
- 是否需要 GitHub Pages / 其他部署
- Obsidian vault 與專案駕駛艙位置

接著建立或補齊：
- `AGENTS.md`
- `README.md`
- `.gitignore`
- Git repo
- Obsidian 專案駕駛艙

---

## 五、全域技能健檢與三方同步驗證 (必要步驟)

為了確保 AI Agent 在第二台電腦上擁有完整且無障礙的工作能力，AI 助理在設定完成後**必須執行以下健檢與三方同步驗證**：

### 1. 驗證全域 Skills/MCP/CLI 可用性
- 掃描全域所有 Skill (`~/.codex/skills/` 或 `~/.gemini/config/plugins/codex/skills/`)，確認其中提及的所有 plug-in、API、MCP、CLI 均已安裝並可正常連線與呼叫。

### 2. 三方相容性校驗 (相容 Codex/AntiGravity，清除 Claude)
- 複查「全域 Skill 文檔 (`codex_symlink/skills`)」、「LazyPack 安裝檔 (本專案 `01-antigravity-lazypack.md`)」與「Obsidian 知識庫/駕駛艙」這三者：
  - 確認皆相容於 Codex 或 AntiGravity 的設定與路徑。
  - **徹底清除所有舊有 Claude 相關字眼與殘留設定** (例如移除對舊 `CLAUDE.md` 的引用或排除 Claude 的提示語)。
  - 確保這三者的核心內容與路徑是 100% 同步且一致的。

### 3. 沙盒限制排除
- 執行健檢或操作時，若遇到 AI 助理沙盒寫入/讀取限制，**必須立刻修改配置，將該限制路徑新增到沙盒規則中**（例如修改 `~/.codex/config.toml` 或 `~/.gemini/config/` 中的 `writable_roots` 或是 sandbox paths），避免後續執行相同動作時還需要繞路或手動干預。

### 4. 疑難排解與參考資料
- **如果在執行本章節或上述步驟時遇到任何環境、連線或權限問題，請直接參考 `Github Codex Installation 的 lazy pack 路徑` 中的對應文件進行排查與恢復：**
  - [09-個人助手設定.md](file:///Users/arrywu/Library/CloudStorage/GoogleDrive-icestone0128@gmail.com/我的雲端硬碟/codex_installation/lazy-pack/09-個人助手設定.md)
  - [10-專案初始化工作模式.md](file:///Users/arrywu/Library/CloudStorage/GoogleDrive-icestone0128@gmail.com/我的雲端硬碟/codex_installation/lazy-pack/10-專案初始化工作模式.md)
  - [16-Codex-全域-Skills-跨裝置同步.md](file:///Users/arrywu/Library/CloudStorage/GoogleDrive-icestone0128@gmail.com/我的雲端硬碟/codex_installation/lazy-pack/16-Codex-全域-Skills-跨裝置同步.md)

---

## 建議的 AGENTS.md 範本

```markdown
# <專案名稱> - AGENTS.md

## 專案入口

專案名稱：
專案用途：
主要工作目錄：
GitHub repo：
預設 branch：

## Obsidian 對應筆記

Obsidian vault：
專案駕駛艙：

## 工作規則

- 回應使用繁體中文。
- 涉及檔案操作時回報完整產出位置。
- 使用 zsh 語法。
- 開工時讀本檔、讀 Obsidian 駕駛艙、檢查 Git 狀態。
- 收工時更新 Obsidian，必要時更新本檔，檢查 diff 後只提交相關檔案。
- 不把每日流水帳寫進本檔。

## 不要做

- 不要 commit API key、token、密碼、Firebase Admin 憑證。
- 不要 commit NotebookLM 個人匯出清單或筆記本 ID 清單。
- 不要自動納入無關 git 變更。
- 不要儲存學生真名；正式資料只用班級代號與座號。
```

---

## 完成回報格式

```markdown
## Anti-Gravity 懶人包設定完成

- GitHub：已登入 / 待登入 / 失敗
- Obsidian：已連接 / 待設定 / 失敗
- 全域 Symlinks 與載入 (arry-assistant, project-init-sync)：已完成 / 失敗
- 全域 Skills / MCP / CLI 健檢：已通過 / 有問題
- 三方相容性 (移除 Claude/路徑同步)：已完成 / 失敗
- 規則檔：AGENTS.md 已建立 / 已更新 / 未建立
- Git 狀態：乾淨 / 有未提交變更
- 下一步：
```
