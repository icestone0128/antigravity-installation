# 專案本地技能庫 (Project-Local Skills) - README

本目錄 (`000_Agent/skills/`) 用於存放此專案專屬的 AI Agent 技能 (Skills) 套件。

## 設計原則

根據 `arry-assistant` 雙層整合架構與 `project-init-sync` 的可攜性原則：
1. **歸屬判定**：
   - 若為**跨專案可重用**或需在全域觸發之技能：應放置於全域技能路徑 `$CODEX_HOME/skills/` (同步至 `codex_symlink/skills`)。
   - 若為**僅限本專案使用**之特定流程或特殊工具整合技能：應放置於本目錄下。
2. **可攜化要求**：
   - 存放在此處的技能套件必須包含完整的說明檔 (`SKILL.md`)，作為獨立可移植的 Package。
   - 禁止在此處建立指回全域目錄的 symlink。
   - 建立新的專案專用技能後，必須將其名稱、路徑與用途記錄在 Obsidian 專案駕駛艙 (`專案工作流程.md`) 中。

## 目錄結構範例

若要建立一個本地技能 `local-custom-tool`：
```text
000_Agent/skills/
└── local-custom-tool/
    ├── SKILL.md        # 技能說明與規範
    └── scripts/        # (選填) 輔助指令碼或工具程式
```
