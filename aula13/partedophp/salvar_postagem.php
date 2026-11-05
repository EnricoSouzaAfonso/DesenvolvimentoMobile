<?php
header("Access-Control-Allow-Origin: *");

$conexao = new mysqli("localhost", "root", "", "xuitter");

$diretorio = "uploads/";
if (!is_dir($diretorio)) {
    mkdir($diretorio, 0777, true);
}

if (isset($_FILES['foto']) && isset($_POST['descricao'])) {
    $descricao = $_POST['descricao'];
    $extensao = pathinfo($_FILES['foto']['name'], PATHINFO_EXTENSION);
    $nomeArquivo = uniqid() . "." . ($extensao ? $extensao : "jpg");
    $caminho = $diretorio . $nomeArquivo;

    if (move_uploaded_file($_FILES['foto']['tmp_name'], $caminho)) {
        $stmt = $conexao->prepare("INSERT INTO fotos (arquivo, descricao) VALUES (?, ?)");
        $stmt->bind_param("ss", $nomeArquivo, $descricao);
        $stmt->execute();
        echo json_encode(["status" => "sucesso"]);
    } else {
        echo json_encode(["status" => "erro"]);
    }
}
?>