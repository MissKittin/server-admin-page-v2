<?php include('login.php'); ?>
<?php
	$ALERT='';

	if(isset($_POST['port']))
	{
		if($_POST['input-interface'] === $_POST['output-interface'])
			$ALERT='onload="javacript:lerror(\'Input interface cannot be output\');"';
		else
			shell_exec('./shell.sh forward add ' . $_POST['port'] . ' ' . $_POST['protocol'] . ' ' . $_POST['input-interface'] . ' ' . $_POST['destination'] . ' ' . $_POST['output-interface']);
	}
?>
<!DOCTYPE html>
<html>
	<head>
		<title>Port forwarding</title>
		<meta charset="utf-8">
		<link rel="stylesheet" type="text/css" href="theme.css">
		<link rel="stylesheet" type="text/css" href="menu.css">
		<?php include 'favicon.php'; ?>
		<script type="text/javascript">
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
				<h1>Port forwarding</h1>
				<form action="net-forwarding.php" method="post">
					Port: <input type="text" name="port" pattern="[0-9]{1,5}" title="Port number" required><br>
					<input type="radio" name="protocol" value="tcp"> TCP
					<input type="radio" name="protocol" value="udp"> UDP
					<input type="radio" name="protocol" value="tcpudp" checked> Both<br>
					From <select name="input-interface">
						<?php echo shell_exec('./shell.sh generate-interfaces'); ?>
					</select>
					to <select name="output-interface">
						<?php echo shell_exec('./shell.sh generate-interfaces'); ?>
					</select><br>
					Destination: <input type="text" name="destination" pattern="^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$" title="IP address" required><br>
					<input type="submit" value="Set">
				</form>
				<h3>Forwarded ports:</h3>
				<pre><?php echo shell_exec('./shell.sh list-iptables-settings forwarding'); ?></pre>
			</div>
		</div>
	</body>
</html>