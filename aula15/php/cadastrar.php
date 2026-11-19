<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$conexao = new mysqli("localhost", "root", "", "trufas");

if (isset($_POST['nome'], $_POST['email'], $_POST['senha'], $_POST['perfil'])) {
    $nome = trim($_POST['nome']);
    $email = trim($_POST['email']);
    $senha = trim($_POST['senha']);
    $perfil = trim($_POST['perfil']);

    $check = $conexao->prepare("SELECT id FROM usuarios WHERE email = ?");
    $check->bind_param("s", $email);
    $check->execute();
    if ($check->get_result()->num_rows > 0) {
        echo json_encode(["status" => "erro", "mensagem" => "E-mail já cadastrado"]);
        exit;
    }

    $stmt = $conexao->prepare("INSERT INTO usuarios (nome, email, senha, perfil) VALUES (?, ?, ?, ?)");
    $stmt->bind_param("ssss", $nome, $email, $senha, $perfil);

    if ($stmt->execute()) {
        echo json_encode(["status" => "sucesso"]);
    } else {
        echo json_encode(["status" => "erro", "mensagem" => "Erro ao cadastrar"]);
    }
} else {
    echo json_encode(["status" => "erro", "mensagem" => "Dados incompletos"]);
}
?>