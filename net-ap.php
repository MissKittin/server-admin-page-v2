<?php include('login.php'); ?>
<?php
	if(isset($_POST['ssid']))
	{
		//ssid
		shell_exec('./shell.sh ap set ssid ' . $_POST['ssid']);
		//password
		if($_POST['password'] != '')
			shell_exec('./shell.sh ap set password ' . $_POST['password']);
		//hide ssid
		if(isset($_POST['hide-ssid']))
		{
			if($_POST['hide-ssid'] === 'yes')
				shell_exec('./shell.sh ap set hide-ssid yes');
		}
		else
			shell_exec('./shell.sh ap set hide-ssid no');
		//mode
		shell_exec('./shell.sh ap set mode ' . $_POST['mode']);
		//channel
		shell_exec('./shell.sh ap set channel ' . $_POST['channel']);
		//restart daemon
		shell_exec('./shell.sh ap restart');
	}
?>
<!DOCTYPE html>
<html>
	<head>
		<title>Access Point</title>
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
				<h1>Access Point</h1>
				<form action="net-ap.php" method="post">
					SSID: <input type="text" name="ssid" value="<?php echo shell_exec('./shell.sh ap get ssid'); ?>" required="required"><br>
					Change password: <input type="password" name="password"><br>
					Hide SSID: <input type="checkbox" name="hide-ssid" value="yes" <?php echo shell_exec('./shell.sh ap get hide-ssid'); ?>><br>
					Mode:
					<select name="mode">
						<?php echo shell_exec('./shell.sh ap get mode'); ?>
					</select><br>
					Channel:
					<select name="channel">
						<?php echo shell_exec('./shell.sh ap get channel'); ?>
					</select><br>
					<input type="submit" value="Set">
				</form>
			</div>
		</div>
	</body>
</html>