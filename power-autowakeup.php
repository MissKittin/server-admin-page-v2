<?php include('login.php'); ?>
<?php
	if(isset($_GET['autowakeup-time']))
	{
		shell_exec('./shell.sh autowakeup set-time ' . $_GET['autowakeup-time']);
		if(isset($_GET['autowakeup-enabled']))
		{
			if($_GET['autowakeup-enabled'] === 'yes')
				shell_exec('./shell.sh autowakeup set-enabled yes');
		}
		else
			shell_exec('./shell.sh autowakeup set-enabled no');
	}
?>
<!DOCTYPE html>
<html>
	<head>
		<title>Auto wake-up</title>
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
				<h1>Auto wake-up</h1>
				<?php echo shell_exec('./shell.sh autowakeup get-time'); ?>
				<h3>Set new time</h3>
				<form action="power-autowakeup.php" method="get">
					<input type="text" name="autowakeup-time" pattern="([01]?[0-9]{1}|2[0-3]{1}):[0-5]{1}[0-9]{1}" title="HH:MM" value="<?php echo shell_exec('./shell.sh autowakeup get-time only-time'); ?>"><br>
					Enabled: <input type="checkbox" name="autowakeup-enabled" value="yes" <?php echo shell_exec('./shell.sh autowakeup get-enabled'); ?>><br>
					<input type="submit" value="Set">
				</form>
			</div>
		</div>
	</body>
</html>