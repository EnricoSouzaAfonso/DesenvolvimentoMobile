<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$conexao = new mysqli("localhost", "root", "", "trufas");

if (isset($_POST['vendedor_id'], $_POST['producao_id'], $_POST['quantidade'])) {
    $vendedor_id = intval($_POST['vendedor_id']);
    $producao_id = intval($_POST['producao_id']);
    $quantidade = intval($_POST['quantidade']);

    if ($quantidade <= 0) {
        echo json_encode(["status" => "erro", "mensagem" => "Quantidade inválida"]);
        exit;
    }

    $stmt = $conexao->prepare("SELECT p.quantidade, p.valor_unitario, u.nome AS produtor_nome FROM producoes p INNER JOIN usuarios u ON p.produtor_id = u.id WHERE p.id = ?");
    $stmt->bind_param("i", $producao_id);
    $stmt->execute();
    $res = $stmt->get_result();

    if ($prod = $res->fetch_assoc()) {
        $estoque = intval($prod['quantidade']);
        $valor_unitario = floatval($prod['valor_unitario']);
        $produtor_nome = $prod['produtor_nome'];

        if ($quantidade > $estoque) {
            echo json_encode(["status" => "erro", "mensagem" => "Estoque insuficiente"]);
            exit;
        }

        $resCom = $conexao->query("SELECT comissao FROM configuracoes WHERE id = 1");
        $rowCom = $resCom->fetch_assoc();
        $comissao = $rowCom ? floatval($rowCom['comissao']) : 0.0;

        $subtotal = $quantidade * $valor_unitario;
        $valor_total = $subtotal + ($subtotal * ($comissao / 100));

        $novo_estoque = $estoque - $quantidade;
        $upd = $conexao->prepare("UPDATE producoes SET quantidade = ? WHERE id = ?");
        $upd->bind_param("ii", $novo_estoque, $producao_id);
        $upd->execute();

        $ins = $conexao->prepare("INSERT INTO vendas (vendedor_id, producao_id, quantidade, valor_unitario, comissao, valor_total) VALUES (?, ?, ?, ?, ?, ?)");
        $ins->bind_param("iiiddd", $vendedor_id, $producao_id, $quantidade, $valor_unitario, $comissao, $valor_total);
        $ins->execute();

        echo json_encode([
            "status" => "sucesso",
            "produtor_nome" => $produtor_nome,
            "quantidade" => $quantidade,
            "valor_unitario" => $valor_unitario,
            "subtotal" => $subtotal,
            "comissao" => $comissao,
            "valor_total" => $valor_total
        ]);
    } else {
        echo json_encode(["status" => "erro", "mensagem" => "Produção não encontrada"]);
    }
} else {
    echo json_encode(["status" => "erro", "mensagem" => "Dados incompletos"]);
}
?>