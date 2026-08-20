#!/system/bin/sh
# ============================================================
#  Inode Hijacker v2.1 — 修复 awk 语法 + 简化推荐逻辑
#  作者: YiJieqwq异界 基于MIT协议开源
#  项目链接: https://github.com/YiJieqwq/Inode-Hijacker
# ============================================================

TARGET="${1:-/data/local/tmp}"
WORK_DIR="$(dirname "$TARGET")"
MAX_INODE="${2:-10000}"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
DIM='\033[2m'

die()  { echo -e "\n${RED}[✗] $*${NC}" >&2; exit 1; }
warn() { echo -e "${YELLOW}[!] $*${NC}" >&2; }

# ======================== 风险知识库 ========================
eval_risk() {
    local name="$1"
    case "$name" in
        system_ce|system_de|user|user_de|vendor_ce|vendor_de|misc_ce|misc_de)
            echo "forbidden:加密/多用户核心目录" ;;
        mediadrm|drm)
            echo "forbidden:DRM 密钥" ;;
        unencrypted)
            echo "forbidden:加密链路" ;;
        resource-cache)
            echo "forbidden:系统资源缓存" ;;
        anr|tombstones)
            echo "forbidden:系统崩溃日志路径" ;;
        rollback-observer|rollback-history)
            echo "forbidden:系统回滚机制" ;;
        storage|property|security|dpm|apex|dalvik-cache)
            echo "forbidden:系统关键路径" ;;
        oplusbootstats|persist_log)
            echo "cautious:系统日志/统计" ;;
        oplus_backup|oplus)
            echo "cautious:厂商备份/配置" ;;
        sota_package)
            echo "cautious:系统 OTA 包" ;;
        app-metadata|preloads|preapps-lib)
            echo "cautious:预装数据" ;;
        engineercamera|engineermode)
            echo "safe:工程测试目录，正常使用永不访问" ;;
        logswitch)
            echo "safe:日志开关标记" ;;
        theme_bak)
            echo "safe:主题备份，系统自动重建" ;;
        cota)
            echo "safe:运营商 OTA 缓存" ;;
        ramdump)
            echo "safe:内存转储调试" ;;
        oplus_ota_package)
            echo "safe:OTA 包缓存" ;;
        oplus_lib)
            echo "safe:厂商库缓存" ;;
        opluscvtnvm|debug_log|format_unclear)
            echo "safe:残留调试/临时目录" ;;
        log*|debug*|cache*|temp*|tmp*)
            echo "safe:日志/缓存/临时" ;;
        *log*|*cache*|*bak*|*backup*|*temp*)
            echo "safe:可重建目录" ;;
        *engineer*|*debug*|*dump*|*test*)
            echo "safe:调试/测试目录" ;;
        *)
            echo "unknown:请自行评估" ;;
    esac
}

# ======================== 启动 ========================
clear
echo -e "\n${BOLD}${CYAN}  ╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}  ║           Inode Hijacker v2.1            ║${NC}"
echo -e "${BOLD}${CYAN}  ║    智能候选 · 风险分级 · 秒级交换        ║${NC}"
echo -e "${BOLD}${CYAN}  ║    作者: YiJieqwq异界  基于MIT协议开源   ║${NC}"
echo -e "${BOLD}${CYAN}  ╚══════════════════════════════════════════╝${NC}\n"

[ "$(id -u)" -ne 0 ] && die "需要 root 权限"
[ ! -d "$TARGET"  ] && die "$TARGET 不存在"

CURRENT_INODE=$(stat -c '%i' "$TARGET" 2>/dev/null)
[ -z "$CURRENT_INODE" ] && die "无法获取 inode"
echo -e " 目标: ${CYAN}${TARGET}${NC}   inode: ${YELLOW}${CURRENT_INODE}${NC}"

[ "$CURRENT_INODE" -le "$MAX_INODE" ] && {
    echo -e "  ${GREEN}[✓]${NC} 已 ≤ ${MAX_INODE}，无需操作\n"; exit 0; }

# ======================== 扫描 + 分级 + 实时推荐 ========================
SAFE_COUNT=0; CAUTIOUS_COUNT=0; FORBIDDEN_COUNT=0; UNKNOWN_COUNT=0; global_idx=0
BEST_IDX=""; BEST_INODE=999999; BEST_NAME=""; BEST_RISK=""

TMP_SAFE="${WORK_DIR}/.hijack_safe"
TMP_CAUT="${WORK_DIR}/.hijack_caut"
TMP_UNKN="${WORK_DIR}/.hijack_unkn"

