<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$conexao = new mysqli("localhost", "root", "", "atividades");

$mes = isset($_GET['mes']) ? intval($_GET['mes']) : intval(date('m'));
$ano = isset($_GET['ano']) ? intval($_GET['ano']) : intval(date('Y'));

$stmt = $conexao->prepare("SELECT id, DATE_FORMAT(dia, '%d/%m/%Y') AS dia_formatado, atividade FROM atividades WHERE MONTH(dia) = ? AND YEAR(dia) = ? ORDER BY dia DESC, id DESC");
$stmt->bind_param("ii", $mes, $ano);
$stmt->execute();
$res = $stmt->get_result();

$lista = [];
while ($row = $res->fetch_assoc()) {
    $lista[] = $row;
}

echo json_encode($lista);
?>