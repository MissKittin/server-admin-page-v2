<?php
	// router script
	// shell.sh denied
	// menu.html in address bar denied


	/* Router script - filter */

	// hide this script - fake 404
	if(strtok($_SERVER['REQUEST_URI'],  '?') === '/router.php')
	{
		echo '<!DOCTYPE html>
			<html>
				<head>
					<title>'.$_SERVER["HTTP_HOST"].'</title>
					<meta http-equiv="refresh" content="0; url=.">
				</head>
			</html>
		';
		exit();
	}

	// 404 handle
	/*not file exist cut after $CHAR absolute path                           $CHAR */
	if(!file_exists(strtok($_SERVER['DOCUMENT_ROOT'].$_SERVER['REQUEST_URI'], '?')))
	{
		echo '<html>
			<head>
				<title>'.$_SERVER["HTTP_HOST"].'</title>
				<meta http-equiv="refresh" content="0; url=.">
			</head>
		</html>';
		exit();
	}

	// denied file types
	if(preg_match('/\.(?:sh)$/', $_SERVER['REQUEST_URI'])) // if type ****.xxx in url
	{
		echo '<html>
			<head>
				<title><?php echo $_SERVER["HTTP_HOST"]; ?></title>
				<meta http-equiv="refresh" content="0; url=.">
			</head>
		</html>';
		exit();
	}

	// hide menu.html
	if(strtok($_SERVER['REQUEST_URI'],  '?') === '/menu.html')
	{
		echo '<!DOCTYPE html>
			<html>
				<head>
					<title>'.$_SERVER["HTTP_HOST"].'</title>
					<meta http-equiv="refresh" content="0; url=.">
				</head>
			</html>
		';
		exit();
	}

	// abort script - load destination file
	return false;
?>