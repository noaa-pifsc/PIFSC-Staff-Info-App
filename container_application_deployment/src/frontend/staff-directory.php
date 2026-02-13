<?php
 
	//include the php file that defines the includes directory path:
	include("/usr/src/app/include_path.php");

	//include the php file that connects to the Oracle database
	include(PROJECT_FOLDER_PATH."staff_directory_class.php");

	//include the php file that connects to the Oracle database
	include(PROJECT_FOLDER_PATH."process_parameters.php");

	//specify the sort column value from the specified page parameter
	$staff_directory = new staff_directory(get_parameter_value('sort_type'), get_parameter_value('sort_direction'));
	
	echo $staff_directory->generate_html_page_content();
	
	unset ($staff_directory);

?>