for dir in /data/*/; do
    [ ! -d "$dir" ] && continue
    dir="${dir%/}"; name="${dir##*/}"
    [ "$dir" = "/data/local" ] && continue
    mountpoint -q "$dir" 2>/dev/null && continue

    inode=$(stat -c '%i' "$dir" 2>/dev/null) || continue
    [ -z "$inode" ] && continue
    [ "$inode" -gt "$MAX_INODE" ] && continue

    [ -z "$(ls -A "$dir" 2>/dev/null)" ] && is_empty=1 || is_empty=0

    risk_info=$(eval_risk "$name")
    risk="${risk_info%%:*}"; desc="${risk_info#*:}"
    global_idx=$((global_idx + 1))

    case "$risk" in
        safe)        SAFE_COUNT=$((SAFE_COUNT + 1))
                     echo "${global_idx}|${inode}|${name}|${is_empty}|${desc}" >> "$TMP_SAFE" ;;
        cautious)    CAUTIOUS_COUNT=$((CAUTIOUS_COUNT + 1))
                     echo "${global_idx}|${inode}|${name}|${is_empty}|${desc}" >> "$TMP_CAUT" ;;
        forbidden)   FORBIDDEN_COUNT=$((FORBIDDEN_COUNT + 1)); continue ;;
        *)           UNKNOWN_COUNT=$((UNKNOWN_COUNT + 1))
                     echo "${global_idx}|${inode}|${name}|${is_empty}|${desc}" >> "$TMP_UNKN" ;;
    esac

    # ★ 实时选优：优先级 safe > cautious > unknown，同优先级空目录 > 非空，再比 inode
    _score=0
    case "$risk" in safe) _score=300 ;; cautious) _score=200 ;; *) _score=100 ;; esac
    [ "$is_empty" = "1" ] && _score=$((_score + 50))
    # 同分比 inode（越小越好，反转：inode 小 → 得分高）
    _finalscore=$((_score * 1000000 - inode))

    if [ "$_finalscore" -gt "$_bestscore" ] 2>/dev/null || [ -z "$_bestscore" ]; then
        _bestscore="$_finalscore"
        BEST_IDX="$global_idx"
        BEST_INODE="$inode"
        BEST_NAME="$name"
        BEST_RISK="$risk"
    fi
done

# ======================== 展示 ========================
print_entry() {
    local idx="$1" inode="$2" name="$3" empty="$4" icon="$5" color="$6" tag="$7"
    printf "  ${icon} ${CYAN}[%2s]${NC}  %-6s  ${color}%-30s${NC}" "$idx" "$inode" "/data/$name"
    [ "$empty" -eq 1 ] && printf "  ${GREEN}[空]${NC}" || printf "  ${YELLOW}[有内容]${NC}"
    printf "  ${DIM}${tag}${NC}\n"
}

[ "$SAFE_COUNT" -gt 0 ] && {
    echo -e "  ${BOLD}${GREEN}═══ 安全推荐 ═══${NC}"
    while IFS='|' read -r idx inode name empty desc; do
        print_entry "$idx" "$inode" "$name" "$empty" "${GREEN}▶" "${GREEN}" "$desc"
    done < "$TMP_SAFE"
    echo ""
}
[ "$CAUTIOUS_COUNT" -gt 0 ] && {
    echo -e "  ${BOLD}${YELLOW}═══ 谨慎使用 ═══${NC}"
    while IFS='|' read -r idx inode name empty desc; do
        print_entry "$idx" "$inode" "$name" "$empty" "${YELLOW}●" "${YELLOW}" "$desc"
    done < "$TMP_CAUT"
    echo ""
}
[ "$UNKNOWN_COUNT" -gt 0 ] && {
    echo -e "  ${BOLD}${BLUE}═══ 需自行判断 ═══${NC}"
    while IFS='|' read -r idx inode name empty desc; do
        print_entry "$idx" "$inode" "$name" "$empty" "${BLUE}○" "${NC}" "$desc"
    done < "$TMP_UNKN"
    echo ""
}
[ "$FORBIDDEN_COUNT" -gt 0 ] && {
    echo -e "  ${DIM}${RED}已自动排除 ${FORBIDDEN_COUNT} 个系统关键目录${NC}\n"
}

# ★ 推荐直接来自循环里存的变量
total=$((SAFE_COUNT + CAUTIOUS_COUNT + UNKNOWN_COUNT))
[ "$total" -eq 0 ] && die "未找到任何可用目录"

echo -e "  ${BOLD}───────────────${NC}"
echo -e "  ${BOLD}${GREEN}★ 推荐:${NC} ${CYAN}[${BEST_IDX}] /data/${BEST_NAME}${NC}  inode ${YELLOW}${BEST_INODE}${NC}"

# ======================== 用户选择 ========================
echo ""
if [ "$total" -eq 1 ] && [ -n "$BEST_IDX" ]; then
    echo -e "  ${GREEN}仅 1 个可用候选，自动选择${NC}"
    CHOICE="$BEST_IDX"
else
    echo -n "  选择序号 (直接回车 = 推荐): "
    read -r CHOICE
    [ -z "$CHOICE" ] && CHOICE="$BEST_IDX"
fi
[ -z "$CHOICE" ] && die "已取消"

