#!/bin/bash
# ============================================================================
# 文件: quicksim.sh (强化版)
# 用途: 智能编译当前目录的 Verilog 代码并仿真
# ============================================================================

set -e # 遇到错误立即停止

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' 

# 环境自检：检查 iverilog 是否安装
if ! command -v iverilog &> /dev/null; then
    echo -e "${RED}[错误]${NC} 未找到 iverilog，请先在 Linux 上运行 sudo apt install iverilog"
    exit 1
fi

SIM_OUTPUT="sim_result.vvp"

# =========================================
# 核心逻辑
# =========================================

# 处理清理命令
if [ "$1" == "--clean" ] || [ "$1" == "-c" ]; then
    rm -f $SIM_OUTPUT *.vcd *.fst
    echo -e "${GREEN}[清理完成]${NC} 已删除编译产物和波形文件。"
    exit 0
fi

# 1. 寻找源文件：如果用户传参了就用参数，没传参就自动找目录下所有 .v 文件
if [ $# -gt 0 ] && [ "$1" != "--view" ]; then
    SOURCE_FILES="$@"
else
    SOURCE_FILES=$(ls *.v 2>/dev/null)
    if [ -z "$SOURCE_FILES" ]; then
        echo -e "${RED}[错误]${NC} 当前目录下没有找到任何 .v 文件！"
        exit 1
    fi
fi

# 2. 编译
echo -e "${YELLOW}>> [1/2] 正在编译:${NC} ${SOURCE_FILES}"
if ! iverilog -o $SIM_OUTPUT $SOURCE_FILES; then
    echo -e "${RED}❌ 编译失败，请检查上方的语法报错！${NC}"
    exit 1
fi

# 3. 仿真
echo -e "${YELLOW}>> [2/2] 正在运行仿真...${NC}"
if ! vvp $SIM_OUTPUT; then
    echo -e "${RED}❌ 仿真运行崩溃！${NC}"
    exit 1
fi

echo -e "${GREEN}✅ 仿真成功！${NC}"
rm -f $SIM_OUTPUT
# 寻找生成的波形文件并提示
VCD_FILE=$(ls *.vcd 2>/dev/null | head -n 1)
if [ -n "$VCD_FILE" ]; then
    echo -e "📈 波形已生成: ${GREEN}$VCD_FILE${NC}"
    echo -e "👉 ${YELLOW}请在 VS Code 中直接点击该文件查看波形。${NC}"
fi