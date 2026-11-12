<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$conexao = new mysqli("localhost", "root", "", "xuitter");

$usuario_id = isset($_POST['usuario_id']) ? intval($_POST['usuario_id']) : 0;
$amigo_id = isset($_POST['amigo_id']) ? intval($_POST['amigo_id']) : 0;

if ($usuario_id <= 0 || $amigo_id <= 0 || $usuario_id === $amigo_id) {
    echo json_encode(["status" => "erro", "mensagem" => "Dados invalidos"]);
    exit;
}

$stmt = $conexao->prepare("SELECT id FROM amizades WHERE (usuario_id = ? AND amigo_id = ?) OR (usuario_id = ? AND amigo_id = ?)");
$stmt->bind_param("iiii", $usuario_id, $amigo_id, $amigo_id, $usuario_id);
$stmt->execute();
if ($stmt->get_result()->num_rows > 0) {
    echo json_encode(["status" => "sucesso", "mensagem" => "Ja sao amigos"]);
    exit;
}

$stmt = $conexao->prepare("INSERT INTO amizades (usuario_id, amigo_id) VALUES (?, ?)");
$stmt->bind_param("ii", $usuario_id, $amigo_id);
if ($stmt->execute()) {
    echo json_encode(["status" => "sucesso"]);
} else {
    echo json_encode(["status" => "erro"]);
}
?>