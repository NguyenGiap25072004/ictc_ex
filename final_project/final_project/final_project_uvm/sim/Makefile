## 
## -------------------------------------------------------------
##    Copyright 2010 Mentor Graphics Corporation
##    All Rights Reserved Worldwide
## 
##    Licensed under the Apache License, Version 2.0 (the
##    "License"); you may not use this file except in
##    compliance with the License.  You may obtain a copy of
##    the License at
## 
##        http://www.apache.org/licenses/LICENSE-2.0
## 
##    Unless required by applicable law or agreed to in
##    writing, software distributed under the License is
##    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
##    CONDITIONS OF ANY KIND, either express or implied.  See
##    the License for the specific language governing
##    permissions and limitations under the License.
## -------------------------------------------------------------
## 
USES_DPI   =0
TB_NAME    =test_bench
TESTNAME  ?=timer_register_test
VERBOSITY ?=UVM_MEDIUM
COV				?=OFF
RUNARG    ?=
SEED      ?=random
DEF_OPT   =
TB_LIST   = compile.f

ifeq ($(strip $(SEED)),random)
  SEED = $(shell /bin/date +%s)
endif

ifeq ($(COV),ON)
	comp_cov_opt =+cover=bcefst
	sim_cov_opt  =-coverage -do "coverage save -onexit $(TESTNAME)_$(SEED).ucdb; log -r -d 6 /*;run -all;"
	store_cov    = mv ${TESTNAME}_$(SEED).ucdb ./coverage
endif
##==============================================================
VLOG =  vlog \
        $(comp_cov_opt) \
        -timescale "1ps/1ps" \
        +define+UVM_NO_DPI \
        -mfcu \
        -suppress 2181 \
        +acc=rb \
        -writetoplevels ${TB_NAME} \
        +incdir+$(UVM_HOME)/src \
        $(UVM_HOME)/src/uvm.sv
		
VSIM =  vsim \
        $(sim_cov_opt) \
        -sv_seed ${SEED} \
        -voptargs=+acc \
        -assertdebug \
        -nocvg \
        -c ${TB_NAME}\
        -do "log -r /*;run -all;" \
        -l $(TESTNAME)_$(SEED).log	
##==============================================================

all: build run
build: 	vlib
	$(VLOG)  -f $(TB_LIST) \
  	+define+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR $(DEF_OPT)
		
run:
	$(VSIM) +UVM_TESTNAME=$(TESTNAME) \
          +UVM_VERBOSITY=$(VERBOSITY) \
	        ${RUNARG}
	mv ${TESTNAME}_$(SEED).log ./log	
	ln -sf ./log/${TESTNAME}_$(SEED).log xrun.log
	$(store_cov)

gen_cov:
	mkdir -p report_coverage
	vcover merge IP.ucdb ./coverage/*.ucdb
	vcover report IP.ucdb -output report_coverage/summary_report.txt
	vcover report -zeros -details -code bcefst -All -codeAll IP.ucdb -output report_coverage/detail_report.txt
	vcover report -zeros -details -code bcesft -annotate -testhitdataAll -html IP.ucdb -output report_coverage/html

vlib:
	mkdir -p log
	mkdir -p coverage
	vlib work
	vmap work work

wave:
	vsim -i -view vsim.wlf -do "add wave vsim:/$(TB_NAME)/*;" &

clean: 
	rm -rf work
	rm -rf log
	rm -rf *.ini
	rm -rf *.log
	rm -rf *.trace
	rm -rf *.wlf
	rm -rf transcript
	rm -rf coverage
	rm -rf report_coverage
	rm -rf *.ucdb
	rm -rf ${TB_NAME}
