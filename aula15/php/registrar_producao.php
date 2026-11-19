<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$conexao = new mysqli("localhost", "root", "", "trufas");

if (isset($_POST['produtor_id'], $_POST['quantidade'], $_POST['valor_unitario'])) {
    $produtor_id = intval($_POST['produtor_id']);
    $quantidade = intval($_POST['quantidade']);
    $valor_unitario = floatval(str_replace(',', '.', $_POST['valor_unitario']));

    $res = $conexao->query("SELECT comissao FROM configuracoes WHERE id = 1");
    $row = $res->fetch_assoc();
    $comissao = $row ? floatval($row['comissao']) : 0.0;

    $valor_total = $quantidade * $valor_unitario;
    $valor_liquido = $valor_total - ($valor_total * ($comissao / 100));

    $stmt = $conexao->prepare("INSERT INTO producoes (produtor_id, quantidade, valor_unitario, comissao, valor_total, valor_liquido) VALUES (?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("iidddd", $produtor_id, $quantidade, $valor_unitario, $comissao, $valor_total, $valor_liquido);

    if ($stmt->execute()) {
        echo json_encode([
            "status" => "sucesso",
            "comissao" => $comissao,
            "valor_total" => $valor_total,
            "valor_liquido" => $valor_liquido
        ]);
    } else {
        echo json_encode(["status" => "erro", "mensagem" => "Erro ao salvar produção"]);
    }
} else {
    echo json_encode(["status" => "erro", "mensagem" => "Dados incompletos"]);
}
?>