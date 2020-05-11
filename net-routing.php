<?php include('login.php'); ?>
<!DOCTYPE html>
<html>
	<head>
		<title>Routing & Firewall</title>
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
				<h1>Routing</h1>
				<pre><?php echo shell_exec('./shell.sh net-routing-list route'); ?></pre>
				<hr>
				<pre><?php echo shell_exec('./shell.sh list-iptables-settings routing'); ?></pre>
				<h1>Bridges</h1>
				<pre><?php echo shell_exec('./shell.sh net-routing-list brctl'); ?></pre>
				<h1>Bondings</h1>
				<pre><?php echo shell_exec('./shell.sh net-routing-list bonds'); ?></pre>
				<h1>Firewall</h1>
				<pre><?php echo shell_exec('./shell.sh net-routing-list iptables'); ?></pre>
				<hr>
				<pre><?php echo shell_exec('./shell.sh list-iptables-settings firewall'); ?></pre>
				<h1>ARP table</h1>
				<pre><?php echo shell_exec('./shell.sh net-routing-list arp'); ?></pre><br>
			</div>
		</div>
	</body>
</html>