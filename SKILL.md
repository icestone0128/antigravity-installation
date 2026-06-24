---
name: antigravity-lazy-packs
description: AntiGravity 懶人包 — 服務連接與工作流程設定。說「AntiGravity 懶人包」「安裝 Antigravity 設定」時載入。
---

# AntiGravity 懶人包 — AI Agent 自動安裝與設定入口

當使用者給你這個 repo 網址並說要安裝時，請依以下流程執行。本專案作為服務連接與工作流程的設定指引，全域技能均已在全域目錄中管理，不需額外重複安裝個別 Skill。

## 步驟一：執行自動化設定腳本 (GitHub, Obsidian & Symlinks)

引導使用者在本專案目錄下執行以下指令：
```bash
./setup.sh
```
此腳本將自動按順序完成：
1. 驗證 GitHub 連線狀態，若未登入則引導登入
2. 建置第二大腦 (Obsidian Vault) 目錄結構與路徑設定
3. 初始化本地專案資料層 (`100_Todo` 與 `200_Reference`)
4. 建立全域軟連結 (Symlink)，將 `skills`、`memories` 等指向 `codex_symlink`
   - **注意**：軟連結建立成功後，AI 助理才能在新電腦中自動載入 `arry-assistant`（個人助手設定）與 `project-init-sync`（專案初始化工作模式）以及 `image-generator`（生圖技能）等全域技能。

## 步驟二：註冊與連接 Obsidian MCP

引導/協助使用者開啟 [01-antigravity-lazypack.md](file:///Users/arrywu/Library/CloudStorage/GoogleDrive-icestone0128@gmail.com/我的雲端硬碟/antigravity_installation/01-antigravity-lazypack.md) 的「二、建置第二大腦與連接 Obsidian」：
1. 註冊 Obsidian MCP 並驗證連線。

## 步驟三：生圖功能驗證

引導/協助使用者開啟 [01-antigravity-lazypack.md](file:///Users/arrywu/Library/CloudStorage/GoogleDrive-icestone0128@gmail.com/我的雲端硬碟/antigravity_installation/01-antigravity-lazypack.md) 的「四、生圖」：
1. 此時因為軟連結已掛載，AI 助理已可正常讀取並啟用全域生圖技能。此技能依賴 AI 內建生圖工具，**不需要配置 OpenAI API key，亦無須安裝額外 CLI**。請使用提示詞執行生圖測試以完成驗證。

## 步驟四：全域技能健檢與三方同步驗證

引導/協助使用者開啟 [01-antigravity-lazypack.md](file:///Users/arrywu/Library/CloudStorage/GoogleDrive-icestone0128@gmail.com/我的雲端硬碟/antigravity_installation/01-antigravity-lazypack.md) 的「五、全域技能健檢與三方同步驗證」：
1. 驗證全域 Skills / MCP / CLI 依賴可用性（包含 Git/gh, Node/npm/playwright, Python/pip/poppler/yt-dlp, FFmpeg, mcpvault）。
2. 校驗「全域 Skill 文檔 (`codex_symlink/skills`)」、「LazyPack 本專案安裝檔 (`01-antigravity-lazypack.md`)」與「Obsidian 知識庫/駕駛艙」三方相容性（相容 Codex/AntiGravity，清除 Claude，保持內容與路徑 100% 同步）。
3. 遇到任何沙盒限制時，將限制新增到沙盒規則中（如寫入權限 `writable_roots`）。
4. **若有任何問題，直接參考 `Github Codex Installation 的 lazy pack 路徑` 中的相關對應說明**。

## 步驟五：回報狀態

完成後，請依以下格式回報完成狀態給使用者：

```markdown
## Anti-Gravity 懶人包設定完成

- GitHub：已登入 / 待登入 / 失敗
- Obsidian：已連接 / 待設定 / 失敗
- 全域 Symlinks 與載入 (arry-assistant, project-init-sync)：已完成 / 失敗
- 生圖功能驗證：已測試通過 / 失敗
- 全域 Skills / MCP / CLI 健檢：
  - GitHub CLI (gh)：[通過 / 失敗]
  - Node.js & npm：[通過 / 失敗]
  - Playwright：[通過 / 失敗]
  - Python 3 & pip：[通過 / 失敗]
  - Poppler (PDF)：[通過 / 失敗]
  - FFmpeg (多媒體)：[通過 / 失敗]
  - yt-dlp (YouTube)：[通過 / 失敗]
  - mcpvault：[通過 / 失敗]
  - API secrets 安全：[通過 / 失敗]
- 三方相容性 (移除 Claude/路徑同步)：已完成 / 失敗
- 規則檔：AGENTS.md 已建立 / 已更新 / 未建立
- Git 狀態：[乾淨 / 有未提交變更]
```
