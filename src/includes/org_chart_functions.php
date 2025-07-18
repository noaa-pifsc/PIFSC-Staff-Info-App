<?php



//function to retrieve the PIFSC organization information in $pifsc_org_info, function returns true if there were no errors and false if there were errors
function get_PIFSC_org_info (&$pifsc_org_info)
{
	global $oracle_db;
	global $db_error_exists;

	//initialize the $return_value, true indicates the function was successful, false indicates an error condition
	$return_value = true;

	$SQL = "SELECT org_id, org_name
	FROM picadm.orgs_v
	WHERE abbr = 'PIFSC'
	AND retired_yn = 'N'";

	//execute the query
	if ($oracle_db->query($SQL, $stid, $return_id))
	{
		//the query was successfully executed

		//attempt to retrieve the first result row
		if (!($pifsc_org_info = $oracle_db->fetch($stid)))
		{
			//there were no records returned by the query
			$return_value = false;
		}
	}
	else
	{
		//the query was unsuccessful
		$return_value = false;

	}

	return $return_value;
	
}

//function to retrieve and return the director's office information
function get_do_org_info ($pifsc_org_id, &$do_org_info)
{
	global $oracle_db;
	global $db_error_exists;

	//initialize the $return_value, true indicates the function was successful, false indicates an error condition
	$return_value = true;

	$SQL = "SELECT org_id, org_name
	FROM picadm.orgs_v
	WHERE parent_org_id = :org_id
	AND retired_yn = 'N'";

	$bind_array = array(array(":org_id", $pifsc_org_id));

	//execute the query
	if ($oracle_db->query($SQL, $stid, $return_id, $bind_array))
	{
		//the query was successfully executed

		//attempt to retrieve the first result row
		if (!($do_org_info = $oracle_db->fetch($stid)))
		{
			//there were no records returned by the query
			$return_value = false;
		}
	}
	else
	{
		//the query was unsuccessful
		$return_value = false;
	}

	return $return_value;
}



//function to generate HTML content for the director's office personnel section
function display_do_personnel_content (&$content_string)
{
	
	//initialize the content string variable
	$content_string = '';

	//specify the where clause for the specified organization
	$where_clause = "program = :program_name 
	OR mgt_position = :position_name";
	
	//create the bind array for the specified organization
	$bind_array = array(array(":program_name", 'Dir'), array(":position_name", "Director"));

	//specify the order by clause
	$order_by_clause = "DECODE(mgt_position, 'Director', 1, 'Deputy Director', 2, 3), lastname";
	
	//generate the person content for the given organization
	$return_value = generate_person_content($where_clause, $order_by_clause, $bind_array, $content_string);
	
	return $return_value;
}


//function to generate HTML content for the CIMAR admin personnel section
function cimar_admin_personnel_content (&$content_string)
{
	
	//initialize the content string variable
	$content_string = '';

	//specify the where clause for the specified list of primary key ID values
	$where_clause = "pers_id in (:p1, :p2, :p3, :p4, :p5)";
	
	//create the bind array for the specific list of values
	$bind_array = array(array(":p1", 6449), array(":p2", 6720), array(":p3", 6715), array(":p4", 6708), array(":p5", 6945));

	//specify the order by clause
	$order_by_clause = "position_abbr DESC, lastname";
	
	//generate the person content for the given organization
	$return_value = generate_person_content($where_clause, $order_by_clause, $bind_array, $content_string);
	
	return $return_value;	

}



//function to generate HTML content for the budget and planning personnel section
function div_prog_personnel_content ($do_org_id)
{
	//initialize the content string variable
	$content_string = '';

	global $oracle_db;
	global $db_error_exists;

	//Divisions (Budget and Planning is not really a division):
	//Exclude the ones with persons already listed under Director's Office

	//query for all divisions
	$SQL = "SELECT org_id, org_name, abbr
			FROM picadm.orgs_v
		 WHERE retired_yn = 'N'
			 AND parent_org_id = :org_id
			 AND UPPER(abbr) NOT IN ('BP', 'DO', 'DIR', 'DEPDIR', 'BUD', 'SOCIO','SO','CIMARPIC','SIS', 'HIMB')
		 ORDER BY DECODE(abbr, 'OMI', 1, 'SOD', 2, 'EOD', 3, 'FRMD', 4, 99)";

	 $bind_array = array(array(":org_id", $do_org_id));


	//execute the query
	if ($oracle_db->query($SQL, $division_stid, $return_id, $bind_array))
	{
		//the query was successfully executed

		//loop through the result rows and generate the table row content
		while ($division_row = $oracle_db->fetch($division_stid))
		{

			$content_string .= "		<TD COLSPAN=2 CLASS=\"divisionouter align_top\">
			<TABLE class=\"layout_table\">\n
				<TR><TD CLASS=\"division display_header\">".$division_row['ORG_NAME']."\n				</TD></TR>\n";



			//attempt to generate HTML content for the organization's personnel
			if (org_person_content($division_row['ORG_ID'], $return_string))
			{
				//append the generated content
				$content_string .= $return_string;


				//recursively call the generate the child organizations to generate the content:
				$content_string .= generate_child_orgs ($division_row['ORG_ID']);
			}
			else	//there was a DB error:
				$content_string = db_error_exists();


//			echo "At the end of the current division_row loop, content_string is: <BR>".$content_string."<BR>";

			//this is the end of a division display table, close the table and parent table cell HTML elements:
			$content_string .= "			</TABLE>
			</TD>\n";

		}
	}
	else
	{
		//there was a DB error:
		$content_string = db_error_exists();

	}

	return $content_string;
}



