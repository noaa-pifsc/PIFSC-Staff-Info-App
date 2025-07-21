<?php

//include the php file that connects to the Oracle database
include(INCLUDE_PATH."staff-directory/db_connect.php");

//include the php file that generates shared web elements
include(INCLUDE_PATH."staff-directory/shared_web_elements.php");


//class to provide the functionality required for the PIFSC staff directory
class staff_directory
{
	
	
	//private class properties
	private $oracle_db;
	private $db_error_exists;
	private $sort_column;
	
	//constructor method
	function __construct ($sort_column)
	{
		$this->sort_column = $sort_column;
		
		//initialize the variable to track if a database error occurred
		$this->db_error_exists = false;

		//connect to the Oracle DB
		if (db_connect($oracle_db))
		{
			$this->oracle_db = $oracle_db;
		}		
		else
		{
			//the DB connection could not be established
			$this->db_error_exists = true;
		}		
	}
	
	//destructor method
	function __destruct ()
	{
		//unset the class properties
		unset ($this->oracle_db);
		unset ($this->db_error_exists);
		unset ($this->sort_column);
	}

	//accessor method
	function get_db_error_exists()
	{
		return $this->db_error_exists;
	}


	//function to generate the staff directory HTML content based on the $type parameter 
	// $type:
	//    alpha - sort by staff name
	//    div - sort by division
	//    loc - sort by staff location
	//    email - sort by email
	//    phone - sort by phone, lastname
	//    title - sort by position title, lastname
	//the $content_string variable will contain the HTML content for the page
	function generate_staff_directory_html (&$content_string)
	{
		//initialize the variable to store the generated HTML content
		$content_string = '';
		
		//initialize the $return_value, true indicates the function was successful, false indicates an error condition
		$return_value = true;

		//define the sort order of the result set based on the $type parameter value
		if (!isset($this->sort_column))
			$order_by = "lastname asc";
		else if ($this->sort_column == "loc")
			$order_by = "worksite, lastname asc";
		else if ($this->sort_column == "div")
			$order_by = "div_abbr, program, lastname asc";
		else if ($this->sort_column == "alpha")
			$order_by = "lastname desc";
		else if ($this->sort_column == "email")
			$order_by = "email_addr asc";
		else if ($this->sort_column == "phone")
			$order_by = "workph1 asc, lastname asc";
		else if ($this->sort_column == "title")
			$order_by = "position_name, lastname asc";
		else
		{
			$content_string = "<span class=\"page_content_on_background\">Error: You used an invalid link, you can access the PIFSC Staff Directory by following <a class=\"mail_link\" href=\"./staff-directory.php\">this link</a></span>";
			
			//a valid sort order argument was not specified
			$return_value = false;
		}
		
		if ($return_value)
		{
			$SQL = "SELECT lastname, firstname, email_addr, workph1,
			worksite, room_num, div_name, div_abbr,
			program,
			position_name,
			workph2,
			--calculated field to display division/program if they are defined
			(CASE 
			WHEN div_abbr IS NOT NULL AND program IS NOT NULL THEN div_abbr||' -'||program 
			WHEN div_abbr IS NULL AND program IS NOT NULL THEN program
			WHEN div_abbr IS NOT NULL AND program IS NULL THEN div_abbr
			ELSE NULL END) DIV_PROG
			FROM picadm.vw_nonpii_pers_v
			WHERE NOT worksite = 'DC'
			AND NOT worksite = 'WPRFMC'
			AND NOT worksite like 'PIR%'
			AND NOT worksite like 'NOAA-PRC'
			ORDER BY ".$order_by;
			
			//execute the query
			if ($return_value = $this->oracle_db->query($SQL, $stid, $return_id))
			{
				//the query was successful
	//				print "The select query was successful<BR>";
				
				$content_string .= "<span class=\"page_content_on_background\">Click the given column header to sort the staff directory by the corresponding column values.</span>";
				
				$content_string .= "<span class=\"page_content_on_background\">For corrections, contact <a class=\"mail_link\" href=\"mailto:Jeffrey.Jones@noaa.gov\">Jeffrey.Jones@noaa.gov</a></span>";
				$content_string .= "<span class=\"spacer\"></span>";

				
				//construct the HTML table header:
				$table_string = "<table class=\"staff_directory display\">";
				$table_string .= "<thead><tr>
				<th class=\"column_heading\"><a href=\"./staff-directory.php?type=alpha\">NAME</a></th>
				<th class=\"column_heading\"><a href=\"./staff-directory.php?type=email\">EMAIL</a></th>
				<th class=\"column_heading\"><a href=\"./staff-directory.php?type=phone\">PHONE</a></th>
				<th class=\"column_heading\"><a href=\"./staff-directory.php?type=div\">DIVISION</a></th>
				<th class=\"column_heading\"><a href=\"./staff-directory.php?type=loc\">LOCATION</a></th>
				<th class=\"column_heading\"><a href=\"./staff-directory.php?type=title\">POSITION TITLE</a></th></tr>
				</thead><tbody>\n";
					
				while ($row = $this->oracle_db->fetch($stid)) 
				{
	//					echo "the value of the current row is: " . var_export($row, true)."<BR>\n";
					//loop through the results and format/add them to the display table
				
					$table_string .= "<tr><td><span>".$row['LASTNAME'].", ".$row['FIRSTNAME']."</span></td>
					<td><span><a href=\"mailto:".$row['EMAIL_ADDR']."\">".$row['EMAIL_ADDR']."</a></span></td>
					<td><span>".((!is_null($row['WORKPH1'])) ? "<a href=\"tel:".$row['WORKPH1']."\">".$row['WORKPH1']."</a>": '')."<br>".((!is_null($row['WORKPH2'])) ? "<a href=\"tel:".$row['WORKPH2']."\">".$row['WORKPH2']."</a>": '')."</span></td>
					<TD><span>".$row['DIV_PROG']."</span></td>
					<td><span>".$row['WORKSITE']."<br>".$row['ROOM_NUM']."</span></td>
					<td><span>".$row['POSITION_NAME']."</span></td> </tr>";
				}

				//end the html table:
				$table_string .= "\n</tbody>\n</table>\n";

				//add the image link:
				$content_string .= $table_string;
				
				//add the image/top link
				$content_string .= "\n<div class=\"center_content\"><a class=\"top_link\" href=\"#top\"><img src=\"./img/blue_arrow.gif\" border=\"0\"></a></div>";
				
			}
			else
			{
				$this->db_error_exists = true;
				
				//log the query parsing database error:
				$e = oci_error($stid);
				//log the Oracle error message:
				error_log("Oracle error - Code: ".($e['code'] ?? "N/A")." | Message: ".($e['message'] ?? "N/A")." | Offset: ".($e['offset'] ?? "N/A"));

				$content_string = "<span class=\"page_content_on_background\">Error: we're experiencing technical difficulties, please try again later</span>";
			}
		}

		//wrap the content_string in a div that includes the horizontally repeating background image
		$content_string = "<div class=\"background-image\">\n".$content_string."\n</div>";
		
		return $return_value;
	}
	
	
	
	function generate_html_page_content ()
	{
		$this->generate_staff_directory_html($content_string);
		
		
		//wrap the $content_string in the html for the page regardless if it's an error or the org chart content:
		return "<!DOCTYPE html>
	<HEAD>
		<META HTTP-EQUIV=\"Pragma\" CONTENT=\"no-cache\"><META HTTP-EQUIV=\"Expires\" CONTENT=\"-1\">
		<TITLE>PIFSC Staff Directory</TITLE>
		<link rel=\"stylesheet\" href=\"style/staff_dir.css\">
		<link rel=\"stylesheet\" href=\"style/shared_styles.css\">
		<link rel=\"SHORTCUT ICON\" href=\"./img/noaa_sm.jpg\" />
	</HEAD>
	<BODY>
	".generate_navigation_bar ("staff-directory")."
	<div class=\"page_heading\">PIFSC Staff Directory</div>
".$content_string."
	</BODY>";
		
	}
	
}


?>