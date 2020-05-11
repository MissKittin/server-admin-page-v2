<?php include('login.php'); ?>
<?php
	$ALERT='';

	if(isset($_POST['reserve-name']))
	{
		shell_exec('./shell.sh net-reserve add ' . $_POST['reserve-name'] . ' ' . $_POST['reserve-ip'] . ' ' . $_POST['reserve-mac']);
		$ALERT='onload="javacript:reserve(\'' . $_POST['reserve-name'] . '\', \'' . $_POST['reserve-ip'] . '\');"';
	}
	if(isset($_POST['release']))
	{
		$params = explode(' ', $_POST['release']);
		if($params[1] == '')
			$ALERT='onload="javacript:lerror(\'MAC address empty, interrupted\');"';
		else
			shell_exec('./shell.sh net-reserve del ' . $params[2] . ' ' . str_replace('_', '.', $params[0]) . ' ' . $params[1]);
	}

	if(isset($_POST['ban']))
	{
		shell_exec('./shell.sh net-block ban ' . str_replace('_', '.', $_POST['ban']));
		$ALERT='onload="javacript:ban(\'' . str_replace('_', '.', $_POST['ban']) . '\');"';
	}
	if(isset($_POST['unban']))
	{
		shell_exec('./shell.sh net-block unban ' . str_replace('_', '.', $_POST['unban']));
		$ALERT='onload="javacript:unban(\'' . str_replace('_', '.', $_POST['unban']) . '\');"';
	}
?>
<!DOCTYPE html>
<html>
	<head>
		<title>Devices</title>
		<meta charset="utf-8">
		<link rel="stylesheet" type="text/css" href="theme.css">
		<link rel="stylesheet" type="text/css" href="menu.css">
		<?php include 'favicon.php'; ?>
		<style type="text/css">
			tr, td, th {
				border: 1px solid #000000;
			}
			table {
				border-collapse: collapse;
			}
		</style>
		<script type="text/javascript">
			function reserve(device, ip)
			{
				alert(device + " at " + ip + " reserved");
			}
			function ban(device)
			{
				alert(device + " banned");
			}
			function unban(device)
			{
				alert(device + " freed");
			}
			function limit(device)
			{
				alert(device + " limited");
			}
			function lerror(message)
			{
				alert(message);
			}
		</script>
	</head>
	<body <?php echo $ALERT; ?>>
		<?php include('header.php'); ?>
		<div>
			<?php include('menu.html'); ?>
			<div id="content">
				<?php if(isset($_POST['reserve'])) { ?>
					<h1>Reserve</h1>
					<form action="net-devices.php" method="post">
						<?php $params = explode(' ', $_POST['reserve']); ?>
						Device name: <input type="text" name="reserve-name" value="<?php echo $params[2]; ?>" required><br>
						Device IP: <input type="text" name="reserve-ip" value="<?php echo str_replace('_', '.', $params[0]); ?>" required><br>
						Device MAC: <input type="text" name="reserve-mac" value="<?php echo $params[1]; ?>" required><br>
						<input type="submit" value="Reserve">
					</form>
				<?php } else { ?>
					<h1>Devices</h1>
					<form method="post" action="net-devices.php">
						<table>
							<tr><th>Stat</th><th>Hostname</th><th>IP</th><th>MAC</th><th>Reserved</th></tr>
							<?php echo shell_exec('./shell.sh list-devices'); ?>
						</table>
					</form>
					<?php
						if(isset($_GET['details']))
							echo shell_exec('./shell.sh net-reserve details');
						else
							echo '<a href="net-devices.php?details=1" style="text-decoration: none; color: #0000ff;">More details</a>';
					?>
				<?php } ?>
			</div>
		</div>
	</body>
</html>