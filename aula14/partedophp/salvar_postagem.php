<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$conexao = new mysqli("localhost", "root", "", "xuitter");

$diretorio = "uploads/";
if (!is_dir($diretorio)) {
    mkdir($diretorio, 0777, true);
}

$usuario_id = isset($_POST['usuario_id']) ? intval($_POST['usuario_id']) : null;
$texto = isset($_POST['texto']) ? trim($_POST['texto']) : "";
$nomeArquivo = null;


if (isset($_FILES['foto']) && $_FILES['foto']['error'] === UPLOAD_ERR_OK) {
    $extensao = pathinfo($_FILES['foto']['name'], PATHINFO_EXTENSION);
    $nomeArquivo = uniqid() . "." . ($extensao ? $extensao : "jpg");
    move_uploaded_file($_FILES['foto']['tmp_name'], $diretorio . $nomeArquivo);
}

if (!empty($texto) || $nomeArquivo !== null) {
    $stmt = $conexao->prepare("INSERT INTO postagens (usuario_id, texto, foto) VALUES (?, ?, ?)");
    $stmt->bind_param("iss", $usuario_id, $texto, $nomeArquivo);
    $stmt->execute();
    echo json_encode(["status" => "sucesso"]);
} else {
    echo json_encode(["status" => "erro", "mensagem" => "A postagem não pode ser vazia"]);
}
?>