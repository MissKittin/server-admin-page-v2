<?php include('login.php'); ?>
<?php
	function getlog($file)
	{
		$rfile = fopen($file, "r") or die('Unable to open file!</pre></div></body></html>');
		echo fread($rfile,filesize($file));
		fclose($rfile);
	}
?>
<!DOCTYPE html>
<html>
	<head>
		<title>Logs</title>
		<meta charset="utf-8">
		<link rel="stylesheet" type="text/css" href="theme.css">
		<link rel="stylesheet" type="text/css" href="menu.css">
		<?php include 'favicon.php'; ?>
		<style type="text/css">
			a, a:hover, a:visited {
				text-decoration: none;
				color: #0000ff;
			}
		</style>
	</head>
	<body>
		<?php include('header.php'); ?>
		<div>
			<?php include('menu.html'); ?>
			<div id="content">
				<h1>Logs</h1>
				<div id="log-links">
					<a href="sys-logs.php?log=auth.log">auth.log</a><br>
					<a href="sys-logs.php?log=acpid-suspend.log">acpid-suspend.log</a><br>
					<a href="sys-logs.php?cmd=last">last</a><br>
					<a href="sys-logs.php?log=checkroot">checkroot</a><br>
					<a href="sys-logs.php?log=checkfs">checkfs</a><br>
					<a href="sys-logs.php?log=notify-daemon.log">notify-daemon.log</a><br>
					<a href="sys-logs.php?log=php.log">php.log</a><br>
					<a href="sys-logs.php?log=samba.log">samba.log</a><br>
					<a href="sys-logs.php?log=wicd.log">wicd.log</a><br>

					<a href="sys-logs.php?cmd=dmesg">dmesg</a><br>
					<a href="sys-logs.php?cmd=lspci">lspci</a><br>
					<!-- <a href="sys-logs.php?cmd=lsusb">lsusb</a><br> -->
					<a href="sys-logs.php?cmd=lsmod">lsmod</a><br>
					<a href="sys-logs.php?cmd=lsblk">lsblk</a><br>
					<a href="sys-logs.php?cmd=ethtool">ethtool</a><br>
				</div>
				<div id="log-content">
					<pre>
<?php
	if(isset($_GET['log']))
		switch($_GET['log'])
		{
			case 'auth.log':
				getlog('/var/log/auth.log');
				break;
			case 'acpid-suspend.log':
				getlog('/tmp/.acpid-suspend.log');
				break;
			case 'checkroot':
				getlog('/var/log/fsck/checkroot');
				break;
			case 'checkfs':
				getlog('/var/log/fsck/checkfs');
				break;
			case 'php.log':
				getlog('/tmp/.php.log');
				break;
			case 'notify-daemon.log':
				getlog('/tmp/.notify-daemon.log');
				break;
			case 'samba.log':
				echo shell_exec('smbstatus') . '<hr>';
				getlog('/tmp/.samba.log');
				break;
			case 'wicd.log':
				getlog('/var/log/wicd/wicd.log');
				break;
		}
	if(isset($_GET['cmd']))
		switch($_GET['cmd'])
		{
			case 'dmesg':
				echo shell_exec('/bin/dmesg');
				break;
			case 'last':
				echo shell_exec('/usr/bin/last');
				break;
			case 'lspci':
				echo shell_exec('/usr/bin/lspci');
				echo "</pre><hr><pre>";
				echo shell_exec('/usr/bin/lspci.bin -vvv | sed -e "s/</(/g" | sed -e "s/>/)/g"');
				break;
			case 'lsusb':
				echo shell_exec('/bin/su -c "/usr/local/bin/lsusb"');
				echo "</pre><hr><pre>";
				echo shell_exec('/bin/su -c "/usr/local/bin/lsusb -v"');
				break;
			case 'lsmod':
				echo shell_exec('/bin/lsmod');
				break;
			case 'lsblk':
				echo shell_exec('/bin/lsblk');
				break;
			case 'ethtool':
				echo shell_exec('./shell.sh ethtool');
				break;
		}
?>
					</pre>
				</div>
			</div>
		</div>
	</body>
</html>