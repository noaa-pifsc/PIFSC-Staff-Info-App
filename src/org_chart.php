<?php

	//include the php file that defines the includes directory path:
	include("/usr/src/app/staff-directory/include_path.php");

	//include the php file that connects to the Oracle database
	include(INCLUDE_PATH."staff-directory/db_connect.php");


//check the parameters
if (!isset($_REQUEST['p_show_all']))
	$p_show_all = 'N';
else
	$p_show_all = $_REQUEST['p_show_all'];



//function to generate HTML content for the director's office personnel section
function display_do_personnel_content ()
{
	$content_string = '';

	global $oracle_db;
	global $db_error_exists;

	//query for the director's office personnel
	$SQL = "SELECT pers_id
				 , DECODE(mgt_position, 'Director', 1, 'Deputy Director', 2, 3) orderby
				 , SUBSTR(firstname, 1, 1) firstname, lastname, NVL(mgt_position, position_name) position
				 , DECODE(mgt_position, NULL, '', '<B>') bold
				 , DECODE(mgt_position, NULL, '', '</B>') endbold
				 , DECODE(employer, 'CIMAR', ' (CI)', 'AF', ' (AF)', 'MOP', ' (MOP)', '') employer
				 , DECODE( perstype, 'PIC-Contracted', ' (c)', '') contracted
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

			$content_string .= "			<TR>\n
				<TD NOWRAP>\n
					".$row['BOLD'].$row['FIRSTNAME'].". ".$row['LASTNAME'].", ".$row['POSITION']." ".$row['EMPLOYER']." ".$row['CONTRACTED']." ".$row['ENDBOLD']."\n
				</TD>\n
			</TR>\n";
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
						 , DECODE( perstype, 'PIC-Contracted', ' (c)', '') contracted
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

			$content_string .= "			<TR>\n
				<TD NOWRAP>\n
					".$row['BOLD'].$row['FIRSTNAME'].". ".$row['LASTNAME'].", ".$row['POSITION_ABBR']." ".$row['EMPLOYER']." ".$row['CONTRACTED']." ".$row['ENDBOLD']."\n
				</TD>\n
			</TR>\n";
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

			$content_string .= "		<TD COLSPAN=2 VALIGN=TOP CLASS=\"divisionouter\">
			<TABLE class=\"layout_table\">\n
				<TR><TD CLASS=\"division\">".$division_row['ORG_NAME']."\n				</TD></TR>\n";

			//add content for the organization's personnel
			$content_string .= org_person_content($division_row['ORG_ID']);

			//query for any subdivisions/programs
			$SQL = "SELECT org_id, org_name, ROW_NUMBER() OVER (ORDER BY org_name) AS row_num
			FROM picadm.orgs_v
			WHERE retired_yn = 'N'
			AND parent_org_id = :org_id";


			$bind_array = array(array(":org_id", $division_row['ORG_ID']));


			//execute the query
			if ($oracle_db->query($SQL, $subdivision_stid, $return_id, $bind_array))
			{
				//the query was successfully executed

				//loop through the result rows and generate the table row content
				while ($subdivision_row = $oracle_db->fetch($subdivision_stid))
				{

					$content_string .= "			<TR><TD>&nbsp;</TD></TR>\n
				<TR><TD CLASS=\"program\">".$subdivision_row['ORG_NAME']."\n				</TD></TR>\n";

					//add content for the organization's personnel
					$content_string .= org_person_content($subdivision_row['ORG_ID']);



					$SQL = "SELECT org_id, org_name, org_level
					FROM picadm.orgs_v
					WHERE retired_yn = 'N'
					AND parent_org_id = :org_id";


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
								$content_string .= "					<TR><TD CLASS=\"program\">";
							}
							else
							{
								$content_string .= "					<TR><TD CLASS=\"subprogram\">";
							}

							$content_string .= $program_row['ORG_NAME']."</TD></TR>\n";

							//add the HTML content for the personnel for the given program
							$content_string .= org_person_content($program_row['ORG_ID']);


							$SQL = "SELECT org_id, org_name
							FROM picadm.orgs_v
							WHERE retired_yn = 'N'
							AND parent_org_id = :org_id";

							$bind_array = array(array(":org_id", $program_row['ORG_ID']));


							//execute the query
							if ($oracle_db->query($SQL, $subprogram_stid, $return_id, $bind_array))
							{
								//the query was successfully executed

								//loop through the result rows and generate the table row content
								while ($subprogram_row = $oracle_db->fetch($subprogram_stid))
								{

									$content_string .= "					<TR><TD>&nbsp;</TD></TR>\n
					<TR><TD CLASS=\"subprogram\">\n".$subprogram_row['ORG_NAME']."\n				</TD></TR>\n";

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
			$content_string .= "				<TR><TD NOWRAP>\n
			".$row['BOLD']." ".$row['FIRSTNAME'].". ".$row['LASTNAME'].", ".$row['POSITION_ABBR']." ".$row['EMPLOYER']." ".$row['TYPE_ABBR'].$row['ENDBOLD']."\n
			</TD></TR>\n";

		}
	}
	else
	{
		$db_error_exists = true;

		$content_string = "<span class=\"page_content_on_background\">Error: we're experiencing technical difficulties, please try again later</span>";

	}


	return $content_string;
}











?>
<HTML>
<HEAD>
	<META HTTP-EQUIV="Pragma" CONTENT="no-cache"><META HTTP-EQUIV="Expires" CONTENT="-1">
	<TITLE>PIFSC Organization Hierarchy</TITLE>
	<link rel="stylesheet" href="style/org_chart.css">
</HEAD>

<BODY>
	<CENTER>
<?php

	//initialize a variable to track if there are database errors
	$db_error_exists = false;

	//connect to the database
	if ($conn = db_connect($oracle_db))
	{


		$SQL = "SELECT org_id, org_name, retired_yn
		FROM picadm.orgs_v
		WHERE abbr = 'PIFSC'
		AND retired_yn = 'N'";

		//execute the query
		if ($oracle_db->query($SQL, $stid, $return_id))
		{
			//the query was successfully executed

			//attempt to retrieve the first result row
			if ($row = $oracle_db->fetch($stid))
			{
				//the result set row was successfully retrieved

				//store the organization name in $org_name
				$pifsc_org_name = $row['ORG_NAME'];
				$pifsc_org_id = $row['ORG_ID'];
				$pifsc_retired = $row['RETIRED_YN'];

			}
			else
			{
				//there were no records returned by the query
				$db_error_exists = true;

				echo "<span class=\"page_content_on_background\">Error: we're experiencing technical difficulties, please try again later</span>";

			}
		}
		else
		{
			$db_error_exists = true;

			echo "<span class=\"page_content_on_background\">Error: we're experiencing technical difficulties, please try again later</span>";

		}
	}
	else
	{
		//could not successfully connect to the DB

		$db_error_exists = true;

		echo "<span class=\"page_content_on_background\">Error: we're experiencing technical difficulties, please try again later</span>";
	}

?>
	<TABLE class="layout_table">
		<TR>
			<TD COLSPAN=8 class="main_layout_cell">
<?php
echo $pifsc_org_name
?>
			</TD>
		</TR>
<?php

	//query for the director's office information:

	if (!$db_error_exists)
	{

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
			if ($row = $oracle_db->fetch($stid))
			{
				//the result set row was successfully retrieved

				//store the director's office organization info
				$do_org_name = $row['ORG_NAME'];
				$do_org_id = $row['ORG_ID'];

			}
			else
			{
				//there were no records returned by the query
				$db_error_exists = true;

				echo "<span class=\"page_content_on_background\">Error: we're experiencing technical difficulties, please try again later</span>";

			}
		}
		else
		{
			$db_error_exists = true;

			echo "<span class=\"page_content_on_background\">Error: we're experiencing technical difficulties, please try again later</span>";

		}





	}

