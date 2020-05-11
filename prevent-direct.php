<?php
	if(!function_exists('goto_home'))
	{
		function goto_home()
		{
			echo '
				<!DOCTYPE html>
				<html>
					<head>
						<title>Router</title>
						<meta http-equiv="refresh" content="0; url=.">
					</head>
				</html>
			';
		}

		function prevent_direct($name)
		{
			if(strtok($_SERVER['REQUEST_URI'],  '?') === "/$name")
			{
				goto_home();
				exit();
			}
		}
	}

	prevent_direct('prevent-direct.php');
?>