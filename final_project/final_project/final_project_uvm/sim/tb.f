
+incdir+${TIMER_IP_VERIF_PATH}/register_model
+incdir+${TIMER_IP_VERIF_PATH}/register_model/register
+incdir+${TIMER_IP_VERIF_PATH}/sequences
+incdir+${TIMER_IP_VERIF_PATH}/testcases
+incdir+${TIMER_IP_VERIF_PATH}/tb

+define+APB_ADDR_WIDTH=12
+define+APB_DATA_WIDTH=32

// APB VIP compilation
-f ${APB_VIP_ROOT}/apb_vip.list

// Compilation Environment
${TIMER_IP_VERIF_PATH}/register_model/register/timer_register_pkg.sv
${TIMER_IP_VERIF_PATH}/register_model/timer_register_model_pkg.sv
${TIMER_IP_VERIF_PATH}/tb/timer_env_pkg.sv
${TIMER_IP_VERIF_PATH}/testcases/timer_test_pkg.sv
${TIMER_IP_VERIF_PATH}/tb/test_bench.sv