?>
		<TR>
			<TD COLSPAN=2>&nbsp;</TD>
			<TD COLSPAN=4 CLASS="program">
				<TABLE ALIGN=CENTER>
					<TR><TD COLSPAN=2 class="director_office_display_header"><?php echo $do_org_name; ?>
					</TD></TR>
					<TR>
						<TD ALIGN=CENTER VALIGN=TOP >
							<TABLE>
<?php
if (!$db_error_exists)
	echo display_do_personnel_content();
?>
							</TABLE>
						</TD>
					</TR>
				</TABLE>
			</TD>
<?php /* CIMAR box begin */ ?>
			<TD COLSPAN=2 VALIGN=TOP>
				<TABLE ALIGN=CENTER>
					<TR>
						<TD CLASS="program">
							<TABLE>
								<TR>
									<TD CLASS="program">CIMAR</TD>
<?php
if (!$db_error_exists)
	echo cimar_admin_personnel_content();
?>
								</TR>
							</TABLE>
						</TD>
					</TR>
				</TABLE>
			</TD>
<?php /* CIMAR box end */ ?>
		</TR>
		<TR>
			<TD COLSPAN=4>&nbsp;</TD>
			<TD CLASS="lineleft">&nbsp;</TD>
		</TR>
		<TR>
			<TD>&nbsp;</TD>
			<TD CLASS="linetopleft">&nbsp;</TD>
			<TD CLASS="linetop">&nbsp;</TD>
			<TD CLASS="linetopleft">&nbsp;</TD>
			<TD CLASS="linetop">&nbsp;</TD>
			<TD CLASS="linetopleft">&nbsp;</TD>
			<TD CLASS="linetop">&nbsp;</TD>
			<TD CLASS="lineleft">&nbsp;</TD>
		</TR>
		<TR>
<?php
	if (!$db_error_exists)
		echo div_prog_personnel_content($do_org_id);
?>
		</TR>
	</TABLE>
	</CENTER>
	<P>
	<FONT SIZE=-2>Printed on
	<?php
	echo date("m/d/Y H:i");
	?></FONT></P>
</BODY>
</HTML>
