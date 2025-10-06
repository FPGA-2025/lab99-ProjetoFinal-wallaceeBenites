module codlok (
    input wire clk,
    input wire reset_n,
    input wire [3:0] key_value,
    input wire key_valid,
    output reg led,
    output reg [1:0] state_out,
    output reg [2:0] digit_count,
    output reg access_granted,
    output reg access_denied
);

    // SENHA : 000123 
    parameter [3:0] CORRECT_1 = 4'h0;
    parameter [3:0] CORRECT_2 = 4'h0;
    parameter [3:0] CORRECT_3 = 4'h0;
    parameter [3:0] CORRECT_4 = 4'h1;
    parameter [3:0] CORRECT_5 = 4'h2;
    parameter [3:0] CORRECT_6 = 4'h3;
    
    parameter [1:0] IDLE = 2'b00;
    parameter [1:0] PASSWORD_ENTRY = 2'b01;
    parameter [1:0] ACCESS_GRANTED = 2'b10;
    parameter [1:0] ACCESS_DENIED = 2'b11;
    
    reg [1:0] state;
    reg [3:0] digit1, digit2, digit3, digit4, digit5, digit6;
    reg [2:0] current_digit;
    reg [31:0] timer;
    reg led_active;
    reg check_password; 
    
    initial begin
        state = IDLE;
        digit1 = 0; digit2 = 0; digit3 = 0; digit4 = 0; digit5 = 0; digit6 = 0;
        current_digit = 0;
        timer = 0;
        led = 0;
        led_active = 0;
        access_granted = 0;
        access_denied = 0;
        digit_count = 0;
        state_out = IDLE;
        check_password = 0;
    end
    
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= IDLE;
            digit1 <= 0; digit2 <= 0; digit3 <= 0; digit4 <= 0; digit5 <= 0; digit6 <= 0;
            current_digit <= 0;
            timer <= 0;
            led_active <= 0;
            access_granted <= 0;
            access_denied <= 0;
            digit_count <= 0;
            check_password <= 0;
        end else begin
            access_granted <= 0;
            access_denied <= 0;
            
            // Verificação de senha no ciclo seguinte
            if (check_password) begin
                check_password <= 0;
                $display("[CODLOK] === VERIFICAÇÃO FINAL ===");
                $display("[CODLOK] Senha digitada: %h%h%h%h%h%h", 
                    digit1, digit2, digit3, digit4, digit5, digit6);
                $display("[CODLOK] Senha correta:  000123");
                
                if (digit1 == 4'h0 && digit2 == 4'h0 && digit3 == 4'h0 &&
                    digit4 == 4'h1 && digit5 == 4'h2 && digit6 == 4'h3) begin
                    $display("[CODLOK] *** SENHA CORRETA! ACESSO CONCEDIDO ***");
                    state <= ACCESS_GRANTED;
                    access_granted <= 1;
                    led_active <= 1;
                    timer <= 0;
                end else begin
                    $display("[CODLOK] *** SENHA INCORRETA! ACESSO NEGADO ***");
                    state <= ACCESS_DENIED;
                    access_denied <= 1;
                    timer <= 0;
                end
            end
            
            case (state)
                IDLE: begin
                    led_active <= 0;
                    current_digit <= 0;
                    digit1 <= 0; digit2 <= 0; digit3 <= 0; digit4 <= 0; digit5 <= 0; digit6 <= 0;
                    digit_count <= 0;
                    check_password <= 0;
                    
                    if (key_valid && key_value <= 9) begin
                        digit1 <= key_value;
                        current_digit <= 1;
                        digit_count <= 1;
                        state <= PASSWORD_ENTRY;
                        $display("[CODLOK] Primeiro dígito: %h", key_value);
                    end
                end
                
                PASSWORD_ENTRY: begin
                    if (key_valid) begin
                        if (key_value <= 9) begin
                            case (current_digit)
                                1: begin digit2 <= key_value; $display("[CODLOK] Dígito 2: %h", key_value); end
                                2: begin digit3 <= key_value; $display("[CODLOK] Dígito 3: %h", key_value); end
                                3: begin digit4 <= key_value; $display("[CODLOK] Dígito 4: %h", key_value); end
                                4: begin digit5 <= key_value; $display("[CODLOK] Dígito 5: %h", key_value); end
                                5: begin 
                                    digit6 <= key_value; 
                                    $display("[CODLOK] Dígito 6: %h", key_value);
                                    // MARCA para verificar no PRÓXIMO ciclo
                                    check_password <= 1;
                                end
                            endcase
                            
                            current_digit <= current_digit + 1;
                            digit_count <= current_digit + 1;
                        end else if (key_value == 4'hB) begin // Tecla '#'
                            $display("[CODLOK] Cancelado com #");
                            state <= IDLE;
                        end
                    end
                end
                
                ACCESS_GRANTED: begin
                    led_active <= 1;
                    timer <= timer + 1;
                    if (timer >= 500) begin
                        $display("[CODLOK] Tempo expirado");
                        led_active <= 0;
                        state <= IDLE;
                    end
                end
                
                ACCESS_DENIED: begin
                    led_active <= timer[20];
                    timer <= timer + 1;
                    if (timer >= 250) begin
                        led_active <= 0;
                        state <= IDLE;
                    end
                end
            endcase
            
            led <= led_active;
            state_out <= state;
        end
    end

endmodule