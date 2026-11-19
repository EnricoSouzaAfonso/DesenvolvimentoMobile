<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$conexao = new mysqli("localhost", "root", "", "trufas");

if (isset($_POST['comissao'])) {
    $comissao = floatval(str_replace(',', '.', $_POST['comissao']));

    if ($comissao < 0) {
        echo json_encode(["status" => "erro", "mensagem" => "Percentual inválido"]);
        exit;
    }

    $stmt = $conexao->prepare("UPDATE configuracoes SET comissao = ? WHERE id = 1");
    $stmt->bind_param("d", $comissao);

    if ($stmt->execute()) {
        echo json_encode(["status" => "sucesso"]);
    } else {
        echo json_encode(["status" => "erro", "mensagem" => "Erro ao atualizar comissão"]);
    }
} else {
    echo json_encode(["status" => "erro", "mensagem" => "Dados não enviados"]);
}
?>