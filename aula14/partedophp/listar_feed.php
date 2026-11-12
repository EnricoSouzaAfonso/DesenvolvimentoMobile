<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$conexao = new mysqli("localhost", "root", "", "xuitter");

$usuario_id = isset($_GET['usuario_id']) ? intval($_GET['usuario_id']) : 0;

$sql = "SELECT p.id, p.texto, p.foto, p.usuario_id AS autor_id, u.nome, u.arroba,
        (SELECT COUNT(*) FROM curtidas c WHERE c.postagem_id = p.id) AS total_curtidas,
        (SELECT COUNT(*) FROM curtidas c WHERE c.postagem_id = p.id AND c.usuario_id = $usuario_id) AS curtiu
        FROM postagens p
        LEFT JOIN usuarios u ON p.usuario_id = u.id
        ORDER BY p.id DESC";

$res = $conexao->query($sql);

$feed = [];
while ($post = $res->fetch_assoc()) {
    $post_id = intval($post['id']);
    $post['total_curtidas'] = intval($post['total_curtidas']);
    $post['curtiu'] = intval($post['curtiu']) > 0;

    $sqlComentarios = "SELECT c.texto, u.nome, u.arroba 
                       FROM comentarios c 
                       LEFT JOIN usuarios u ON c.usuario_id = u.id 
                       WHERE c.postagem_id = $post_id 
                       ORDER BY c.id ASC";
    $resComentarios = $conexao->query($sqlComentarios);
    $comentarios = [];
    while ($c = $resComentarios->fetch_assoc()) {
        $comentarios[] = $c;
    }
    $post['comentarios'] = $comentarios;
    $feed[] = $post;
}

echo json_encode($feed);
?>