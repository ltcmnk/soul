<?php
session_start();
header('Content-Type: application/json');

$host = "localhost";
$usuario = "root";
$senha = "";
$banco = "mydb";

$conn = new mysqli($host, $usuario, $senha, $banco);
if ($conn->connect_error) {
    echo json_encode(['success' => false, 'message' => 'Falha na conexão com o banco de dados']);
    exit;
}

$data = json_decode(file_get_contents('php://input'), true);

// Validação dos campos
if (empty($data['email']) || empty($data['senha'])) {
    echo json_encode(['success' => false, 'message' => 'Email e senha são obrigatórios']);
    exit;
}

$email = $conn->real_escape_string($data['email']);
$senha = $data['senha'];

$sql = "SELECT id, nome, senha FROM usuario WHERE email = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();
    if (password_verify($senha, $user['senha'])) {
        $_SESSION['user_id'] = $user['id'];
        $_SESSION['user_name'] = $user['nome'];
        echo json_encode([
            'success' => true, 
            'message' => 'Login realizado com sucesso!',
            'redirect' => 'index.html',
            'user' => $user['nome']
        ]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Email ou senha incorretos']);
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Email ou senha incorretos']);
}

$stmt->close();
$conn->close();
?>