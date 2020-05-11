<?php include('login.php'); ?>
<?php
	if(isset($_POST['pptp-login']))
	{
		// set pptp
		shell_exec('./shell.sh vpn set pptp login ' . $_POST['pptp-login']);
		shell_exec('./shell.sh vpn set pptp password ' . $_POST['pptp-password']);
	}
	if(isset($_POST['l2tp-login']))
	{
		// set l2tp
		shell_exec('./shell.sh vpn set l2tp login ' . $_POST['l2tp-login']);
		shell_exec('./shell.sh vpn set l2tp password ' . $_POST['l2tp-password']);
		shell_exec('./shell.sh vpn set l2tp serverpassword ' . $_POST['l2tp-main-password']);
	}
?>
<!DOCTYPE html>
<html>
	<head>
		<title>VPN</title>
		<meta charset="utf-8">
		<link rel="stylesheet" type="text/css" href="theme.css">
		<link rel="stylesheet" type="text/css" href="menu.css">
		<?php include 'favicon.php'; ?>
	</head>
	<body>
		<?php include('header.php'); ?>
		<div>
			<?php include('menu.html'); ?>
			<div id="content">
				<h1>VPN</h1>
				<h3>PPTP</h3>
				<form action="net-vpn.php" method="post">
					Login: <input type="text" name="pptp-login" value="<?php echo shell_exec('./shell.sh vpn get pptp login'); ?>" required="required"><br>
					Change user's password: <input type="password" name="pptp-password"><br>
					<input type="submit" value="Set">
				</form>
				<h3>L2TP</h3>
				<form action="net-vpn.php" method="post">
					Login: <input type="text" name="l2tp-login" value="<?php echo shell_exec('./shell.sh vpn get l2tp login'); ?>" required="required"><br>
					Change user's password: <input type="password" name="l2tp-password"><br>
					Change server password: <input type="password" name="l2tp-main-password" required><br>
					<input type="submit" value="Set">
				</form>
			</div>
		</div>
	</body>
</html>