<?php

	//include the php file that defines the includes directory path:
	include("/usr/src/app/staff-directory/include_path.php");

	//include the php file that connects to the Oracle database
	include(INCLUDE_PATH."staff-directory/db_connect.php");

	//include the php file that supports the org_chart application
	include(INCLUDE_PATH."staff-directory/org_chart_functions.php");



?>
<!DOCTYPE html>
<!--<html>-->
<HEAD>
	<META HTTP-EQUIV="Pragma" CONTENT="no-cache"><META HTTP-EQUIV="Expires" CONTENT="-1">
	<TITLE>PIFSC Organization Hierarchy</TITLE>
	<link rel="stylesheet" href="style/org_chart.css">
</HEAD>

<BODY>
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
					<TR><TD COLSPAN=2 class="display_header"><?php echo $do_org_name; ?>
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
									<TD CLASS="display_header">CIMAR</TD>
								</TR>
<?php
if (!$db_error_exists)
	echo cimar_admin_personnel_content();
?>
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
	<P>
	<FONT SIZE=-2>Printed on
	<?php
	echo date("m/d/Y H:i");
	?></FONT></P>
</BODY>
<!--</html>-->
