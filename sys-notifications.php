<?php include('login.php'); ?>
<?php
	if(isset($_GET['action']))
	{
		switch ($_GET['action'])
		{
			case 'enable':
				echo shell_exec('./shell.sh notify-daemon-settings set enable ' . $_GET['type'] . ' ' . $_GET['name']);
			break;
			case 'disable':
				echo shell_exec('./shell.sh notify-daemon-settings set disable ' . $_GET['type'] . ' ' . $_GET['name']);
			break;
		}
	}
?>
<!DOCTYPE html>
<html>
	<head>
		<title>Notifications</title>
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
				<h1>Notifications</h1>
				Daemon: <?php echo shell_exec('./shell.sh notify-daemon-settings status');?>
				<?php echo shell_exec('./shell.sh notify-daemon-settings print ' . preg_replace('/\//', '', $_SERVER['SCRIPT_NAME'])); ?>
			</div>
		</div>
	</body>
</html>