<?php include('login.php'); ?>
<?php
	if(isset($_POST['add']))
	{
		shell_exec('./shell.sh wifi add ' . $_POST['add'] . ' ' . $_POST['password']);
	}
	if(isset($_POST['connect']))
	{
		shell_exec('./shell.sh wifi connect ' . $_POST['connect']);
	}
	if(isset($_POST['disconnect']))
	{
		shell_exec('./shell.sh wifi disconnect');
	}
?>
<!DOCTYPE html>
<html>
	<head>
		<title>WiFi</title>
		<meta charset="utf-8">
		<link rel="stylesheet" type="text/css" href="theme.css">
		<link rel="stylesheet" type="text/css" href="menu.css">
		<?php include 'favicon.php'; ?>
		<script type="text/javascript" src="jquery.js"></script>
		<style type="text/css">
			tr {
				text-align: center;
			}
		</style>
		<script type="text/javascript">
			$(document).ready(
				function()
				{
					$('#networks-list').load('shell.php?wifi=1');
					list_refresh();
				}
			);
			function list_refresh()
			{
				setTimeout(
					function()
					{
						$('#networks-list').html('<table><tr><th>Name</th><th>MAC</th><th>Channel</th><th>Range</th></tr><tr><td colspan="4">Scanning...</td></tr></table>');
						$('#networks-list').load('shell.php?wifi=1');
						list_refresh();
					}
				, 14400)
			}
			function manual_refresh()
			{
				$('#networks-list').html('<table><tr><th>Name</th><th>MAC</th><th>Channel</th><th>Range</th></tr><tr><td colspan="4">Scanning...</td></tr></table>');
				$('#networks-list').load('shell.php?wifi=1');
			}
		</script>
	</head>
	<body>
		<?php include('header.php'); ?>
		<div>
			<?php include('menu.html'); ?>
			<div id="content">
				<h1>WiFi</h1>
				<form action="net-wifi.php" method="post" >
					<div id="networks-list"><?php /* content is only temporary for layout */ ?>
						<table>
							<tr><th>Name</th><th>MAC</th><th>Channel</th><th>Range</th></tr>
							<tr><td colspan="4">Starting...</td></tr>
						</table>
					</div>
					<br>
					<button name="disconnect" type="submit" value="disconnect">Disconnect</button>
					<input type="button" value="Refresh" onclick="javascript:manual_refresh();">
				</form>
				<?php echo shell_exec('./shell.sh wifi print-connected'); ?>
			</div>
		</div>
	</body>
</html>