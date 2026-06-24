# Anti-Gravity 懶人包 #01：服務連接與工作流程設定

> 版本：v2.6 (優化五大步驟版)
> 更新日期：2026-06-24
> 語系偏好：繁體中文（Taiwan）

這份懶人包的目標，是讓 Anti-Gravity 使用者能在**完全乾淨的第二台電腦**上，快速且安全地連接 GitHub 與 Obsidian，並建立「開工 / 收工 / 新專案初始化」工作流程。NotebookLM 與 Firebase 的連線已由全域配置接管，本指引不重複設定。

本文件只放可公開教學的設定流程，不放任何個人帳號 token、密碼或敏感測試專案資訊。

---

## 一、安裝與連接基礎服務 (必要前置環境準備)

在進行任何 Symlink 設定前，必須先完成實體同步環境、筆記工具與 MCP 連線的準備。這是您的 AI 助理能讀取過往所有記錄的唯一物理先決條件。

### 1. 安裝 Homebrew (macOS 套件管理器，可選但極度推薦)
啟動 Terminal，執行以下指令安裝 Homebrew：
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. 一鍵安裝基礎應用與開發依賴
使用 Brew 自動化安裝 Google Drive、Obsidian、Git 以及 GitHub CLI：
```bash
brew install --cask google-drive obsidian
brew install git gh
```
*(手動替代方案：您亦可手動前往 [Google Drive 電腦版官網](https://www.google.com/drive/download/) 與 [Obsidian 官網](https://obsidian.md/) 下載並手動安裝)*

### 3. 登入 Google Drive 並確認雲端同步
- 啟動並登入您的 **Google Drive 電腦版** 帳號。
- **關鍵等待**：請確認 macOS 的本地掛載點（例如 `~/Library/CloudStorage/GoogleDrive-你的帳號/`）已出現在 Finder 中，且您在雲端上的 `codex_symlink` 和二腦資料夾（例如 `secondbrain`）已**完全同步至本機**。

### 4. 安裝與註冊 Obsidian MCP
- 全域安裝 `mcpvault` 伺服器：
  ```bash
  npm install -g @bitbonsai/mcpvault
  ```
- 開啟本機 AI 助理的 MCP 設定檔（例如 `~/.gemini/config/mcp_config.json` 或本機 `mcp_config.json`），寫入以下 `obsidian` 設定：
  ```json
  {
    "mcpServers": {
      "obsidian": {
        "command": "/opt/homebrew/bin/mcpvault",  // 若在 macOS Brew 環境，亦可使用 "mcpvault"
        "args": ["/absolute/path/to/your/secondbrain"]
      }
    }
  }
  ```
  *(請將 args 中的路徑替換為您在 Google Drive 本地同步掛載點底下的 `secondbrain` 實體絕對路徑)*

### 5. 在 Obsidian 中開啟現有二腦
- 啟動 **Obsidian** 筆記軟體。
- 選擇 **「開啟現有倉庫 (Open folder as vault)」**，並指向已同步的二腦資料夾（例如 `~/Library/CloudStorage/.../secondbrain`）。
- 確認過往所有的筆記、工作流程與專案駕駛艙在介面中成功加載。

### 6. 登入 GitHub CLI
```powershell
gh auth status
gh auth login --web --git-protocol https
gh auth status
```

### 7. 安全規則
- 不把 GitHub token 寫進 Markdown、AGENTS、Obsidian 對外筆記 or repo。
- commit 前先檢查 diff，不要無差別提交。

---

## 二、設定全域配置軟連結 (Symlink)

在步驟一的所有基礎軟體、MCP 註冊與二腦連線完成後，請執行設定腳本建立指向您雲端硬碟 `codex_symlink` 的全域軟連結。

### 執行設定腳本
```bash
./setup.sh
```

### 腳本執行互動填寫與對接邏輯：
- **互動確認路徑**：腳本會動態偵測並讓您確認 Google Drive 掛載點中的 `codex_symlink` 與 `secondbrain` 目錄。
- **Git 全域設定補全**：若 Git 全域 `user.name` 或 `user.email` 為空，提示輸入並自動寫入 `git config --global`（防止日後提交中斷）。
- **Gemini API Key 安全配置**：互動提示輸入金鑰，自動建立並安全儲存至 `~/.codex/secrets/gemini_api_key`（權限 600，自動排除在 Git 之外，保證全域 API 可正常呼叫）。
- **建立軟連結**：將全域 `skills`、`memories`、`AGENTS.md` 對接到 AI 助理載入路徑中（`~/.codex` 與 `~/.gemini/config`）。

*執行完成後，請重啟您的 AI 助理。此時 AI 助理重啟後，便能加載 `arry-assistant` 等全域技能，繼承跨專案記憶。*

---

## 三、對接與驗證第二大腦 (防覆寫保護)

軟連結與全域技能載入後，接下來進行二腦對接驗證與本地專案初始化。

### 1. 腳本防覆寫機制說明
- **安全保護**：若偵測到您的 Obsidian Vault 中已存在檔案（即您已在步驟一中同步了已有二腦），此腳本將**僅更新全域核心規則至 Obsidian Vault 底下的 `AGENTS.md`，絕對不會替換或生成任何 `index.md`、`log.md` 等預設占位檔案**，以防覆蓋或損害您的過往記錄。若目錄為全新，才初始化建立結構。

### 2. 專案本地層初始化
- 腳本已在步驟二執行時，自動為此專案建立了本地的 `100_Todo` 和 `200_Reference` 目錄，您可以在本地直接使用。

### 3. 驗證 Obsidian MCP 連線與讀寫
- 重啟 AI 助理後，在對話中要求 AI 助理讀取二腦根目錄（例如使用 `mcpvault` 讀取 `AGENTS.md`），以驗證 Obsidian MCP 連線是否暢通。

---

## 四、全域技能健檢與三方同步驗證 (必要步驟)

為了確保 AI Agent 在第二台電腦上擁有完整且無障礙的工作能力，AI 助理在設定完成後**必須執行以下依賴健檢與三方同步驗證**：

### 1. 驗證全域 Skills / MCP / CLI 依賴可用性
掃描並確認以下全域技能及相關環境依賴已正確安裝、配置並可正常調用：
- [ ] **GitHub CLI (`gh`) 狀態**：可用於 repo 同步與 PR 建立（供 `contribute-catalog`, `project-init-sync` 等使用）。
- [ ] **Node.js 與 npm 環境**：供執行 `mcpvault` 與前端套件建置。
- [ ] **Playwright 瀏覽器截圖環境**：可正常開啟無頭瀏覽器（供 `playwright`, `social-cards` 等使用）。
- [ ] **Python 3 與 pip 環境**：供執行備份指令與文字/轉換腳本。
- [ ] **Poppler / pdfplumber 工具**：可用於 PDF 渲染與資訊提取（供 `pdf`, `doc-to-md` 等使用）。
- [ ] **FFmpeg 媒體工具**：多媒體編輯與影片渲染正常（供 `hyperframes`, `video-processing-automation` 等使用）。
- [ ] **yt-dlp 下載器**：用於轉錄 YouTube 資訊（供 `youtube-transcript-collector` 使用）。
- [ ] **mcpvault (Obsidian MCP) 狀態**：AI 能透過 MCP 成功讀寫二腦檔案。
- [ ] **個人 API 憑證安全**：API 金鑰安全存放於 `~/.codex/secrets/`（如 `gemini_api_key`）且已被排除在 Git 外。

### 2. 三方相容性校驗 (相容 Codex/AntiGravity，清除 Claude)
- 複查「全域 Skill 文檔 (`codex_symlink/skills`)」、「LazyPack 本手冊 (`01-antigravity-lazypack.md`)」與「Obsidian 知識庫/駕駛艙」這三者：
  - 確認皆相容於 Codex 或 AntiGravity 的設定與路徑。
  - **徹底清除所有舊有 Claude 相關字眼與殘留設定**。
  - 確保這三者的核心內容與路徑是 100% 同步且一致的。

### 3. 沙盒限制排除
- 執行健檢或操作時，若遇到 AI 助理沙盒寫入/讀取限制，**必須立刻修改配置，將該限制路徑新增到沙盒規則中**（例如修改本機 `config.toml` 或 AI 助理配置中的 `writable_roots` ）。**特別是 PIP、NPM、Python 及其相關的實體路徑（如 `~/.npm/`, `~/.pip/`, 以及 Python 與 Node.js 的全局二進位執行檔路徑、環境資料夾與專案工作目錄），都必須被完整列為沙盒排除項目，以確保這些指令、相依庫安裝以及指令調用都能直接、無礙地執行。**

### 4. 疑難排解與參考資料
- **如果在執行本步驟或懶人包引導時遇到任何環境、連線、模組或權限問題，請直接參考 GitHub 上的公開說明。本專案中所有技能皆與 Codex Installation 專案的懶人包設計相呼應。您可以隨時回到其 GitHub 遠端倉庫 the `lazy-pack` 目錄尋求完整的設定檔與疑難排解指引：**
  - [GitHub Codex Installation - lazy-pack 目錄](https://github.com/icestone0128/codex-installation/tree/main/lazy-pack)

---

## 五、完成回報格式

```markdown
## Anti-Gravity 懶人包設定完成

- GitHub：已登入 / 待登入 / 失敗
- Obsidian：已連接 / 待設定 / 失敗
- 全域 Symlinks 與載入 (arry-assistant, project-init-sync)：已完成 / 失敗
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
