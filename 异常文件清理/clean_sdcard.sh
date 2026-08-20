#!/system/bin/sh

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

SDCARD="/sdcard"

echo ""
echo "============================================="
echo "            春秋检测异常文件清理              "
echo "        扫描文件：: *.img / *.sh / *.xml          "
echo "             扫描文件夹： SH / MT2            "
echo "============================================="
echo ""

FOUND_FILES=""
for f in "$SDCARD"/*.img "$SDCARD"/*.sh "$SDCARD"/*.xml; do
    [ -f "$f" ] && FOUND_FILES="$FOUND_FILES
$f"
done

FOUND_DIRS=""
for dir_name in "sh" "MT2"; do
    target="$SDCARD/$dir_name"
    [ -d "$target" ] && FOUND_DIRS="$FOUND_DIRS
$target"
done

HAS_ANY=false

if [ -n "$FOUND_FILES" ]; then
    HAS_ANY=true
    echo -e "${YELLOW}[!] 发现以下文件：${NC}"
    echo "$FOUND_FILES" | while read -r f; do
        [ -z "$f" ] && continue
        echo -e "    ${RED}$f${NC}"
    done
    echo ""
fi

if [ -n "$FOUND_DIRS" ]; then
    HAS_ANY=true
    echo -e "${YELLOW}[!] 发现以下文件夹：${NC}"
    echo "$FOUND_DIRS" | while read -r d; do
        [ -z "$d" ] && continue
        echo -e "    ${RED}$d${NC}"
    done
    echo ""
fi

if [ "$HAS_ANY" = false ]; then
    echo -e "${GREEN}[✓] 未检测到目标残留文件/文件夹${NC}"
    echo "Done"
    exit 0
fi


echo "----------------------------------------------"
echo -e "${BOLD}${RED}  请选择操作：${NC}"
echo -e "${BLUE}   音量上键 => 删除以上所有残留${NC}"
echo -e "${PURPLE}   音量下键 => 跳过清理${NC}"
echo "----------------------------------------------"
echo ""

count=30
key_click=""

while [ $count -gt 0 ] && [ -z "$key_click" ]; do
    sleep 0.3
    count=$((count - 1))
    key_click="$(timeout 0.1 getevent -qlc 1 2>/dev/null | awk '{ print $3 }' | grep 'KEY_')"
done

[ -z "$key_click" ] && key_click="KEY_VOLUMEDOWN"

echo ""

case "$key_click" in
    "KEY_VOLUMEUP")
        echo -e "${BLUE}[*] 正在清理...${NC}"
        
        echo "$FOUND_FILES" | while read -r file; do
            [ -z "$file" ] && continue
            rm -f "$file" && echo -e "  ${GREEN}[✓]${NC} 已删除文件: $file"
        done


        echo "$FOUND_DIRS" | while read -r d; do
            [ -z "$d" ] && continue
            rm -rf "$d" && echo -e "  ${GREEN}[✓]${NC} 已删除文件夹: $d"
        done

        echo ""
        echo -e "${GREEN}[✓] 清理完成${NC}"
        ;;
    *)
        echo -e "${PURPLE}[i] 已跳过清理，请注意残留风险。${NC}"
        ;;
esac

echo ""
echo "Done"
