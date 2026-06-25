#!/bin/bash
# AntiGravity / Codex 懶人包環境配置與二腦建置腳本
# 適用於 macOS 與 zsh 環境

set -e

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

# ==========================================
# 7. 部署預設知識架構範本
# ==========================================
echo -e "\n${YELLOW}[步驟 6] 部署預設知識架構範本...${NC}"
if [ -d "$USER_SYM_ROOT/knowledge" ]; then
  TEMPLATE_FILES=(
    "context-management-strategy.md"
    "verification-checklist.md"
    "subagent-strategy.md"
    "parallelization-strategy.md"
    "advanced-memory-learning.md"
    "prompt-defense-baseline.md"
    "security-review-checklist.md"
    "coding-standards.md"
  )
  
  for tfile in "${TEMPLATE_FILES[@]}"; do
    if [ -f "200_Reference/templates/$tfile" ]; then
      if [ ! -f "$USER_SYM_ROOT/knowledge/$tfile" ]; then
        cp "200_Reference/templates/$tfile" "$USER_SYM_ROOT/knowledge/"
        echo -e "  已部署知識文件: ${GREEN}$tfile${NC}"
      else
        echo -e "  知識文件已存在 (略過，防覆寫): $tfile"
      fi
    fi
  done
else
  echo -e "${RED}警告: 找不到全域知識庫目錄 '$USER_SYM_ROOT/knowledge'，略過部署。${NC}"
fi

# 完成提示
echo -e "\n${BLUE}==================================================${NC}"
echo -e "${GREEN}🎉 懶人包環境配置與建置完成！${NC}"
echo -e "1. 全域軟連結 (Symlink) 建立成功"
echo -e "2. Obsidian Vault 對接完成 (${GREEN}防覆寫模式啟用${NC})"
echo -e "3. Gemini API Key 安全配置就緒"
echo -e "4. 本地專案層資料夾初始化完成"
echo -e "5. 預設知識架構範本部署完成 (${GREEN}防覆寫模式啟用${NC})"
echo -e ""
echo -e "${YELLOW}請重啟您的 AI 助理以加載設定，並接續最後的健檢步驟！${NC}"
echo -e "${BLUE}==================================================${NC}"

