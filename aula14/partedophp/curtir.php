<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$conexao = new mysqli("localhost", "root", "", "xuitter");

$postagem_id = isset($_POST['postagem_id']) ? intval($_POST['postagem_id']) : 0;
$usuario_id = isset($_POST['usuario_id']) ? intval($_POST['usuario_id']) : 0;

if ($postagem_id <= 0 || $usuario_id <= 0) {
    echo json_encode(["status" => "erro", "mensagem" => "Dados invalidos"]);
    exit;
}

$stmt = $conexao->prepare("SELECT id FROM curtidas WHERE postagem_id = ? AND usuario_id = ?");
$stmt->bind_param("ii", $postagem_id, $usuario_id);
$stmt->execute();
$res = $stmt->get_result();

if ($res->num_rows > 0) {
    $stmt = $conexao->prepare("DELETE FROM curtidas WHERE postagem_id = ? AND usuario_id = ?");
    $stmt->bind_param("ii", $postagem_id, $usuario_id);
    $stmt->execute();
    echo json_encode(["status" => "sucesso", "acao" => "descurtiu"]);
} else {
    $stmt = $conexao->prepare("INSERT INTO curtidas (postagem_id, usuario_id) VALUES (?, ?)");
    $stmt->bind_param("ii", $postagem_id, $usuario_id);
    $stmt->execute();
    echo json_encode(["status" => "sucesso", "acao" => "curtiu"]);
}
?>