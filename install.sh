#!/usr/bin/env bash
# BMAD CQS (Code Quality Standards) Module — Post-Installer
# Run AFTER: npx bmad-method install
# Run FROM: the project root (where _bmad/ lives)
#
# Usage: bash /path/to/bmad-coding-standards-module/install.sh [path-to-cqs-module-repo]

set -euo pipefail

# ---------------------------------------------------------------------------
# Colors
# ---------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ---------------------------------------------------------------------------
# Resolve CQS module repo path
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $# -ge 1 ]]; then
    CQS_MODULE_DIR="$(cd "$1" && pwd)"
else
    # Default: script lives inside the module repo
    CQS_MODULE_DIR="$SCRIPT_DIR"
fi

PROJECT_ROOT="$(pwd)"

# ---------------------------------------------------------------------------
# Pre-flight checks
# ---------------------------------------------------------------------------
echo -e "${CYAN}BMAD CQS Post-Installer${NC}"
echo "Project root : $PROJECT_ROOT"
echo "CQS module   : $CQS_MODULE_DIR"
echo ""

# 1. _bmad/bmm/ must exist
if [[ ! -d "$PROJECT_ROOT/_bmad/bmm" ]]; then
    echo -e "${RED}ERROR: _bmad/bmm/ not found in project root.${NC}"
    echo "Run 'npx bmad-method install' first, then re-run this installer."
    exit 1
fi

# 2. Patched workflow source files must exist
WORKFLOWS="$PROJECT_ROOT/_bmad/bmm/workflows"
if [[ ! -d "$WORKFLOWS" ]]; then
    echo -e "${RED}ERROR: _bmad/bmm/workflows/ not found.${NC}"
    exit 1
fi

# 3. Verify the dev-story workflow contains CQS patches
DEV_STORY_WF="$WORKFLOWS/4-implementation/bmad-dev-story/workflow.md"
if [[ ! -f "$DEV_STORY_WF" ]]; then
    echo -e "${RED}ERROR: dev-story workflow not found at expected path.${NC}"
    echo "  Expected: $DEV_STORY_WF"
    exit 1
fi

if ! grep -qi 'coding.standards' "$DEV_STORY_WF"; then
    echo -e "${YELLOW}WARNING: dev-story workflow.md does not contain coding-standards references.${NC}"
    echo "  The source files may not have CQS patches applied."
    echo "  Continuing anyway..."
fi

# 4. CQS skill source must exist
CQS_SKILL_SRC="$CQS_MODULE_DIR/src/skills/bmad-cqs-setup-coding-standards"
if [[ ! -d "$CQS_SKILL_SRC" ]]; then
    echo -e "${RED}ERROR: CQS skill source not found at: $CQS_SKILL_SRC${NC}"
    exit 1
fi

# ---------------------------------------------------------------------------
# Detect IDE skill directories
# ---------------------------------------------------------------------------
IDE_DIRS=()
for ide in .claude .gemini .cursor .windsurf; do
    if [[ -d "$PROJECT_ROOT/$ide/skills" ]]; then
        IDE_DIRS+=("$PROJECT_ROOT/$ide/skills")
    fi
done

