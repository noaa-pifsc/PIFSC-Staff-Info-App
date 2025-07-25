<?php
//include the php file that connects to the Oracle database
include(INCLUDE_PATH."staff-info-app/db_connect.php");

//include the php file that generates shared web elements
include(INCLUDE_PATH."staff-info-app/shared_web_elements.php");

//class to provide the functionality required for the PIFSC organization chart
class org_chart
{
	//private class properties
	private $oracle_db;
	private $db_error_exists;
	private $tooltip_data = array();	
		
	//constructor method
	function __construct ()
	{
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
		unset ($this->tooltip_data);
	}

	//accessor method
	function get_db_error_exists()
	{
		return $this->db_error_exists;
	}

	//function to mark that a database error occurred and to output the information to the user
	function show_db_error_message ()
	{
		//set the db_error_exists flag
		$this->db_error_exists = true;

		//return the HTML content to indicate there is an error
		return "<p class=\"error_message\"><span class=\"error_bold\">Error:</span> we're experiencing technical difficulties, please try again later</p>";
	}
	

	//function to retrieve organization name and ID in the $org_info variable
	//the function returns true when the function was executed successfully and false when it was not successful
	function get_org_info ($where_clause, $bind_array, &$org_info)
	{
		//initialize the $return_value, true indicates the function was successful, false indicates an error condition
		$return_value = true;

		//generate the SELECT query for the organization information
		$SQL = "SELECT org_id, org_name
		FROM picadm.orgs_v
		WHERE $where_clause";

		//execute the query
		if ($return_value = $this->oracle_db->query($SQL, $stid, $return_id, $bind_array))
		{
			//the query was successfully executed

			//attempt to retrieve the first result row
			if (!($org_info = $this->oracle_db->fetch($stid)))
			{
				//there were no records returned by the query
				$return_value = false;
			}
		}

		//return true if the method was successful and false if it was not
		return $return_value;
	}
	
	//function to retrieve the PIFSC organization information in $pifsc_org_info, function returns true if there were no errors and false if there were errors
	function get_PIFSC_org_info (&$pifsc_org_info)
	{
		//define the where clause
		$where_clause = "abbr = :abbr AND retired_yn = :retired_yn";
		
		//define the bind variable values
		$bind_array = array(array(":abbr", "PIFSC"), array(":retired_yn", "N"));
		
		//retrieve the organization info and return true if the method was successful and false if it was not
		return $this->get_org_info ($where_clause, $bind_array, $pifsc_org_info);
	}

	//function to retrieve and return the director's office information
	function get_do_org_info ($pifsc_org_id, &$do_org_info)
	{
		
		//define the where clause
		$where_clause = "parent_org_id = :org_id AND retired_yn = :retired_yn";

		//define the bind variable values
		$bind_array = array(array(":org_id", $pifsc_org_id), array(":retired_yn", "N")) ;

		//retrieve the director's office info and return true if the method was successful and false if it was not

		return $this->get_org_info ($where_clause, $bind_array, $do_org_info);
	}

	//generate the HTML content for the person with information specified by $person_info
	//the function returns the HTML content
	function generate_person_row_content($person_info)
	{
		
		//generate the html to display the person in the org chart:
		$return_string = "				<TR><TD class=\"nowrap person-tooltip-trigger\" data-tooltip-id=\"".htmlspecialchars($person_info['PERS_ID'])."\">\n
	".($person_info['MGMT_POSITION_YN'] == 'Y' ? "<span class=\"mgmt_position\">": '').htmlspecialchars($person_info['FIRST_INITIAL']).". ".htmlspecialchars($person_info['LASTNAME']).", ".htmlspecialchars($person_info['POSITION'])." ".htmlspecialchars($person_info['EMPLOYER'])." ".htmlspecialchars($person_info['TYPE_ABBR']).($person_info['MGMT_POSITION_YN'] == 'Y' ? "</span>": '')."\n
					</TD></TR>\n";
					
		//remove unnecessary information not needed in the tooltips:
		unset ($person_info['FIRST_INITIAL']);
		unset ($person_info['EMPLOYER']);
		unset ($person_info['MGMT_POSITION_YN']);
		unset ($person_info['TYPE_ABBR']);
		unset ($person_info['POSITION']);

					
		//append the current person_info array to the tooltip_data property 
		$this->tooltip_data[] = $person_info;
					
