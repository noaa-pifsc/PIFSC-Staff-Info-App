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
		//retrieve the pifsc information
		if (!get_PIFSC_org_info($pifsc_org_info))
			echo db_error_exists();
	}
	else
	{
		//could not successfully connect to the DB
		echo db_error_exists();
	}
		
?>
	<TABLE class="layout_table">
		<TR>
			<TD COLSPAN=8 class="main_layout_cell">
<?php
echo $pifsc_org_info['ORG_NAME'];
?>
			</TD>
		</TR>
<?php

	//query for the director's office information:

	if (!$db_error_exists)
	{
		//retrieve the director's office organization info
		if (!get_do_org_info($pifsc_org_info['ORG_ID'], $do_org_info))
			echo db_error_exists();
	}

?>
		<TR>
			<TD COLSPAN=2>&nbsp;</TD>
			<TD COLSPAN=4 CLASS="program">
				<TABLE class="center">
					<TR><TD COLSPAN=2 class="display_header"><?php echo $do_org_info['ORG_NAME']; ?>
					</TD></TR>
					<TR>
						<TD class="center align_top">
							<TABLE>
<?php
if (!$db_error_exists)
{
	//generate the director's office content
	if (display_do_personnel_content($content_string))
	{
		//add the content to the HTML page:
		echo $content_string;
	}
	else	//there was a DB error
		echo db_error_exists();
}
?>
							</TABLE>
						</TD>
					</TR>
				</TABLE>
			</TD>
<?php /* CIMAR box begin */ ?>
			<TD COLSPAN=2 class="align_top">
				<TABLE class="center">
					<TR>
						<TD CLASS="program">
							<TABLE>
								<TR>
									<TD CLASS="program display_header">CIMAR</TD>
								</TR>
<?php

if (!$db_error_exists)
{
	//generate the director's office content
	if (cimar_admin_personnel_content($content_string))
	{
		//add the content to the HTML page:
		echo $content_string;
	}
	else	//there was a DB error
		echo db_error_exists();
}
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
		echo div_prog_personnel_content($do_org_info['ORG_ID']);
?>
		</TR>
	</TABLE>
	<P>
	<FONT SIZE=-2>Generated on
	<?php
	echo date("m/d/Y H:i");
	?></FONT></P>
</BODY>
<!--</html>-->
