#!/bin/bash
set -euo pipefail

# MCP Server Installer for mcp-server-tron
# This script ONLY configures the MCP server

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
if [ -t 0 ]; then
    exec 3<&0
elif [ -e /dev/tty ]; then
    exec 3</dev/tty
else
    exec 3<&0
fi

MCP_CONFIG_DIR="$HOME/.mcporter"
MCP_CONFIG_FILE="$MCP_CONFIG_DIR/mcporter.json"
TMPFILES=()

# --- Cleanup ---
cleanup() {
    for f in "${TMPFILES[@]:-}"; do
        rm -f "$f" 2>/dev/null || true
    done
    tput cnorm 2>/dev/null || true
}
trap cleanup EXIT

mktempfile() {
    local f
    f="$(mktemp)"
    TMPFILES+=("$f")
    echo "$f"
}

# --- Functions ---

check_env() {
    if ! command -v node &> /dev/null; then
        echo -e "${ERROR}Error: Node.js is not installed${NC}"
        exit 1
    fi
    if ! command -v npx &> /dev/null; then
        echo -e "${ERROR}Error: npx is not found${NC}"
        exit 1
    fi

    # Detect Python
    if command -v python3 &> /dev/null; then
        PYTHON_CMD="python3"
    elif command -v python &> /dev/null; then
        PYTHON_CMD="python"
    else
        echo -e "${ERROR}Error: Python not found (required for JSON processing)${NC}"
        exit 1
    fi
}

check_mcporter() {
    echo -e "${BOLD}Checking mcporter...${NC}"
    
    # Check if mcporter is installed
    if command -v mcporter &> /dev/null; then
        echo -e "${SUCCESS}✓ mcporter is installed${NC}"
        return 0
    fi
    
    # Check if clawhub is available
    if ! command -v clawhub &> /dev/null && ! npx clawhub --version &> /dev/null 2>&1; then
        echo -e "${WARN}⚠ clawhub not found${NC}"
        echo -e "${INFO}mcporter is required to manage MCP servers in OpenClaw${NC}"
        echo ""
        echo -e "${BOLD}Install mcporter:${NC}"
        echo -e "  ${INFO}npx clawhub install mcporter${NC}"
        echo ""
        echo -ne "${INFO}?${NC} Install mcporter now? ${MUTED}(Y/n)${NC}: "
        read -r install_mcporter <&3
        install_mcporter=${install_mcporter:-Y}
        
        if [[ "$install_mcporter" =~ ^[Yy]$ ]]; then
            echo -e "${INFO}Installing mcporter...${NC}"
            npx clawhub install --force mcporter || {
                echo -e "${ERROR}Failed to install mcporter${NC}"
                echo -e "${MUTED}You may need to install it manually${NC}"
                return 1
            }
            echo -e "${SUCCESS}✓ mcporter installed${NC}"
        else
            echo -e "${WARN}Skipping mcporter installation${NC}"
            echo -e "${MUTED}Note: You'll need mcporter for OpenClaw to load MCP servers${NC}"
            return 1
        fi
    else
        echo -e "${INFO}Installing mcporter via clawhub...${NC}"
        npx clawhub install --force mcporter || {
            echo -e "${WARN}Could not install mcporter automatically${NC}"
            echo -e "${MUTED}You may need to install it manually: npx clawhub install mcporter${NC}"
            return 1
        }
        echo -e "${SUCCESS}✓ mcporter installed${NC}"
    fi
    
    echo ""
    return 0
}

write_server_config() {
    local server="$1"
    local json_payload="$2"
    local config_file="$3"

    local py_script
    py_script=$(mktempfile)

    local payload_file
    payload_file=$(mktempfile)
    echo "$json_payload" > "$payload_file"

    cat <<EOF > "$py_script"
import json
import os
import sys

file_path = '$config_file'
server_name = '$server'
payload_file = '$payload_file'

try:
    with open(payload_file, 'r') as f:
        payload = json.load(f)
except Exception:
    sys.exit(1)

data = {}
if os.path.exists(file_path):
    try:
        with open(file_path, 'r') as f:
            content = f.read()
            if content.strip():
                data = json.loads(content)
    except ValueError:
        pass

if 'mcpServers' not in data:
    data['mcpServers'] = {}

if server_name not in data['mcpServers']:
    data['mcpServers'][server_name] = {}

# Deep merge for env
if 'env' in payload:
    if 'env' not in data['mcpServers'][server_name]:
        data['mcpServers'][server_name]['env'] = {}
    for k, v in payload['env'].items():
        if v is None or v == "":
            if k in data['mcpServers'][server_name]['env']:
                del data['mcpServers'][server_name]['env'][k]
        else:
            data['mcpServers'][server_name]['env'][k] = v
    del payload['env']

# Update other keys
for k, v in payload.items():
    data['mcpServers'][server_name][k] = v

with open(file_path, 'w') as f:
    json.dump(data, f, indent=2)
EOF
    $PYTHON_CMD "$py_script"
}

