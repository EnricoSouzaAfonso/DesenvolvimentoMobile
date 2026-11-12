<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$conexao = new mysqli("localhost", "root", "", "xuitter");

if ($conexao->connect_error) {
    echo json_encode(["status" => "erro", "mensagem" => "Falha na conexão"]);
    exit;
}

if (isset($_POST['nome'], $_POST['arroba'], $_POST['email'], $_POST['senha'])) {
    $nome = trim($_POST['nome']);
    $arroba = trim($_POST['arroba']);
    $email = trim($_POST['email']);
    $senha = trim($_POST['senha']);

    // Garante que o @ comece com o caractere @
    if (substr($arroba, 0, 1) !== '@') {
        $arroba = '@' . $arroba;
    }

    $stmt = $conexao->prepare("INSERT INTO usuarios (nome, arroba, email, senha) VALUES (?, ?, ?, ?)");
    $stmt->bind_param("ssss", $nome, $arroba, $email, $senha);

    if ($stmt->execute()) {
        echo json_encode(["status" => "sucesso", "id" => $stmt->insert_id]);
    } else {
        echo json_encode(["status" => "erro", "mensagem" => "Erro ao cadastrar"]);
    }
} else {
    echo json_encode(["status" => "erro", "mensagem" => "Dados incompletos"]);
}
?>