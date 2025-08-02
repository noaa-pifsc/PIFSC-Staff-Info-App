<?php 

	//function to connect to an oracle database using the oci library:
	function oracle_connect($username, $password, $host = 'localhost/XE')
	{
		//connect to the $host with the specified $username and $password:
		$conn = @oci_new_connect($username, $password, $host);

		//check if the connection was made successfully:
		if (!$conn)
		{
//			trigger_error("Could not connect to database", E_USER_ERROR);
		}	
		return $conn;
	}


?>