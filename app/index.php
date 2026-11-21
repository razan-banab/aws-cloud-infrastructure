<?php
// Database configuration
require '/var/www/db-config';

$message = "";

// Check if the form was submitted
if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $user = trim($_POST['username'] ?? '');
    $raw_password = $_POST['password'] ?? '';

    // Basic server-side validation
    if ($user === '' || $raw_password === '') {
        $message = "Username and password are required.";
    } elseif (mb_strlen($user) > 50) {
        $message = "Username must be 50 characters or fewer.";
    } elseif (strlen($raw_password) < 8) {
        $message = "Password must be at least 8 characters.";
    } else {
        // Open connection
        $conn = new mysqli($servername, $username, $password, $dbname);

        // Check connection
        if ($conn->connect_error) {
            $message = "Registration failed. Please try again.";
        } else {
            $conn->set_charset("utf8mb4");

            // Hash password
            $hashed_password = password_hash($raw_password, PASSWORD_DEFAULT);

            // Prepare SQL statement
            $stmt = $conn->prepare("INSERT INTO users (name, password) VALUES (?, ?)");

            if ($stmt === false) {
                $message = "Registration failed. Please try again.";
            } else {
                // Bind parameters
                $stmt->bind_param("ss", $user, $hashed_password);

                // Execute query
                if ($stmt->execute()) {
                    $message = "Registration successful!";
                } else {
                    $message = "Registration failed. Please try again.";
                }

                // Close statement
                $stmt->close();
            }

            // Close connection
            $conn->close();
        }
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Secure User Registration</title>
</head>
<body>
    <h2>Secure Project Registration Form</h2>

    <!-- Form submits to the exact same file -->
    <form method="POST" action="">
        <label>Username:</label><br>
        <input type="text" name="username" maxlength="50" required><br><br>

        <label>Password:</label><br>
        <input type="password" name="password" required><br><br>

        <input type="submit" value="Register">
    </form>

    <!-- Display status message -->
    <p><strong><?php echo htmlspecialchars($message, ENT_QUOTES, 'UTF-8'); ?></strong></p>
</body>
</html>