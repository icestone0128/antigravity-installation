---
name: antigravity-lazy-packs
description: AntiGravity 懶人包 — 服務連接與工作流程設定。說「AntiGravity 懶人包」「安裝 Antigravity 設定」時載入。
---

# AntiGravity 懶人包 — AI Agent 自動安裝與設定入口

當使用者給你這個 repo 網址並說要安裝時，請依以下流程執行。本專案作為服務連接與工作流程的設定指引，全域技能均已在全域目錄中管理，不需額外重複安裝個別 Skill。

## 步驟一：安裝與連接基礎服務 (必要前置環境準備 - 免 Homebrew)

引導使用者手動前往官網下載並安裝以下實體軟體，完全免除 Homebrew：
1. **安裝 Node.js 與 npm**：提供 `npx` 運行環境（前往 Node 官方網站下載安裝包）。
2. **安裝 Google Drive 電腦版**：登入帳號並確認全域 `codex_symlink` 和二腦 `secondbrain` 已完全同步下載至本機掛載點下。
3. **安裝 Obsidian Desktop**：下載安裝後開啟，選擇「開啟現有倉庫 (Open folder as vault)」，指向已同步之本地二腦路徑，加載過往所有記錄。
4. **安裝與註冊 Obsidian MCP (`mcpvault`)**：全域執行 `npm install -g @bitbonsai/mcpvault`，並在 AI 助理的 MCP 設定檔中註冊 `obsidian` 的 command 和二腦實體絕對路徑。
5. **安裝 Git 與 GitHub CLI**：Git 透過官網或 Xcode 命令列安裝；GitHub CLI 下載編譯包並移動執行檔至系統 PATH，執行 `gh auth login` 登入。
6. **安裝 Python 3 與 FFmpeg、yt-dlp**：提供全域技能之文字與媒體依賴。

## 步驟二：執行自動化設定腳本與設定 Symlink

引導使用者在本專案目錄下執行以下指令以配置 Symlink 與本地環境：
```bash
./setup.sh
```
此腳本將互動引導使用者輸入必需資訊，並自動按順序完成：
1. 自動偵測/確認 Google Drive 掛載路徑與 Obsidian Vault 路徑。
2. 配置 Git 使用者身分全域設定（若為空）。
3. 配置 Gemini API Key，安全寫入至 `~/.codex/secrets/gemini_api_key` (排除在 Git 之外，權限 600)。
4. 建立全域軟連結 (Symlink)，將 `skills`、`memories` 與全域 `AGENTS.md` 對接到 AI 助理載入路徑中（`~/.codex` 與 `~/.gemini/config`）。
5. 重啟 AI 助理，使全域技能與 MCP 連線載入生效。

## 步驟三：建置與驗證第二大腦對接 (防覆寫保護)

引導並執行二腦防覆寫驗證與本地專案初始化：
1. **防覆寫保護**：檢查指定的 Obsidian Vault 是否有檔案。若不為空，僅更新規則檔至 `secondbrain/AGENTS.md`，絕不生成占位檔案，防範覆寫過往記錄。若路徑全新，才進行初始化建置。
2. 初始化專案本地資料層 (`100_Todo` 與 `200_Reference`)。
3. 驗證連線：要求 AI 助理透過註冊好的 `obsidian` MCP 讀寫二腦，確保連線暢通。

## 步驟四：全域技能健檢與三方同步驗證

引導/協助使用者開啟 [01-antigravity-lazypack.md](./01-antigravity-lazypack.md) 的「四、全域技能健檢與三方同步驗證」：
1. 驗證基礎服務連線狀態（Git/gh 驗證、Node/npm 環境、mcpvault 與二腦讀寫、Google Drive 同步）。
2. 驗證與補充全域技能進階依賴環境，包含：**GPT Image Tool (生圖技能) 測試**、Playwright 瀏覽器、Python 3 與 pip、Poppler / pdfplumber、FFmpeg 影音渲染、yt-dlp 轉錄下載、Heptabase CLI 狀態、Netlify CLI 狀態、Firebase CLI 狀態及 Kokoro TTS 音訊合成環境。
3. 校驗「全域 Skill 文檔 (`codex_symlink/skills`)」、「LazyPack 本專案安裝檔 (`01-antigravity-lazypack.md`)」與「Obsidian 知識庫/駕駛艙」三方相容性（相容 Codex/AntiGravity，清除 Claude，保持內容與路徑 100% 同步）。
4. 遇到任何沙盒限制時，將限制新增到沙盒規則中（將 **PIP、NPM、Python 及其執行與工作路徑**完整列為沙盒例外 `writable_roots`，確保無阻礙執行）。
5. **若有任何問題，直接參考 GitHub 遠端倉庫的公開說明。所有技能的完整安裝與修復指引，均可於 [GitHub Codex Installation - lazy-pack 目錄](https://github.com/icestone0128/codex-installation/tree/main/lazy-pack) 中取得。**

## 步驟五：完成回報格式

完成後，請依手冊回報格式進行狀態回報。