if [[ ${#IDE_DIRS[@]} -eq 0 ]]; then
    echo -e "${RED}ERROR: No IDE skill directories found (.claude/skills/, .gemini/skills/, etc.).${NC}"
    echo "Run 'npx bmad-method install' first to create them."
    exit 1
fi

echo -e "Detected IDE skill directories:"
for d in "${IDE_DIRS[@]}"; do
    echo "  - $d"
done
echo ""

# ---------------------------------------------------------------------------
# File mapping: source (relative to $WORKFLOWS or $CQS_SKILL_SRC) -> dest skill dir
# ---------------------------------------------------------------------------
# Each entry: "source_path|dest_skill_subpath"
# source_path is relative to $WORKFLOWS
# dest_skill_subpath is the path inside {ide}/skills/
WORKFLOW_MAPPINGS=(
    # dev-story
    "4-implementation/bmad-dev-story/workflow.md|bmad-dev-story/workflow.md"
    "4-implementation/bmad-dev-story/checklist.md|bmad-dev-story/checklist.md"

    # code-review
    "4-implementation/bmad-code-review/workflow.md|bmad-code-review/workflow.md"
    "4-implementation/bmad-code-review/steps/step-01-gather-context.md|bmad-code-review/steps/step-01-gather-context.md"
    "4-implementation/bmad-code-review/steps/step-02-review.md|bmad-code-review/steps/step-02-review.md"
    "4-implementation/bmad-code-review/steps/step-04-present.md|bmad-code-review/steps/step-04-present.md"

    # create-story
    "4-implementation/bmad-create-story/workflow.md|bmad-create-story/workflow.md"

    # qa-generate-e2e-tests
    "bmad-qa-generate-e2e-tests/workflow.md|bmad-qa-generate-e2e-tests/workflow.md"

    # quick-dev (step files)
    "bmad-quick-flow/bmad-quick-dev/steps/step-01-mode-detection.md|bmad-quick-dev/steps/step-01-mode-detection.md"
    "bmad-quick-flow/bmad-quick-dev/steps/step-03-execute.md|bmad-quick-dev/steps/step-03-execute.md"
    "bmad-quick-flow/bmad-quick-dev/steps/step-04-self-check.md|bmad-quick-dev/steps/step-04-self-check.md"
)

# ---------------------------------------------------------------------------
# Sync function
# ---------------------------------------------------------------------------
TOTAL_COPIED=0
TOTAL_SKIPPED=0

copy_file() {
    local src="$1"
    local dst="$2"

    if [[ ! -f "$src" ]]; then
        echo -e "  ${YELLOW}SKIP${NC} (source missing): $(basename "$src")"
        TOTAL_SKIPPED=$((TOTAL_SKIPPED + 1))
        return
    fi

    # Create destination directory if needed
    mkdir -p "$(dirname "$dst")"

    # Copy (overwrite) — idempotent
    cp "$src" "$dst"
    TOTAL_COPIED=$((TOTAL_COPIED + 1))
}

# ---------------------------------------------------------------------------
# Perform sync
# ---------------------------------------------------------------------------
for ide_skills in "${IDE_DIRS[@]}"; do
    ide_name="$(basename "$(dirname "$ide_skills")")"
    echo -e "${GREEN}Syncing to ${ide_name}/skills/${NC}"

    # 1. Copy CQS skill from module repo
    cqs_dest="$ide_skills/bmad-cqs-setup-coding-standards"
    mkdir -p "$cqs_dest"
    for f in "$CQS_SKILL_SRC"/*; do
        if [[ -f "$f" ]]; then
            copy_file "$f" "$cqs_dest/$(basename "$f")"
            echo "  + bmad-cqs-setup-coding-standards/$(basename "$f")"
        fi
    done

    # 2. Sync patched workflow files
    for mapping in "${WORKFLOW_MAPPINGS[@]}"; do
        src_rel="${mapping%%|*}"
        dst_rel="${mapping##*|}"
        src="$WORKFLOWS/$src_rel"
        dst="$ide_skills/$dst_rel"

        copy_file "$src" "$dst"
        echo "  + $dst_rel"
    done

    echo ""
done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo -e "${CYAN}--- Summary ---${NC}"
echo -e "IDEs patched : ${GREEN}${#IDE_DIRS[@]}${NC}"
echo -e "Files copied : ${GREEN}${TOTAL_COPIED}${NC}"
if [[ $TOTAL_SKIPPED -gt 0 ]]; then
    echo -e "Files skipped: ${YELLOW}${TOTAL_SKIPPED}${NC} (source not found)"
fi
echo ""
echo -e "${GREEN}CQS post-install complete.${NC}"
