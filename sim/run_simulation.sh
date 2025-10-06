#!/bin/bash

echo "=========================================="
echo "    CODLOK - SIMULADOR DE SENHA FPGA"
echo "    Projeto Final - Wallace e Benites"
echo "=========================================="
echo ""

# Configurações
SRC_DIR="../src"
OUT_DIR="../build"
LOG_DIR="../logs"

# Criar diretórios se não existirem
mkdir -p $OUT_DIR
mkdir -p $LOG_DIR

echo "📁 Diretórios configurados..."
echo "🔧 Compilando projeto..."

# Compilar
iverilog -o $OUT_DIR/codlok_sim $SRC_DIR/tb_codlok.v $SRC_DIR/codlok.v

if [ $? -eq 0 ]; then
    echo "✅ Compilação bem-sucedida!"
    echo ""
    echo "🎬 Iniciando simulação..."
    echo "=========================================="
    
    # Executar simulação e salvar log
    cd $OUT_DIR
    vvp codlok_sim | tee ../logs/simulation.log
    
    echo ""
    echo "=========================================="
    echo "📊 Simulação concluída!"
    echo "📄 Log salvo em: logs/simulation.log"
    
    # Mostrar resumo
    echo ""
    echo "📋 RESUMO DA SIMULAÇÃO:"
    echo "-----------------------"
    grep -E "(SENHA CORRETA|SENHA INCORRETA|ACESSO CONCEDIDO|ACESSO NEGADO)" ../logs/simulation.log
    
else
    echo "❌ Erro na compilação!"
    exit 1
fi