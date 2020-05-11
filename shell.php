<?php include('prevent-direct.php'); ?>
<?php include('login.php'); ?>
<?php
	// bandwidth usage
	if(isset($_GET['bwusage']))
	{
		echo shell_exec('./shell.sh bwusage ' . $_GET['interface'] . ' "' . $_GET['name'] . '"');
		exit();
	}

	// wifi
	if(isset($_GET['wifi']))
	{
		echo '<table><tr><th>Name</th><th>MAC</th><th>Channel</th><th>Range</th></tr>';
		echo shell_exec('./shell.sh wifi list-aps');
		echo '</table>';
		exit();
	}

	// real-time shellscript output provider (for apt)
	if(!isset($_GET['shell-command']))
	{
		goto_home();
		exit();
	}

	$a = popen('./shell.sh ' . $_GET['shell-command'], 'r');

	while($b = fgets($a, 2048))
	{
		echo $b . "<br>\n";
		ob_flush();
		flush();
	}

	pclose($a);
?>