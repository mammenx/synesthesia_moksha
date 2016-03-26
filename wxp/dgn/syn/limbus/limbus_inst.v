	limbus u0 (
		.clk_100_clk                                                  (<connected-to-clk_100_clk>),                                                  //                          clk_100.clk
		.reset_100_reset_n                                            (<connected-to-reset_100_reset_n>),                                            //                        reset_100.reset_n
		.tristate_conduit_bridge_sram_out_sram_tcm_data_out           (<connected-to-tristate_conduit_bridge_sram_out_sram_tcm_data_out>),           // tristate_conduit_bridge_sram_out.sram_tcm_data_out
		.tristate_conduit_bridge_sram_out_sram_tcm_address_out        (<connected-to-tristate_conduit_bridge_sram_out_sram_tcm_address_out>),        //                                 .sram_tcm_address_out
		.tristate_conduit_bridge_sram_out_sram_tcm_outputenable_n_out (<connected-to-tristate_conduit_bridge_sram_out_sram_tcm_outputenable_n_out>), //                                 .sram_tcm_outputenable_n_out
		.tristate_conduit_bridge_sram_out_sram_tcm_chipselect_n_out   (<connected-to-tristate_conduit_bridge_sram_out_sram_tcm_chipselect_n_out>),   //                                 .sram_tcm_chipselect_n_out
		.tristate_conduit_bridge_sram_out_sram_tcm_byteenable_n_out   (<connected-to-tristate_conduit_bridge_sram_out_sram_tcm_byteenable_n_out>),   //                                 .sram_tcm_byteenable_n_out
		.tristate_conduit_bridge_sram_out_sram_tcm_write_n_out        (<connected-to-tristate_conduit_bridge_sram_out_sram_tcm_write_n_out>),        //                                 .sram_tcm_write_n_out
		.cortex_s_address                                             (<connected-to-cortex_s_address>),                                             //                         cortex_s.address
		.cortex_s_read                                                (<connected-to-cortex_s_read>),                                                //                                 .read
		.cortex_s_readdata                                            (<connected-to-cortex_s_readdata>),                                            //                                 .readdata
		.cortex_s_write                                               (<connected-to-cortex_s_write>),                                               //                                 .write
		.cortex_s_writedata                                           (<connected-to-cortex_s_writedata>),                                           //                                 .writedata
		.cortex_s_readdatavalid                                       (<connected-to-cortex_s_readdatavalid>),                                       //                                 .readdatavalid
		.cortex_reset_reset_n                                         (<connected-to-cortex_reset_reset_n>),                                         //                     cortex_reset.reset_n
		.cortex_irq_irq                                               (<connected-to-cortex_irq_irq>),                                               //                       cortex_irq.irq
		.uart_rxd                                                     (<connected-to-uart_rxd>),                                                     //                             uart.rxd
		.uart_txd                                                     (<connected-to-uart_txd>),                                                     //                                 .txd
		.hdmi_tx_int_n_export                                         (<connected-to-hdmi_tx_int_n_export>)                                          //                    hdmi_tx_int_n.export
	);

