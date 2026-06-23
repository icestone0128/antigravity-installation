---
name: antigravity-lazy-packs
description: AntiGravity 懶人包 — 服務連接與工作流程設定。說「AntiGravity 懶人包」「安裝 Antigravity 設定」時載入。
---

# AntiGravity 懶人包 — AI Agent 自動安裝與設定入口

當使用者給你這個 repo 網址並說要安裝時，請依以下流程執行。本專案作為服務連接與工作流程的設定指引，全域技能均已在全域目錄中管理，不需額外重複安裝個別 Skill。

## 步驟一：執行自動化設定腳本

引導使用者在本專案目錄下執行以下指令：
```bash
./setup.sh
```
此腳本將自動按順序完成：
1. 驗證 GitHub 連線狀態，若未登入則引導登入
2. 建置第二大腦 (Obsidian Vault) 目錄結構與路徑設定
3. 初始化本地專案資料層 (`100_Todo` 與 `200_Reference`)
4. 建立全域軟連結 (Symlink)，將 `skills`、`memories` 等指向 `codex_symlink`

## 步驟二：進行服務連接設定

接著引導使用者/協助使用者開啟 [01-antigravity-lazypack.md](file:///Users/arrywu/Library/CloudStorage/GoogleDrive-icestone0128@gmail.com/我的雲端硬碟/antigravity_installation/01-antigravity-lazypack.md) 以完成其餘服務連接：
1. 註冊 Obsidian MCP

## 步驟三：回報狀態

完成後，請依以下格式回報完成狀態給使用者：

```markdown
## Anti-Gravity 懶人包設定完成

- 專案初始化與 Symlinks：[已完成 / 失敗]
- Obsidian 二腦建置與路徑設定：[已建置 / 未建置]
- GitHub：[已登入 / 待登入 / 失敗]
- Obsidian：[已連接 / 待設定 / 失敗]
- 規則檔：AGENTS.md 已建立 / 已更新 / 未建立
- Git 狀態：[乾淨 / 有未提交變更]
```
