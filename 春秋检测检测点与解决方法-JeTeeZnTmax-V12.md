# 🔍 春秋检测4.2 · 检测点与解决方案（第十二版）

> 作者：**@JeTeeZnTmax**
>
> 更新日期：2026年8月20日
> 
> 声明：若要搬运请注明原作者，本文档有许多我自己尝试过的解决方法，不一定有效，因为我没有那么多品牌的测试设备。
>          本人没有宣传过任何群聊，非必要也不会主动接单隐藏环境/刷机。
           若您因为本文档内说明的操作-包括但不限于：
                 嵌入kpm
                 刷写作者提供的一键隐藏
                 刷写本文中提及的模块/脚本
                 删除系统文件
                 等...
           作者不承担任何后果，望周知。
> 
> 继续阅读默认您同意以上内容。

---

## 📦 所需模块/文件下载

> 📂 总文件夹：[点此进入]( https://1846303615.share.123pan.cn/123pan/N5L6Td-y2rnA )

---

## 📋 全部检测点（共 95 项）

---

### 1. Looper fd 图异常

- **检测项：** 图形相关的文件描述符异常。
- **解决方法：** ⚠️ 暂时未知，待补充。

---

### 2. HMA 或许存在

- **检测项：** 检测不到 Scene 应用，但检测到了 Scene 端口。
- **解决方法：** 如果你是老版本/破解版/非官方版本scene，参考[Scene-Port-Hider-by-eBPF]( https://github.com/Andrea-lyz/Scene-Port-Hider-by-eBPF  )；如果你是官方版本scene，那去官网更新到最新版本即可。
> 如遇网址无法打开请自行解决网络问题。

---

### 3. 存在模块修改春秋

- **检测项：** 发现 IsolPolicy 的 LSP 模块。
- **解决方法：** 卸载 IsolPolicy，并按提示解决新检测词条。

---

### 4. 检测 SELinux Policy 时发现问题

- **检测项：** 新加入的 SELinux 特性——应用程序 zygote 拥有访问 `/sys/fs/selinux/access` 的权限。
- **解决方法：**
  - 🔹 **KSU 系 · LKM：** 更新管理器 → 重新修补镜像 → 重启 → 开启管理器中的「隐藏 SELinux 修改」。
  - 🔹 **KSU 系 · 免解锁越狱模式：** 安装新版本的管理器 → 重启到fastboot→ 重新越狱 → 开启管理器中的「隐藏 SELinux 修改」。
  - 🔹 **KSU 系 · GKI：** 以下方案任选其一：
    - 加载 / 嵌入 **selinux-hook**
    - 自行编译新的 ak3
    - 换回 LKM
  - 🔹 **APatch / FolkPatch：** 加载 / 嵌入 **selinux-hook**
  - 🔹 **Magisk：** ……老古董...咱还是别折腾了吧。
  
```
selinux_hook模块使用说明：

内核版本4.19-6.12的设备，必须嵌入此模块才能生效，如果使用加载模式，则不会启用任何伪装方法。 注意：由于编译优化导致的机器指令与预期不符，6.12内核设备请慎重嵌入此模块，会有很大概率导致kernelpanic，此问题后续将会被解决。
内核版本4.14的设备，建议嵌入模块，但由于模拟context_struct_compute_av存在风险，在嵌入模块前请备份原boot.img，以便在出现kernelpanic后可救砖；加载模式同样可生效，但会使用基于关键词过滤的备选方法，效果相对较差，如果设备的policy中包含了模块没有收录的且能被证明异常的关键词，则会发生泄露。
内核版本4.9的设备，建议嵌入模块，且无模拟context_struct_compute_av的风险，加载模式效果同4.14。
```

> 部分设备存在误报情况，如果你确定你是最新的管理器且开启了隐藏selinux修改无论如何都去不掉的情况那就是误报了。

---

### 5. fdinfo mnt 采样异常（c）

- **检测项：** USB 调试残留导致的异常。
- **解决方法：** 清理 USB 调试残留

---

### 6. 内存异常

- **检测项：** 春秋检测应用运行时内存表现异常。
- **解决方法：** 尝试清除春秋检测应用数据。

---

### 7. Futile hide 1

- **检测项：** 极少出现的未知异常。
- **解决方法：** ❗暂时未知，暂无可靠解决方案。

---

### 8. 风险应用

- **检测项：** 检测到存在风险的应用程序。
- **解决方法：** 使用 `hma-oss`，刷入Fuse Hide零宽漏洞修复模块(部分机型启用作用域后可能卡开机，进入安全模式关闭作用域/卸载即可)。

---

### 9. mountinfo

- **检测项：** 刚开机时的挂载信息异常。
- **解决方法：** 开机后等待 **20 秒~5 分钟**再测。

---

### 10. Dirty Device / 脏设备（a）

- **检测项：** 检测到 `/storage/emulated/0/` 目录下有名称包含 `sh` 的文件夹/文件，或外挂文件/外挂驱动。
- **解决方法：** 重启后删除 `/sdcard` 目录下所有名字带 `sh` 的文件/文件夹。

---

### 11.~~zygote test（X）~~（已删除）

- **检测项：** Zygote 环境检测，偶发性误报。
- **解决方法：** 打开 Zygisk Next 的「链接器功能」与「匿名内存功能」；排除列表策略设为 **「仅还原挂载」**；或直接重测一遍。

---

### 12.~~Inconsistent mount~~（已删除）

- **检测项：** 挂载类型不一致（3.4 版本中已修复误报）。
- **解决方法：** 无需解决，可能为设备误报。

---

### 13. TEE 环境不可信

- **检测项：** soter service 假死。
- **解决方法：** 使用 SUSFS / PathMask 隐藏 soterservice。
> 非常不推荐这么做，游戏会三方更快，且只是自我安慰。

---

### 14. Tampered Attention Key（X）

- **检测项：** TEE 处理异常标签，如 HanAttest 链不一致、KeyMint 异常、证书矛盾等。
- **解决方法（仅列举 26 的解法）：**
  1. 删除 `/data/adb/tricky_store/security_patch.txt` 和 类似` 月虹/悲伤 `一键隐藏模块，重启后观察是否解决。
  2. 如果仍报错，请去 TS 插件自行配置安全补丁时间。
  Q：如何查看自己的安全补丁时间？
  A：打开设置，我的设备，版本信息，找到 Android 安全更新那一行的日期。
  注意：配置时如为手动填写注意格式。
> **小米/红米用户注意：** 如果你是 2026 年 3 月份左右更新的系统，那么你当前的系统版本不管 root 没 root 都会报，因为小米新版本系统构建时间和安卓安全补丁时间本来就不一样——**无视即可**
> 一些魔改版 TEESimulatorRS（如 yurikey？）/ 一键隐藏模块（月虹 / 悲伤）也会导致被检测。**换回原版 TEESimulatorRS / 卸载以上模块**
> 某些改机模块也会导致Tampered Attention Key（26），尝试卸载改机模块。

---

### 15. Found property（X）

- **检测项：** 检测到 Logd 属性被修改。
- **解决方法：** Root 权限执行以下命令：

```
for prop in persist.logd.size persist.logd.size.crash persist.logd.size.system persist.logd.size.main; do
    setprop "$prop" ""
done
```

---

### 16.~~Tricky Store hook / test（X）~~（已删除）

- **检测项：** 误报——不管你 root 没 root 都会概率报。
- **解决方法：** 重测一遍。

---

### 17.~~发现 TrickyStore / 类似模块~~（已删除）

- **检测项：** 检测到 Tricky Store 痕迹。
- **解决方法：** 更换为 `TEESimulatorRS`。

---

### 18. TEE 伪造

- **检测项：** 检测到 TEE 环境被伪造。
- **解决方法：** 更换为 `TEESimulatorRS`。

---

### 19. Property Modified

- **检测项：** 查属性区空洞，发现属性被修改。
- **解决方法：**
  - 🔹 **Magisk / Alpha：** 将 Shamiko 模块中的 `shamiko.sh` 移动至 `/data/adb/service.d/` 目录下并重启。
  - 🔹 **KSU 系：** 最快方案——恢复出厂设置（没有人知道你干了什么）。
  - 🔹 **通用：** 作者曾遇到过莫名其妙报，把所有模块全部禁用 → 重启 → 再启用 → 重启，解决了。

---

### 20.~~环境存疑 1（实验性检测）~~（已删除）

- **检测项：** HMA 黑名单模式下勾选「输入法」后出现。
- **解决方法：** 该检测项疑似已被删除。

---

### 21. Evil Service

- **检测项：** 检测到 LSP Shizuku 或 XP 模块修改。
- **解决方法：** 排查/sdcard与/data/local/tmp的异常文件(你装的杂七杂八的模块释放的文件)。

---

### 22. Found KSU / 免解设备

- **检测项：** 发现 KSU 处于越狱模式或检测到 KSU 进程。
- **解决方法：**
  - 🔹 **解锁 BL 的 root 用户：** 正常重启一遍。
  - 🔹 **免解用户：** 刷入免解隐藏模块。

---

### 23. SU binary detected

- **检测项：** 检测到 SU 二进制文件（Root 权限）。
- **解决方法：** **不要给春秋检测 Root 权限。**
- > *** iQoo/Vivo ***请把*** /apex/com.android.virt/bin/su ***这个路径的文件移走/mt管理器-设置文件权限-把执行那一行全关了。

---

### 24. Miscellaneous Check（a）

- **检测项：** 需要更新 LSP 模块或通用检测。
- **解决方法：** 更换 / 更新 LSPosed 模块。

---

### 25. Mount loophole

- **检测项：** 检测到挂载空洞。
- **解决方法：** 使用 Zygisk Next 的排除策略 →「仅还原挂载」；或卸载/更换元模块。

---

### 26. Magic Mount

- **检测项：** 检测到 Magic Mount 挂载。
- **解决方法：** 使用 Zygisk Next 的排除策略 →「仅还原挂载」；或卸载/更换元模块。

---

### 27. [Hook] Suspicious library injection

- **检测项：** 检测到 Zygisk / Riru / Xposed 注入。
- **解决方法：** 更新 LSPosed；自行排查 LSP 模块。

---

### 28.~~SU list~~（已删除）

- **检测项：**（旧）检测到 KSU 的 ROOT 权限排除列表。
- **解决方法：** 该检测项已被移除。

---

### 29.~~Abnormal Environment（04）~~（已删除）

- **检测项：** 检测到 KSU / APatch / Magisk 特征。
- **解决方法：** 更新你的 Root 管理器并重新修补镜像。

---

### 30. Abnormal Environment

- **检测项：** 新版函数调用检测，APatch 排除列表开启后易出现。
- **检测原理：** [点击查看]( https://github.com/mingzun09/Chunqiu-Detector-Problem-solution/blob/main/File/Doc/ksu_kp_sidechannel_zh.md )
- **解决方法：** 更新 Root 管理器。
> 会出现明明同一个管理器版本但不同设备一个报一个不报的情况，可以尝试**降级管理器**。
> 不稳定，概率出现，可以无视。
---

### 31. KernelSU loop device

- **检测项：** 检测到 KSU 循环设备。
- **解决方法：** 更新管理器并重新修补；或关闭 / 更换元模块。

---

### 32. Suspicious Surroundings

- **检测项：** 检测到 APatch 特征。
- **解决方法：** 更新 APatch 并加载 KPM 隐藏模块（如 `Nohello.kpm`）。

---

### 33. 设备为模拟器

- **检测项：** 当前运行在模拟器环境。
- **解决方法：** 卸载重装春秋检测，不要在不插 SIM卡+满电量+充电情况下测。

---

### 34. AVB 校验异常 avb=2.0

- **检测项：** AVB 版本异常，通常由改机型模块引起。
- **解决方法：** 卸载改机模块；或使用 Device Faker 对特定应用改机而非全局。
- > 若卸载以后还出现，请尝试执行

```
check_reset_prop() {
  local NAME=$1
  local EXPECTED=$2
  local VALUE=$(resetprop $NAME)
  [ -z $VALUE ] || [ $VALUE = $EXPECTED ] || resetprop -n $NAME $EXPECTED
}
check_reset_prop "ro.boot.avb_version" "1.3"
```

---

### 35. Found LSPHook Framework

- **检测项：** 检测到 LSPosed Hook 框架。
- **解决方法：** 更新 LSPosed；排查是否有 XP 模块修改导致。
> 也可能是元模块导致的，卸载/更换为mountify？

---

### 36. 检测到 Scene 端口占用

- **检测项：** 检测到 Scene 工具箱占用的端口。
- **解决方法：** 如果你是老版本/破解版/非官方版本scene，参考[Scene-Port-Hider-by-eBPF]( https://github.com/Andrea-lyz/Scene-Port-Hider-by-eBPF  )；如果你是官方版本scene，那去官网更新到最新版本即可。
> 如遇网址无法打开请自行解决网络问题。

---

### 37. Zygisk detected

- **检测项：** 检测到 Zygisk（通常为 Magisk 自带或其他原因）。
- **解决方法：**
  - 🔹 **KSU 系：** 更新 Zygisk Next 模块。
  - 🔹 **Magisk：** 设置中关闭 Zygisk。

---

### 38. Tampered kernel

- **检测项：** 内核信息校验异常（版本字符串、构建时间）。
- **解决方法：** 使用 SUSFS 隐藏内核名称。
> 来自开发者原话：如果你确保你是原厂系统+lkm模式，那就是误报。

---

### 39. [Hook] Resetprop modified

- **检测项：** Resetprop 工具修改了系统属性。
- **解决方法：** 检查自己进行的操作，还原相关属性修改。

---

### 40. Suspicious Surroundings（a）

- **检测项：** `/data/local/tmp` 文件夹属主为 root。
- **解决方法：** 把所有者改为 shell：

```
su -c chown shell:shell /data/local/tmp
```

---

### 41. Suspicious Surroundings（b）

- **检测项：** `/data/local/tmp` 的 inode 值高于 10000（曾被删除）。
- **解决方法：** 参考( https://github.com/YiJieqwq/Inode-Hijacker )
- > 只需要把它下载下来执行一下就行。
> 请做好卡开机的心理准备(虽然大概率不会)。
> 执行不了的换老release。

---

### 42. Suspicious Surroundings（c）

- **检测项：** `/data/local/tmp` 权限非 771。
- **解决方法：** 把 tmp 文件夹权限改为 771：

```
su -c chmod 771 /data/local/tmp
```

---

### 43. Futile hide

- **检测项：** `/data/local/tmp` 文件夹时间被修改。
- **解决方法：** 删除 /data/local/tmp → 重启 → 再根据上面 Suspicious Surroundings (a/b/c) 项对应解决。

---

### 44. Miscellaneous Check（2）

- **检测项：** 检测设备篡改 / 机型篡改。
- **解决方法：** 删除改机型模块。

---

### 45. Miscellaneous Check（3）

- **检测项：** 改机检测。
- **解决方法：** 开启「隐藏应用列（HMA）」的 **Vold app data 隔离**。

---

### 46. 不一致的挂载 / debug_ramdisk

- **检测项：** `/proc/self/exe` 解析出的挂载类型不一致。
- **解决方法：** Root 权限执行：

```
su -c umount /debug_ramdisk
```

---

### 47. Netlink socket anomaly

- **检测项：** Netlink 套接字异常。
- **解决方法：** ⚠️ 暂时未知。

---

### 48. /data/local/tmp denied

- **检测项：** `/data/local/tmp` 目录拒绝访问或不存在。
- **解决方法：** 删除 tmp 文件夹 → 重启 → 再根据新出现的检测项对应解决。

---

### 49. 伪装内核

- **检测项：** 无效地使用 SUSFS 伪装内核。
- **解决方法：** 在 SUSFS 设置中将伪装内核启动阶段选择为 **`post-fs-data`**。

---

### 50. Futile hide 04

- **检测项：** 检测挂载命名空间异常。
- **解决方法：** 更换「元模块」。

---

### 51. 发现异常模块

- **检测项：** 部分温控 / 调度 / 优化模块被特征并检测。
- **解决方法：**
  - 排查并删除可能的温控 / 调度 / 优化模块
  - 尝试重启解决
> 大概率误报，多重启几次再测就行。

---

### 52. 挂载间隙

- **检测项：** 检测挂载异常。
- **解决方法：** 更换「元模块」/更新 ROOT 管理器并重新修补/如果你使用scene，请更新scene。

---

### 53. 第三方内核

- **检测项：** 内核信息符合预设的第三方内核名单。
- **解决方法：** 使用 SUSFS 伪装内核名称。

---

### 54. 第三方 ROM / 自编译内核

- **检测项：** 内核版本号后缀带有 `-Dirty` 或第三方 ROM 标记。
- **解决方法：** 使用 SUSFS 伪装内核名称。

---

### 55. 第三方 ROM（2）

- **检测项：** 暂时未知。
- **解决方法：** ⚠️ 暂时未知。

---

### 56. ROM detected

- **检测项：** 检测到第三方 ROM 特征。
- **解决方法：** 使用 SUSFS 伪装内核名称。

---

### 57. 终端环境存疑

- **检测项：** 检测 Pty 终端环境。
- **解决方法：** ❌ 暂无有效解决方案。

---

### 58. 环境伪造

- **检测项：** 旧内核设备或刷入 ZN-Audit Patch 后触发。
- **解决方法：** 卸载 ZN-Audit Patch 模块。

---

### 59. ROOT 进程

- **检测项：** 通过审计日志漏洞读取 Zygote 环境。
- **解决方法：** 更新系统至 **2025-09-01** 以上安全补丁(可能无效) / 或使用 ZN-Audit Patch 模块。

---

### 60. 异常进程

- **检测项：** 检测到隐藏的进程组。
- **解决方法：**
  - 确保你使用的是最新 ZygiskNext / LSPosed 并打开「匿名内存」。
  - 在系统设置中随意开启一个应用分身尝试解决。
> 联想 / 谷歌或其他小众机型大概率误报。
> 小米 / 红米系统概率误报，可自己看一眼给的uid是否为lsp进程，若不是则大概率误报。
> 小米 / 红米请使用**西米露模块**，并打开「禁用环境检查」，冻结手机管家。

```
你可以尝试以root权限执行“ps -ef | grep 数字id”来查找对应pid进程,通常是拥有root权限的守护进程（如lspd进程、Tricky-Store进程）
此检测依赖安全漏洞，更新安全补丁到2026-01-01可显著降低检出率，但目前无法完全解决，此安全漏洞将在Google正式发布Android 17后完全修复。
安全补丁更新往往伴随系统更新，如果因为不想更新系统而无法更新安全补丁，可以忽略此条目。
双开应用有时可以使此检测方案失效，但不会实质上解决此安全漏洞，所以双开应用不应被视为可行的方法。
```

---

### 61. 检测运行环境可疑 / 容器 / 多开

- **检测项：** 检测到应用处于多开或沙盒环境。
- **解决方法：** 卸载重装春秋检测；**不要应用双开春秋检测。**

---

### 62.~~Evil Modification（1）~~（已删除）

- **检测项：** 模仿 Zygisk Detector 或侧信道检测 Tricky Store。
- **解决方法：**
  - 更新 Zygisk Next / ReZygisk
  - 删除 `/data/adb/tricky_store/security_patch.txt`
  - 使用 SUSFS / Path Mask 隐藏 Tricky Store 目录

---

### 63.~~Miscellaneous Check（12）~~（已删除）

- **检测项：** 检测到 Zygisk。
- **解决方法：** 更换最新 Zygisk Next 。
> 自测：截止 2026/07/29 Zygisk Next（1.4.3）+ LSPosed（2.1.1）可以过，但如果有其他需要 Zygisk Next 作为前置的模块（如 Device Faker？）可能会漏。

---

### 64. Miscellaneous Check（4 / 5 / 6 / 7 / 8 / 9）

- **检测项：** 模拟器 / 改机 / 三方 ROM 检测。
- **解决方法：** 卸载改机模块 / 如有需要使用 Device Faker 对特定应用改机。
> 国外设备 Poco / 三星有误报。
> 部分设备使用scene也会报。
Q：为什么我卸载了改机模块还是报
A：某些改机模块因为各种原因有残留/某些行为不可逆

---

### 65. Risk apps「软件包名」

- **检测项：** 检测到存在风险的应用程序。
- **解决方法：** 使用hma-oss的黑名单模式，刷入Fuse Hide零宽漏洞修复模块。

---

### 66. Thanox service detected

- **检测项：** 检测到 Thanox 服务。
- **解决方法：** 使用 `hideThanox` 模块进行隐藏。

---

### 67.~~检测失败~~（已删除）

- **检测项：** 应用内部检测逻辑出错。
- **解决方法：** 重启应用或手机后重试。

---

### 68. TEE 损坏

- **检测项：** TEE 功能损坏或失效。
- **解决方法：** 使用 TEESimulatorRS 或类似模块，并在 `/data/adb/tricky_store/target.txt` 中添加春秋检测包名，后面加英文感叹号 `!`。
> 推荐使用以下脚本一键添加所有包名

```
TRICKY_DATA="/data/adb/tricky_store"
{
            echo "com.google.android.gms!"
            echo "com.android.vending!"
            pm list packages -3 | sed 's/^package://;s/$/!/'
        } > "$TRICKY_DATA/target.txt"
```

---

### 69. 密钥证明未完成或链不一致

- **检测项：** 密钥的证书链不完整或者被吊销。
- **解决方法：** 更换 `/data/adb/tricky_store/keybox.xml`。

---

### 70. AOSP 密钥

- **检测项：** 使用了 Tricky Store 默认 AOSP 密钥。
- **解决方法：** 更换 `/data/adb/tricky_store/keybox.xml` 为有效密钥。

---

### 71. Boot Hash 不匹配

- **检测项：** Boot 镜像的哈希值与预期不符。
- **解决方法：** 打开密钥认证，找到 `VerifiedBootHash` 并复制哈希值，使用 TS 插件配置 Hash 。

---

### 72. 启动状态异常 / Bootloader Unlock

- **检测项：** 启动状态与解锁状态不匹配。
- **解决方法：** 仍在测试中，尝试更新TeeSimulator-v307，刷入tricky addon module-v5-beta1，在管理器设置关闭卸载模块(内核级)，在zygisk next设置仅还原挂载，冻结手机管家(或类似应用(小米设备使用西米露模块打开禁用环境检查))，将云盘中的 属性隐藏文件夹 - service.sh 放入/data/adb/service.d。
- > 有反馈说** iQoo/Vivo **橘子5不报但升级橘子6报了，不清楚是否误报。

---

### 73. 密钥篡改（128）

- **检测项：** 检测到密钥文件被篡改。
- **解决方法：** 更换 `TEESimulatorRS`。

---

### 74. 密钥篡改（q）

- **检测项：** 未知。
- **解决方法：** ⚠️ 未知。

---

### 75. 密钥篡改（b）

- **检测项：** 未知。
- **解决方法：** ⚠️ 未知。

---

### 76. 证书已被吊销（CRL）

- **检测项：** 使用的证书已被吊销列表收录。
- **解决方法：** 更换 `/data/adb/tricky_store/keybox.xml` 为有效密钥。

---

### 77. 密钥篡改

- **检测项：** 检测到密钥异常。
- **解决方法：** 更换 `TEESimulatorRS`。

---

### 78. TrustedCert 证书篡改

- **检测项：** 可信证书被篡改。
- **解决方法：** ⚠️ 未知。

---

### 79. Something wrong

- **检测项：** 未知错误。
- **解决方法：** ⚠️ 未知。

---

### 80. MT2 文件夹 / 异常文件

- **检测项：** 扫盘扫到特定文件（夹）。
- **解决方法：**
  1. 打开 MT 管理器 → 设置 → 自定义 MT2 目录 → 改为 `/data/adb/MT2`
  2. 删除 `/storage/emulated/0/MT2`
  3. 删除 `/storage/emulated/0/` 目录下所有 `sh` / `img` / `xml` 文件（夹）

---

### 81. 设备获取 Root 权限 / 异常模块

- **检测项：** 检测 KSU / Magisk 修改的 SELinux 上下文。
- **解决方法：** 同第 4 项。

---

### 82. GMS被屏蔽

- **检测项：** Google服务被屏蔽，未检测到Google服务套件。
- **解决方法：** hma配置问题( 隐藏了系统组件？ )系统rom问题？

---

### 83. /dev/cpuset/AppOpt

- **检测项：** 检测到线程模块的挂载。
- **解决方法：** 卸载线程模块。

---

### 84. /system/bin/fastboot和/system/bin/adb

- **检测项：** 检测到异常可执行文件，常见于(小米)官改包。
- **解决方法：** 刷回官包/使用pathmask隐藏这两个文件。

---

### 85. “一条路径”

- **检测项：** 检测到特定sh/模块/...释放的文件(夹)。
- **解决方法：** 按给出路径删除即可。

---

### 86. Zygote存在异常

- **检测项：** 检测到应用自身的INET-GID权能被限制。
- **解决方法：** HMA-oss关掉春秋检测限制zygote权限中的INET-GID。

---

### 87.~~内核模块加载~~（已删除）

- **检测项：** 误报(尤其是小米设备)。
- **解决方法：** 到设置里点击清除双开应用账户，但是你没root也会爆，所以无需解决。

---

### 88. Obb目录存在异常

- **检测项：** 安装了一些试图阻止春秋扫盘的模块。
- **解决方法：** ** 暂时把这条检测项理解为误报 **，无风险掩耳盗铃：hma-oss打开春秋检测的限制zygote权限(除了倒数第二个INET_GID)；可能有风险：点击显示详情，删除给出的目录。
 
---

### 89. App Zygote 分叉顺序异常

- **检测项：** 检测到应用自身zygote权限被修改。
- **解决方法：** ** 暂时把这条检测项理解为误报 **有人假回锁0模块也有。
> 联想Y700系列无论root没root都有，无视即可。

---

### 90. SELinux 状态指纹可疑

- **检测项：** 检测到selinux规则被修改。
- **解决方法：** 非联想的用户参考第4条，确保你为最新版本的管理器，尝试关闭设置里的隐藏selinux修改再打开。
> 联想系列若出现无视即可。

---

### 91. Current-app-root-domain-trace

- **检测项：** 作为 untrusted_app 遍历  /proc 的 PID，挨个尝试读 context/cmdline/comm。正常情况下全被 SELinux 拒绝，被拒后去翻日志：读 auditd/logcat 里的 AVC denied 记录，发现了tcontext=u:r:ksu:s0 。
- **解决方法：** 更新到最新的管理器，gki用户在susfs中打开AVC日志欺骗，尝试把设置里的传统su命令支持关了再开。
> 牛大了穷举法都来了。
> 如果你只想过检测装一下，可以去设置禁用传统su支持，去过一遍春秋再打开。

---

### 92. Vold隔离已开启

- **检测项：** 检测到 persist.sys.vold.app_data_isolation_enabled=0
- **解决方法：** 确保你在hma关闭了Vold app data数据隔离并执行云盘里的脚本。

---

### 93. Bootloader 解锁ro.boot.flash.locked=0,ro.boot.verifiedbootstate=orange,ro.boot.vbmetadevice_state=unlocked

- **检测项：** 检测到一系列有关bl的属性值标明设备处于解锁状态。
- **解决方法：** 刷入云盘中的bl弱级隐藏。

---

### 94. Tampered Attention Key（16）

- **检测项：** TEE 处理异常标签，如 HanAttest 链不一致、KeyMint 异常、证书矛盾等。
- **解决方法：** 纯误报我假回锁都能概率测出来，再测一次就行。

---

### 94. 证书链篡改（x）

- **检测项：** 检测到设备密钥证书链不完整/被吊销/篡改。
- **解决方法：** 确保你是最新的TeeSimulator(RS)，点击模块的执行按钮清除缓存密钥，再导入未被吊销的新密钥。

---

### 95. USB调试已开启

- **检测项：** 检测到设备开启了USB调试。
- **解决方法：** 去开发者选项关闭USB调试或直接执行以下脚本
```
su -c settings put global adb_enabled 0
```

> 部分设备解锁bl后会自动开启USB调试，在/data/adb/service.d中创建一个sh里面写入以上脚本，达到开机自动关闭的效果。

---
---

> 📝 *本文档持续更新中，欢迎反馈新检测项和解决方案。*
> 云盘直链是作者付费自己购买的，做这个文档到现在一分钱没圈过，有能力的可以赞助一下吗QwQ：( https://qr.alipay.com/fkx14997mfiuixqv08lbo73 )
