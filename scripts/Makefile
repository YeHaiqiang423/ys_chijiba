# 简单Makefile 用于仿真流程自动化

# ============================================================================
# 用途: 一键快速仿真和波形查看
# 用法:
#   make          # 编译+仿真
#   make view     # 编译+仿真+看波形
#   make clean    # 清理
#   make help     # 帮助
# ============================================================================

# 配置变量
PROJECT = sc_fir_8tap
SOURCES = sc_fir_8tap.v tb_sc_fir_8tap.v 
EXECUTABLE = sim.o
VCD = tb_$(PROJECT).vcd

# 工具
CC = iverilog
SIM = vvp
VIEWER = gtkwave

# 编译选项
CFLAGS = -o $(EXECUTABLE)

# ============================================================
# 目标 (targets)
# ============================================================

# 默认目标: 编译 + 仿真
.PHONY: all
all: compile simulate

# 编译
.PHONY: compile
compile:
	@echo "【编译中】$(PROJECT)..."
	@$(CC) $(CFLAGS) $(SOURCES)
	@echo "【编译成功】"

# 仿真
.PHONY: simulate
simulate: compile
	@echo "【仿真中】..."
	@$(SIM) $(EXECUTABLE)
	@echo "【仿真成功】"
	@if [ -f $(VCD) ]; then echo "【波形文件】$(VCD)"; fi

# 看波形
.PHONY: view
view: simulate
	@echo "【打开波形】用GTKWave..."
	@$(VIEWER) $(VCD) &

# 清理
.PHONY: clean
clean:
	@rm -f $(EXECUTABLE) $(VCD)
	@echo "【清理完成】"

# 统计信息
.PHONY: info
info:
	@echo "========== 项目信息 =========="
	@echo "项目名: $(PROJECT)"
	@echo "源文件: $(SOURCES)"
	@echo "编译器: $(CC)"
	@echo "仿真器: $(SIM)"
	@echo "波形查看器: $(VIEWER)"

# 帮助
.PHONY: help
help:
	@echo "使用: make [目标]"
	@echo ""
	@echo "目标:"
	@echo "  all      - 编译 + 仿真 (默认)"
	@echo "  compile  - 仅编译"
	@echo "  simulate - 编译 + 仿真"
	@echo "  view     - 编译 + 仿真 + 看波形"
	@echo "  clean    - 清理临时文件"
	@echo "  info     - 显示项目信息"
	@echo "  help     - 显示此帮助"
	@echo ""
	@echo "示例:"
	@echo "  make          # 快速仿真"
	@echo "  make view     # 看波形"
	@echo "  make clean    # 清理"
