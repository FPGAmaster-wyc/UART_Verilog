module UART_tx_gen_data(
	input clk_a,
	input rst_n,
	output txd
);

	reg [7:0] temp_data;
	reg [7:0] tx_data;
	reg tx_valid;
	wire ready;


	reg [3:0] c_state, n_state;
	parameter S0 = 0,
				S1 = 1;

	uart_tx #(
	.CHECK_BIT ("None"	)	,       //“None”无校验  “Odd”奇校验  “Even”偶校验
	.BPS       (115200	)	,       //系统波特率 
	.CLK       (25_000_000)	,   	//系统时钟频率 hz 
	.DATA_BIT  (8		)	,       //数据位（6、7、8）
	.STOP_BIT  (1       )   		//停止位
) TX (
	.i_reset(!rst_n),
	.i_clk(clk_a),
	.i_data(tx_data),
	.i_valid(tx_valid),
	.o_ready(ready),
	.o_txd(txd)
);

	always @(posedge clk_a, negedge rst_n) begin
		if (!rst_n)
			c_state <= 0;
		else 
			c_state <= n_state;
	end

	always @(*) begin
		case (c_state)
			S0	:	begin
						if (ready)
							n_state = S1;
						else
							n_state = S0;
			end

			S1	:	begin
						n_state = S0;
			end

			default :	n_state = 0;
		endcase 
	end

	always @(posedge clk_a, negedge rst_n) begin
		if (!rst_n)
			begin
				tx_data <= 0;
				temp_data <= 8'h5a;
				tx_valid <= 0;
			end
		else 
			case (n_state)
				S0	:	begin
							tx_valid <= 1;
							tx_data <= temp_data;	
				end

				S1	:	begin
							tx_valid <= 0;
							temp_data <= temp_data + 1;
				end

			endcase 
	end


endmodule


