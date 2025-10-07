module keypad_controller (
    input wire clk,
    input wire [3:0] row,
    output reg [3:0] col,
    output reg [3:0] key_value,
    output reg key_valid
);

    reg [19:0] scan_counter;
    reg [1:0] scan_col;
    reg [3:0] row_sync [1:0];
    reg [3:0] row_debounced;
    reg [3:0] prev_row_debounced;
    
    // Mapeamento do teclado 4x4
    function [3:0] map_key;
        input [3:0] p_row;
        input [1:0] p_col;
        begin
            case ({p_row, p_col})
                // Coluna 0
                {4'b1110, 2'b00}: map_key = 4'h1; // 1
                {4'b1101, 2'b00}: map_key = 4'h4; // 4
                {4'b1011, 2'b00}: map_key = 4'h7; // 7
                {4'b0111, 2'b00}: map_key = 4'hA; // *
                // Coluna 1
                {4'b1110, 2'b01}: map_key = 4'h2; // 2
                {4'b1101, 2'b01}: map_key = 4'h5; // 5
                {4'b1011, 2'b01}: map_key = 4'h8; // 8
                {4'b0111, 2'b01}: map_key = 4'h0; // 0
                // Coluna 2
                {4'b1110, 2'b10}: map_key = 4'h3; // 3
                {4'b1101, 2'b10}: map_key = 4'h6; // 6
                {4'b1011, 2'b10}: map_key = 4'h9; // 9
                {4'b0111, 2'b10}: map_key = 4'hB; // #
                // Coluna 3
                {4'b1110, 2'b11}: map_key = 4'hC; // A
                {4'b1101, 2'b11}: map_key = 4'hD; // B
                {4'b1011, 2'b11}: map_key = 4'hE; // C
                {4'b0111, 2'b11}: map_key = 4'hF; // D
                default: map_key = 4'hF; // Nenhuma tecla
            endcase
        end
    endfunction

    initial begin
        scan_counter = 0;
        scan_col = 0;
        col = 4'b1111;
        key_value = 4'hF;
        key_valid = 0;
        row_sync[0] = 4'b1111;
        row_sync[1] = 4'b1111;
        row_debounced = 4'b1111;
        prev_row_debounced = 4'b1111;
    end
    
    always @(posedge clk) begin
        // Scan das colunas (5ms)
        scan_counter <= scan_counter + 1;
        if (scan_counter == 125000) begin // 25MHz / 200Hz = 125000
            scan_counter <= 0;
            scan_col <= scan_col + 1;
            
            case (scan_col)
                2'b00: col <= 4'b1110; // Ativa coluna 0
                2'b01: col <= 4'b1101; // Ativa coluna 1
                2'b10: col <= 4'b1011; // Ativa coluna 2
                2'b11: col <= 4'b0111; // Ativa coluna 3
            endcase
        end
        
        // Sincronização e debounce
        row_sync[0] <= row;
        row_sync[1] <= row_sync[0];
        
        // Debounce simples
        if (scan_counter == 0) begin
            row_debounced <= row_sync[1];
        end
        
        // Detecção de borda
        prev_row_debounced <= row_debounced;
        
        // Detecta tecla pressionada (borda de descida)
        if ((row_debounced != 4'b1111) && (prev_row_debounced == 4'b1111)) begin
            key_value <= map_key(row_debounced, scan_col);
            key_valid <= 1;
        end else begin
            key_valid <= 0;
        end
    end

endmodule