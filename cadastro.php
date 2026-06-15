<?php
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

if (empty($data['nome']) || empty($data['email']) || empty($data['senha'])) {
    echo json_encode(['success' => false, 'message' => 'Todos os campos são obrigatórios']);
    exit;
}

$nome  = $data['nome'];
$email = $data['email'];
$senha = password_hash($data['senha'], PASSWORD_DEFAULT);

// Verifica e-mail duplicado
$check = $conn->prepare('SELECT id FROM usuario WHERE email = ?');
$check->bind_param('s', $email);
$check->execute();
$check->store_result();

if ($check->num_rows > 0) {
    echo json_encode(['success' => false, 'message' => 'E-mail já cadastrado']);
    exit;
}
$check->close();

$stmt = $conn->prepare(
    'INSERT INTO usuario (nome, email, senha, data_reg, tema) VALUES (?, ?, ?, NOW(), "escuro")'
);
$stmt->bind_param('sss', $nome, $email, $senha);

if ($stmt->execute()) {
    $new_id = $conn->insert_id;
    echo json_encode([
        'success'  => true,
        'message'  => 'Conta criada com sucesso!',
        'redirect' => 'login.html',
        'userId'   => $new_id,
    ]);
} else {
    echo json_encode(['success' => false, 'message' => 'Erro ao cadastrar: ' . $stmt->error]);
}

$stmt->close();
$conn->close();
