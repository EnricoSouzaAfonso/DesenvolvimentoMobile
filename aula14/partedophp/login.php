<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$conexao = new mysqli("localhost", "root", "", "xuitter");

if (isset($_POST['email'], $_POST['senha'])) {
    $email = trim($_POST['email']);
    $senha = trim($_POST['senha']);

    $stmt = $conexao->prepare("SELECT id, nome, arroba FROM usuarios WHERE email = ? AND senha = ?");
    $stmt->bind_param("ss", $email, $senha);
    $stmt->execute();
    $resultado = $stmt->get_result();

    if ($usuario = $resultado->fetch_assoc()) {
        echo json_encode(["status" => "sucesso", "usuario" => $usuario]);
    } else {
        echo json_encode(["status" => "erro", "mensagem" => "E-mail ou senha incorretos"]);
    }
} else {
    echo json_encode(["status" => "erro", "mensagem" => "Dados não enviados"]);
}
?>