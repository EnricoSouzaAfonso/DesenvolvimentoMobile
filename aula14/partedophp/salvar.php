<?php
$mensagem = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $texto = $_POST['texto'] ?? null;

    if (!empty($texto)) {
        $pdo = new PDO('mysql:host=localhost;dbname=Xuitter;charset=utf8', 'root', '');
        $stmt = $pdo->prepare("INSERT INTO textos (texto) VALUES (:texto)");
        $stmt->execute([':texto' => $texto]);
        $mensagem = 'Salvo com sucesso';
    }
}
?>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Xuitter - Salvar</title>
</head>
<body>
    <form method="POST">
        <textarea name="texto" rows="4" cols="50" placeholder="Escreva o texto aqui..."></textarea>
        <br><br>
        <button type="submit">Salvar no Banco</button>
    </form>
    <?php if ($mensagem): ?>
        <p><?= $mensagem ?></p>
    <?php endif; ?>
</body>
</html>