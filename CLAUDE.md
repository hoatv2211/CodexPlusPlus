# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Codex++ is an external enhancement launcher and manager for the Codex App. It does not modify the original Codex installation. Instead, it starts Codex externally and injects enhancements through the Chromium DevTools Protocol (CDP).

Two entry points:
- **Codex++** (silent launcher): Starts Codex with Codex++ injection, no UI
- **Codex++ Manager**: Tauri-based control panel for configuration, diagnostics, and updates

## Build Commands

### Frontend (React/Tauri)
```bash
cd apps/codex-plus-manager
npm install
npm run check        # TypeScript type check
npm run vite:build   # Vite production build
npm run dev          # Tauri dev mode with hot reload
```

### Rust Backend
```bash
cargo fmt --check    # Check formatting
cargo test           # Run all tests
cargo build --release # Full release build
```

## Architecture

### Crates
- **`crates/codex-plus-core/`**: Core logic - launch, CDP injection, config management, update, install, HTTP bridge (`codex-plus-launcher` depends on this)
- **`crates/codex-plus-data/`**: Session data handling - SQLite storage, Markdown export, Provider Sync (`codex-plus-launcher` and manager both depend on this)

### Apps
- **`apps/codex-plus-launcher/`**: Silent launcher binary (`codex-plus-plus`). Handles process launch, CDP injection setup, and HTTP helper bridge on port 57321
- **`apps/codex-plus-manager/`**: Tauri + React 19 + Tailwind CSS v4 manager UI. Communicates with launcher via Tauri commands

### Injection
- **`assets/inject/renderer-inject.js`**: Large (340KB+) JS injected into Codex renderer via CDP. Handles all UI enhancements (session delete, Markdown export, project move, Timeline, user scripts)

### Installers
- **`scripts/installer/windows/CodexPlusPlus.nsi`**: NSIS installer for Windows
- **`scripts/installer/macos/package-dmg.sh`**: DMG packager for macOS

## Key Technical Patterns

### Relay Injection
Codex++ writes to `~/.codex/config.toml` to configure a `CodexPlusPlus` model provider with custom base URL and bearer token. Two modes:
- `relay`: Compatible mode (plugin unlock disabled)
- `patch`: Full enhancement mode (plugin unlock enabled)

### Provider Sync
Backs up and migrates session ownership markers between provider configurations to keep historical sessions visible after switching.

### CDP Bridge
Launcher exposes HTTP helper on `http://127.0.0.1:57321` for browser-renderer communication. Frontend checks endpoint:
```powershell
Invoke-RestMethod -Method Post -Uri http://127.0.0.1:57321/backend/status -Body "{}" -ContentType "application/json"
```

### Data Paths
- Codex config: `~/.codex/config.toml`
- Codex auth: `~/.codex/auth.json`
- Codex SQLite DB: `~/.codex/state_5.sqlite`
- Codex++ state/logs: `~/.codex-session-delete/`
- Provider Sync backups: `~/.codex/backups_state/provider-sync`

## UI Routes (Manager)
Located in `apps/codex-plus-manager/src/App.tsx`:
- `overview` - Health check and launch status
- `relay` - Provider profiles and relay injection
- `context` - MCP servers, skills, plugins
- `enhance` - Enhancement features toggle
- `userScripts` - Script Market and local scripts
- `providerSync` - Session repair settings
- `recommendations` - Ad/sponsor content
- `maintenance` - Install, repair, shortcuts
- `about` - Version, logs, diagnostics
- `settings` - Language, theme, CLI wrapper

## Dependency Notes
- Workspace Rust edition is 2024
- React 19 + Tailwind CSS v4 (uses `@tailwindcss/vite` plugin)
- Tauri 2.x with `codex_plus_manager_lib::run()` in main