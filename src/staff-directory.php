<?php
 
	//include the php file that defines the includes directory path:
	include("/usr/src/app/staff-directory/include_path.php");

	//include the DB credentials file
	include(INCLUDE_PATH."staff-directory/db_credentials.php");

	//include the php file that connects to the Oracle database
	include(INCLUDE_PATH."php-shared-library/db_connect.php");

?>


<HTML><HEAD><TITLE>PIFSC Staff Directory - Full List</TITLE>
<link rel="stylesheet" type="text/css" href="./style/staffdir_style.css" />
<link rel="SHORTCUT ICON" href="./img/noaa_sm.jpg" />
</HEAD><BODY>
<a name="top"></a>
<center>
<span class="page_heading">PIFSC Staff Directory</span>
</center>


<?php


//function to generate the staff directory HTML content based on the $type parameter 
// $type:
//    alpha - sort by staff name
//    div - sort by division
//    loc - sort by staff location
function generate_staff_directory ($type = null)
{
//	echo "running generate_staff_directory($type)<BR>";

	$content_string = '';

	if ($conn = db_connect())
	{
		
		//define the sort order of the result set based on the $type parameter value
		if (!isset($type))
			$sort_order = "lastname asc";
		else if ($type == "loc")
			$sort_order = "worksite, lastname asc";
		else if ($type == "div")
			$sort_order = "div_abbr, program, lastname asc";
		else if ($type == "alpha")
			$sort_order = "lastname desc";
		else
		{
			echo "<span class=\"page_content_on_background\">Error: You used an invalid link, you can access the PIFSC Staff Directory by following the <a class=\"mail_link\" href=\"./staff-directory.php\">link</a></span>";
			exit;
		}
		
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
		ORDER BY ".$sort_order;
		
		//prepare the SQL statement
		$stid = oci_parse($conn, $SQL);
	
		if (!$stid) {
			//log the query parsing database error:
			$e = oci_error($conn);
			//log the Oracle error message:
			error_log("Oracle error - Code: ".($e['code'] ?? "N/A")." | Message: ".($e['message'] ?? "N/A")." | Offset: ".($e['offset'] ?? "N/A"));

			//output generic error message to the user
			echo "<span class=\"page_content_on_background\">Error: we're experiencing technical difficulties, please try again later</span>";
			exit;
		}
		else 
		{
//			echo "Execute the query<BR>";

			$r = oci_execute($stid);
			if (!$r) 
			{
				//the query was not executed successfully

				//capture and log the query error:
				$e = oci_error($stid);
				error_log("Oracle error - Code: ".($e['code'] ?? "N/A")." | Message: ".($e['message'] ?? "N/A")." | Offset: ".($e['offset'] ?? "N/A"));

				//output generic error message to the user
				echo "<span class=\"page_content_on_background\">Error: we're experiencing technical difficulties, please try again later</span>";
				exit;

			}
			else 
			{
				
//				print "The select query was successful<BR>";
				
				$content_string .= "<span class=\"page_content_on_background\">Click the appropriate column header to sort by name, division, or work location.</span>";
				
				$content_string .= "<span class=\"page_content_on_background\">For corrections, contact <a class=\"mail_link\" href=\"mailto:Jeffrey.Jones@noaa.gov\">Jeffrey.Jones@noaa.gov</a></span>";
				$content_string .= "<span class=\"spacer\"></span>";

				
				//construct the HTML table header:
				$table_string = "<center><table id=\"staff_directory\" class=\"display\">";
				$table_string .= "<thead><tr>
				<th align=\"left\"><a href=\"./staff-directory.php?type=alpha\"><span><b><u>NAME</u></b></span></th>
				<th align=\"left\"><span>EMAIL</span></th>
				<th align=\"left\"><span>PHONE</span></th>
				<th align=\"left\"><a href=\"./staff-directory.php?type=div\"><span><b><u>DIVISION</u></b></span></a></th>
				<th align=\"left\"><a href=\"./staff-directory.php?type=loc\"><span><b><u>LOCATION</u></b></span></th>
				<th align=\"left\"><span>POSITION TITLE</span></th></tr>
				</thead><tbody>\n";
					
				while ($row = oci_fetch_array($stid,  OCI_BOTH+OCI_RETURN_NULLS)) 
				{
//					echo "the value of the current row is: " . var_export($row, true)."<BR>\n";
					//loop through the results and format/add them to the display table
				
					$table_string .= "<tr><td><span>$row[0], $row[1]</span></td>
					<td><span><a href=\"mailto:$row[2]\">$row[2]</a></span></td>
					<td><span>$row[3]<br>$row[10]</span></TD>
					<TD><span>$row[11]</span></td>
					<td><span>$row[4]<br>$row[5]</span></td>
					<td><span>$row[9]</span></td> </tr>";
				}

				//end the html table:
				$table_string .= "</tbody></table>";

				//add the image link:
				$content_string .= $table_string;
				
				//add the image/top link
				$content_string .= "<a class=\"top_link\" href=\"#top\"><img src=\"./img/blue_arrow.gif\" border=\"0\"></a>";

				//print the $table_string
				echo $content_string;
				
				//release the database statement from memory
				oci_free_statement($stid);

				//close and unset the database connection
				oci_close($conn);
				unset ($conn);
			}			
		
		}
	}
	else 
	{
		//the database connection could not be created, print out a generic error message
		echo "<span class=\"page_content_on_background\">Error: we're experiencing technical difficulties, please try again later</span>";
	}
}

//call the generate_staff_directory with the $_GET['type'] parameter if it's defined
generate_staff_directory((isset($_GET['type'])) ? $_GET['type'] : null);



?>

</BODY></HTML>
