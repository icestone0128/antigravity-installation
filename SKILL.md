---
name: antigravity-lazy-packs
description: AntiGravity 懶人包 — 服務連接與工作流程設定。說「AntiGravity 懶人包」「安裝 Antigravity 設定」時載入。
---

# AntiGravity 懶人包 — AI Agent 自動安裝與設定入口

當使用者給你這個 repo 網址並說要安裝時，請依以下流程執行。本專案作為服務連接與工作流程的設定指引，全域技能均已在全域目錄中管理，不需額外重複安裝個別 Skill。

## 步驟一：安裝與連接基礎服務 (必要前置環境準備)

引導使用者安裝與連線基礎環境與 Obsidian MCP：
1. 下載並安裝 **Google Drive 電腦版**，登入帳號使其在本地建立同步掛載點。
2. 下載並安裝 **Obsidian** 筆記軟體。
3. 全域安裝 `mcpvault`：`npm install -g @bitbonsai/mcpvault`，並在 AI 助理的 MCP 設定檔（例如 `~/.gemini/config/mcp_config.json`）中註冊 `obsidian` 設定，將 args 指向已同步的二腦實體絕對路徑。
4. 在 Obsidian 中「開啟現有倉庫 (Open folder as vault)」，指向 Google Drive 本地同步掛載點底下的二腦目錄（例如 `secondbrain` ）。這能確保本機 Obsidian 成功與雲端二腦連線，載入過往記錄。
5. 登入 GitHub CLI (`gh auth login`) 並配置 Git 全域使用者。

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
1. 驗證全域 Skills / MCP / CLI 依賴可用性（包含 Git/gh, Node/npm/playwright, Python/pip/poppler/yt-dlp, FFmpeg, mcpvault ）。
2. 校驗「全域 Skill 文檔 (`codex_symlink/skills`)」、「LazyPack 本專案安裝檔 (`01-antigravity-lazypack.md`)」與「Obsidian 知識庫/駕駛艙」三方相容性（相容 Codex/AntiGravity，清除 Claude，保持內容與路徑 100% 同步）。
3. 遇到 any 沙盒限制時，將限制新增到沙盒規則中（特別是將 **PIP、NPM、Python 及其執行與工作路徑**完整列為沙盒例外 `writable_roots`，確保無阻礙執行指令與安裝）。
4. **若有任何問題，直接參考 GitHub 遠端倉庫的公開說明。所有技能的完整安裝與修復指引，均可於 [GitHub Codex Installation - lazy-pack 目錄](https://github.com/icestone0128/codex-installation/tree/main/lazy-pack) 中取得。**

## 步驟五：完成回報格式

完成後，請依手冊回報格式進行狀態回報。
