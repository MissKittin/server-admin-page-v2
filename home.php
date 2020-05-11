<?php include('prevent-direct.php'); prevent_direct('home.php'); ?>
<?php include('login.php'); ?>
<!DOCTYPE html>
<html>
	<head>
		<title>Router</title>
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
				<h1>General info</h1>
				<!-- 
				Default gateway: <?php /* echo shell_exec('./shell.sh default-gateway'); */ ?><br>
				Gateway #1 eth0 xxx.xxx.xxx.xxx<br>
				Link available: yes<br>
				Default gateway: yes<br>
				Internet connection: yes, outside IP: xxx.xxx.xxx.xxx<br>
				Received 40GB, transmitted 1GB<br>
				<br>
				Gateway #2 ppp0 xxx.xxx.xxx.xxx<br>
				Device available: yes<br>
				Link available: yes RANGE_ICON<br>
				Default gateway: no<br>
				Internet connection: yes, outside IP: xxx.xxx.xxx.xxx<br>
				SMS service available: yes<br>
				Received 10GB, transmitted 2GB<br>
				Data used: 50% 10GB/20GB
				<div style="width: 100px; height: 3px; border: 1px solid #000000;">
					<div style="width: 50px; height: 3px; background-color: #999900;"></div>
				</div>
				<br>
				Gateway #3 ppp1 xxx.xxx.xxx.xxx banned<br>
				Device available: yes<br>
				Link available: no IIII<br>
				Default gateway: no<br>
				Internet connection: no<br>
				SMS service available: yes<br>
				Received 0kB, transmitted 0kB<br>
				Data used: 100% 20GB/20GB
				<!-- <button type="submit" name="net-reset" value="ppp1">Reset data status</button>
				<button type="submit" name="net-change" value="ppp1">Change status</button>
				<button type="submit" name="net-update" value="ppp1">Update data status</button> -->
				<!-- <div style="width: 100px; height: 3px; border: 1px solid #000000;">
					<div style="width: 100px; height: 3px; background-color: #ff0000;"></div>
				</div>
				-->

				<?php echo shell_exec('./shell.sh dashboard-info'); ?>
				<?php include('notifications.php'); ?>
			</div>
		</div>
	</body>
</html>