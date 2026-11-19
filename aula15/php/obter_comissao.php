<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$conexao = new mysqli("localhost", "root", "", "trufas");

$res = $conexao->query("SELECT comissao FROM configuracoes WHERE id = 1");
if ($row = $res->fetch_assoc()) {
    echo json_encode(["comissao" => floatval($row['comissao'])]);
} else {
    echo json_encode(["comissao" => 0.0]);
}
?>