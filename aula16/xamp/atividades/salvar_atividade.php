<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$conexao = new mysqli("localhost", "root", "", "atividades");

if (isset($_POST['dia'], $_POST['atividade'])) {
    $diaInput = trim($_POST['dia']);
    $atividade = trim($_POST['atividade']);

    if (empty($diaInput) || empty($atividade)) {
        echo json_encode(["status" => "erro", "mensagem" => "Preencha o dia e a atividade"]);
        exit;
    }

    $dataFormatada = null;

    if (is_numeric($diaInput) && intval($diaInput) >= 1 && intval($diaInput) <= 31) {
        $dataFormatada = date("Y-m-") . str_pad(intval($diaInput), 2, "0", STR_PAD_LEFT);
    } else {
        $dt = DateTime::createFromFormat("d/m/Y", $diaInput);
        if ($dt && $dt->format("d/m/Y") === $diaInput) {
            $dataFormatada = $dt->format("Y-m-d");
        } else {
            $dtIso = DateTime::createFromFormat("Y-m-d", $diaInput);
            if ($dtIso && $dtIso->format("Y-m-d") === $diaInput) {
                $dataFormatada = $dtIso->format("Y-m-d");
            }
        }
    }

    if ($dataFormatada === null) {
        echo json_encode(["status" => "erro", "mensagem" => "Data inválida. Use DD/MM/AAAA ou o dia do mês"]);
        exit;
    }

    $stmt = $conexao->prepare("INSERT INTO atividades (dia, atividade) VALUES (?, ?)");
    $stmt->bind_param("ss", $dataFormatada, $atividade);

    if ($stmt->execute()) {
        echo json_encode(["status" => "sucesso"]);
    } else {
        echo json_encode(["status" => "erro", "mensagem" => "Erro ao salvar atividade"]);
    }
} else {
    echo json_encode(["status" => "erro", "mensagem" => "Dados incompletos"]);
}
?>