<?php include('login.php'); ?>
<!DOCTYPE html>
<html>
	<head>
		<title>System updates</title>
		<meta charset="utf-8">
		<link rel="stylesheet" type="text/css" href="theme.css">
		<link rel="stylesheet" type="text/css" href="menu.css">
		<?php include 'favicon.php'; ?>
		<style type="text/css">
			#updateobject {
				height: 800px;
				width: 600px;
			}
		</style>
		<script type="text/javascript">
			function update()
			{
				document.getElementById('eol').style.visibility = "hidden";
				document.getElementById('update').style.height="800px";
				document.getElementById('update').style.width="600px";
				document.getElementById("update").innerHTML='<object id="updateobject" type="text/html" data="shell.php?shell-command=apt-update"></object>';
			}
		</script>
	</head>
	<body>
		<?php include('header.php'); ?>
		<div>
			<?php include('menu.html'); ?>
			<div id="content">
				<h1>System updates</h1>
				Last update: 22 May 2018 <button onclick="javascript:update();">Update</button><br><br>
				<span style="font-size: 20px;">
					<?php echo shell_exec('./shell.sh updates'); ?>
				</span><br><br>
				<div id="eol" style="position: absolute; bottom: 0px;">
					<span style="font-weight: bold;">End of life: <?php echo shell_exec('./shell.sh system-eol'); ?></span>
				</div>
				<div id="update">
					<!-- reserved for apt-get update -->
				</div>
			</div>
		</div>
	</body>
</html>