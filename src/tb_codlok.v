`timescale 1ns/1ps

module tb_codlok;
    // Sinais de entrada
    reg clk;
    reg reset_n;
    reg [3:0] key_value;
    reg key_valid;
    
    // Sinais de saída
    wire led;
    wire [1:0] state_out;
    wire [2:0] digit_count;
    wire access_granted;
    wire access_denied;
    
    // Instância do DUT
    codlok dut (
        .clk(clk),
        .reset_n(reset_n),
        .key_value(key_value),
        .key_valid(key_valid),
        .led(led),
        .state_out(state_out),
        .digit_count(digit_count),
        .access_granted(access_granted),
        .access_denied(access_denied)
    );
    
    // Gerador de clock 
    always #5 clk = ~clk;
    
    // Task para simular pressionamento de tecla
    task press_key;
        input [3:0] value;
        begin
            @(negedge clk);
            key_value = value;
            key_valid = 1;
            @(negedge clk);
            key_valid = 0;
            key_value = 4'hF;
            #200;
            $display("--- Tecla: %h ---", value);
        end
    endtask
    
    // Test cases
    initial begin
        
        $display("==========================================");
        $display("    TESTE DO CODLOK - SIMULADOR");
        $display("    SENHA CORRETA: 000123");
        $display("==========================================");
        
        // Inicialização
        clk = 0;
        reset_n = 0;
        key_value = 4'hF;
        key_valid = 0;
        
        // Reset
        #100;
        reset_n = 1;
        #100;
        
        $display("\n=== TESTE 1: Senha Correta (000123) ===");
        press_key(4'h0); // 0
        press_key(4'h0); // 0  
        press_key(4'h0); // 0
        press_key(4'h1); // 1
        press_key(4'h2); // 2
        press_key(4'h3); // 3
        
        // Espera o tempo de acesso
        #10000;
        
        $display("\n=== TESTE 2: Senha Incorreta (000122) ===");
        press_key(4'h0); // 0
        press_key(4'h0); // 0
        press_key(4'h0); // 0
        press_key(4'h1); // 1
        press_key(4'h2); // 2
        press_key(4'h2); // 2 (errado)
        
        // Espera o tempo de erro
        #5000;
        
        $display("\n=== TESTE 3: Cancelamento com # ===");
        press_key(4'h1); // 1
        press_key(4'h2); // 2
        press_key(4'hB); // # (cancelar)
        
        #500;
        
        $display("\n=== TESTE 4: Senha Curta (apenas 3 dígitos) ===");
        press_key(4'h1); // 1
        press_key(4'h2); // 2
        press_key(4'h3); // 3
        // Não completa
        #5000;
        
        $display("\n=== TESTE 5: Teclas Não Numéricas ===");
        press_key(4'hA); // *
        press_key(4'hC); // C
        press_key(4'hD); // D
        
        #500;
        
        $display("\n==========================================");
        $display("         FIM DOS TESTES");
        $display("==========================================");
        $finish;
    end
    
    // Monitor para observar mudanças de estado
    always @(state_out) begin
        case (state_out)
            2'b00: $display("[ESTADO] IDLE");
            2'b01: $display("[ESTADO] PASSWORD_ENTRY");
            2'b10: $display("[ESTADO] ACCESS_GRANTED");
            2'b11: $display("[ESTADO] ACCESS_DENIED");
        endcase
    end
    
    // Monitor para eventos importantes
    always @(posedge access_granted) begin
        $display("[EVENTO] >>> ACESSO CONCEDIDO! <<<");
    end
    
    always @(posedge access_denied) begin
        $display("[EVENTO] >>> ACESSO NEGADO! <<<");
    end
    
    // Log de dígitos digitados
    always @(digit_count) begin
        if (digit_count > 0) 
            $display("[PROGRESSO] Dígitos digitados: %0d/6", digit_count);
    end

endmodule