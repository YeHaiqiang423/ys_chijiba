#!/bin/bash
set -e 

# --- 1. 参数检查 ---
# $# 代表传入参数的个数。如果你没输够3个参数，脚本会教你怎么用并退出
if [ "$#" -lt 3 ]; then
    echo "❌ 错误: 参数不足！"
    echo "💡 用法: $0 <RTL源码路径> <TB文件路径> <顶层模块名>"
    echo "🔥 示例: $0 rtl/eth_bridge/eth_crc32_8b.v tb/tb_eth_crc32_8b.sv tb_eth_crc32_8b"
    exit 1
fi

# 将传入的参数赋值给易读的变量
RTL_FILE=$1
TB_FILE=$2
TB_TOP=$3

# --- 2. 智能路径解析（核心黑科技） ---
# 无论你在哪个目录下执行这个脚本，它都能精准找到工程根目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PRJ_ROOT="$(dirname "$SCRIPT_DIR")"
WORK_DIR="${PRJ_ROOT}/workspace"

echo ">>> [1/4] Preparing Simulation Workspace..."
# 确保 workspace 文件夹存在，然后进去
mkdir -p "${WORK_DIR}"
cd "${WORK_DIR}"

echo ">>> [2/4] Compiling Design and Testbench..."
# 使用绝对路径编译，彻底告别找不到文件的烦恼
xvlog -sv "${PRJ_ROOT}/${RTL_FILE}" "${PRJ_ROOT}/${TB_FILE}"

echo ">>> [3/4] Elaborating and Running Simulation..."
# 使用你传入的顶层模块名进行 elaboration
xelab -debug typical -top "${TB_TOP}" -snapshot sim_snap
xsim sim_snap -R

echo ">>> [4/4] Converting VCD to FST for Surfer..."
# 生成带模块名的波形文件，避免多个模块仿真覆盖同一个文件
echo ">>> [4/4] Converting VCD to FST for Surfer..."
# 用动态的顶层模块名去找文件
if [ -f "${TB_TOP}.vcd" ]; then
    vcd2fst "${TB_TOP}.vcd" "${TB_TOP}_result.fst"
    rm "${TB_TOP}.vcd" 
    echo "🎉 All Done! Check workspace/${TB_TOP}_result.fst in Surfer!"
else
    echo "⚠️ Warning: ${TB_TOP}.vcd not found. Check your testbench \$dumpvars setup."
fi