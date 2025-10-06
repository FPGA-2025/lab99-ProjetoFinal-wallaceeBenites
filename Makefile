# Makefile para Projeto CodLok - FPGA
# Autores: Wallace e Benites

# Diretórios
SRC_DIR = src
SIM_DIR = sim
BUILD_DIR = build
LOG_DIR = logs

# Alvo principal
all: sim

# Criar diretórios
dirs:
	mkdir -p $(BUILD_DIR)
	mkdir -p $(LOG_DIR)

# Compilar
compile: dirs
	@echo "Compilando projeto..."
	iverilog -o $(BUILD_DIR)/codlok_sim $(SRC_DIR)/tb_codlok.v $(SRC_DIR)/codlok.v

# Simular
sim: compile
	@echo "Executando simulação..."
	@cd $(BUILD_DIR) && vvp codlok_sim | tee ../$(LOG_DIR)/simulation.log
	@echo ""
	@echo "Simulação concluída! Verifique $(LOG_DIR)/simulation.log"

# Simulação rápida (apenas terminal)
quick: compile
	@cd $(BUILD_DIR) && vvp codlok_sim

# Limpar arquivos gerados
clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(LOG_DIR)

# Ajuda
help:
	@echo "Comandos disponíveis:"
	@echo "  make sim     - Compila e executa simulação completa"
	@echo "  make quick   - Compila e executa simulação rápida"
	@echo "  make compile - Apenas compila"
	@echo "  make clean   - Limpa arquivos gerados"
	@echo "  make help    - Mostra esta ajuda"

.PHONY: all sim quick compile clean help dirs