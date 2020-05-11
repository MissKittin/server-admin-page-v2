<?php include('prevent-direct.php'); prevent_direct('notifications.php'); ?>
<?php
	if(isset($_GET['remove-notify']))
	{
		shell_exec('./shell.sh remove-notify ' . $_GET['remove-notify']);
		goto_home();
	}
?>
<div id="notifications">
	<?php
		$notifications=shell_exec('./shell.sh get-notifications');
		if($notifications != '')
		{
			echo '<h1>Notifications</h1>';
			echo "$notifications";
		}
	?>
</div>