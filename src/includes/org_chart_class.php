<?php

//include the php file that connects to the Oracle database
include(INCLUDE_PATH."staff-directory/db_connect.php");

//class to provide the functionality required for the PIFSC organization chart
class org_chart
{
	
	//private class properties
	private $oracle_db;
	private $db_error_exists;
	
	
	//constructor method
	function __construct ()
	{
		//initialize the variable to track if a database error occurred
		$this->db_error_exists = false;

		//connect to the Oracle DB
		if (db_connect($oracle_db))
			$this->oracle_db = $oracle_db;
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
	}

	//accessor method
	function get_db_error_exists()
	{
		return $this->db_error_exists;
	}
	
	//set method
	function set_db_error_exists($error_exists)
	{
		$this->db_error_exists = $error_exists;
	}
		
		

	//function to retrieve the PIFSC organization information in $pifsc_org_info, function returns true if there were no errors and false if there were errors
	function get_PIFSC_org_info (&$pifsc_org_info)
	{
		//initialize the $return_value, true indicates the function was successful, false indicates an error condition
		$return_value = true;

		$SQL = "SELECT org_id, org_name
		FROM picadm.orgs_v
		WHERE abbr = 'PIFSC'
		AND retired_yn = 'N'";

		//execute the query
		if ($return_value = $this->oracle_db->query($SQL, $stid, $return_id))
		{
			//the query was successfully executed

			//attempt to retrieve the first result row
			if (!($pifsc_org_info = $this->oracle_db->fetch($stid)))
			{
				//there were no records returned by the query
				$return_value = false;
			}
		}

		return $return_value;
		
	}

