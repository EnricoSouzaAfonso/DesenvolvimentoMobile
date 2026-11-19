<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$conexao = new mysqli("localhost", "root", "", "trufas");

$sql = "SELECT p.id, p.produtor_id, p.quantidade, p.valor_unitario, u.nome AS produtor_nome
        FROM producoes p
        INNER JOIN usuarios u ON p.produtor_id = u.id
        WHERE p.quantidade > 0
        ORDER BY p.id DESC";

$res = $conexao->query($sql);

$lista = [];
while ($row = $res->fetch_assoc()) {
    $lista[] = $row;
}

echo json_encode($lista);
?>