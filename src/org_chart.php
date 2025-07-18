<?php

	//include the php file that defines the includes directory path:
	include("/usr/src/app/staff-directory/include_path.php");

	//include the php file that connects to the Oracle database
	include(INCLUDE_PATH."staff-directory/org_chart_class.php");
	$org_chart = new org_chart();
	


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

	//check if there are any database errors
	if (!$org_chart->get_db_error_exists())
	{
		//retrieve the PIFSC organization information
		if (!$org_chart->get_PIFSC_org_info($pifsc_org_info))
			echo $org_chart->show_db_error_message();	//there was a database error
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
	if (!$org_chart->get_db_error_exists())
	{
		//retrieve the director's office organization info
		if (!$org_chart->get_do_org_info($pifsc_org_info['ORG_ID'], $do_org_info))
			echo $org_chart->show_db_error_message();	//there was a database error
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
if (!$org_chart->get_db_error_exists())
{
	//generate the director's office personnel content
	if ($org_chart->generate_do_personnel_content($content_string))
		echo $content_string;
	else
		echo $org_chart->show_db_error_message();	//there was a database error
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

if (!$org_chart->get_db_error_exists())
{
	//generate the director's office content
	if ($org_chart->generate_cimar_admin_personnel_content($content_string))
	{
		//add the content to the HTML page:
		echo $content_string;
	}
	else	//there was a DB error
		echo $org_chart->show_db_error_message();
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
	if (!$org_chart->get_db_error_exists())
	{
		//generate the HTML for the org chart for the divisions/programs:
		if ($org_chart->generate_division_personnel_content($do_org_info['ORG_ID'], $content_string))
			echo $content_string;
		else	//there was a DB error
			echo $org_chart->show_db_error_message();
	}
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
