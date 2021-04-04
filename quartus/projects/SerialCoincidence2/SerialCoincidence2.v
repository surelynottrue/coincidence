// Template Verilog file. You can delete these.
// Run quartus-cli -a to configure pin assignments, once you are done.

module SerialCoincidence2(
    input clk,
    input TxD_start,
    input a,
    input b,
    output wire TxD,
    output reg TxD_done
);

parameter ClkFrequency = 50000000; //50MHz
parameter Baud = 9600;
parameter Oversampling = 1;
wire TxD_busy;
wire [7:0] AndData;
wire [7:0] TxD_data;

// Module to generate data (AND)
AndGate andinst(.clk(clk), .bitclk(BitTick), .inA(a), .inB(b), .data(AndData));
//
//
SendData sendinst(.bitclk(BitTick), .data(AndData), .dataout(TxD_data));

//Baud Tick Generator
wire BitTick;
BaudTickGen #(ClkFrequency, Baud, Oversampling) tickgen(.clk(clk), .enable(TxD_busy), .tick(BitTick));
//

reg [3:0] TxD_state = 0;
// wire [7:0] TxD_data = 0; 
// assign TxD_data = ResultChar;
assign TxD_ready = (TxD_state==0);
assign TxD_busy = ~TxD_ready;
reg [7:0] TxD_shift = 0;

always @(posedge clk)
begin
    if(TxD_ready & TxD_start) begin 
        TxD_shift <= TxD_data;
    // Data bits(byte) sending
    end else if(TxD_state[3] & BitTick) begin 
        TxD_shift <= (TxD_shift >> 1); 
    end // Input byte is sening in each clock cycle one by one
    case (TxD_state) // counting each bit
        4'b0000 : if(TxD_start) begin
            TxD_state <= 4'b0100;
            TxD_done<=0;
        end
        4'b0100:    if(BitTick) TxD_state <= 4'b1000;  // start bit
        4'b1000:    if(BitTick) TxD_state <= 4'b1001;  // bit 0
        4'b1001:    if(BitTick) TxD_state <= 4'b1010;  // bit 1
        4'b1010:    if(BitTick) TxD_state <= 4'b1011;  // bit 2
        4'b1011:    if(BitTick) TxD_state <= 4'b1100;  // bit 3
        4'b1100:    if(BitTick) TxD_state <= 4'b1101;  // bit 4
        4'b1101:    if(BitTick) TxD_state <= 4'b1110;  // bit 5
        4'b1110:    if(BitTick) TxD_state <= 4'b1111;  // bit 6
        4'b1111:    if(BitTick) TxD_state <= 4'b0010;  // bit 7 4'b0010:    if(BitTick) TxD_state <= 4'b0011;  // stop1
        4'b0011:    if(BitTick) begin// stop2
                        TxD_state <= 4'b0000;
                        TxD_done<=1; 
                    end
        default: if(BitTick) TxD_state <= 4'b0000;
    endcase
end

assign TxD = (TxD_state<4) | (TxD_state[3] & TxD_shift[0]); // put together the start, data and stop bits
endmodule

module BaudTickGen(
    input clk, 
    input enable,
    output tick  // generate a tick at the specified baud rate * oversampling
);
parameter ClkFrequency = 50000000;
parameter Baud = 9600;
parameter Oversampling = 1;

function     integer log2(input integer v);
                begin log2=0;
                while(v>>log2)
                                log2=log2+1;
                end
endfunction

localparam   AccWidth = log2(ClkFrequency/Baud)+8;
reg          [AccWidth:0] Acc = 0;
localparam   ShiftLimiter = log2(Baud*Oversampling >> (31-AccWidth));
localparam   Inc = ((Baud*Oversampling << (AccWidth-ShiftLimiter))+(ClkFrequency>>(ShiftLimiter+1)))/(ClkFrequency>>ShiftLimiter);

always @(posedge clk) begin
    if(enable) begin
    Acc <= Acc[AccWidth-1:0] + Inc[AccWidth:0]; 
    end else begin
    Acc <= Inc[AccWidth:0];
    end
end

assign tick = Acc[AccWidth];
endmodule

module AndGate(
	input clk,
	input bitclk,
	input inA,
	input inB,
	output reg [7:0] data
);

always @(posedge bitclk) begin
		// if (data == 122) begin
		//         data <= 48;
		// end else
		data <= data + 1;
end

endmodule


module SendData(
	input bitclk,
	input [7:0] data,
	output reg [7:0] dataout
);

reg increment = 0;

always @(posedge bitclk) begin
	if (increment == 11) begin
		dataout <= data + 1;
		increment <= 0;
	end
	else begin
		increment = increment + 1;
	end
end
endmodule
