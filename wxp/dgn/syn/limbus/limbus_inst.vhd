	component limbus is
		port (
			clk_100_clk                                                  : in    std_logic                     := 'X';             -- clk
			reset_100_reset_n                                            : in    std_logic                     := 'X';             -- reset_n
			tristate_conduit_bridge_sram_out_sram_tcm_data_out           : inout std_logic_vector(15 downto 0) := (others => 'X'); -- sram_tcm_data_out
			tristate_conduit_bridge_sram_out_sram_tcm_address_out        : out   std_logic_vector(18 downto 0);                    -- sram_tcm_address_out
			tristate_conduit_bridge_sram_out_sram_tcm_outputenable_n_out : out   std_logic_vector(0 downto 0);                     -- sram_tcm_outputenable_n_out
			tristate_conduit_bridge_sram_out_sram_tcm_chipselect_n_out   : out   std_logic_vector(0 downto 0);                     -- sram_tcm_chipselect_n_out
			tristate_conduit_bridge_sram_out_sram_tcm_byteenable_n_out   : out   std_logic_vector(1 downto 0);                     -- sram_tcm_byteenable_n_out
			tristate_conduit_bridge_sram_out_sram_tcm_write_n_out        : out   std_logic_vector(0 downto 0);                     -- sram_tcm_write_n_out
			cortex_s_address                                             : out   std_logic_vector(17 downto 0);                    -- address
			cortex_s_read                                                : out   std_logic;                                        -- read
			cortex_s_readdata                                            : in    std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			cortex_s_write                                               : out   std_logic;                                        -- write
			cortex_s_writedata                                           : out   std_logic_vector(31 downto 0);                    -- writedata
			cortex_s_readdatavalid                                       : in    std_logic                     := 'X';             -- readdatavalid
			cortex_reset_reset_n                                         : out   std_logic;                                        -- reset_n
			cortex_irq_irq                                               : in    std_logic                     := 'X';             -- irq
			uart_rxd                                                     : in    std_logic                     := 'X';             -- rxd
			uart_txd                                                     : out   std_logic;                                        -- txd
			hdmi_tx_int_n_export                                         : in    std_logic                     := 'X'              -- export
		);
	end component limbus;

	u0 : component limbus
		port map (
			clk_100_clk                                                  => CONNECTED_TO_clk_100_clk,                                                  --                          clk_100.clk
			reset_100_reset_n                                            => CONNECTED_TO_reset_100_reset_n,                                            --                        reset_100.reset_n
			tristate_conduit_bridge_sram_out_sram_tcm_data_out           => CONNECTED_TO_tristate_conduit_bridge_sram_out_sram_tcm_data_out,           -- tristate_conduit_bridge_sram_out.sram_tcm_data_out
			tristate_conduit_bridge_sram_out_sram_tcm_address_out        => CONNECTED_TO_tristate_conduit_bridge_sram_out_sram_tcm_address_out,        --                                 .sram_tcm_address_out
			tristate_conduit_bridge_sram_out_sram_tcm_outputenable_n_out => CONNECTED_TO_tristate_conduit_bridge_sram_out_sram_tcm_outputenable_n_out, --                                 .sram_tcm_outputenable_n_out
			tristate_conduit_bridge_sram_out_sram_tcm_chipselect_n_out   => CONNECTED_TO_tristate_conduit_bridge_sram_out_sram_tcm_chipselect_n_out,   --                                 .sram_tcm_chipselect_n_out
			tristate_conduit_bridge_sram_out_sram_tcm_byteenable_n_out   => CONNECTED_TO_tristate_conduit_bridge_sram_out_sram_tcm_byteenable_n_out,   --                                 .sram_tcm_byteenable_n_out
			tristate_conduit_bridge_sram_out_sram_tcm_write_n_out        => CONNECTED_TO_tristate_conduit_bridge_sram_out_sram_tcm_write_n_out,        --                                 .sram_tcm_write_n_out
			cortex_s_address                                             => CONNECTED_TO_cortex_s_address,                                             --                         cortex_s.address
			cortex_s_read                                                => CONNECTED_TO_cortex_s_read,                                                --                                 .read
			cortex_s_readdata                                            => CONNECTED_TO_cortex_s_readdata,                                            --                                 .readdata
			cortex_s_write                                               => CONNECTED_TO_cortex_s_write,                                               --                                 .write
			cortex_s_writedata                                           => CONNECTED_TO_cortex_s_writedata,                                           --                                 .writedata
			cortex_s_readdatavalid                                       => CONNECTED_TO_cortex_s_readdatavalid,                                       --                                 .readdatavalid
			cortex_reset_reset_n                                         => CONNECTED_TO_cortex_reset_reset_n,                                         --                     cortex_reset.reset_n
			cortex_irq_irq                                               => CONNECTED_TO_cortex_irq_irq,                                               --                       cortex_irq.irq
			uart_rxd                                                     => CONNECTED_TO_uart_rxd,                                                     --                             uart.rxd
			uart_txd                                                     => CONNECTED_TO_uart_txd,                                                     --                                 .txd
			hdmi_tx_int_n_export                                         => CONNECTED_TO_hdmi_tx_int_n_export                                          --                    hdmi_tx_int_n.export
		);

