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
        print("用法: python3 register_mcp.py <Obsidian_Vault_實體路徑>")
        sys.exit(1)
    register_obsidian_mcp(sys.argv[1])
