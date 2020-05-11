<?php include('login.php'); ?>
<!DOCTYPE html>
<html>
	<head>
		<title>Bandwidth usage</title>
		<meta charset="utf-8">
		<link rel="stylesheet" type="text/css" href="theme.css">
		<link rel="stylesheet" type="text/css" href="menu.css">
		<?php include 'favicon.php'; ?>
		<script type="text/javascript" src="jquery.js"></script>
		<style type="text/css">
			.bar-out {
				height: 5px;
				width: 100px;
				border: 1px solid #000000;
				margin: 0;
				padding: 0;
			}
			.bar {
				left: 0;
				height: 5px;
				/* add width: Npx; to local styles */
				margin: 0;
				padding: 0;
			}
			#explantation {
				width: 350px;
			}
		</style>
		<script type="text/javascript">
			$(document).ready(
				function()
				{
					$('#bar_eth').load('shell.php?bwusage=1&interface=eth&name=Ethernet+gateway');
					$('#bar_wifi-in').load('shell.php?bwusage=1&interface=wifi-in&name=WiFi+gateway');
					$('#bar_1gbps').load('shell.php?bwusage=1&interface=1gbps&name=1Gbps');
					$('#bar_100mbps').load('shell.php?bwusage=1&interface=100mbps&name=100Mbps');
					$('#bar_wifi').load('shell.php?bwusage=1&interface=wifi&name=WiFi');
					bars_refresh();
				}
			);

			function bars_refresh()
			{
				setTimeout(
					function()
					{
						$('#bar_eth').load('shell.php?bwusage=1&interface=eth&name=Ethernet+gateway');
						$('#bar_wifi-in').load('shell.php?bwusage=1&interface=wifi-in&name=WiFi+gateway');
						$('#bar_1gbps').load('shell.php?bwusage=1&interface=1gbps&name=1Gbps');
						$('#bar_100mbps').load('shell.php?bwusage=1&interface=100mbps&name=100Mbps');
						$('#bar_wifi').load('shell.php?bwusage=1&interface=wifi&name=WiFi');
						bars_refresh();
					}
				, 600)
			}
		</script>
	</head>
	<body>
		<?php include('header.php'); ?>
		<div>
			<?php include('menu.html'); ?>
			<div id="content">
				<h1>Bandwidth usage</h1>
				<table>
					<tr><th></th><th>Received</th><th>Transmitted</th></tr>
					<tr id="bar_eth"></tr>
					<tr><td>PPP gateway</td><td colspan="2"><span style="color: #ff0000;">Not implemented!</span></td></tr>
					<tr id="bar_wifi-in"></tr>
					<tr id="bar_1gbps"></tr>
					<tr id="bar_100mbps"></tr>
					<tr id="bar_wifi"></tr>
				</table>
				<h1>Explanation</h1>
				<div id="explantation">
					<table>
						<tr><td rowspan="2" style="text-align: right;">[LAN host]</td><td style="text-align: center;">&#8592; transmitted &#9472;&#9472;&#9472;&#9472;</td><td rowspan="2" style="text-align: left;">[router]</td></tr>
						<tr>		<td style="text-align: center;">&#9472;&#9472;&#9472;&#9472;&#9472; received &#8594;</td>						</tr>
						<tr><td colspan="3"><hr></td></tr>
						<tr><td rowspan="2" style="text-align: right;">[router]</td><td style="text-align: center;">&#8592; received &#9472;&#9472;&#9472;&#9472;&#9472;&#9472;</td><td rowspan="2" style="text-align: left;">[gateway]</td></tr>
						<tr>		<td style="text-align: center;">&#9472;&#9472;&#9472;&#9472;&#9472; transmitted &#8594;</td>					</tr>
					</table>
				</div>
			</div>
		</div>
	</body>
</html>