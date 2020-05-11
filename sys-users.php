<?php include('login.php'); ?>
<?php
	if(isset($_POST['kick_user']))
	{
		exec('/usr/bin/pkill -9 -t ' . $_POST['kick_user']);
	}
?>
<!DOCTYPE html>
<html>
	<head>
		<title>Logged users</title>
		<meta charset="utf-8">
		<link rel="stylesheet" type="text/css" href="theme.css">
		<link rel="stylesheet" type="text/css" href="menu.css">
		<?php include 'favicon.php'; ?>
		<style type="text/css">
			table {
				border: 1px solid #000000;
			}
		</style>
	</head>
	<body>
		<?php include('header.php'); ?>
		<div>
			<?php include('menu.html'); ?>
			<div id="content">
				<h1>Logged users</h1>
				<form action="sys-users.php" method="post">
					<table>
						<tr><th>User</th><th>Term</th><th>Date</th><th>IP</th></tr>
						<?php echo shell_exec('./shell.sh logged_users'); ?>
					</table>
				</form>
			</div>
		</div>
	</body>
</html>