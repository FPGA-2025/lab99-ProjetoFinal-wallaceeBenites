module codlok_top (
    input wire clk,
    output wire led,
    // Teclado matricial - linhas e colunas
    input wire [3:0] row,
    output wire [3:0] col
);

    wire [3:0] key_value;
    wire key_valid;
    
    // Instância do controlador do teclado
    keypad_controller keypad_ctrl (
        .clk(clk),
        .row(row),
        .col(col),
        .key_value(key_value),
        .key_valid(key_valid)
    );
    
    // Instância do codlok principal
    codlok security_system (
        .clk(clk),
        .reset_n(1'b1), // Reset sempre ativo
        .key_value(key_value),
        .key_valid(key_valid),
        .led(led),
        .state_out(),    // Não usado no topo
        .digit_count(),  // Não usado no topo  
        .access_granted(), // Não usado no topo
        .access_denied()   // Não usado no topo
    );

endmodule