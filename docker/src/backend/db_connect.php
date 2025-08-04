<?php

//include the oracle_db class for DB interactions
include(SHARED_LIBRARY_FOLDER_PATH."oracle_db.php");

function db_connect(&$oracle_db) {

	error_log ("DEBUG: running db_connect()");
	error_log ("DEBUG: the value of DB_HOST is: ".getenv("DB_HOST"));
	error_log ("DEBUG: the value of DB_SERVICE_NAME is: ".getenv("DB_SERVICE_NAME"));
  
	//connect to the database, do not exit on failure
	$oracle_db = new oracle_db(get_secret('sia_db_username_secret', 'DB_USERNAME'), get_secret('sia_db_password_secret', 'DB_PASSWORD'), getenv("DB_HOST")."/".getenv("DB_SERVICE_NAME"), false);
  
  
	if (!($conn = $oracle_db->is_connected($error_info))) {
		//capture and log the connection error
		error_log("Oracle error - Code: ".($error_info['code'] ?? "N/A")." | Message: ".($error_info['message'] ?? "N/A")." | Offset: ".($error_info['offset'] ?? "N/A"));
	}

	//return true if the connection was successful and false if it was not
	return $conn;
}

//function to return secret database connection values, $secret_name is the name of the docker secret file and $env_var_name is the name of the local development environment variable if this is not implemented in docker swarm 
function get_secret ($secret_name, $env_var_name)
{
//	echo "running get_secret($secret_name)<BR>";
	
	//check for Docker Swarm secret file
	$filePath = '/run/secrets/' . $secret_name;
    if (file_exists($filePath)) {
        return trim(file_get_contents($filePath));
    }
	
	//fallback to an environment variable for local development
	$env_value = getenv($env_var_name);
	if ($env_value !== false)
		return $env_value;
	
    return null; // Or throw an exception
}

?>