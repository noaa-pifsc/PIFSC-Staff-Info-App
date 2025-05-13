<?php
include_once (INCLUDE_PATH."db_credentials.php");

function db_connect() {
  $conn = oci_connect(ORACLE_USERNAME, ORACLE_PASSWORD, ORACLE_HOST."/".ORACLE_INSTANCE);

    if (!$conn) {
		//capture and log the connection error
        $e = oci_error($stid);
		error_log("Oracle error - Code: ".($e['code'] ?? "N/A")." | Message: ".($e['message'] ?? "N/A")." | Offset: ".($e['offset'] ?? "N/A"));
     }
	return $conn;
}
?>