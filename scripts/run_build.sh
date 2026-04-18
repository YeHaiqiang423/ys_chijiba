#!/bin/bash
# 开启管道错误传递（Vivado 报错时让 Shell 也能感知到）
set -o pipefail 

PRJ_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "${PRJ_ROOT}"

# 把所有的原始刷屏垃圾全部收集到这个文件里，你真想查细节可以随时去这里看
FULL_LOG="${PRJ_ROOT}/build_full_dump.log"

clear
echo "======================================================="
echo "🚀 启动自动化构建流 (极简拦截模式)"
echo "📁 完整的原汁原味日志将保存在: ${FULL_LOG}"
echo "======================================================="

# 核心黑科技：用 tee 把日志存一份，同时用 while read 逐行拦截过滤屏幕输出
vivado -mode batch -source ./scripts/build_project.tcl -nolog -nojournal 2>&1 | tee "$FULL_LOG" | while IFS= read -r line; do
    
    # 🎯 拦截 1：我们自己在 Tcl 里写的日志
    if [[ "$line" == "[USER_LOG]"* ]]; then
        # 把 [USER_LOG] 替换成闪亮的 Emoji
        echo -e "\033[36m💎 ${line/[USER_LOG]/}\033[0m"

    # 🎯 拦截 2：原生致命错误 (标红并加上醒目 Emoji)
    elif [[ "$line" == "ERROR:"* ]]; then
        echo -e "\033[31m❌ [原生报错] ${line}\033[0m"

    # 🎯 拦截 3：原生严重警告 (标黄，过滤掉普通警告免得烦人)
    elif [[ "$line" == "CRITICAL WARNING:"* ]]; then
        echo -e "\033[33m⚠️ [严重警告] ${line}\033[0m"

    # 🎯 拦截 4：进度监控 (证明它没卡死，只是在后台闷声干大事)
    elif [[ "$line" == *"Waiting for synth_1 to finish"* ]]; then
        echo "⏳ [后台监控] 引擎正在疯狂综合中，请耐心等待 (约需几分钟)..."
    elif [[ "$line" == *"Waiting for impl_1 to finish"* ]]; then
        echo "⏳ [后台监控] 引擎正在布局布线，非常耗时，请去刷会儿 B 站..."
    elif [[ "$line" == *"Loading part"* ]]; then
        echo "🗺️ [底层加载] 正在将 Zynq 芯片地图载入内存 (这步看起来像死机，其实没有)..."
    fi
    
    # 其他成千上万行的原生 INFO 和常规 WARNING 全部被忽略，绝对不打在屏幕上！
done

# 获取 Vivado 的最终退出状态码
EXIT_CODE=$?

echo "======================================================="
if [ $EXIT_CODE -eq 0 ]; then
    echo "🎉 流程安全结束！"
else
    echo "💀 流程异常中断，请打开 build_full_dump.log 搜索 'ERROR' 查找死因！"
fi