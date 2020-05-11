<?php include('login.php'); ?>
<?php
	// helper
	$dot='.';

	// lists
	$daemons_list=array(
				'acpid',
				'dnsmasq',
				'fancontrol',
				'hostapd',
				'isc-dhcp-server',
				'nfs-kernel-server',
				'pptpd',
				'racoon',
				'samba',
				'ssh',
				'wicd'
	);
	$special_daemons_list=array(
					'xl2tpd',
					'firewall.sh',
					'notify-daemon.sh',
					'system-autoupdate.sh'
	);

	// special daemons buttons - replace '.' with ${dot} , array('none') -> no buttons
	$special_daemon_xl2tpd=array('start', 'restart', 'stop');
	${"special_daemon_firewall${dot}sh"}=array('start');
	${"special_daemon_notify-daemon${dot}sh"}=array('start', 'stop');
	${"special_daemon_system-autoupdate${dot}sh"}=array('none');

	// list generator
	function generate_daemons_list()
	{
		global $daemons_list;
		foreach ($daemons_list as $daemon)
		{
			echo '
				<tr>
					<td>'. $daemon . '</td>
					<td>
						<input type="submit" name="' . $daemon . '" value="Start">
						<input type="submit" name="' . $daemon . '" value="Restart">
						<input type="submit" name="' . $daemon . '" value="Stop">
					</td>
					<td>' . shell_exec('./shell.sh check_service ' . $daemon) . '</td>
				</tr>';
		}

		global $special_daemons_list;
		foreach ($special_daemons_list as $daemon)
		{
			echo '
				<tr>
					<td>'. $daemon . '</td>
					<td>';
			global ${"special_daemon_$daemon"};
			foreach(${"special_daemon_$daemon"} as $button)
			{
				if(strpos($daemon, "."))
				{
					// has '.'
					$daemon_name=substr($daemon, 0, strpos($daemon, '.'));
				}
				else
					$daemon_name=$daemon;

				switch($button)
				{
					case 'start':
						echo '<input type="submit" name="' . $daemon_name . '" value="Start"> '; // spaces at end for pretty look
						break;
					case 'restart':
						echo '<input type="submit" name="' . $daemon_name . '" value="Restart"> ';
						break;
					case 'stop':
						echo '<input type="submit" name="' . $daemon_name . '" value="Stop"> ';
						break;
				}
			}

			echo '		</td>
					<td>' . shell_exec('./shell.sh check_special_service ' . $daemon) . '</td>
				</tr>';
		}
	}

	// parser
	foreach($daemons_list as $daemon)
	{
		if(isset($_POST[$daemon]))
			shell_exec("./shell.sh service $daemon " . strtolower($_POST[$daemon]));
	}
	foreach($special_daemons_list as $daemon)
	{
		// for names with .sh
		$daemon_name=substr($daemon, 0, strpos($daemon, '.')); // without .sh
		if(isset($_POST[$daemon_name]))
		{
			shell_exec("./shell.sh special_service $daemon " . strtolower($_POST[$daemon_name]));
		}
		// for names without .sh
		if(isset($_POST[$daemon]))
		{
			shell_exec("./shell.sh special_service $daemon " . strtolower($_POST[$daemon]));
		}
	}
?>
<!DOCTYPE html>
<html>
	<head>
		<title>Daemons</title>
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
				<h1>Daemons</h1>
				<form action="sys-daemons.php" method="post">
					<table>
						<tr>
							<?php generate_daemons_list(); ?>
						</tr>
					</table>
				</form>
			</div>
		</div>
	</body>
</html>