//function to generate the HTML content for the people within the specified organization ($org_id)
function org_person_content ($org_id, &$content_string)
{
	//specify the orderby column alias formula to order the result set	
	$order_by_clause = "DECODE(mgt_position, NULL,
								 DECODE( perstype, 'PIC-Volunteer', 8, 'PIC-Associate', 7, 'PIC-Contracted', 6, DECODE(employer, 'MOP', 5, 'CIMAR', 4, 'AF', 3, 2) )
								 , 1), lastname";

	//specify the where clause for the specified organization
	$where_clause = "org_id = :org_id";
	
	//create the bind array for the specified organization
	$bind_array = array(array(":org_id", $org_id));

	//generate the person content for the given organization
	$return_value = generate_person_content($where_clause, $order_by_clause, $bind_array, $content_string);
	
	return $return_value;
}

//generate the HTML content for the person with information specified by $person_info
function person_row_content($person_info)
{
	return "				<TR><TD class=\"nowrap\">\n
".$person_info['BOLD']." ".$person_info['FIRSTNAME'].". ".$person_info['LASTNAME'].", ".$person_info['POSITION_ABBR']." ".$person_info['EMPLOYER']." ".$person_info['TYPE_ABBR'].$person_info['ENDBOLD']."\n
				</TD></TR>\n";
}

//recursive function that generates the child organizations for the specified parent organization ($parent_org_id)
function generate_child_orgs ($parent_org_id)
{
	global $oracle_db;
	global $db_error_exists;

//	echo "running generate_child_orgs ($parent_org_id)<BR>";

	//query for all child organizations
	$SQL = "SELECT org_id, org_name, org_level
			FROM picadm.orgs_v
			WHERE retired_yn = 'N'
			AND parent_org_id = :org_id
			ORDER BY org_name";
	
	$bind_array = array(array(":org_id", $parent_org_id));
	
	//initialize the content string that will be used to generate the HTML for the current child org
	$content_string = '';
	
	//execute the query
	if ($oracle_db->query($SQL, $stid, $return_id, $bind_array))
	{
		//the query was successfully executed

		//loop through the result rows and generate the table row content
		while ($row = $oracle_db->fetch($stid))
		{
//			echo "The current org_name is: ".$row['ORG_NAME']."<BR>";
			
			//check which type of organization this is:
			switch ($row['ORG_LEVEL'])
			{
				case "PIC Program":
				
					$content_string .= "				<TR><TD>&nbsp;</TD></TR>\n
					<TR><TD CLASS=\"program display_header\">".$row['ORG_NAME']."</TD></TR>\n";
				
				break;
				
				case "PIC Subdivision":

					$content_string .= "			<TR><TD>&nbsp;</TD></TR>\n
				<TR><TD CLASS=\"program display_header\">".$row['ORG_NAME']."\n				</TD></TR>\n";

		
				break;
				
				case "PIC Subprogram":
					$content_string .= "				<TR><TD>&nbsp;</TD></TR>\n
					<TR><TD CLASS=\"subprogram display_header\">".$row['ORG_NAME']."</TD></TR>\n";


				break;

			}

			//attempt to generate HTML content for the organization's personnel
			if (org_person_content($row['ORG_ID'], $return_string))
			{
				//append the generated content
				$content_string .= $return_string;


				//recursively call the generate the child organizations to generate the content:
				$content_string .= generate_child_orgs ($row['ORG_ID']);
			}
			else	//there was a DB error:
				$content_string = db_error_exists();
				
		}
	}
	else
	{
		//there was a DB error:
		$content_string = db_error_exists();
	}
	
	return $content_string;

}


//function that 
function db_error_exists ()
{
	global $db_error_exists;
	
	$db_error_exists = true;

	return "<span class=\"page_content_on_background\">Error: we're experiencing technical difficulties, please try again later</span>";

	
	
}


//general function that generates person content based on the specified $where_clause and $bind_array values.  The $orderby_clause is used to calculate a sort order for the person query
function generate_person_content ($where_clause, $order_by_clause, $bind_array, &$content_string)
{
	global $oracle_db;
	
	//initialize the $content_string that will be used to generate the HTML content
	$content_string = '';

	$SQL = "SELECT pers_id,
	SUBSTR(firstname, 1, 1) firstname, 
	lastname, 
	position_abbr,
	DECODE(employer, 'CIMAR', ' (CI)', 'AF', ' (AF)', 'MOP', ' (MOP)', '') employer,
	DECODE(mgt_position, NULL, '', '<B>') bold,
	DECODE(mgt_position, NULL, '', '</B>') endbold,
	DECODE( perstype, 'PIC-Contracted', ' (c)', 'PIC-Associate', ' (a)','PIC-Volunteer', ' (v)', '') type_abbr
	FROM picadm.view_persons_v
	WHERE $where_clause
	AND emp_status = 'Active'
	AND perstype IN ( 'PIC-Staff', 'PIC-Contracted' )
	ORDER BY $order_by_clause";

	//execute the query
	if ($return_value = $oracle_db->query($SQL, $stid, $return_id, $bind_array))
	{
		//the query was successfully executed

		//loop through the result rows and generate the table row content for each person
		while ($row = $oracle_db->fetch($stid))
		{

			//append the person row content for the current result set row
			$content_string .= person_row_content($row);
		}
	}
	return $return_value;
}


?>
