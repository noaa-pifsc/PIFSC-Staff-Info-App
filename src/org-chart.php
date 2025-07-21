<?php

	//include the php file that defines the includes directory path:
	include("/usr/src/app/staff-directory/include_path.php");

	//include the php file that connects to the Oracle database
	include(INCLUDE_PATH."staff-directory/org_chart_class.php");
	$org_chart = new org_chart();

	//generate and display the HTML page content
	echo $org_chart->generate_html_page_content();
	
	//cleanup the $org_chart object
	unset ($org_chart);

?>