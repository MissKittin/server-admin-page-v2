<?php include('prevent-direct.php'); prevent_direct('login-form.php'); ?>
<!DOCTYPE html>
<html>
	<head>
		<title>Router Login</title>
		<meta charset="utf-8">
		<link rel="stylesheet" type="text/css" href="theme.css">
		<?php include 'favicon.php'; ?>
	</head>
	<body>
		<div>
			<h1>Router Login</h1>
			<form action="." method="post">
				Username: <input type="text" name="user"><span id="hostname">@<?php echo $_SERVER['HTTP_HOST']; ?></span><br>
				Password: <input type="password" name="password"><br>
				<input type="submit" value="Login">
			</form>
			<br>
			<?php echo shell_exec('./shell.sh check-internet'); ?>
		</div>
	</body>
</html>