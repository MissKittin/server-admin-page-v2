<?php include('login.php'); ?>
<!DOCTYPE html>
<html>
	<head>
		<title>Interfaces</title>
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
				<h1>Interfaces</h1>
				<h2>WAN</h2>
					<pre><?php echo shell_exec('./shell.sh interfaces wan'); ?></pre>
					<h3>PPP</h3>
						<pre><?php echo shell_exec('./shell.sh interfaces ppp'); ?></pre>
					<h3>Wifi</h3>
						<pre><?php echo shell_exec('./shell.sh interfaces wifi-in'); ?></pre>
				<h2>LAN</h2>
					<h3>1Gbps</h3>
						<pre><?php echo shell_exec('./shell.sh interfaces 1gbps'); ?></pre>
					<h3>100Mbps</h3>
						<pre><?php echo shell_exec('./shell.sh interfaces 100mbps'); ?></pre>
					<h3>Wifi AP</h3>
						<pre><?php echo shell_exec('./shell.sh interfaces wifi'); ?></pre>
				<h2>VPN</h2>
				<h3>PPTP</h3>
				<pre><?php echo shell_exec('./shell.sh vpn_info pptp'); ?></pre>
				<h3>L2TP</h3>
				<pre><?php echo shell_exec('./shell.sh vpn_info l2tp'); ?></pre><br>
			</div>
		</div>
	</body>
</html>