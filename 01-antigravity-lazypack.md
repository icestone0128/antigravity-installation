# Anti-Gravity 懶人包 #01：服務連接與工作流程設定

> 版本：v2.6 (優化五大步驟版)
> 更新日期：2026-06-24
> 語系偏好：繁體中文（Taiwan）

這份懶人包的目標，是讓 Anti-Gravity 使用者能在**完全乾淨的第二台電腦**上，快速且安全地連接 GitHub 與 Obsidian，並建立「開工 / 收工 / 新專案初始化」工作流程。NotebookLM 與 Firebase 的連線已由全域配置接管，本指引不重複設定。

本文件只放可公開教學的設定流程，不放任何個人帳號 token、密碼或敏感測試專案資訊。

---

## 一、安裝與連接基礎服務 (必要前置環境準備 - 免 Homebrew 手動下載與安裝流程)

在進行任何 Symlink 對接前，請依序手動完成以下軟體安裝與 MCP 配置。這是讓您在新電腦上成功加載雲端全域配置與 Obsidian 第二大腦記錄的物理先決條件。

### 1. 安裝 Node.js 與 npm (Obsidian MCP 運行底層)
- **目的**：提供 `npx` 與全球套件管理環境，這是運行 `mcpvault` 與其他 AI 助理工具 the 底層依賴。
- **下載指引**：請前往 [Node.js 官方網站 (推薦下載 LTS 版本)](https://nodejs.org/) 下載 macOS `.pkg` 安裝程式，雙擊執行安裝。
- **驗證環境**：在 Terminal 中執行以下指令，確認安裝成功：
  ```bash
  node -v
  npm -v
  ```

### 2. 安裝 Google Drive 電腦版並同步雲端檔案
- **目的**：將您雲端硬碟中的全域資源母資料夾 `codex_symlink` 和第二大腦資料夾 `secondbrain` 同步至本機。
- **下載指引**：前往 [Google Drive 電腦版官方下載頁](https://www.google.com/drive/download/) 下載 macOS `.dmg` 安裝程式，打開掛載後將應用程式拖移至「應用程式 (Applications)」資料夾。
- **雲端同步與掛載**：
  1. 啟動 Google Drive 電腦版並登入您的 Google 帳號。
  2. 確認 macOS 的本地實體掛載點（預設位於 `/Users/你的系統使用者名稱/Library/CloudStorage/GoogleDrive-你的信箱/我的雲端硬碟/`，在 Finder 左側側邊欄「位置」亦會顯示）已建立。
  3. **關鍵等待**：確認該目錄下的 `codex_symlink` 與 `secondbrain` 資料夾已**完全同步下載至本地電腦**。

### 3. 安裝 Obsidian Desktop 並開啟現有二腦
- **目的**：本機筆記管理與專案駕駛艙。
- **下載指引**：前往 [Obsidian 官方網站](https://obsidian.md/) 下載 macOS `.dmg` 安裝檔，安裝並開啟。
- **開啟現有二腦**：
  1. 在 Obsidian 歡迎畫面選擇 **「開啟現有倉庫 (Open folder as vault)」**。
  2. 選擇已同步至本地的二腦資料夾路徑（如：`/Users/你的系統使用者名稱/Library/CloudStorage/GoogleDrive-你的信箱/我的雲端硬碟/secondbrain`）。
  3. 確認過往所有的筆記、工作流程與專案駕駛艙在介面中成功加載。

### 4. 安裝與註冊 Obsidian MCP
- **目的**：讓您的 AI 助理可以直接透過工具 API 讀寫您的 Obsidian 第二大腦。
- **安裝指令**：開啟 Terminal，執行以下指令全域安裝 `mcpvault` 伺服器：
  ```bash
  npm install -g @bitbonsai/mcpvault
  ```
- **配置 MCP 伺服器**：
  1. 開啟本機 AI 助理的 MCP 設定檔（例如 `~/.gemini/config/mcp_config.json` 或 `~/.codex/config.toml`）。
  2. 在 `mcpServers` 的 `obsidian` 設定中，填入 `mcpvault` 執行檔及您的 Obsidian Vault 本地實體絕對路徑：
     ```json
     {
       "mcpServers": {
         "obsidian": {
           "command": "mcpvault",
           "args": ["/Users/你的系統使用者名稱/Library/CloudStorage/GoogleDrive-你的信箱/我的雲端硬碟/secondbrain"]
         }
       }
     }
     ```
     *(註：在 macOS 中，若 PATH 未能正確加載 global npm bin，command 亦可填寫為絕對路徑如 `/usr/local/bin/mcpvault` 或 `/Users/你的使用者/.npm-global/bin/mcpvault`)*
- **自動化註冊腳本 (推薦選項)**：
  您也可以直接在本專案目錄下，執行本 repo 提供的 Python 自動化註冊腳本，它會自動定位 `mcpvault` 並寫入 `mcp_config.json`，且安全保留其他已存在的 MCP 伺服器配置（例如 NotebookLM, Firebase 等）：
  ```bash
  python3 200_Reference/scripts/register_mcp.py "/Users/你的系統使用者名稱/Library/CloudStorage/GoogleDrive-你的信箱/我的雲端硬碟/secondbrain"
  ```
  *(腳本詳細原始碼與說明請參見本文末附錄一)*

### 5. 安裝 Git 與 GitHub CLI (`gh`) 並登入
- **目的**：進行專案與全域設定的版本控制、自動同步以及 PR 提交。
- **Git 手動下載**：前往 [Git 官方網站 (macOS downloads)](https://git-scm.com/downloads) 下載 macOS 官方安裝程式。或者在 Terminal 直接輸入 `git --version`，系統若偵測到未安裝，會彈出視窗提示安裝「Xcode Command Line Tools」，點擊安裝即可取得系統原生 `git`。
- **GitHub CLI (`gh`) 手動下載**：
  1. 前往 [GitHub CLI 官網](https://cli.github.com/) 或 [GitHub CLI Releases 頁面](https://github.com/cli/cli/releases) 下載 macOS 預編譯的 `.zip` 壓縮檔（如 `gh_*_macOS_amd64.zip` 或 `arm64.zip`）。
  2. 解壓縮後，將 `bin/gh` 執行檔拖移或移動至系統 PATH 目錄下（例如 `/usr/local/bin/`）。
- **登入與驗證**：在 Terminal 中執行以下指令：
  ```bash
  gh auth login --web --git-protocol https
  gh auth status
  ```

### 6. 安裝 Python 3 與相關全域技能依賴
- **Python 3 & pip**：前往 [Python 官方網站](https://www.python.org/downloads/) 下載 macOS `.pkg` 檔案雙擊安裝，確保 `python3` 與 `pip3` 指令可用。
- **FFmpeg (影音多媒體渲染依賴)**：前往 [FFmpeg 官網推薦下載頁](https://ffmpeg.org/download.html#build-mac) 下載預編譯的 macOS 靜態執行檔，將 `ffmpeg` 解壓後移動至 `/usr/local/bin/`。
- **yt-dlp (YouTube 轉錄依賴)**：在 Terminal 中執行以下命令安裝：
  ```bash
  pip3 install yt-dlp
  ```

### 7. 安全規則
- 嚴禁將個人 GitHub token、API keys 寫進 Markdown、AGENTS.md、Obsidian 對外筆記或 commit 中。
- commit 前務必先檢查 diff，嚴禁自動無差別提交。

---

## 二、設定全域配置軟連結 (Symlink)

在步驟一的所有基礎軟體、MCP 註冊與二腦連線完成後，請執行設定腳本建立指向您雲端硬碟 `codex_symlink` 的全域軟連結。

### 執行設定腳本
```bash
./200_Reference/scripts/setup.sh
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

為了確保 AI Agent 在第二台電腦上擁有完整且無障礙的工作能力，AI 助理在設定完成後**必須執行以下依賴健檢與三方同步驗證**，清查全域技能運行環境：

### 1. 驗證步驟一已安裝之基礎服務連線狀態
AI 助理應直接在 Terminal 運行相關指令，或調用 MCP 接口進行連線驗證（無須重複安裝）：
- [ ] **GitHub CLI (`gh`) 驗證**：運行 `git --version`、`gh auth status`，確認 Git 與 GitHub 登入正常，且 credentials 未受無效 `GITHUB_TOKEN` 污染（供 `contribute-catalog`, `project-init-sync` 使用）。
- [ ] **Node.js & npm 運行環境**：運行 `node -v`、`npm -v`，確認為正常配置的運行環境。
- [ ] **Obsidian MCP (`mcpvault`) 狀態**：AI 助理能透過 `obsidian` MCP 讀寫二腦，可直接讀取二腦根目錄的 `AGENTS.md` 以確認連線暢通。
- [ ] **Google Drive 掛載與二腦對接**：確認 `/Users/你的使用者/Library/CloudStorage/...` 目錄下的 `codex_symlink` 與 `secondbrain` 檔案已正確同步且可被讀取。

### 2. 驗證與補充全域技能的進階依賴環境
清查全域技能所需的 CLI、相依庫或 MCP 服務。若尚未安裝，引導使用者進行補充配置：
- [ ] **GPT Image Tool (生圖技能) 驗證**：AI 助理必須調用內建的 `image-generator` 或 `imagegen` 進行一次低風險的生圖測試（例如生成一張測試頭像），確認 AI 具備生圖能力並能產出實體圖檔（供 `image-generator`, `visual-note-generator`, `social-cards` 使用）。
- [ ] **Playwright 瀏覽器截圖環境**：確認無頭瀏覽器環境已安裝且可抓取網頁，若缺失可引導使用者於本地執行 `npx playwright install`（供 `playwright`, `social-cards`, `website-to-hyperframes` 使用）。
- [ ] **Python 3 與 pip 相關庫**：驗證 `python3 --version`，確認 `pip3 install` 相關依賴正常（供執行備份腳本與文字/轉換腳本使用）。
- [ ] **Poppler / pdfplumber 工具**：可用於 PDF 渲染與資訊提取（供 `pdf`, `doc-to-md` 使用）。
- [ ] **FFmpeg 媒體工具**：多媒體編輯與影音合成正常，確認 `/usr/local/bin/ffmpeg` 可用（供 `hyperframes`, `video-processing-automation` 等使用）。
- [ ] **yt-dlp 下載器**：用於轉錄 YouTube 資訊，確認 `yt-dlp --version` 可用（供 `youtube-transcript-collector` 使用）。
- [ ] **Heptabase CLI 驗證**：確認 `heptabase --version` 及 Heptabase desktop 內的 Local CLI Server 連線正常（供 `heptabase-cli` 技能使用）。
- [ ] **Netlify CLI / MCP 驗證**：確認 `netlify --version` 或 Netlify MCP 狀態正常（供 `netlify-deploy` 技能使用）。
- [ ] **Firebase CLI 驗證**：確認 `npx -y firebase-tools@latest --version` 可用且專案關聯正確（供 Firebase 系列技能使用）。
- [ ] **Kokoro / TTS 語音合成環境**：語音合成功能與模型配置正常，MPS/CUDA/CPU 運行正常（供 `hyperframes-media` 和 `voxcpm2-voice-cloner` 技能的 TTS 及聲音複製使用）。
- [ ] **個人 API 憑證安全**：API 金鑰安全存放於 `~/.codex/secrets/`（如 `gemini_api_key`）且已被排除在 Git 外（供 `gemini-free-api` 及全域 API 呼叫使用）。

### 3. 三方相容性校驗 (相容 Codex/AntiGravity，清除 Claude)
- 複查「全域 Skill 文檔 (`codex_symlink/skills`)」、「LazyPack 本手冊 (`01-antigravity-lazypack.md`)」與「Obsidian 知識庫/駕駛艙」這三者：
  - 確認皆相容於 Codex 或 AntiGravity 的設定與路徑。
  - **徹底清除所有舊有 Claude 相關字眼與殘留設定**。
  - 確保這三者的核心內容與路徑是 100% 同步且一致的。

### 4. 沙盒限制排除
- 執行健檢或操作時，若遇到 AI 助理沙盒寫入/讀取限制，**必須立刻修改配置，將該限制路徑新增到沙盒規則中**（例如修改本機 `config.toml` 或 AI 助理配置中的 `writable_roots` ）。**特別是 PIP、NPM、Python 及其相關的實體路徑（如 `~/.npm/`, `~/.pip/`, 以及 Python 與 Node.js 的全局二進位執行檔路徑、環境資料夾與專案工作目錄），都必須被完整列為沙盒排除項目，以確保這些指令、相依庫安裝以及指令調用都能直接、無礙地執行。**

### 5. 疑難排解與參考資料
- **如果在執行本步驟或懶人包引導時遇到任何環境、連線、模組或權限問題，請直接參考 GitHub 上的公開說明。本專案中所有技能皆與 Codex Installation 專案的懶人包設計相呼應。您可以隨時回到其 GitHub 遠端倉庫 the `lazy-pack` 目錄尋求完整的設定檔與疑難排解指引：**
  - [GitHub Codex Installation - lazy-pack 目錄](https://github.com/icestone0128/codex-installation/tree/main/lazy-pack)

---

## 五、完成回報格式

```markdown
## Anti-Gravity 懶人包設定完成

- GitHub：已登入 / 待登入 / 失敗
- Obsidian：已連接 / 待設定 / 失敗
- 全域 Symlinks 與載入 (arry-assistant, project-init-sync)：已完成 / 失敗
- 基礎服務連線驗證：
  - GitHub CLI (gh) 驗證：[通過 / 失敗]
  - Node.js & npm：[通過 / 失敗]
  - mcpvault 連線：[通過 / 失敗]
- 全域進階相依健檢：
  - GPT Image Tool (生圖驗證)：[通過 / 失敗]
  - Playwright (瀏覽器)：[通過 / 失敗]
  - Python 3 & pip：[通過 / 失敗]
  - Poppler (PDF)：[通過 / 失敗]
  - FFmpeg (多媒體)：[通過 / 失敗]
  - yt-dlp (YouTube)：[通過 / 失敗]
  - Heptabase CLI：[通過 / 失敗]
  - Netlify CLI：[通過 / 失敗]
  - Firebase CLI：[通過 / 失敗]
  - Kokoro / TTS 音訊：[通過 / 失敗]
  - API secrets 安全：[通過 / 失敗]
- 三方相容性 (移除 Claude/路徑同步)：已完成 / 失敗
- 規則檔：AGENTS.md 已建立 / 已更新 / 未建立
- Git 狀態：[乾淨 / 有未提交變更]
```

---

## 附錄：關鍵自動化與同步程式碼

為了讓使用者在全新第二台電腦上能快速部署、配置與備份，本節完整涵蓋了整個 repo 運行中所需跑的所有關鍵自動化程式原始碼。您可以直接閱讀或拷貝使用：

### 附錄一：Obsidian MCP 全自動註冊腳本 (`200_Reference/scripts/register_mcp.py`)
這段 Python 腳本會自動定位全域安裝的 `mcpvault` 執行檔，並在不干擾其他現有 MCP（如 NotebookLM 或 Firebase）的前提下，將 `obsidian` MCP 伺服器配置動態寫入/更新至您的本機 `mcp_config.json`。

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# register_mcp.py - 自動全域定位 mcpvault 並註冊 Obsidian MCP 至 mcp_config.json

import os
import sys
import json
import subprocess

def locate_mcpvault():
    """使用 which 命令或常見路徑自動定位 mcpvault 絕對路徑"""
    try:
        result = subprocess.run(["which", "mcpvault"], capture_output=True, text=True, check=True)
        path = result.stdout.strip()
        if path and os.path.exists(path):
            return path
    except Exception:
        pass

    # 常見 macOS npm 全域安裝路徑
    fallback_paths = [
        "/usr/local/bin/mcpvault",
        "/opt/homebrew/bin/mcpvault",
        os.path.expanduser("~/.npm-global/bin/mcpvault"),
        "/usr/bin/mcpvault"
    ]
    for path in fallback_paths:
        if os.path.exists(path):
            return path
            
    # 預設直接使用 command 名稱
    return "mcpvault"

def register_obsidian_mcp(vault_path):
    vault_path = os.path.abspath(os.path.expanduser(vault_path))
    if not os.path.exists(vault_path):
        print(f"⚠️ 警告: 指定的 Obsidian Vault 路徑不存在: {vault_path}")
        print("將繼續寫入設定，但請確認該目錄稍後同步完成。")
        
    config_dir = os.path.expanduser("~/.gemini/config")
    config_path = os.path.join(config_dir, "mcp_config.json")
    
    # 確保設定目錄存在
    os.makedirs(config_dir, exist_ok=True)
    
    # 讀取現有配置
    config_data = {}
    if os.path.exists(config_path):
        try:
            with open(config_path, "r", encoding="utf-8") as f:
                config_data = json.load(f)
        except Exception as e:
            print(f"⚠️ 讀取現有 mcp_config.json 失敗: {e}。將建立全新配置。")
            
    # 確保結構完整，不覆寫其他 MCP (如 Firebase, NotebookLM 等)
    if "mcpServers" not in config_data:
        config_data["mcpServers"] = {}
        
    mcpvault_cmd = locate_mcpvault()
    print(f"🔍 自動定位 mcpvault 執行檔: {mcpvault_cmd}")
    
    # 更新或寫入 obsidian 設定
    config_data["mcpServers"]["obsidian"] = {
        "command": mcpvault_cmd,
        "args": [vault_path]
    }
    
    # 寫回檔案
    try:
        with open(config_path, "w", encoding="utf-8") as f:
            json.dump(config_data, f, indent=2, ensure_ascii=False)
        print(f"✅ 成功註冊 Obsidian MCP 至: {config_path}")
        print(f"   - 運行路徑: {mcpvault_cmd}")
        print(f"   - Vault 對接: {vault_path}")
    except Exception as e:
        print(f"❌ 寫入 mcp_config.json 失敗: {e}")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("用法: python3 200_Reference/scripts/register_mcp.py <Obsidian_Vault_實體路徑>")
        sys.exit(1)
    register_obsidian_mcp(sys.argv[1])
```

---

### 附錄二：環境配置與全域軟連結一鍵建置腳本 (`200_Reference/scripts/setup.sh`)
這段 Bash 腳本用於一鍵建立指向雲端 `codex_symlink` 的全域軟連結（Skills、Memories、AGENTS.md），同時互動補全 Git 全域設定、安全配置本機 Gemini API Secrets，並對已同步之 Obsidian 二腦進行防覆寫對接與專案本地層初始化。

```bash
#!/bin/bash
# AntiGravity / Codex 懶人包環境配置與二腦建置腳本
# 適用於 macOS 與 zsh 環境

set -e

# 自動切換至專案根目錄，確保相對路徑操作正確
cd "$(dirname "$0")/../.."

# 文字顏色定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # 無顏色

echo -e "${BLUE}==================================================${NC}"
echo -e "${GREEN}  AntiGravity / Codex 懶人包環境初始化與建置腳本${NC}"
echo -e "${BLUE}==================================================${NC}"

# ==========================================
# 0. 物理前置條件引導與互動確認
# ==========================================
echo -e "${YELLOW}【重要前置檢查】${NC}"
echo -e "在開始配置全域 Symlink 之前，請務必確認已手動下載並完成以下前置步驟（免 Homebrew）："
echo -e " 1. ${GREEN}手動安裝並登入 Google Drive 電腦版${NC}（確保雲端檔案完全同步至本地）。"
echo -e " 2. ${GREEN}手動安裝 Obsidian 筆記軟體${NC}。"
echo -e " 3. ${GREEN}手動安裝 Node.js，全域安裝且在 mcp_config.json 中註冊 Obsidian MCP (mcpvault)${NC}。"
echo -e " 4. ${GREEN}在 Obsidian 中「開啟現有倉庫 (Open folder as vault)」${NC}，並指向已同步之 secondbrain 二腦目錄。"
echo -e "    * 原因：這能讓這台新電腦的 Obsidian 成功同步並連線您過往的所有記錄與專案駕駛艙。"
echo -e ""

read -p "您是否已確認完成上述 Google Drive、Obsidian 以及 Obsidian MCP (mcpvault) 連線步驟？ (y/n) [預設: y]: " PRE_CHECK
PRE_CHECK="${PRE_CHECK:-y}"

if [[ "$PRE_CHECK" != "y" && "$PRE_CHECK" != "Y" ]]; then
  echo -e "${RED}提示: 請先下載安裝 Google Drive、Obsidian 與 mcpvault，並完成連線設定後，再重新執行此腳本。${NC}"
  exit 1
fi

# ==========================================
# 1. 驗證 GitHub 連線狀態與 Git 全域設定
# ==========================================
echo -e "\n${YELLOW}[步驟 1] 驗證 GitHub 連線與 Git 全域設定...${NC}"
if ! command -v gh &> /dev/null; then
  echo -e "${RED}錯誤: 系統未安裝 GitHub CLI (gh)。請先安裝 GitHub CLI 才能繼續執行。${NC}"
  exit 1
fi

echo -e "正在檢查 GitHub 登入狀態..."
if ! gh auth status &> /dev/null; then
  echo -e "${YELLOW}未偵測到 GitHub 登入資訊。正在啟動瀏覽器登入流程...${NC}"
  gh auth login --web --git-protocol https
else
  echo -e "${GREEN}GitHub CLI 已成功連接並登入！${NC}"
fi

# 設定 Git 使用者身分 (若未設定則引導填寫，防止日後 commit 中斷)
echo -e "正在檢查 Git 全域設定..."
GIT_USER=$(git config --global user.name || true)
GIT_EMAIL=$(git config --global user.email || true)

if [ -z "$GIT_USER" ] || [ -z "$GIT_EMAIL" ]; then
  echo -e "${YELLOW}未偵測到完整的 Git user.name 或 user.email，引導手動設定：${NC}"
  read -p "請輸入 Git 使用者名稱 user.name: " NEW_GIT_USER
  read -p "請輸入 Git 電子郵件 user.email: " NEW_GIT_EMAIL
  if [ -n "$NEW_GIT_USER" ] && [ -n "$NEW_GIT_EMAIL" ]; then
    git config --global user.name "$NEW_GIT_USER"
    git config --global user.email "$NEW_GIT_EMAIL"
    echo -e "${GREEN}Git 全域設定已更新！${NC}"
  else
    echo -e "${RED}警告: Git 使用者設定不完整，日後執行 git commit 時可能會被阻擋。${NC}"
  fi
else
  echo -e "  Git user.name: ${GREEN}$GIT_USER${NC}"
  echo -e "  Git user.email: ${GREEN}$GIT_EMAIL${NC}"
fi

# ==========================================
# 2. 自動偵測 Google Drive 掛載路徑
# ==========================================
echo -e "\n${YELLOW}正在本機動態偵測 Google Drive 掛載路徑...${NC}"
DETECTED_GD=""
if [ -d "$HOME/Library/CloudStorage" ]; then
  # 搜尋 Library/CloudStorage 下所有 GoogleDrive 開頭的目錄
  GD_CANDIDATES=($(find "$HOME/Library/CloudStorage" -maxdepth 1 -name "GoogleDrive-*" 2>/dev/null || true))
  for candidate in "${GD_CANDIDATES[@]}"; do
    if [ -d "$candidate/我的雲端硬碟" ]; then
      DETECTED_GD="$candidate/我的雲端硬碟"
      break
    elif [ -d "$candidate/My Drive" ]; then
      DETECTED_GD="$candidate/My Drive"
      break
    fi
  done
fi

if [ -n "$DETECTED_GD" ]; then
  echo -e "${GREEN}偵測到 Google Drive 本地實體路徑為: $DETECTED_GD${NC}"
  DEFAULT_SYM_ROOT="$DETECTED_GD/codex_symlink"
  DEFAULT_VAULT="$DETECTED_GD/secondbrain"
else
  echo -e "${RED}未偵測到本機 Google Drive 掛載目錄！${NC}"
  echo -e "請確認您已下載並登入 Google Drive 電腦版，且已正確掛載於雲端存取目錄中。"
  echo -e "若您的系統環境特殊，請在下方手動輸入您的 Google Drive 實體路徑。"
  DEFAULT_SYM_ROOT="$HOME/Library/CloudStorage/GoogleDrive-your_email@gmail.com/我的雲端硬碟/codex_symlink"
  DEFAULT_VAULT="$HOME/Library/CloudStorage/GoogleDrive-your_email@gmail.com/我的雲端硬碟/secondbrain"
fi

# ==========================================
# 3. 建立指向 codex_symlink 的全域 Symlinks (優先執行)
# ==========================================
echo -e "\n${YELLOW}[步驟 2] 設定全域配置軟連結 (Symlink)...${NC}"
echo -e "這個步驟會將全域技能、記憶與規則檔對接到 AI 助理載入路徑中。"

read -p "請指定您 Google Drive 中 codex_symlink 的實體路徑 [預設: $DEFAULT_SYM_ROOT]: " USER_SYM_ROOT
USER_SYM_ROOT="${USER_SYM_ROOT:-$DEFAULT_SYM_ROOT}"
USER_SYM_ROOT="${USER_SYM_ROOT/#\~/$HOME}"

if [ ! -d "$USER_SYM_ROOT" ]; then
  echo -e "${RED}錯誤: 找不到路徑 '$USER_SYM_ROOT'，請確認 Google Drive 串流已啟用並掛載！${NC}"
  exit 1
fi

echo -e "使用全域共用層實體路徑: ${GREEN}$USER_SYM_ROOT${NC}"

# 輔助建立 symlink 的函數
create_symlink() {
  local target="$1"
  local link="$2"
  
  if [ -L "$link" ] && [ "$(readlink "$link")" = "$target" ]; then
    echo -e "  軟連結已存在且正確 (略過): $link"
    return
  fi

  if [ -e "$link" ] || [ -L "$link" ]; then
    if [ -d "$link" ] && [ ! -L "$link" ]; then
      echo -e "${RED}警告: '$link' 是實體資料夾且已存在，為避免覆蓋未直接替換。${NC}"
      return
    fi
    rm -f "$link"
  fi

  mkdir -p "$(dirname "$link")"
  ln -s "$target" "$link"
  echo -e "  已建立軟連結: ${GREEN}$link${NC} -> $target"
}

# --- Codex 全域設定 ---
echo -e "\n設定 Codex 全域軟連結..."
CODEX_HOME="$HOME/.codex"
create_symlink "$USER_SYM_ROOT/skills" "$CODEX_HOME/skills"
create_symlink "$USER_SYM_ROOT/memories" "$CODEX_HOME/memories"
create_symlink "$USER_SYM_ROOT/core-rules.md" "$CODEX_HOME/AGENTS.md"

# --- AntiGravity 全域設定 ---
echo -e "\n設定 AntiGravity 全域軟連結..."
AG_HOME="$HOME/.gemini/config"
create_symlink "$USER_SYM_ROOT/skills" "$AG_HOME/plugins/codex/skills"
create_symlink "$USER_SYM_ROOT/memories" "$AG_HOME/memories"
create_symlink "$USER_SYM_ROOT/core-rules.md" "$AG_HOME/AGENTS.md"

echo -e "${GREEN}軟連結對接完成！AI 助理現在已可讀取全域技能。${NC}"

# ==========================================
# 4. 對接或初始化第二大腦 (Obsidian Vault - 防覆寫保護)
# ==========================================
echo -e "\n${YELLOW}[步驟 3] 對接第二大腦 (Obsidian Vault)...${NC}"

read -p "請指定您的 Obsidian Vault 實體路徑 [預設: $DEFAULT_VAULT]: " USER_VAULT
USER_VAULT="${USER_VAULT:-$DEFAULT_VAULT}"
USER_VAULT="${USER_VAULT/#\~/$HOME}"

# 檢查此路徑是否已經存在且含有檔案
V_FILES_COUNT=0
if [ -d "$USER_VAULT" ]; then
  # 計算檔案數量 (排除 .DS_Store 及點開頭的系統檔)
  V_FILES_COUNT=$(find "$USER_VAULT" -maxdepth 2 -type f ! -name ".*" 2>/dev/null | wc -l || echo 0)
fi

if [ "$V_FILES_COUNT" -gt 0 ]; then
  echo -e "${GREEN}偵測到現有的 Obsidian Vault 實體目錄 (內含 $V_FILES_COUNT 個檔案)。將自動啟用【防覆寫對接】模式。${NC}"
  echo -e "  - 將僅更新與備份全域規則檔至 Obsidian Vault 目錄底下的 AGENTS.md。"
  echo -e "  - 將不會覆寫、替換或生成 any index.md、log.md 等預設占位檔案，以保護您的過往筆記與記錄。"
  
  # 備份規則檔至 Obsidian
  if [ -f "$USER_SYM_ROOT/core-rules.md" ]; then
    mkdir -p "$USER_VAULT"
    cp "$USER_SYM_ROOT/core-rules.md" "$USER_VAULT/AGENTS.md"
    echo -e "  已更新/備份全域核心規則至 Obsidian: ${GREEN}$USER_VAULT/AGENTS.md${NC}"
  fi
else
  # 全新建立
  echo -e "${YELLOW}提示: 目錄 '$USER_VAULT' 不存在或為空，將為您自動建立與初始化結構。${NC}"
  mkdir -p "$USER_VAULT"
  
  # 建立 Vault 必要目錄
  VAULT_DIRS=(
    "Clippings"
    "知識庫"
    "每日筆記"
    "Templates"
    "專案庫"
  )

  for vdir in "${VAULT_DIRS[@]}"; do
    mkdir -p "$USER_VAULT/$vdir"
    echo -e "  建立 Obsidian 資料夾: ${GREEN}$USER_VAULT/$vdir${NC}"
  done

  # 建立基本索引檔案 (因為是全新目錄)
  if [ ! -f "$USER_VAULT/知識庫/index.md" ]; then
    cat > "$USER_VAULT/知識庫/index.md" <<'EOF'
---
title: 知識庫首頁
type: index
tags:
  - 知識庫
---
# 知識庫首頁
EOF
    echo -e "  建立檔案: ${GREEN}$USER_VAULT/知識庫/index.md${NC}"
  fi

  if [ ! -f "$USER_VAULT/知識庫/log.md" ]; then
    cat > "$USER_VAULT/知識庫/log.md" <<'EOF'
---
title: 知識庫異動日誌
type: log
tags:
  - 知識庫
---
# 知識庫異動日誌
EOF
    echo -e "  建立檔案: ${GREEN}$USER_VAULT/知識庫/log.md${NC}"
  fi

  # 備份規則檔至 Obsidian
  if [ -f "$USER_SYM_ROOT/core-rules.md" ]; then
    cp "$USER_SYM_ROOT/core-rules.md" "$USER_VAULT/AGENTS.md"
    echo -e "  已複製全域核心規則至 Obsidian: ${GREEN}$USER_VAULT/AGENTS.md${NC}"
  fi
fi

# ==========================================
# 5. 配置 API Secrets (Gemini API Key 安全寫入)
# ==========================================
echo -e "\n${YELLOW}[步驟 4] 安全配置 Gemini API Key...${NC}"
echo -e "此步驟會在本機安全寫入您的 Gemini API 密鑰，該密鑰將被排除在 Git 外且僅由本地 AI 助理調用。"

read -p "您是否要在此時配置 Google AI Studio Gemini API Key？ (y/n) [預設: y]: " WANT_KEY
WANT_KEY="${WANT_KEY:-y}"

if [[ "$WANT_KEY" == "y" || "$WANT_KEY" == "Y" ]]; then
  read -sp "請輸入您的 Gemini API Key: " GEMINI_KEY
  echo ""
  if [ -n "$GEMINI_KEY" ]; then
    mkdir -p "$HOME/.codex/secrets"
    chmod 700 "$HOME/.codex/secrets"
    echo "$GEMINI_KEY" > "$HOME/.codex/secrets/gemini_api_key"
    chmod 600 "$HOME/.codex/secrets/gemini_api_key"
    echo -e "${GREEN}Gemini API Key 已安全儲存於本機 ~/.codex/secrets/gemini_api_key！${NC}"
  else
    echo -e "${RED}警告: 輸入的金鑰為空，略過配置。${NC}"
  fi
else
  echo -e "${YELLOW}已略過配置。請確保日後自行配置，否則全域 API 功能將無法調用。${NC}"
fi

# ==========================================
# 6. 初始化專案本地資料層
# ==========================================
echo -e "\n${YELLOW}[步驟 5] 初始化專案本地資料層...${NC}"
LOCAL_DIRS=(
  "100_Todo/drafts"
  "100_Todo/projects"
  "100_Todo/archive"
  "200_Reference/writing-samples"
  "200_Reference/templates"
  "200_Reference/past-work"
)

for dir in "${LOCAL_DIRS[@]}"; do
  if [ ! -d "$dir" ]; then
    mkdir -p "$dir"
    echo -e "  已建立資料夾: ${GREEN}$dir${NC}"
  else
    echo -e "  資料夾已存在 (略過): $dir"
  fi
done

# 完成提示
echo -e "\n${BLUE}==================================================${NC}"
echo -e "${GREEN}🎉 懶人包環境配置與建置完成！${NC}"
echo -e "1. 全域軟連結 (Symlink) 建立成功"
echo -e "2. Obsidian Vault 對接完成 (${GREEN}防覆寫模式啟用${NC})"
echo -e "3. Gemini API Key 安全配置就緒"
echo -e "4. 本地專案層資料夾初始化完成"
echo -e ""
echo -e "${YELLOW}請重啟您的 AI 助理以加載設定，並接續最後的健檢步驟！${NC}"
echo -e "${BLUE}==================================================${NC}"
```

---

### 附錄三：Arry 助手收工同步與備份腳本 (`sync_backup.py`)
這段 Python 腳本用於在收工（`shutdown-sync`）時，將 Google Drive 全域共用層中的核心設定與記憶檔案，遞迴且完整地鏡像備份同步至您的 Obsidian Vault 目錄下，同時它也具備反向套用（`apply`）的能力。

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import shutil
import hashlib
import sys

# 定義路徑
SRC_DIR = "/Users/arrywu/Library/CloudStorage/GoogleDrive-icestone0128@gmail.com/我的雲端硬碟/codex_symlink"
DEST_DIR = "/Users/arrywu/Library/CloudStorage/GoogleDrive-icestone0128@gmail.com/我的雲端硬碟/secondbrain/專案庫/codex_installation/Arry 助手"

# 同步目標
TARGETS = [
    ("core-rules.md", "core-rules.md"),
    ("knowledge", "knowledge"),
    ("memories", "memories"),
    ("rules", "rules"),
    ("workflows", "workflows")
]

# 排除名單 (子目錄或檔名)
EXCLUDE_NAMES = {".git", ".DS_Store", "sync_backup.py", "__pycache__"}

def get_md5(file_path):
    if not os.path.exists(file_path):
        return None
    hash_md5 = hashlib.md5()
    try:
        with open(file_path, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                hash_md5.update(chunk)
        return hash_md5.hexdigest()
    except Exception as e:
        print(f"無法讀取檔案 {file_path} 的 MD5: {e}")
        return None

def sync_file(src, dest, dry_run=False):
    if not os.path.exists(src):
        return False, "source_not_found"
    
    src_md5 = get_md5(src)
    dest_md5 = get_md5(dest)
    
    if src_md5 == dest_md5:
        return False, "up_to_date"
    
    if not dry_run:
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        shutil.copy2(src, dest)
    return True, "copied"

def sync_directory(src_dir, dest_dir, dry_run=False):
    copied_count = 0
    deleted_count = 0
    
    if not os.path.exists(src_dir):
        print(f"來源目錄不存在: {src_dir}")
        return 0, 0
    
    # 1. 同步所有檔案與子目錄
    for root, dirs, files in os.walk(src_dir):
        dirs[:] = [d for d in dirs if d not in EXCLUDE_NAMES]
        rel_path = os.path.relpath(root, src_dir)
        target_root = dest_dir if rel_path == "." else os.path.join(dest_dir, rel_path)
        
        if not dry_run:
            os.makedirs(target_root, exist_ok=True)
            
        for file in files:
            if file in EXCLUDE_NAMES:
                continue
            src_file = os.path.join(root, file)
            dest_file = os.path.join(target_root, file)
            
            copied, reason = sync_file(src_file, dest_file, dry_run)
            if copied:
                print(f"[新增/更新] {os.path.relpath(dest_file, DEST_DIR if 'secondbrain' in dest_file else SRC_DIR)}")
                copied_count += 1
                
    # 2. 清理 destination 多餘的檔案 (Mirror 機制)
    for root, dirs, files in os.walk(dest_dir, topdown=False):
        rel_path = os.path.relpath(root, dest_dir)
        path_parts = rel_path.split(os.sep)
        if any(part in EXCLUDE_NAMES for part in path_parts):
            continue
            
        source_root = src_dir if rel_path == "." else os.path.join(src_dir, rel_path)
        
        for file in files:
            if file in EXCLUDE_NAMES:
                continue
            dest_file = os.path.join(root, file)
            src_file = os.path.join(source_root, file)
            
            if not os.path.exists(src_file):
                print(f"[刪除多餘] {os.path.relpath(dest_file, DEST_DIR if 'secondbrain' in dest_file else SRC_DIR)}")
                deleted_count += 1
                if not dry_run:
                    try:
                        os.remove(dest_file)
                    except Exception as e:
                        print(f"刪除檔案失敗 {dest_file}: {e}")
                        
        for d in dirs:
            if d in EXCLUDE_NAMES:
                continue
            dest_subdir = os.path.join(root, d)
            src_subdir = os.path.join(source_root, d)
            if not os.path.exists(src_subdir):
                print(f"[刪除多餘目錄] {os.path.relpath(dest_subdir, DEST_DIR if 'secondbrain' in dest_subdir else SRC_DIR)}")
                deleted_count += 1
                if not dry_run:
                    try:
                        shutil.rmtree(dest_subdir)
                    except Exception as e:
                        print(f"刪除目錄失敗 {dest_subdir}: {e}")
                        
    return copied_count, deleted_count

def run_sync(mode):
    if mode == "backup":
        print("=== 執行備份：全域共用層 -> Obsidian ===")
        from_dir, to_dir = SRC_DIR, DEST_DIR
    elif mode == "apply":
        print("=== 執行套用：Obsidian -> 全域共用層 ===")
        from_dir, to_dir = DEST_DIR, SRC_DIR
        
        if "-y" in sys.argv or "--yes" in sys.argv:
            confirm = "y"
        else:
            confirm = input("這將覆蓋全域共用層的檔案，確定要繼續嗎？(y/N): ")
            
        if confirm.lower() != 'y':
            print("取消操作。")
            return
    else:
        print("未知的模式。請使用 'backup' 或 'apply'。")
        return

    total_copied = 0
    total_deleted = 0
    
    for src_name, dest_name in TARGETS:
        src_path = os.path.join(from_dir, src_name)
        dest_path = os.path.join(to_dir, dest_name)
        
        if os.path.isdir(src_path) or (not os.path.exists(src_path) and os.path.isdir(dest_path)):
            copied, deleted = sync_directory(src_path, dest_path)
            total_copied += copied
            total_deleted += deleted
        else:
            copied, reason = sync_file(src_path, dest_path)
            if copied:
                print(f"[更新檔案] {dest_name}")
                total_copied += 1
                
    print(f"\n同步完成！共新增/更新 {total_copied} 個檔案，刪除 {total_deleted} 個檔案/目錄。")

if __name__ == "__main__":
    mode = "backup"
    if len(sys.argv) > 1:
        if sys.argv[1].startswith("-"):
            mode = "backup"
        else:
            mode = sys.argv[1].lower()
    run_sync(mode)
```


