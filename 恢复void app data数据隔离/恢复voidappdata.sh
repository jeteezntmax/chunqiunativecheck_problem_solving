#!/system/bin/sh

TARGET_PATHS=(
    "/data/media/0/Android/data"
    "/data/media/0/Android/media"
    "/data/media/0/Android/obb"
)
EXCLUDE_DIRS=("com.termux" "com.android.providers.downloads")
CLEAN_LOG="/data/local/tmp/clean_empty.log"

clean_empty_dirs() {
    echo -e "\n=== 空目录清理开始 $(date) ===" >> "$CLEAN_LOG"
    for path in "${TARGET_PATHS[@]}"; do
        echo "▌ 处理路径: $path" >> "$CLEAN_LOG"
        find "$path" -mindepth 1 -maxdepth 1 -type d | while IFS= read -r dir; do
            local dir_name=${dir##*/}
            if echo " ${EXCLUDE_DIRS[*]} " | grep -qE "\<${dir_name}\>"; then
                echo "[保护] $dir_name" >> "$CLEAN_LOG"
                continue
            fi
            [[ -z "$(ls -A "$dir")" ]] && {
                echo "[删除] $dir_name" >> "$CLEAN_LOG"
                rm -rf -- "$dir"
            }
        done
    done
    echo "空目录清理日志：$CLEAN_LOG"
}

SMALL_TARGET_DIRS=(
    "/storage/emulated/0/Android/data"
    "/storage/emulated/0/Android/media"
    "/storage/emulated/0/Android/obb"
)
SIZE_LIMIT=20
PROTECT_PATTERNS=("com.android.*" "com.google.*" "android" "*.nomedia" "*.obb")

clean_small_dirs() {
    echo -e "\n=== 小文件目录清理开始 $(date) ==="
    for dir in "${SMALL_TARGET_DIRS[@]}"; do
        [ ! -d "$dir" ] && {
            echo "⚠️ 目录不存在: $dir"
            continue
        }
        echo "🔍 扫描目录: $dir"
        find "$dir" -mindepth 1 -maxdepth 1 -type d | while IFS= read -r dir_path; do
            local name=${dir_path##*/}
            for pattern in "${PROTECT_PATTERNS[@]}"; do
                case "$name" in $pattern)
                    echo "🛡️ 受保护目录: $name"
                    continue 2
                esac
            done
            # 大小计算
            local size=$(du -sk "$dir_path" | cut -f1)
            [[ "$size" -lt "$SIZE_LIMIT" ]] && {
                echo "🗑️ 删除 ${size}KB 目录: $name"
                rm -rf -- "$dir_path"
            }
        done
    done
}

DELETE_PATHS=(
    "/data/nh/"          "/data/nh5/"         "/data/nh6/"
    "/data/nh2/"         "/data/nh3/"         "/data/nh4/"
    "/data/nh.ko"        "/data/gamepad_driver.so"
    "/sdcard/elgg/"      "/data/BingPUBG/"    "/data/BingHPJY/"
    "/data/jz/"          "/data/jz.sh"
    "/data/system/liboxmem.so"
    "/data/local/tmp/gamepad_driver.so"
    "/system/lib/hid/gamepad_driver.so"
    "/data/.gamepad_driver_installed"
    "/data/system/liborangeinit.so"
    "/data/system/xydriver.ko"
    "/data/BingPUBG/guns.cfg"
    "/data/BingHPJY/pz.cfg"
    "/dev/Bing/"
    "/data/单发枪配置.txt"
    "/data/local/tmp/单发枪配置.txt"
    "/data/A内核.ini"   "/data/物资.txt"
    "/data/HPX/"        "/data/HPY/"
    "/data/system/HPX/" "/data/system/HPY/"
    "/storage/emulated/0/落叶配置/"
    "/storage/emulated/0/BY物资/"
    "/storage/emulated/0/落叶配置/落叶配置.txt"
    "/storage/emulated/0/BY物资/BY物资.txt"
    "/storage/emulated/elgg/"
    "/storage/emulated/0/Download/WechatXposed/"
    "/storage/emulated/legacy/Android/data/com.apocalua.run/"
)

delete_specified_paths() {
    echo -e "\n=== 指定路径删除开始 $(date) ==="
    for path in "${DELETE_PATHS[@]}"; do
        [ -e "$path" ] || {
            echo "跳过不存在的路径: $path"
            continue
        }
        rm -rf -- "$path" 2>/dev/null
        echo "$(if [ -d "$path" ]; then echo "已删除目录"; else echo "已删除文件"; fi): $path"
    done
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "       ROOT工具集 整合版 v1.1"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "注意：请确保已获取ROOT权限"
echo "开始执行以下操作：\n"

clean_empty_dirs
clean_small_dirs
delete_specified_paths

echo -e "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "所有操作完成！"
echo "空目录清理日志：$CLEAN_LOG"
echo "可通过 adb pull $CLEAN_LOG 查看详细记录"
