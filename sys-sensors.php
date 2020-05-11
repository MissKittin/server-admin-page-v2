<?php include('login.php'); ?>
<!DOCTYPE html>
<html>
	<head>
		<title>Sensors</title>
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
				<h1>Hardware sensors</h1>
				<!-- <table>
					<tr><th>Name</th><th>Value</th></tr> -->
					<pre><?php echo shell_exec('./shell.sh sensors'); ?></pre>
				<!-- </table> -->
			</div>
		</div>
	</body>
</html>