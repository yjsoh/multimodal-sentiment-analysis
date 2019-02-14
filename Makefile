### Makefile for multimodal-sentiment-analysis
### Version: 0.1.0

MKDIR=mkdir -p

BIN=/usr/bin/python
BIN_ARG=./run.py --unimodal True --fusion True --data mosi --classes 2
RESULT_DIR=result
# DATA_DIR=simple-examples/data
CUR_USER=env

# abs dir because of sudo perf stat
EXEC_BIN=$(BIN) $(BIN_ARG)

all: check force

force: bench graph

bench: strace_summary strace_full perf_stat nvidia_smi

graph: nvidia_smi_graph

### Bench
# strace summary
STRACE_SUMMARY_RES=$(RESULT_DIR)/strace_summary.txt
STRACE_SUMMARY_CMD=strace -cf $(EXEC_BIN)
strace_summary: $(BIN) $(RESULT_DIR)
	$(STRACE_SUMMARY_CMD) 2> $(STRACE_SUMMARY_RES)

# strace full
STRACE_FULL_RES=$(RESULT_DIR)/strace_full.txt
# y for showing fd name, -s0 for no binary print
STRACE_FULL_CMD=strace -y -s0 $(EXEC_BIN)
strace_full: $(BIN) $(RESULT_DIR)
	$(STRACE_FULL_CMD) 2> $(STRACE_FULL_RES)

# perf stat
PERF_STAT_RES=$(RESULT_DIR)/perf_stat.txt
PERF_STAT_CMD=sudo perf stat $(EXEC_BIN)
perf_stat: $(BIN) $(RESULT_DIR)
	$(PERF_STAT_CMD) 2> $(PERF_STAT_RES)

# nvidia-smi
NVIDIA_SMI_RES=$(RESULT_DIR)/nvidia-smi.txt
NVIDIA_SMI_FREQ=500 # millisec
NVIDIA_SMI_CMD=nvidia-smi --query-gpu=utilization.gpu,utilization.memory,power.draw --format=csv --filename=$(NVIDIA_SMI_RES) --loop-ms=$(NVIDIA_SMI_FREQ) $(EXEC_BIN)
nvidia_smi: $(BIN) $(RESULT_DIR)
#	$(NVIDIA_SMI_CMD) 2> $(NVIDIA_SMI_RES)
	$(NVIDIA_SMI_CMD)

# nvprof
NVPROF_RES=$(RESULT_DIR)/nvprof.txt
NVPROF_CMD=/usr/local/cuda-9.0/bin/nvprof --print-summary $(EXEC)
nvprof: $(BIN) $(RESULT_DIR)
	$(NVPROF_CMD) 2> $(NVPROF_RES)

# iotop
# TODO: automatically terminate after some time
# sudo iotop -ob -u$USER -qqq
IOTOP_RES=$(RESULT_DIR)/iotop.txt
IOTOP_CMD=sudo /usr/sbin/iotop -ob -u$(USER) -qqq
iotop: $(BIN) $(RESULT_DIR)
	$(IOTOP_CMD) > $(IOTOP_RES)

# iostat

### Graph
NVIDIA_SMI_GRAPHER=process_nvidia_smi.py
nvidia_smi_graph: $(NVIDIA_SMI_RES) $(NVIDIA_SMI_GRAPHER)
	./$(NVIDIA_SMI_GRAPHER) --input-file=$(NVIDIA_SMI_RES)

### Helper
# dir generator
$(RESULT_DIR):
	if [ ! -d $(RESULT_DIR) ]; then $(MKDIR) $(RESULT_DIR); fi

# checks
check: 
	if [ -d $(RESULT_DIR) ]; then echo "RESULT_DIR($(RESULT_DIR)\) already exists. <make force> to override."; exit -1; fi

# check_data:
#	if [ ! -d $(DATA_DIR) ]; then wget http://www.fit.vutbr.cz/~imikolov/rnnlm/simple-examples.tgz; tar xvf simple-examples.tgz; fi

# clean
clean:

clean_res:
	$(RM) -r $(RESULT_DIR)

# super_clean:
#	$(RM) -r $(RESULT_DIR) $(DATA_DIR)

