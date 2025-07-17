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
		$db_error_exists = true;

		$content_string = "<span class=\"page_content_on_background\">Error: we're experiencing technical difficulties, please try again later</span>";

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
		$db_error_exists = true;

		$content_string = "<span class=\"page_content_on_background\">Error: we're experiencing technical difficulties, please try again later</span>";

	}




	return $content_string;
}



//function to generate HTML content for the budget and planning personnel section
function div_prog_personnel_content ($do_org_id)
{
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

			//query for any subdivisions/programs
			$SQL = "SELECT org_id, org_name
			FROM picadm.orgs_v
			WHERE retired_yn = 'N'
			AND parent_org_id = :org_id
			ORDER BY org_name";


			$bind_array = array(array(":org_id", $division_row['ORG_ID']));


			//execute the query
			if ($oracle_db->query($SQL, $subdivision_stid, $return_id, $bind_array))
			{
				//the query was successfully executed

				//loop through the result rows and generate the table row content
				while ($subdivision_row = $oracle_db->fetch($subdivision_stid))
				{

					$content_string .= "			<TR><TD>&nbsp;</TD></TR>\n
				<TR><TD CLASS=\"program display_header\">".$subdivision_row['ORG_NAME']."\n				</TD></TR>\n";

					//add content for the organization's personnel
					$content_string .= org_person_content($subdivision_row['ORG_ID']);



					$SQL = "SELECT org_id, org_name, org_level
					FROM picadm.orgs_v
					WHERE retired_yn = 'N'
					AND parent_org_id = :org_id
					order by org_name";


					$bind_array = array(array(":org_id", $subdivision_row['ORG_ID']));

					//execute the query
					if ($oracle_db->query($SQL, $program_stid, $return_id, $bind_array))
					{
						//the query was successfully executed

						//loop through the result rows and generate the table row content
						while ($program_row = $oracle_db->fetch($program_stid))
						{
							$content_string .= "				<TR><TD>&nbsp;</TD></TR>\n";

							if ($program_row['ORG_LEVEL'] == "PIC Program")
							{
								$content_string .= "					<TR><TD CLASS=\"program display_header\">";
							}
							else
							{
								$content_string .= "					<TR><TD CLASS=\"subprogram display_header\">";
							}

							$content_string .= $program_row['ORG_NAME']."</TD></TR>\n";

							//add the HTML content for the personnel for the given program
							$content_string .= org_person_content($program_row['ORG_ID']);


							$SQL = "SELECT org_id, org_name
							FROM picadm.orgs_v
							WHERE retired_yn = 'N'
							AND parent_org_id = :org_id
							order by org_name";

							$bind_array = array(array(":org_id", $program_row['ORG_ID']));


							//execute the query
							if ($oracle_db->query($SQL, $subprogram_stid, $return_id, $bind_array))
							{
								//the query was successfully executed

								//loop through the result rows and generate the table row content
								while ($subprogram_row = $oracle_db->fetch($subprogram_stid))
								{

									$content_string .= "					<TR><TD>&nbsp;</TD></TR>\n
					<TR><TD CLASS=\"subprogram display_header\">\n".$subprogram_row['ORG_NAME']."\n				</TD></TR>\n";

									//generate the HTML content for the subprogram personnel
									$content_string .= org_person_content($subprogram_row['ORG_ID']);
								}
							}
							else
							{
								$db_error_exists = true;

								$content_string = "<span class=\"page_content_on_background\">Error: we're experiencing technical difficulties, please try again later</span>";

							}



						}
					}
					else
					{
						$db_error_exists = true;

						$content_string = "<span class=\"page_content_on_background\">Error: we're experiencing technical difficulties, please try again later</span>";

					}
				}

				$content_string .= "			</TABLE>
		</TD>\n";

			}
			else
			{
				$db_error_exists = true;

				$content_string = "<span class=\"page_content_on_background\">Error: we're experiencing technical difficulties, please try again later</span>";

			}

		}
	}
	else
	{
		$db_error_exists = true;

		$content_string = "<span class=\"page_content_on_background\">Error: we're experiencing technical difficulties, please try again later</span>";

	}




	return $content_string;
}




function org_person_content ($org_id)
{
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

	$content_string = '';

	global $oracle_db;
	global $db_error_exists;



	//execute the query
	if ($oracle_db->query($SQL, $stid, $return_id, $bind_array))
	{
		//the query was successfully executed

		//loop through the result rows and generate the table row content for each person
		while ($row = $oracle_db->fetch($stid))
		{

			//append the person row content for the current result set row
			$content_string .= person_row_content($row);
		}
	}
	else
	{
		$db_error_exists = true;

		$content_string = "<span class=\"page_content_on_background\">Error: we're experiencing technical difficulties, please try again later</span>";

	}


	return $content_string;
}


function person_row_content($person_info)
{



	return "				<TR><TD class=\"nowrap\">\n
".$person_info['BOLD']." ".$person_info['FIRSTNAME'].". ".$person_info['LASTNAME'].", ".$person_info['POSITION_ABBR']." ".$person_info['EMPLOYER']." ".$person_info['TYPE_ABBR'].$person_info['ENDBOLD']."\n
				</TD></TR>\n";


}



?>