	//function to retrieve and return the director's office information
	function get_do_org_info ($pifsc_org_id, &$do_org_info)
	{
		//initialize the $return_value, true indicates the function was successful, false indicates an error condition
		$return_value = true;

		$SQL = "SELECT org_id, org_name
		FROM picadm.orgs_v
		WHERE parent_org_id = :org_id
		AND retired_yn = 'N'";

		$bind_array = array(array(":org_id", $pifsc_org_id));

		//execute the query
		if ($return_value = $this->oracle_db->query($SQL, $stid, $return_id, $bind_array))
		{
			//the query was successfully executed

			//attempt to retrieve the first result row
			if (!($do_org_info = $this->oracle_db->fetch($stid)))
			{
				//there were no records returned by the query
				$return_value = false;
			}
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
		$return_value = $this->generate_person_content($where_clause, $order_by_clause, $bind_array, $content_string);
		
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
		$return_value = $this->generate_person_content($where_clause, $order_by_clause, $bind_array, $content_string);
		
		return $return_value;	

	}



	//function to generate HTML content for the budget and planning personnel section
	function div_prog_personnel_content ($do_org_id, &$content_string)
	{
		//initialize the content string variable
		$content_string = '';

		//initialize the $return_value, true indicates the function was successful, false indicates an error condition
		$return_value = true;

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
		if ($return_value = $this->oracle_db->query($SQL, $division_stid, $return_id, $bind_array))
		{
			//the query was successfully executed

			//loop through the result rows and generate the table row content
			while ($division_row = $this->oracle_db->fetch($division_stid))
			{

				$content_string .= "		<TD COLSPAN=2 CLASS=\"divisionouter align_top\">
				<TABLE class=\"layout_table\">\n
					<TR><TD CLASS=\"division display_header\">".$division_row['ORG_NAME']."\n				</TD></TR>\n";



				//attempt to generate HTML content for the organization's personnel
				if ($return_value = $this->org_person_content($division_row['ORG_ID'], $return_string))
				{
					//append the generated content
					$content_string .= $return_string;


					//recursively call the generate the child organizations to generate the content:
					if ($return_value = $this->generate_child_orgs ($division_row['ORG_ID'], 1, $return_string))
					{
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


		return $return_value;
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
		$return_value = $this->generate_person_content($where_clause, $order_by_clause, $bind_array, $content_string);
		
		return $return_value;
	}

	//generate the HTML content for the person with information specified by $person_info
	function person_row_content($person_info)
	{
		return "				<TR><TD class=\"nowrap\">\n
	".$person_info['START_MGMT_CLASS_STYLE']." ".$person_info['FIRSTNAME'].". ".$person_info['LASTNAME'].", ".$person_info['POSITION']." ".$person_info['EMPLOYER']." ".$person_info['TYPE_ABBR'].$person_info['END_MGMT_CLASS_STYLE']."\n
					</TD></TR>\n";
	}

	//recursive function that generates the child organizations for the specified parent organization ($parent_org_id)
	//$org_depth is a positive integer that indicates how many levels of parent records are above the current $parent_org_id
	function generate_child_orgs ($parent_org_id, $org_depth, &$content_string)
	{
	//	echo "running generate_child_orgs ($parent_org_id)<BR>";

		//query for all child organizations, the DECODE statement maintains the sorting that was implemented in the production application when the conversion to PHP was performed
		$SQL = "SELECT org_id, org_name, org_level
				FROM picadm.orgs_v
				WHERE retired_yn = 'N'
				AND parent_org_id = :org_id
				ORDER BY DECODE(abbr, 'AGF', 1, 'BUD', 2, 'HR Admin', 3, 'ITS', 4, 'OPT', 5, 'SSS', 6, 'ARB', 7, 'LHP', 8, 'IFA', 9, 'OFA', 10, 'BYC', 11, 'IFCP', 12, 'MSE', 13, 'MB', 14, 'E-Tech', 15, 'D-GOV', 16, 'D-IN', 17, 'D-OUT', 18, 'ARP', 19, 'PRP', 20, 'SEES', 21, 'CRP', 22, 'HMSRP', 23, 'PAEG', 24, 'MTBAP', 25, 'PSaSP', 26, 99)";
		
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

				//the following logic was implemented as-is from the legacy web app that was converted

				//style the current org's HTML based on the $org_depth and ORG_LEVEL
				if ($org_depth == 1)
				{
					//this is a child record of a division, style this as a program

					$content_string .= "				<TR><TD>&nbsp;</TD></TR>\n
					<TR><TD CLASS=\"program display_header\">".$row['ORG_NAME']."</TD></TR>\n";
					
				}
				else if ($org_depth == 2)
				{
					//check what the org level of the current organization record is:
					if ($row['ORG_LEVEL'] == "PIC Program")
					{
						//style this as a program
						$content_string .= "				<TR><TD>&nbsp;</TD></TR>\n
						<TR><TD CLASS=\"program display_header\">".$row['ORG_NAME']."</TD></TR>\n";
					}
					else 
					{
						//style this as a subprogram
						$content_string .= "				<TR><TD>&nbsp;</TD></TR>\n
						<TR><TD CLASS=\"subprogram display_header\">".$row['ORG_NAME']."</TD></TR>\n";					
					}					
				}
				else
				{
					//this has 3 or more levels of parent records, style this as a subprogram
				
					$content_string .= "				<TR><TD>&nbsp;</TD></TR>\n
					<TR><TD CLASS=\"subprogram display_header\">".$row['ORG_NAME']."</TD></TR>\n";				
				}

				//attempt to generate HTML content for the organization's personnel
				if ($return_value = $this->org_person_content($row['ORG_ID'], $return_string))
				{
					//append the generated content
					$content_string .= $return_string;


					//recursively call the generate the child organizations to generate the content, increment the $org_depth since the child records are being processed:
					if ($this->generate_child_orgs ($row['ORG_ID'], ($org_depth + 1), $return_string))
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
		
		return $return_value;
	}


	//function to mark that a database error occurred and to output the information to the user
	function show_db_error_message ()
	{
		$this->db_error_exists = true;

		return "<span class=\"page_content_on_background\">Error: we're experiencing technical difficulties, please try again later</span>";
	}


	//general function that generates person content based on the specified $where_clause and $bind_array values.  The $orderby_clause is used to calculate a sort order for the person query
	function generate_person_content ($where_clause, $order_by_clause, $bind_array, &$content_string)
	{
		
//		echo "running generate_person_content($where_clause, $order_by_clause, ".var_export($bind_array, true).")<BR>";
		
		//initialize the $content_string that will be used to generate the HTML content
		$content_string = '';

		$SQL = "SELECT pers_id,
		SUBSTR(firstname, 1, 1) firstname, 
		lastname, 
		--if this is the director's office or this is a director then include them in the director's office
		(CASE WHEN program = 'Dir' OR mgt_position = 'Director' THEN NVL(mgt_position, position_name) ELSE position_abbr END) position,
		DECODE(employer, 'CIMAR', ' (CI)', 'AF', ' (AF)', 'MOP', ' (MOP)', '') employer,
		DECODE(mgt_position, NULL, '', '<span class=\"mgmt_position\">') start_mgmt_class_style,
		DECODE(mgt_position, NULL, '', '</span>') end_mgmt_class_style,
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
				$content_string .= $this->person_row_content($row);
			}
		}

		return $return_value;
	}
}




?>