<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$conexao = new mysqli("localhost", "root", "", "xuitter");
$resultado = $conexao->query("SELECT * FROM fotos ORDER BY id ASC");

$lista = [];
while ($linha = $resultado->fetch_assoc()) {
    $lista[] = $linha;
}

echo json_encode($lista);
?>