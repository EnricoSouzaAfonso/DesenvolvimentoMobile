<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$conexao = new mysqli("localhost", "root", "", "trufas");

$resCom = $conexao->query("SELECT comissao FROM configuracoes WHERE id = 1");
$rowCom = $resCom->fetch_assoc();
$comissao = $rowCom ? floatval($rowCom['comissao']) : 0.0;

$resVendidas = $conexao->query("SELECT COALESCE(SUM(quantidade), 0) AS total FROM vendas");
$total_vendidas = intval($resVendidas->fetch_assoc()['total']);

$resEstoque = $conexao->query("SELECT COALESCE(SUM(quantidade), 0) AS total FROM producoes");
$estoque_atual = intval($resEstoque->fetch_assoc()['total']);

$total_geradas = $estoque_atual + $total_vendidas;

$sqlLucro = "SELECT COALESCE(SUM(valor_total - (quantidade * valor_unitario)), 0) AS lucro 
             FROM vendas 
             WHERE MONTH(data_venda) = MONTH(CURRENT_DATE()) 
               AND YEAR(data_venda) = YEAR(CURRENT_DATE())";
$resLucro = $conexao->query($sqlLucro);
$lucro_mes = floatval($resLucro->fetch_assoc()['lucro']);

echo json_encode([
    "comissao" => $comissao,
    "total_geradas" => $total_geradas,
    "total_vendidas" => $total_vendidas,
    "lucro_mes" => $lucro_mes
]);
?>