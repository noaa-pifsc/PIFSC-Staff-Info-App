<?php
 
	//include the php file that defines the includes directory path:
	include("/usr/src/app/staff-directory/include_path.php");

	//include the php file that connects to the Oracle database
	include(INCLUDE_PATH."staff-directory/staff_directory_class.php");

	//specify the sort column value from the specified page parameter
	$staff_directory = new staff_directory((isset($_GET['type'])) ? $_GET['type'] : null);
	
	echo $staff_directory->generate_html_page_content();
	
	unset ($staff_directory);

?>