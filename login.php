<?php
session_start();
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');

$host   = 'localhost';
$dbuser = 'root';
$dbpass = '';
$banco  = 'SOul';

$conn = new mysqli($host, $dbuser, $dbpass, $banco);
if ($conn->connect_error) {
    echo json_encode(['success' => false, 'message' => 'Falha na conexão com o banco de dados']);
    exit;
}

$data = json_decode(file_get_contents('php://input'), true);

if (empty($data['email']) || empty($data['senha'])) {
    echo json_encode(['success' => false, 'message' => 'E-mail e senha são obrigatórios']);
    exit;
}

$email = $data['email'];
$senha = $data['senha'];

$stmt = $conn->prepare('SELECT id, nome, senha FROM usuario WHERE email = ?');
$stmt->bind_param('s', $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();
    if (password_verify($senha, $user['senha'])) {
        $_SESSION['user_id']   = $user['id'];
        $_SESSION['user_name'] = $user['nome'];
        echo json_encode([
            'success'  => true,
            'message'  => 'Login realizado com sucesso!',
            'redirect' => 'index.html',
            'user'     => $user['nome'],
            'userId'   => $user['id'],
        ]);
    } else {
        echo json_encode(['success' => false, 'message' => 'E-mail ou senha incorretos']);
    }
} else {
    echo json_encode(['success' => false, 'message' => 'E-mail ou senha incorretos']);
}

$stmt->close();
$conn->close();
