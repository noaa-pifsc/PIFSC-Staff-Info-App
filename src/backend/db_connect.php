<?php
//include the DB credentials file
include(PROJECT_FOLDER_PATH."db_credentials.php");

include(SHARED_LIBRARY_FOLDER_PATH."oracle_db.php");

function db_connect(&$oracle_db) {
  
	//connect to the database, do not exit on failure
	$oracle_db = new oracle_db(ORACLE_USERNAME, ORACLE_PASSWORD, ORACLE_HOST."/".ORACLE_INSTANCE, false);
  
  
	if (!($conn = $oracle_db->is_connected($error_info))) {
		//capture and log the connection error
		error_log("Oracle error - Code: ".($error_info['code'] ?? "N/A")." | Message: ".($error_info['message'] ?? "N/A")." | Offset: ".($error_info['offset'] ?? "N/A"));
	}

	//return true if the connection was successful and false if it was not
	return $conn;
}
?>