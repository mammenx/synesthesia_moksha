
module limbus (
	clk_100_clk,
	reset_100_reset_n,
	tristate_conduit_bridge_sram_out_sram_tcm_data_out,
	tristate_conduit_bridge_sram_out_sram_tcm_address_out,
	tristate_conduit_bridge_sram_out_sram_tcm_outputenable_n_out,
	tristate_conduit_bridge_sram_out_sram_tcm_chipselect_n_out,
	tristate_conduit_bridge_sram_out_sram_tcm_byteenable_n_out,
	tristate_conduit_bridge_sram_out_sram_tcm_write_n_out,
	cortex_s_address,
	cortex_s_read,
	cortex_s_readdata,
	cortex_s_write,
	cortex_s_writedata,
	cortex_s_readdatavalid,
	cortex_reset_reset_n,
	cortex_irq_irq,
	uart_rxd,
	uart_txd,
	hdmi_tx_int_n_export);	

	input		clk_100_clk;
	input		reset_100_reset_n;
	inout	[15:0]	tristate_conduit_bridge_sram_out_sram_tcm_data_out;
	output	[18:0]	tristate_conduit_bridge_sram_out_sram_tcm_address_out;
	output	[0:0]	tristate_conduit_bridge_sram_out_sram_tcm_outputenable_n_out;
	output	[0:0]	tristate_conduit_bridge_sram_out_sram_tcm_chipselect_n_out;
	output	[1:0]	tristate_conduit_bridge_sram_out_sram_tcm_byteenable_n_out;
	output	[0:0]	tristate_conduit_bridge_sram_out_sram_tcm_write_n_out;
	output	[17:0]	cortex_s_address;
	output		cortex_s_read;
	input	[31:0]	cortex_s_readdata;
	output		cortex_s_write;
	output	[31:0]	cortex_s_writedata;
	input		cortex_s_readdatavalid;
	output		cortex_reset_reset_n;
	input		cortex_irq_irq;
	input		uart_rxd;
	output		uart_txd;
	input		hdmi_tx_int_n_export;
endmodule