		return $return_string;
	}

	//general function that generates personnel content based on the specified $where_clause and $bind_array values.  The $order_by_clause is used to specify a sort order for the result set
	//the $content_string variable contains the HTML content for the specified organization's personnel
	function generate_personnel_content ($where_clause, $order_by_clause, $bind_array, &$content_string)
	{
		//initialize the $content_string that will be used to generate the HTML content
		$content_string = '';
		
		//generate the select query to retrieve the personnel records
		$SQL = "SELECT pers_id,
		firstname,
		SUBSTR(firstname, 1, 1) first_initial, 
		lastname,
		email_addr,
		workph1,
		--if this is the director's office or this is a director then include them in the director's office
		(CASE WHEN program = 'Dir' OR mgt_position = 'Director' THEN NVL(mgt_position, position_name) ELSE position_abbr END) position,
		(CASE WHEN program = 'Dir' OR mgt_position = 'Director' THEN NVL(mgt_position, position_name) ELSE position_name END) full_position_name,
		DECODE(employer, 'CIMAR', ' (CI)', 'AF', ' (AF)', 'MOP', ' (MOP)', '') employer,
		(CASE WHEN mgt_position IS NULL THEN 'N' ELSE 'Y' END) mgmt_position_yn,
		DECODE( perstype, 'PIC-Contracted', ' (c)', 'PIC-Associate', ' (a)','PIC-Volunteer', ' (v)', '') type_abbr
		FROM picadm.view_persons_v
		WHERE $where_clause
		AND emp_status = 'Active'
		AND perstype IN ( 'PIC-Staff', 'PIC-Contracted' )
		ORDER BY $order_by_clause";

		//execute the query
		if ($return_value = $this->oracle_db->query($SQL, $stid, $return_id, $bind_array))
		{
			//the query was successfully executed

			//loop through the result rows and generate the table row content for each person
			while ($row = $this->oracle_db->fetch($stid))
			{
				//append the person row content for the current result set row
				$content_string .= $this->generate_person_row_content($row);
			}
		}

		//return true if the method was successful and false if it was not
		return $return_value;
	}

	//function to generate the HTML content for the people within the specified organization ($org_id)
	//the $content_string variable contains the HTML content for the specified organization's personnel
	//the function returns true when the function was executed successfully and false when it was not successful
	function generate_org_personnel_content ($org_id, &$content_string)
	{
		//initialize the content string variable
		$content_string = '';

		//specify the orderby column alias formula to order the result set	
		$order_by_clause = "DECODE(mgt_position, NULL,
									 DECODE( perstype, 'PIC-Volunteer', 8, 'PIC-Associate', 7, 'PIC-Contracted', 6, DECODE(employer, 'MOP', 5, 'CIMAR', 4, 'AF', 3, 2) )
									 , 1), lastname";

		//specify the where clause for the specified organization
		$where_clause = "org_id = :org_id";
		
		//create the bind array for the specified organization
		$bind_array = array(array(":org_id", $org_id));

		//generate the person content for the given organization and return true if the method was successful and false if it was not
		return $this->generate_personnel_content($where_clause, $order_by_clause, $bind_array, $content_string);
	}	


	//function to generate HTML content for the director's office personnel section
	//the $content_string variable contains the HTML content for the specified organization's personnel
	//the function returns true when the function was executed successfully and false when it was not successful
	function generate_do_personnel_content (&$content_string)
	{		
		//initialize the content string variable
		$content_string = '';

		//specify the where clause for the specified organization
		$where_clause = "program = :program_name 
		OR mgt_position = :position_name";
		
		//define the bind variable values
		$bind_array = array(array(":program_name", 'Dir'), array(":position_name", "Director"));

		//specify the order by clause
		$order_by_clause = "DECODE(mgt_position, 'Director', 1, 'Deputy Director', 2, 3), lastname";
		
		//generate the person content for the given organization and return true if the method was successful and false if it was not
		return $this->generate_personnel_content($where_clause, $order_by_clause, $bind_array, $content_string);
	}


	//function to generate HTML content for the CIMAR admin personnel section
	//the $content_string variable contains the HTML content for the specified organization's personnel
	//the function returns true when the function was executed successfully and false when it was not successful
	function generate_cimar_admin_personnel_content (&$content_string)
	{
		//initialize the content string variable
		$content_string = '';

		//specify the where clause for the specified list of primary key ID values
		$where_clause = "pers_id in (:p1, :p2, :p3, :p4, :p5)";
		
		//create the bind array for the specific list of values
		$bind_array = array(array(":p1", 6449), array(":p2", 6720), array(":p3", 6715), array(":p4", 6708), array(":p5", 6945));

		//specify the order by clause
		$order_by_clause = "position_abbr DESC, lastname";
		
		//generate the person content for the given organization and return true if the method was successful and false if it was not
		return $this->generate_personnel_content($where_clause, $order_by_clause, $bind_array, $content_string);

	}
	


	//recursive function that generates the child organizations for the specified parent organization ($parent_org_id)
	//$org_depth is a positive integer that indicates how many levels of parent records are above the current $parent_org_id
	//the $content_string variable contains the HTML content for the child organization and corresponding personnel 
	//the function returns true when the function was executed successfully and false when it was not successful
	function generate_child_orgs_content ($parent_org_id, $org_depth, &$content_string)
	{
	//	echo "running generate_child_orgs_content ($parent_org_id)<BR>";

		//query for all child organizations, the DECODE statement maintains the sorting that was implemented in the production application when the conversion to PHP was performed
		$SQL = "SELECT org_id, org_name, org_level
				FROM picadm.orgs_v
				WHERE retired_yn = 'N'
				AND parent_org_id = :org_id
				ORDER BY DECODE(abbr, 'AGF', 1, 'BUD', 2, 'HR Admin', 3, 'ITS', 4, 'OPT', 5, 'SSS', 6, 'ARB', 7, 'LHP', 8, 'IFA', 9, 'OFA', 10, 'BYC', 11, 'IFCP', 12, 'MSE', 13, 'MB', 14, 'E-Tech', 15, 'D-GOV', 16, 'D-IN', 17, 'D-OUT', 18, 'ARP', 19, 'PRP', 20, 'SEES', 21, 'CRP', 22, 'HMSRP', 23, 'PAEG', 24, 'MTBAP', 25, 'PSaSP', 26, 99)";
		
		//define the bind variable values
		$bind_array = array(array(":org_id", $parent_org_id));
		
		//initialize the content string that will be used to generate the HTML for the current child org
		$content_string = '';
		
		//execute the query
		if ($return_value = $this->oracle_db->query($SQL, $stid, $return_id, $bind_array))
		{
			//the query was successfully executed

			//loop through the result rows and generate the table row content
			while ($row = $this->oracle_db->fetch($stid))
			{
				//style the current org's HTML based on the $org_depth and ORG_LEVEL
				//the following logic was implemented as-is from the legacy web app that was converted
				if ($org_depth == 1)
				{
					//this is a child record of a division, style this as a program

					$content_string .= "				<TR><TD>&nbsp;</TD></TR>\n
					<TR><TD CLASS=\"program display_header\">".htmlspecialchars($row['ORG_NAME'])."</TD></TR>\n";
					
				}
				else if ($org_depth == 2)
				{
					//check what the org level of the current organization record is:
					if ($row['ORG_LEVEL'] == "PIC Program")
					{
						//style this as a program
						$content_string .= "				<TR><TD>&nbsp;</TD></TR>\n
						<TR><TD CLASS=\"program display_header\">".htmlspecialchars($row['ORG_NAME'])."</TD></TR>\n";
					}
					else 
					{
						//style this as a subprogram
						$content_string .= "				<TR><TD>&nbsp;</TD></TR>\n
						<TR><TD CLASS=\"subprogram display_header\">".htmlspecialchars($row['ORG_NAME'])."</TD></TR>\n";					
					}					
				}
				else
				{
					//this has 3 or more levels of parent records, style this as a subprogram
				
					$content_string .= "				<TR><TD>&nbsp;</TD></TR>\n
					<TR><TD CLASS=\"subprogram display_header\">".htmlspecialchars($row['ORG_NAME'])."</TD></TR>\n";				
				}

				//attempt to generate HTML content for the organization's personnel
				if ($return_value = $this->generate_org_personnel_content($row['ORG_ID'], $return_string))
				{
					//append the generated content
					$content_string .= $return_string;


					//recursively call the generate the child organizations to generate the content, increment the $org_depth since the current organization's child records are being processed:
					if ($this->generate_child_orgs_content ($row['ORG_ID'], ($org_depth + 1), $return_string))
					{
						//append the generated content
						$content_string .= $return_string;

					}
					else
					{
						//there was a DB error, exit the processing loop:
						break;
					}
				}
				else	//there was a DB error:
				{
					//exit the processing loop due to the error
					break;
				}					
			}
		}
		
		//return true if the method was successful and false if it was not
		return $return_value;
	}

	//function to generate HTML content for all the PIFSC divisions and corresponding child organizations recursively
	//the $content_string variable contains the HTML content for the division's personnel and headings and all child organization's personnel and headings
	//the function returns true when the function was executed successfully and false when it was not successful
	function generate_division_personnel_content ($do_org_id, &$content_string)
	{
		//initialize the $return_value, true indicates the function was successful, false indicates an error condition
		$return_value = true;

		//initialize the content string variable
		$content_string = '';

		//query for all top-level divisions, exclude the ones with persons already listed under Director's Office
		//define the sort order: OMI, FRMD, ESD, PSD
		$SQL = "SELECT org_id, org_name, abbr
				FROM picadm.orgs_v
			 WHERE retired_yn = 'N'
				 AND parent_org_id = :org_id
				 AND UPPER(abbr) NOT IN ('BP', 'DO', 'DIR', 'DEPDIR', 'BUD', 'SOCIO','SO','CIMARPIC','SIS', 'HIMB')
			 ORDER BY DECODE(abbr, 'OMI', 1, 'FRMD', 2, 'ESD', 3, 'PSD', 4, 99)";

		//define the bind variable values
		$bind_array = array(array(":org_id", $do_org_id));

		//execute the query
		if ($return_value = $this->oracle_db->query($SQL, $division_stid, $return_id, $bind_array))
		{
			//the query was successfully executed

			//loop through the division organizations and generate the HTML content
			while ($division_row = $this->oracle_db->fetch($division_stid))
			{
				//generate the start of the division table content
				$content_string .= "		<TD COLSPAN=2 CLASS=\"divisionouter align_top\">
				<TABLE class=\"layout_table\">\n
					<TR><TD CLASS=\"division display_header\">".htmlspecialchars($division_row['ORG_NAME'])."\n				</TD></TR>\n";

				//attempt to generate HTML content for the organization's personnel
				if ($return_value = $this->generate_org_personnel_content($division_row['ORG_ID'], $return_string))
				{
					//append the generated content for the organization's personnel
					$content_string .= $return_string;

					//recursively call the generate the child organizations to generate the content:
					if ($return_value = $this->generate_child_orgs_content ($division_row['ORG_ID'], 1, $return_string))
					{
						//append the child organization HTML
						$content_string .= $return_string;
						
					}
					else
					{
						//there was a DB error, exit the loop:
						break;
						
					}

					//this is the end of a division display table, close the table and parent table cell HTML elements:
					$content_string .= "			</TABLE>
					</TD>\n";
				}
				else	
				{
					//there was a DB error, exit the loop:
					break;
				}

			}
		}

		//return true if the method was successful and false if it was not
		return $return_value;
	}
	
	//function that generates the HTML page content and displays an error if there are any DB errors
	function generate_html_page_content ()
	{
		//initialize the content string that is used to generate the org chart HTML page content
		$content_string = '';
		
		//check if there are any database errors
		if (!$this->get_db_error_exists())
		{
			//retrieve the PIFSC organization information
			if (!$this->get_PIFSC_org_info($pifsc_org_info))
				$content_string = $this->show_db_error_message();	//there was a database error
			else
			{
				//the PIFSC organization info was retrieved successfully
				
				//retrieve the director's office organization info
				if (!$this->get_do_org_info($pifsc_org_info['ORG_ID'], $do_org_info))
					echo $this->show_db_error_message();	//there was a database error
				else
				{
					//the director's office organization info was retrieved successfully
					
					//generate the director's office personnel content
					if ($this->generate_do_personnel_content($do_content_string))
					{
						//the director's office personnel was generated successfully

						//append the tooltip content:
						

						//generate the director's office content
						if ($this->generate_cimar_admin_personnel_content($cimar_content_string))
						{
							//the CIMAR admin personnel was generated successfully

							//generate the HTML for the org chart for the divisions/programs:
							if ($this->generate_division_personnel_content($do_org_info['ORG_ID'], $division_content_string))
							{
								//all of the database queries were successful and the HTML content for each data entity was generated successfully, construct the HTML for the web page:
								

								$content_string = "
								<TABLE class=\"layout_table\">
									<TR>
										<TD COLSPAN=8 class=\"main_layout_cell\">\n<div class=\"page_heading\">\n".htmlspecialchars($pifsc_org_info['ORG_NAME'])."\n</div>
										</TD>
									</TR>
									<TR>
										<TD COLSPAN=2>&nbsp;</TD>
										<!-- DO box begin -->
										<TD COLSPAN=4 CLASS=\"program\">
											<TABLE class=\"center\">
												<TR><TD COLSPAN=2 class=\"display_header\">".htmlspecialchars($do_org_info['ORG_NAME'])."
												</TD></TR>
												<TR>
													<TD class=\"center align_top\" id=\"do_program_id\">
														<TABLE>
														".$do_content_string."
														</TABLE>
													</TD>
												</TR>
											</TABLE>
										</TD>
										<!-- DO box end -->
										<!-- CIMAR box begin -->
										<TD COLSPAN=2 class=\"align_top\">
											<TABLE class=\"center\">
												<TR>
													<TD CLASS=\"program\">
														<TABLE>
															<TR>
																<TD CLASS=\"program display_header\">CIMAR</TD>
															</TR>
															".$cimar_content_string."
														</TABLE>
													</TD>
												</TR>
											</TABLE>
										</TD>
										<!-- CIMAR box end -->
									</TR>
									<TR>
										<TD COLSPAN=4>&nbsp;</TD>
										<TD CLASS=\"lineleft\">&nbsp;</TD>
									</TR>
									<TR>
										<TD>&nbsp;</TD>
										<TD CLASS=\"linetopleft\">&nbsp;</TD>
										<TD CLASS=\"linetop\">&nbsp;</TD>
										<TD CLASS=\"linetopleft\">&nbsp;</TD>
										<TD CLASS=\"linetop\">&nbsp;</TD>
										<TD CLASS=\"linetopleft\">&nbsp;</TD>
										<TD CLASS=\"linetop\">&nbsp;</TD>
										<TD CLASS=\"lineleft\">&nbsp;</TD>
									</TR>
									<TR>
									".$division_content_string."
									</TR>
								</TABLE>
								<P>
									<FONT SIZE=-2>Generated on ".date("m/d/Y g:i A")." (HST)</FONT>
								</P>";
								
								
								//release the string variables from memory
								unset ($division_content_string);
								unset ($cimar_content_string);
								unset ($do_content_string);
								
							}
							else	//there was a DB error
								$content_string = $this->show_db_error_message();

						}
						else	//there was a DB error
							$content_string = $this->show_db_error_message();
					}
					else
						$content_string = $this->show_db_error_message();	//there was a database error
				}
			}
		}
		
	
		//wrap the $content_string in the html for the page regardless if it's an error or the org chart content:
		return "<!DOCTYPE html>
	<HEAD>
		<META HTTP-EQUIV=\"Pragma\" CONTENT=\"no-cache\"><META HTTP-EQUIV=\"Expires\" CONTENT=\"-1\">
		<TITLE>PIFSC Organization Hierarchy</TITLE>
		<link rel=\"stylesheet\" href=\"style/org_chart.css\">
		<link rel=\"stylesheet\" href=\"style/shared_styles.css\">
		<link rel=\"SHORTCUT ICON\" href=\"./img/noaa_sm.jpg\" />
		<script src=\"./js/popper.min.js\"></script>
		<script src=\"./js/tippy.min.js\"></script>
	</HEAD>
	<BODY>
	".generate_navigation_bar ("org-chart").
$content_string."
		<script>
		//personnelData contains the information for all personnel displayed in the organization chart:
		const personnelData = ".json_encode($this->tooltip_data, JSON_PRETTY_PRINT).";\n
		</script>
		<script src=\"./js/tooltips.js\"></script>
	</BODY>";
		
	}
	
	
}
?>