<?php include('prevent-direct.php'); prevent_direct('login.php'); ?>
<?php
	//functions
	function reload()
	{
		echo '
			<!DOCTYPE html>
			<html>
				<head>
					<title>Router</title>
					<meta charset="utf-8">
					<meta name="viewport" content="width=device-width, initial-scale=1">
					<meta http-equiv="refresh" content="0">
					<link rel="stylesheet" type="text/css" href="theme.css">
				</head>
				<body>
					<h1>Loading...</h1>
				</body>
			</html>
		';
	}

	//header
	include('login-config.php');
	session_start();
	if(!isset($_SESSION['logged']))
		$_SESSION['logged']=false;

	//logout
	if(isset($_POST['logout']))
	{
		if($_POST['logout'] == 'logout')
		{
			$_SESSION['logged']=false;
			session_destroy();
			reload();
			exit();
		}
	}

	//logged
	if(isset($_SESSION['logged']) && $_SESSION['logged'])
		$login_method='script_already_logged';

	//login
	switch($login_method)
	{
		case 'multi':
			if(isset($_POST['user']) && isset($_POST['password']))
				for($i=0, $cnt=count($USER); $i<$cnt; $i++)
				{
					if($_POST['user'] === $USER[$i]) // find user
						if($_POST['password'] === $PASSWORD[$i]) // check passwd
						{
							$_SESSION['logged_user']=$USER[$i];
							$_SESSION['logged']=true; // success!!!
							reload();
							exit();
						}
				}
		break;
		case 'script_already_logged':
			//none
		break;
	}
	unset($login_method);


	if(!$_SESSION['logged']) // login form
	{
		include('login-form.php');
		exit();
	}
?>