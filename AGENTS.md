# antigravity_installation - AGENTS.md

## 專案入口

- **專案名稱**：antigravity_installation
- **專案用途**：AntiGravity 懶人包設定與測試專案
- **主要工作目錄**：`/Users/arrywu/Library/CloudStorage/GoogleDrive-icestone0128@gmail.com/我的雲端硬碟/antigravity_installation`
- **GitHub 儲存庫**：`https://github.com/icestone0128/antigravity-installation`
- **預設分支**：`main`

## Obsidian 對應筆記

- **Obsidian Vault 絕對路徑**：`/Users/arrywu/Library/CloudStorage/GoogleDrive-icestone0128@gmail.com/我的雲端硬碟/secondbrain`
- **專案駕駛艙相對路徑**：`專案庫/antigravity_installation/專案工作流程.md`
- **專案駕駛艙絕對路徑**：`/Users/arrywu/Library/CloudStorage/GoogleDrive-icestone0128@gmail.com/我的雲端硬碟/secondbrain/專案庫/antigravity_installation/專案工作流程.md`

## Firebase 設定

- **Firebase 專案**：`未使用`

## 個人助手（Arry 助手）雙層架構整合

本專案採用全域與專案本地雙層資料層架構：
1. **全域核心層**：`codex_symlink/` (或全域 `$CODEX_HOME/skills`)，存放全域記憶偏好、全域共用 skills 與 workflows。不要複製或搬移此層。
2. **專案本地層**：
   - **行動任務盒**：`100_Todo/`
     - `100_Todo/drafts/` (存放草稿)
     - `100_Todo/projects/` (進行中的具體專案任務)
     - `100_Todo/archive/` (已歸檔任務)
   - **參考素材盒**：`200_Reference/`
     - `200_Reference/writing-samples/` (寫作範例)
     - `200_Reference/templates/` (文件範本)
     - `200_Reference/past-work/` (歷史參考)
   - **本地技能盒**：`000_Agent/skills/` (僅在本專案有特殊專用技能時使用)
   - **本地記憶盒**：`000_Agent/memories/` (僅在本專案有獨立助手記憶時使用)
3. **Obsidian 知識盒**：專案駕駛艙與每日筆記，為主要進度與下一步之紀錄核心。

## 工作流程規則

### 1. 開工 (Startup)
使用者說「開工」或「繼續專案」時，AI 應：
1. 讀取專案根目錄的 `AGENTS.md` (或 `ANTIGRAVITY.md`) 規則。
2. 讀取 Obsidian 專案駕駛艙 (`專案工作流程.md`)。
3. 執行 `git status` 與最近變更檢查。
4. 回報目前進度狀態與建議下一步，不自動進行 `git pull`、`commit` 或 `push`。

### 2. 收工 (Shutdown)
使用者說「收工」或「結束今天工作」時，AI 應：
1. 檢查是否有敏感資料（如 API keys、個人資料、密碼等）。
2. 更新 Obsidian 專案駕駛艙的完成進度、踩坑與下一步。
3. 檢查 `git diff`，僅 stage 相關變更檔案，禁止無差別 `git add .`。
4. 產生合適的 commit message 並提交/推送到 GitHub。
5. 回報 Obsidian、設定檔與 Git 同步結果。

### 3. 新專案初始化 (Project Initialization)
參照 `project-init-sync` 全域 Skill。

## 安全與行為守則

- **回應語系**：一律使用**繁體中文**。
- **檔案操作**：涉及任何檔案讀寫、建立時，必須回報**完整絕對路徑**。
- **終端機指令**：使用 **zsh** 語法（適用於 macOS）。
- **禁止提交的檔案**：
  - `.env`、`.env.*` 等環境變數檔案
  - API keys、Tokens、密碼、Firebase Admin SDK 憑證
  - NotebookLM 個人匯出檔、筆記本 ID 清單
- **資料保護**：不得儲存真實學生姓名，正式資料與學生資訊一律以班級代號與座號代替。
- **流水帳控制**：不要將每日瑣碎流水帳寫進 `AGENTS.md` 或 `ANTIGRAVITY.md`，這些應留在 Obsidian 駕駛艙中。
