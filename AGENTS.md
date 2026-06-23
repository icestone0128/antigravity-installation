# antigravity_installation - AGENTS.md

## 專案入口

專案名稱：antigravity_installation
專案用途：AntiGravity 懶人包設定與測試專案
主要工作目錄：/Users/arrywu/Library/CloudStorage/GoogleDrive-icestone0128@gmail.com/我的雲端硬碟/antigravity_installation
GitHub repo：https://github.com/icestone0128/antigravity-installation
預設 branch：main

## Obsidian 對應筆記

Obsidian vault：/Users/arrywu/Library/CloudStorage/GoogleDrive-icestone0128@gmail.com/我的雲端硬碟/secondbrain
專案駕駛艙：/Users/arrywu/Library/CloudStorage/GoogleDrive-icestone0128@gmail.com/我的雲端硬碟/secondbrain/專案庫/antigravity_installation/專案工作流程.md

## 工作規則

- 回應使用繁體中文。
- 涉及檔案操作時回報完整產出位置。
- 使用 zsh 語法。
- 開工時讀本檔、讀 Obsidian 駕駛艙、檢查 Git 狀態。
- 收工時更新 Obsidian，必要時更新本檔，檢查 diff 後只提交相關檔案。
- 不把每日流水帳寫進本檔。

## 專案使用方式與相關系列

### 專案使用方式

- **方式一：直接叫 AI 協助安裝與設定（推薦）**
  把這行貼給你的 AI agent：
  ```text
  這是 AntiGravity 懶人包 https://github.com/icestone0128/antigravity-installation
  請讀取 repo 內容並依據 SKILL.md 引導我完成服務連接與工作流程設定。
  ```
  AI 會自動讀取 `SKILL.md`（安裝與設定入口），並引導您進行相關的環境檢查、服務連接與開收工設定。

- **方式二：手動開啟設定檔**
  1. 開啟 `01-antigravity-lazypack.md`。
  2. 把文件內容交給 Anti-Gravity，依序完成環境檢查、OAuth 登入與 MCP 設定。

## 不要做

- 不要 commit API key、token、密碼、Firebase Admin 憑證。
- 不要 commit NotebookLM 個人匯出清單或筆記本 ID 清單。
- 不要自動納入無關 git 變更。
- 不要儲存學生真名；正式資料只用班級代號與座號。
