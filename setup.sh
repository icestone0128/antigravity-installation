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
# 1. 驗證 GitHub 連線狀態 (Prerequisite)
# ==========================================
echo -e "\n${YELLOW}[步驟 1] 驗證 GitHub 連線與登入狀態...${NC}"
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

# ==========================================
# 2. 建置第二大腦 (Obsidian Vault)
# ==========================================
echo -e "\n${YELLOW}[步驟 2] 建置第二大腦 (Obsidian Vault)...${NC}"

# 預設路徑
DEFAULT_VAULT="/Users/arrywu/Library/CloudStorage/GoogleDrive-icestone0128@gmail.com/我的雲端硬碟/secondbrain"

read -p "請輸入 Obsidian Vault 的實體路徑 [預設: $DEFAULT_VAULT]: " USER_VAULT
USER_VAULT="${USER_VAULT:-$DEFAULT_VAULT}"
USER_VAULT="${USER_VAULT/#\~/$HOME}"

if [ ! -d "$USER_VAULT" ]; then
  echo -e "${YELLOW}警告: 找不到目錄 '$USER_VAULT'，將為您自動建立此目錄。${NC}"
  mkdir -p "$USER_VAULT"
fi

echo -e "建置 Obsidian Vault 結構於: ${GREEN}$USER_VAULT${NC}"

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

# 建立基本索引檔案 (若不存在)
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

# ==========================================
# 3. 專案本地層初始化
# ==========================================
echo -e "\n${YELLOW}[步驟 3] 初始化專案本地資料層...${NC}"
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
# 4. 建立指向 codex_symlink 的全域 Symlinks
# ==========================================
echo -e "\n${YELLOW}[步驟 4] 設定全域配置軟連結 (Symlink)...${NC}"

# 預設路徑
DEFAULT_SYM_ROOT="/Users/arrywu/Library/CloudStorage/GoogleDrive-icestone0128@gmail.com/我的雲端硬碟/codex_symlink"

read -p "請輸入 Google Drive 中 codex_symlink 的實體路徑 [預設: $DEFAULT_SYM_ROOT]: " USER_SYM_ROOT
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

# 建立專案駕駛艙複本 AGENTS.md (若不存在)
if [ ! -f "$USER_VAULT/AGENTS.md" ] && [ -f "$USER_SYM_ROOT/core-rules.md" ]; then
  cp "$USER_SYM_ROOT/core-rules.md" "$USER_VAULT/AGENTS.md"
  echo -e "  已備份全域核心規則至 Obsidian: ${GREEN}$USER_VAULT/AGENTS.md${NC}"
fi

# 完成提示
echo -e "\n${BLUE}==================================================${NC}"
echo -e "${GREEN}🎉 懶人包環境配置與建置完成！${NC}"
echo -e "${BLUE}==================================================${NC}"
