<?php
header('Content-Type: application/json; charset=utf-8');

$pdo = new PDO('mysql:host=localhost;dbname=xuitter;charset=utf8', 'root', '');

$id = $_GET['id'] ?? $_POST['id'] ?? 0;

$stmt = $pdo->prepare("SELECT id, texto FROM textos WHERE id > :id ORDER BY id ASC LIMIT 1");
$stmt->execute([':id' => $id]);
$dado = $stmt->fetch(PDO::FETCH_ASSOC);

if ($dado) {
    echo json_encode([
        'id' => (int)$dado['id'],
        'texto' => $dado['texto']
    ], JSON_UNESCAPED_UNICODE);
} else {
    echo json_encode(null);
}
?>