ask_input() {
    local prompt="$1"
    local var_name="$2"
    local is_secret="${3:-0}"
    local description="${4:-}"
    local input_val

    if [[ -n "$description" ]]; then
        echo -e "${MUTED}  $description${NC}"
    fi

    echo -ne "${INFO}?${NC} $prompt ${MUTED}(optional)${NC}: "

    if [[ "$is_secret" == "1" ]]; then
        read -rs input_val <&3
        echo ""
    else
        read -r input_val <&3
    fi
    printf -v "$var_name" '%s' "$input_val"
}

configure_mcp() {
    echo -e "${BOLD}Configuring mcp-server-tron...${NC}"
    echo ""
    echo -e "${INFO}Security Best Practice:${NC}"
    echo -e "  We recommend storing private keys in ${BOLD}environment variables${NC}"
    echo -e "  instead of the config file for better security."
    echo ""
    echo -e "${BOLD}Choose configuration method:${NC}"
    echo -e "  ${INFO}1)${NC} Use environment variables ${SUCCESS}[Recommended]${NC}"
    echo -e "  ${INFO}2)${NC} Store in config file (less secure)"
    echo ""
    echo -ne "${INFO}?${NC} Enter choice ${MUTED}(1-2, default: 1)${NC}: "
    
    CONFIG_METHOD=""
    read -r CONFIG_METHOD <&3
    CONFIG_METHOD=${CONFIG_METHOD:-1}
    
    case $CONFIG_METHOD in
        1)
            # Environment variables
            echo ""
            echo -e "${SUCCESS}Using environment variables (secure method)${NC}"
            echo ""
            echo -e "${BOLD}Add these lines to your shell profile:${NC}"
            echo -e "${MUTED}  For zsh: ~/.zshrc${NC}"
            echo -e "${MUTED}  For bash: ~/.bashrc${NC}"
            echo ""
            echo -e "${INFO}export TRON_PRIVATE_KEY=\"your_private_key_here\"${NC}"
            echo -e "${INFO}export TRONGRID_API_KEY=\"your_api_key_here\"${NC}"
            echo ""
            echo -e "${MUTED}After adding, run: source ~/.zshrc (or ~/.bashrc)${NC}"
            echo ""
            
            JSON_PAYLOAD=$(cat <<EOF
{
  "command": "npx",
  "args": ["-y", "@bankofai/mcp-server-tron"]
}
EOF
)
            ;;
        2)
            # Config file
            echo ""
            echo -e "${WARN}!!! SECURITY WARNING !!!${NC}"
            echo -e "${WARN}Keys will be saved in PLAINTEXT to: ${INFO}$MCP_CONFIG_FILE${NC}"
            echo ""

            ask_input "Enter TRON_PRIVATE_KEY" TRON_KEY 0 "Your TRON wallet private key."
            ask_input "Enter TRONGRID_API_KEY" TRON_API_KEY 0 "Your TronGrid API Key."

            echo -e "${MUTED}Saving configuration...${NC}"

            TRON_KEY_VAL="\"$TRON_KEY\""
            if [ -z "$TRON_KEY" ]; then TRON_KEY_VAL="null"; fi

            TRON_API_KEY_VAL="\"$TRON_API_KEY\""
            if [ -z "$TRON_API_KEY" ]; then TRON_API_KEY_VAL="null"; fi

            JSON_PAYLOAD=$(cat <<EOF
{
  "command": "npx",
  "args": ["-y", "@bankofai/mcp-server-tron"],
  "env": {
    "TRON_PRIVATE_KEY": $TRON_KEY_VAL,
    "TRONGRID_API_KEY": $TRON_API_KEY_VAL
  }
}
EOF
)
            ;;
        *)
            echo -e "${WARN}Invalid choice, using environment variables${NC}"
            JSON_PAYLOAD=$(cat <<EOF
{
  "command": "npx",
  "args": ["-y", "@bankofai/mcp-server-tron"]
}
EOF
)
            ;;
    esac
    
    mkdir -p "$MCP_CONFIG_DIR"
    write_server_config "mcp-server-tron" "$JSON_PAYLOAD" "$MCP_CONFIG_FILE"
    echo -e "${SUCCESS}✓ Configuration saved${NC}"
    echo ""
}

