<?php
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
if (empty($data['nome']) || empty($data['email']) || empty($data['senha'])) {
    echo json_encode(['success' => false, 'message' => 'Todos os campos são obrigatórios']);
    exit;
}

$nome = $conn->real_escape_string($data['nome']);
$email = $conn->real_escape_string($data['email']);
$senha = password_hash($data['senha'], PASSWORD_DEFAULT);

// Verifica se email já existe
$check = $conn->prepare("SELECT email FROM usuario WHERE email = ?");
$check->bind_param("s", $email);
$check->execute();
$check->store_result();

if ($check->num_rows > 0) {
    echo json_encode(['success' => false, 'message' => 'Email já cadastrado']);
    exit;
}

$sql = "INSERT INTO usuario (nome, email, senha) VALUES (?, ?, ?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("sss", $nome, $email, $senha);

if ($stmt->execute()) {
    echo json_encode(['success' => true, 'message' => 'Usuário cadastrado com sucesso!', 'redirect' => 'index.html']);
} else {
    echo json_encode(['success' => false, 'message' => 'Erro ao cadastrar usuário: ' . $stmt->error]);
}

$stmt->close();
$conn->close();
?>