CHOSEN_INODE=""; CHOSEN_NAME=""
for _f in "$TMP_SAFE" "$TMP_CAUT" "$TMP_UNKN"; do
    [ -s "$_f" ] || continue
    while IFS='|' read -r _idx _ino _name _rest; do
        if [ "$_idx" = "$CHOICE" ]; then
            CHOSEN_INODE="$_ino"
            CHOSEN_NAME="$_name"
            break 2
        fi
    done < "$_f"
done
[ -z "$CHOSEN_NAME" ] && die "无效序号: $CHOICE"
CHOSEN_DIR="/data/${CHOSEN_NAME}"

# ======================== 确认 ========================
echo ""
echo -e "  ${RED}━━━ 确认交换 ━━━${NC}"
echo -e "  ${RED}目标:${NC}  ${TARGET}    (inode ${YELLOW}${CURRENT_INODE}${NC} → ${RED}释放${NC})"
echo -e "  ${GREEN}捐献:${NC}  ${CHOSEN_DIR}  (inode ${YELLOW}${CHOSEN_INODE}${NC} → ${GREEN}继承${NC})"
echo ""

echo -n "  确认？[y/N] "
read -r confirm
case "$confirm" in [yY]|[yY][eE][sS]) ;; *) die "已取消";; esac

# ======================== 执行交换 ========================
echo -e "\n  ${YELLOW}[▶]${NC} 执行交换…"

OLD_PERM=$(stat  -c '%a' "$TARGET"     2>/dev/null || echo "771")
OLD_OWNER=$(stat -c '%U' "$TARGET"     2>/dev/null || echo "shell")
OLD_GROUP=$(stat -c '%G' "$TARGET"     2>/dev/null || echo "shell")
DONOR_PERM=$(stat  -c '%a' "$CHOSEN_DIR" 2>/dev/null || echo "755")
DONOR_OWNER=$(stat -c '%U' "$CHOSEN_DIR" 2>/dev/null || echo "root")
DONOR_GROUP=$(stat -c '%G' "$CHOSEN_DIR" 2>/dev/null || echo "root")

DONOR_BACKUP="${WORK_DIR}/.donor_bak_$$"
DONOR_HAS_CONTENT=0
if [ -n "$(ls -A "$CHOSEN_DIR" 2>/dev/null)" ]; then
    DONOR_HAS_CONTENT=1
    echo -e "  ${YELLOW}[!]${NC} 捐献者非空，备份中…"
    rm -rf "$DONOR_BACKUP" 2>/dev/null
    cp -a "$CHOSEN_DIR" "$DONOR_BACKUP" || die "备份失败"
fi

HOLD="${WORK_DIR}/.swap_hold_$$"
rm -rf "$HOLD" 2>/dev/null

echo -n "  ① mv ${TARGET} → hold… "
mv "$TARGET" "$HOLD" && echo -e "${GREEN}✓${NC}" || die "第一步失败"

echo -n "  ② mv ${CHOSEN_DIR} → ${TARGET}… "
mv "$CHOSEN_DIR" "$TARGET" && echo -e "${GREEN}✓${NC}" || {
    mv "$HOLD" "$TARGET" 2>/dev/null; die "第二步失败，已回滚"
}

echo -n "  ③ 重建捐献者… "
mkdir "$CHOSEN_DIR" 2>/dev/null || warn "重建失败"
chmod  "$DONOR_PERM"             "$CHOSEN_DIR" 2>/dev/null
chown  "${DONOR_OWNER}:${DONOR_GROUP}" "$CHOSEN_DIR" 2>/dev/null
restorecon -R "$CHOSEN_DIR" 2>/dev/null || true
echo -e "${GREEN}✓${NC}"

[ "$DONOR_HAS_CONTENT" -eq 1 ] && [ -d "$DONOR_BACKUP" ] && {
    echo -n "  ④ 恢复内容… "
    cp -a "$DONOR_BACKUP"/*       "$CHOSEN_DIR"/ 2>/dev/null
    cp -a "$DONOR_BACKUP"/.[!.]*  "$CHOSEN_DIR"/ 2>/dev/null
    rm -rf "$DONOR_BACKUP"
    echo -e "${GREEN}✓${NC}"
}

chmod  "$OLD_PERM"               "$TARGET" 2>/dev/null || true
chown  "${OLD_OWNER}:${OLD_GROUP}"   "$TARGET" 2>/dev/null || true
restorecon -R "$TARGET" 2>/dev/null || true
rm -rf "$HOLD" 2>/dev/null

FINAL_INODE=$(stat -c '%i' "$TARGET" 2>/dev/null)

echo -e "\n  ${BOLD}${GREEN}╔════════════════════════${NC}"
echo -e "  ${BOLD}${GREEN}║    操作完成 ✓          ${NC}"
echo -e "  ${BOLD}${GREEN}╚════════════════════════${NC}\n"
echo -e "  inode:  ${RED}${CURRENT_INODE}${NC} → ${GREEN}${FINAL_INODE}${NC}"
echo -e "  来源:   ${CYAN}/data/${CHOSEN_NAME}${NC}（已重建）"
echo -e "  耗时:   < 1 秒\n"