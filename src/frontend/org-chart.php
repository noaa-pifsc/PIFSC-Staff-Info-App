<?php

	//include the php file that defines the includes directory path:
	include("/usr/src/app/staff-info-app/include_path.php");

	//include the php file that connects to the Oracle database
	include(PROJECT_FOLDER_PATH."org_chart_class.php");

	//create the new org_chart class object
	$org_chart = new org_chart();

	//generate and display the HTML page content
	echo $org_chart->generate_html_page_content();
	
	//cleanup the $org_chart object
	unset ($org_chart);

?>