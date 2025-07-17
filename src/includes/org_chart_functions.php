<?php

//function to generate HTML content for the director's office personnel section
function display_do_personnel_content ()
{
	$content_string = '';

	global $oracle_db;
	global $db_error_exists;

	//query for the director's office personnel
	$SQL = "SELECT pers_id
				 , DECODE(mgt_position, 'Director', 1, 'Deputy Director', 2, 3) orderby
				 , SUBSTR(firstname, 1, 1) firstname, lastname, NVL(mgt_position, position_name) position_abbr
				 , DECODE(mgt_position, NULL, '', '<B>') bold
				 , DECODE(mgt_position, NULL, '', '</B>') endbold
				 , DECODE(employer, 'CIMAR', ' (CI)', 'AF', ' (AF)', 'MOP', ' (MOP)', '') employer
				 , DECODE( perstype, 'PIC-Contracted', ' (c)', '') type_abbr
			FROM picadm.vpub_staff_info_v
		 WHERE program = 'Dir'
				OR mgt_position = 'Director'
		 ORDER BY orderby, lastname";


	//execute the query
	if ($oracle_db->query($SQL, $stid, $return_id))
	{
		//the query was successfully executed

		//loop through the result rows and generate the table row content
		while ($row = $oracle_db->fetch($stid))
		{

			//append the person row content for the current result set row
			$content_string .= person_row_content($row);
		}
	}
	else
	{
		//there was a DB error:
		$content_string = db_error_exists();
	}
	return $content_string;
}


//function to generate HTML content for the CIMAR admin personnel section
function cimar_admin_personnel_content ()
{
	$content_string = '';

	global $oracle_db;
	global $db_error_exists;

	//query for the director's office personnel
	$SQL = "SELECT DISTINCT SUBSTR(firstname, 1, 1) firstname, lastname, position_abbr
						 , DECODE(employer, 'CIMAR', ' (CI)', 'AF', ' (AF)', 'MOP', ' (MOP)', '') employer
						 , DECODE(mgt_position, NULL, '', '<B>') bold
						 , DECODE(mgt_position, NULL, '', '</B>') endbold
						 , DECODE( perstype, 'PIC-Contracted', ' (c)', '') type_abbr
					FROM picadm.view_persons_v
				 WHERE pers_id in (6449, 6720, 6715, 6708, 6945)
				 ORDER BY position_abbr DESC, lastname";


	//execute the query
	if ($oracle_db->query($SQL, $stid, $return_id))
	{
		//the query was successfully executed

		//loop through the result rows and generate the table row content
		while ($row = $oracle_db->fetch($stid))
		{

			$content_string .= person_row_content($row);

		}
	}
	else
	{
		//there was a DB error:
		$content_string = db_error_exists();

	}




	return $content_string;
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

			//add content for the organization's personnel
			$content_string .= org_person_content($division_row['ORG_ID']);


			//recursively process each of the subdivisions, programs, subprograms for the current division:
			$content_string .= generate_child_orgs ($division_row['ORG_ID']);


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
function org_person_content ($org_id)
{
	global $oracle_db;
	global $db_error_exists;
	
	$return_string = '';

//	echo "running org_person_content($org_id)<BR>";

	$SQL = "SELECT pers_id
						 , DECODE(mgt_position, NULL,
								 DECODE( perstype, 'PIC-Volunteer', 8, 'PIC-Associate', 7, 'PIC-Contracted', 6, DECODE(employer, 'MOP', 5, 'CIMAR', 4, 'AF', 3, 2) )
								 , 1) orderby
						 , SUBSTR(firstname, 1, 1) firstname, lastname, position_abbr
						 , DECODE(employer, 'CIMAR', ' (CI)', 'AF', ' (AF)', 'MOP', ' (MOP)', '') employer
						 , DECODE(mgt_position, NULL, '', '<B>') bold
						 , DECODE(mgt_position, NULL, '', '</B>') endbold
						 , DECODE( perstype, 'PIC-Contracted', ' (c)', 'PIC-Associate', ' (a)','PIC-Volunteer', ' (v)', '') type_abbr
					FROM picadm.view_persons_v
				 WHERE org_id = :org_id
					 AND emp_status = 'Active'
					 AND perstype IN ( 'PIC-Staff', 'PIC-Contracted' )
				 ORDER BY orderby, lastname";

	$bind_array = array(array(":org_id", $org_id));





	//execute the query
	if ($oracle_db->query($SQL, $stid, $return_id, $bind_array))
	{
		//the query was successfully executed

		//loop through the result rows and generate the table row content for each person
		while ($row = $oracle_db->fetch($stid))
		{

			//append the person row content for the current result set row
			$return_string .= person_row_content($row);
		}
	}
	else
	{
		//there was a DB error:
		$return_string = db_error_exists();

	}


	return $return_string;
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

			//add content for the organization's personnel
			$content_string .= org_person_content($row['ORG_ID']);

			//recursively call the generate the child organizations to generate the content:
			$content_string .= generate_child_orgs ($row['ORG_ID']);

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

?>
