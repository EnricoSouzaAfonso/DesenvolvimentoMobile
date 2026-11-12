<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$conexao = new mysqli("localhost", "root", "", "xuitter");

$postagem_id = isset($_POST['postagem_id']) ? intval($_POST['postagem_id']) : 0;
$usuario_id = isset($_POST['usuario_id']) ? intval($_POST['usuario_id']) : 0;
$texto = isset($_POST['texto']) ? trim($_POST['texto']) : "";

if ($postagem_id <= 0 || $usuario_id <= 0 || empty($texto)) {
    echo json_encode(["status" => "erro", "mensagem" => "Dados incompletos"]);
    exit;
}

$res = $conexao->query("SELECT usuario_id FROM postagens WHERE id = $postagem_id");
if ($res->num_rows === 0) {
    echo json_encode(["status" => "erro", "mensagem" => "Postagem nao encontrada"]);
    exit;
}
$post = $res->fetch_assoc();
$autor_id = intval($post['usuario_id']);

if ($usuario_id !== $autor_id) {
    $stmt = $conexao->prepare("SELECT id FROM amizades WHERE (usuario_id = ? AND amigo_id = ?) OR (usuario_id = ? AND amigo_id = ?)");
    $stmt->bind_param("iiii", $usuario_id, $autor_id, $autor_id, $usuario_id);
    $stmt->execute();
    $resultado = $stmt->get_result();

    if ($resultado->num_rows === 0) {
        echo json_encode(["status" => "erro", "mensagem" => "Apenas amigos podem comentar"]);
        exit;
    }
}

$stmt = $conexao->prepare("INSERT INTO comentarios (postagem_id, usuario_id, texto) VALUES (?, ?, ?)");
$stmt->bind_param("iis", $postagem_id, $usuario_id, $texto);
if ($stmt->execute()) {
    echo json_encode(["status" => "sucesso"]);
} else {
    echo json_encode(["status" => "erro", "mensagem" => "Erro ao comentar"]);
}
?>