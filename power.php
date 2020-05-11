<?php include('login.php'); ?>
<?php
	switch($_GET['do'])
	{
		case 'halt':
			shell_exec('halt');
			break;
		case 'reboot':
			shell_exec('reboot');
			break;
		case 'suspend':
			shell_exec('nohup ./shell.sh suspend > /dev/null 2>&1 &');
			break;
	}
?>
<!DOCTYPE html>
<html>
	<head>
		<title>Shutdown</title>
		<meta charset="utf-8">
		<link rel="stylesheet" type="text/css" href="theme.css">
		<?php include 'favicon.php'; ?>
	</head>
	<body>
		<h1>Doing <?php echo $_GET['do']; ?>...</h1>
		You can close tab.
	</body>
</html>