show_summary() {
    echo ""
    echo -e "${ACCENT}${BOLD}═══════════════════════════════════════${NC}"
    echo -e "${ACCENT}${BOLD}  Configuration Complete!${NC}"
    echo -e "${ACCENT}${BOLD}═══════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${INFO}MCP configuration:${NC} ${BOLD}$MCP_CONFIG_FILE${NC}"
    echo ""
    
    if grep -q "TRON_PRIVATE_KEY" "$MCP_CONFIG_FILE" 2>/dev/null; then
        echo -e "${BOLD}Next steps:${NC}"
        echo -e "  ${INFO}1.${NC} Secure your config file:"
        echo -e "     ${MUTED}chmod 600 $MCP_CONFIG_FILE${NC}"
        echo ""
        echo -e "  ${INFO}2.${NC} ${BOLD}Reload mcporter${NC} to apply changes:"
        echo -e "     ${MUTED}mcporter reload${NC}"
        echo -e "     ${MUTED}# Or if OpenClaw is a service:${NC}"
        echo -e "     ${MUTED}# systemctl restart openclaw (if using systemd)${NC}"
        echo -e "     ${MUTED}# Or restart OpenClaw application${NC}"
        echo ""
        echo -e "  ${INFO}3.${NC} Verify MCP server is loaded:"
        echo -e "     ${MUTED}Ask OpenClaw: \"What MCP servers are available?\"${NC}"
        echo ""
        echo -e "  ${INFO}4.${NC} Test the connection:"
        echo -e "     ${MUTED}Ask OpenClaw: \"Get my TRON wallet address\"${NC}"
    else
        echo -e "${BOLD}Next steps:${NC}"
        echo -e "  ${INFO}1.${NC} Add environment variables to your shell profile:"
        echo -e "     ${MUTED}nano ~/.zshrc  # or ~/.bashrc${NC}"
        echo ""
        echo -e "     ${INFO}export TRON_PRIVATE_KEY=\"your_key\"${NC}"
        echo -e "     ${INFO}export TRONGRID_API_KEY=\"your_api_key\"${NC}"
        echo ""
        echo -e "  ${INFO}2.${NC} Reload shell configuration:"
        echo -e "     ${MUTED}source ~/.zshrc  # or ~/.bashrc${NC}"
        echo ""
        echo -e "  ${INFO}3.${NC} ${BOLD}Reload mcporter${NC} to apply changes:"
        echo -e "     ${MUTED}mcporter reload${NC}"
        echo -e "     ${MUTED}# Or if OpenClaw is a service:${NC}"
        echo -e "     ${MUTED}# systemctl restart openclaw (if using systemd)${NC}"
        echo -e "     ${MUTED}# Or restart OpenClaw application${NC}"
        echo ""
        echo -e "  ${INFO}4.${NC} Verify MCP server is loaded:"
        echo -e "     ${MUTED}Ask OpenClaw: \"What MCP servers are available?\"${NC}"
        echo ""
        echo -e "  ${INFO}5.${NC} Test the connection:"
        echo -e "     ${MUTED}Ask OpenClaw: \"Get my TRON wallet address\"${NC}"
    fi
    echo ""
}

# --- Main Logic ---

echo -e "${ACCENT}${BOLD}"
echo "  🦞 MCP Server Installer"
echo -e "${NC}${ACCENT_DIM}  Configuring mcp-server-tron for OpenClaw${NC}"
echo ""

check_env
check_mcporter

# Check if already configured
if [ -f "$MCP_CONFIG_FILE" ] && grep -q "mcp-server-tron" "$MCP_CONFIG_FILE" 2>/dev/null; then
    echo -e "${WARN}⚠ mcp-server-tron is already configured${NC}"
    echo -ne "${INFO}?${NC} Reconfigure? ${MUTED}(y/N)${NC}: "
    read -r confirm <&3
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${MUTED}Configuration unchanged${NC}"
        exit 0
    fi
    echo ""
fi

configure_mcp
show_summary

echo -e "${MUTED}More info: https://github.com/bankofai/mcp-server-tron${NC}"
echo ""
