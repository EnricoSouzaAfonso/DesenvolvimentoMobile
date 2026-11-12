<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$conexao = new mysqli("localhost", "root", "", "xuitter");

$busca = isset($_GET['busca']) ? trim($_GET['busca']) : "";
$usuario_id = isset($_GET['usuario_id']) ? intval($_GET['usuario_id']) : 0;

if (empty($busca)) {
    echo json_encode([]);
    exit;
}


$termoLimpo = str_replace('@', '', $busca);
$termo = "%" . $termoLimpo . "%";

$sql = "SELECT u.id, u.nome, u.arroba,
            (SELECT COUNT(*) FROM amizades a 
             WHERE (a.usuario_id = ? AND a.amigo_id = u.id) 
                OR (a.usuario_id = u.id AND a.amigo_id = ?)) AS sao_amigos
        FROM usuarios u
        WHERE (u.nome LIKE ? OR u.arroba LIKE ?) AND u.id != ?";

$stmt = $conexao->prepare($sql);

if (!$stmt) {
    echo json_encode([]);
    exit;
}

$stmt->bind_param("iissi", $usuario_id, $usuario_id, $termo, $termo, $usuario_id);
$stmt->execute();
$res = $stmt->get_result();

$usuarios = [];
while ($linha = $res->fetch_assoc()) {
    $linha['sao_amigos'] = intval($linha['sao_amigos']) > 0;
    $usuarios[] = $linha;
}

echo json_encode($usuarios);
?>