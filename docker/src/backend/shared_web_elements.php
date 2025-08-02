<?php

	//function to generate the navigation bar content.  Based on the $current_page_name the link for the corresponding page will be deactivated 
	function generate_navigation_bar ($current_page_name)
	{
		
		$content_string = "<!-- Navigation bar -->
		<div class=\"top-nav\">";
		
		if ($current_page_name == 'org-chart')
		{
			$content_string .= "<a href=\"staff-directory.php\">Staff Directory</a>
			<span class=\"inactive_link\">Org Chart</span>";
		}
		else
		{
			$content_string .= "<span class=\"inactive_link\">Staff Directory</span>
			<a href=\"org-chart.php\">Org Chart</a>";
		}

		$content_string .= "</div>";
		
		return $content_string;
	}


?>