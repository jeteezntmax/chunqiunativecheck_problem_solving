#!/system/bin/sh
# 解决调试痕迹并添加详细错误处理和结果验证

# 检查是否有执行脚本的必要权限
if [ "$(id -u)" -ne 0 ]; then
    echo "请以root权限运行此脚本，否则无法修改系统属性。"
    exit 1
fi

# 尝试设置系统属性
echo "正在尝试设置系统属性sys.usb.adb.disabled..."
setprop sys.usb.adb.disabled ""
if [ $? -ne 0 ]; then
    echo "设置系统属性sys.usb.adb.disabled失败。请检查："
    echo "1. 系统是否支持此属性设置。"
    echo "2. 属性名和值是否正确。"
    exit 1
fi
echo "系统属性sys.usb.adb.disabled已成功设置。"

# 尝试停止adb服务（适用于部分系统）
echo "正在尝试停止adb服务..."
# 尝试常见的adb进程名来查找adb服务进程
adb_pid=$(pidof adbd)
if [ -z "$adb_pid" ]; then
    adb_pid=$(pidof adb)
fi
if [ -z "$adb_pid" ]; then
    echo "未找到adb服务进程，可能该系统没有运行adb服务或者进程名不是常见的adbd或adb。"
else
    # 尝试使用常见包名停止adb服务
    am force-stop com.android.adbd 2>/dev/null
    if [ $? -ne 0 ]; then
        am force-stop com.android.adb 2>/dev/null
    fi
    if [ $? -eq 0 ]; then
        echo "adb服务已停止，有助于消除调试痕迹。"
    else
        echo "停止adb服务失败，可能该系统不支持此操作，但不影响属性设置。"
    fi
fi

# 验证系统属性是否设置成功
is_disabled=$(getprop sys.usb.adb.disabled)
if [ "$is_disabled" = "" ]; then
    echo "系统属性sys.usb.adb.disabled已成功设置，USB调试可能已被禁用。"
else
    echo "虽然执行了设置操作，但系统属性sys.usb.adb.disabled未正确设置，USB调试痕迹可能未完全消除。"
fi