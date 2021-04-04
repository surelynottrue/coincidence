module SerialCoincidence3(
    input clk,
    input TxD_start,
    input a,
    input b,
    output wire TxD,
    output reg TxD_done
);

parameter ClkFrequency = 50000000; //50MHz
parameter Baud = 115200;
parameter Oversampling = 1;
wire TxD_busy;
wire [7:0] AndData;
// wire TxD_data;
wire [7:0] TxD_data;

//Baud Tick Generator
wire BitTick;
BaudTickGen #(ClkFrequency, Baud, Oversampling) tickgen(.clk(clk), .enable(TxD_busy), .tick(BitTick));

// Module to generate data (AND)
// AndGate andinst(.clk(clk), .inA(a), .inB(b), .data(AndData));
wire DataClk;
AndGate andinst(.clk(clk), .inA(a), .inB(b), .dataclk(DataClk));


// Byte Tick Generator
wire ByteTick;
wire Interrupt;
ByteTickGen byteinst(.bitclk(BitTick), .bytetick(ByteTick), .interrupt(Interrupt));


// Increment counter ar every rise of DataClk
Counter counterinst(.dataclk(DataClk), .interrupt(Interrupt), .data(AndData));

// Copyt AndData register to TxD_data every ByteTick
SendData sendinst(.byteclk(ByteTick), .data(AndData), .dataout(TxD_data));




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
        4'b1111:    if(BitTick) TxD_state <= 4'b0010;  // bit 7
        4'b0010:    if(BitTick) TxD_state <= 4'b0011;  // stop1
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
parameter Baud = 115200;
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
    input inA,
    input inB,
    output reg dataclk
);

always @(posedge clk) begin
	if ((inA == inB) && (inA == 1)) begin
		dataclk = 1;
	end else begin
		dataclk = 0;
	end
end

endmodule


module ByteTickGen(
	input bitclk,
	output reg bytetick,
	output reg interrupt
);

reg [3:0] increment = 0;
reg tick = 0;

always @(posedge bitclk) begin
	if (increment == 11) begin
		tick = 1;
		increment = 1;
		interrupt = 1;
	end else begin
		increment = increment + 1;
		tick = 0;
		interrupt = 0;
	end
end

endmodule


module SendData(
	input byteclk,
	input [7:0] data,
	output [7:0] dataout
);

reg [7:0] outdata;

always @(posedge byteclk) begin
	outdata = data;
end

assign dataout = outdata;

endmodule


module Counter(
	input dataclk,
	input interrupt,
	output data
);

reg [7:0] counter = 0;

always @(posedge dataclk) begin
	if (interrupt == 1) begin
		counter = 0;
	end
	counter = counter + 1;
end
assign data = counter;
endmodule
