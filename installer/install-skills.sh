#!/bin/bash
set -euo pipefail

# Skills-Tron Skills Installer
# This script ONLY installs skill files to OpenClaw

# --- Colors & Styling ---
BOLD='\033[1m'
ACCENT='\033[38;2;255;90;45m'
ACCENT_DIM='\033[38;2;209;74;34m'
INFO='\033[38;2;0;145;255m'
SUCCESS='\033[38;2;0;200;83m'
WARN='\033[38;2;255;171;0m'
ERROR='\033[38;2;211;47;47m'
MUTED='\033[38;2;128;128;128m'
NC='\033[0m'

# --- Configuration ---
OPENCLAW_SKILLS_DIR="$HOME/.openclaw/skills"
INSTALLED_SKILLS=()

# Determine script directory
if [ -n "${BASH_SOURCE[0]:-}" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
else
    # Running from curl, need to clone repo
    REPO_ROOT=""
fi

# --- Cleanup ---
cleanup() {
    tput cnorm 2>/dev/null || true
}
trap cleanup EXIT

# --- Taglines ---
TAGLINES=(
    "Teaching OpenClaw to trade like a TRON native."
    "DeFi skills: Because agents deserve low fees too."
    "From zero to DEX trading in one script."
    "Installing SunSwap superpowers for your AI agent."
)

pick_tagline() {
    local count=${#TAGLINES[@]}
    local idx=$((RANDOM % count))
    echo "${TAGLINES[$idx]}"
}

TAGLINE=$(pick_tagline)

# --- Functions ---

check_env() {
    # If REPO_ROOT is empty, clone repo
    if [ -z "$REPO_ROOT" ]; then
        echo -e "${INFO}Cloning skills-tron repository...${NC}"
        TEMP_DIR=$(mktemp -d)
        git clone https://github.com/bankofai/skills-tron.git "$TEMP_DIR" 2>/dev/null || {
            echo -e "${ERROR}Error: Failed to clone repository${NC}"
            exit 1
        }
        REPO_ROOT="$TEMP_DIR"
        echo -e "${SUCCESS}✓ Repository cloned${NC}"
        echo ""
    fi

    # Check if sunswap exists
    if [ ! -d "$REPO_ROOT/sunswap" ]; then
        echo -e "${ERROR}Error: Cannot find sunswap skill${NC}"
        exit 1
    fi

    if [ ! -f "$REPO_ROOT/sunswap/SKILL.md" ]; then
        echo -e "${ERROR}Error: sunswap/SKILL.md not found${NC}"
        exit 1
    fi
}

select_install_target() {
    echo -e "${BOLD}Select installation location:${NC}"
    echo -e "  ${INFO}1)${NC} User-level (${INFO}~/.openclaw/skills/${NC}) ${SUCCESS}[Recommended]${NC}"
    echo -e "  ${INFO}2)${NC} Custom path"
    echo ""
    echo -ne "${INFO}?${NC} Enter choice ${MUTED}(1-2, default: 1)${NC}: "
    
    read -r choice
    choice=${choice:-1}
    
    case $choice in
        1)
            TARGET_DIR="$OPENCLAW_SKILLS_DIR"
            ;;
        2)
            echo -ne "${INFO}?${NC} Enter custom path: "
            read -r TARGET_DIR
            TARGET_DIR="${TARGET_DIR/#\~/$HOME}"
            ;;
        *)
            echo -e "${WARN}Invalid choice, using default${NC}"
            TARGET_DIR="$OPENCLAW_SKILLS_DIR"
            ;;
    esac
    
    echo -e "${MUTED}→ Installing to: ${INFO}$TARGET_DIR${NC}"
    echo ""
}

copy_skill() {
    local skill_id="$1"
    local target_dir="$2"
    
    echo -e "${INFO}Installing ${BOLD}$skill_id${NC}${INFO}...${NC}"
    
    # Check if skill exists
    if [ ! -d "$REPO_ROOT/$skill_id" ]; then
        echo -e "${ERROR}✗ Skill $skill_id not found${NC}"
        return 1
    fi
    
    # Check if already exists
    if [ -d "$target_dir/$skill_id" ]; then
        echo -e "${WARN}⚠ $skill_id already exists${NC}"
        echo -ne "${INFO}?${NC} Overwrite? ${MUTED}(y/N)${NC}: "
        read -r confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo -e "${MUTED}  Skipped $skill_id${NC}"
            return 0
        fi
        rm -rf "$target_dir/$skill_id"
    fi
    
    # Create target directory
    mkdir -p "$target_dir"
    
    # Copy skill
    cp -r "$REPO_ROOT/$skill_id" "$target_dir/"
    
    # Verify
    if [ -f "$target_dir/$skill_id/SKILL.md" ]; then
        echo -e "${SUCCESS}✓ $skill_id installed successfully${NC}"
        INSTALLED_SKILLS+=("$skill_id")
        return 0
    else
        echo -e "${ERROR}✗ Installation failed${NC}"
        return 1
    fi
}

show_summary() {
    echo ""
    echo -e "${ACCENT}${BOLD}═══════════════════════════════════════${NC}"
    echo -e "${ACCENT}${BOLD}  Installation Complete!${NC}"
    echo -e "${ACCENT}${BOLD}═══════════════════════════════════════${NC}"
    echo ""
    
    if [ ${#INSTALLED_SKILLS[@]} -gt 0 ]; then
        echo -e "${SUCCESS}✓${NC} ${BOLD}Installed skills:${NC}"
        for skill in "${INSTALLED_SKILLS[@]}"; do
            echo -e "  ${SUCCESS}•${NC} ${INFO}$skill${NC}"
        done
        echo ""
    fi
    
    echo -e "${INFO}Installation path:${NC} ${BOLD}$TARGET_DIR${NC}"
    echo ""
    echo -e "${BOLD}Next steps:${NC}"
    echo -e "  ${INFO}1.${NC} Ensure ${BOLD}mcp-server-tron${NC} is configured"
    echo -e "     ${MUTED}Run: ./install-mcp-server.sh${NC}"
    echo ""
    echo -e "  ${INFO}2.${NC} ${BOLD}Restart OpenClaw${NC} to load new skills"
    echo -e "     ${MUTED}• Close OpenClaw completely${NC}"
    echo -e "     ${MUTED}• Reopen OpenClaw${NC}"
    echo ""
    echo -e "  ${INFO}3.${NC} Test in OpenClaw:"
    echo -e "     ${MUTED}\"Read the sunswap skill and help me check USDT/TRX price\"${NC}"
    echo ""
}

# --- Main Logic ---

echo -e "${ACCENT}${BOLD}"
echo "  🦞 Skills-Tron Skills Installer"
echo -e "${NC}${ACCENT_DIM}  $TAGLINE${NC}"
echo ""

# Step 1: Check environment
check_env

# Step 2: Select target
select_install_target

# Step 3: Install skills
echo -e "${BOLD}Installing skills...${NC}"
echo ""

copy_skill "sunswap" "$TARGET_DIR"

# Step 4: Summary
show_summary

echo -e "${MUTED}Repository: https://github.com/bankofai/skills-tron${NC}"
echo ""
