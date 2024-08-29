#!/usr/bin/perl -wT

use DBI;
use strict;
use File::Copy;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use lib qw(.);
use MyConnectStaff; 



#Create new CGI object and assigns the variable $query to point to it.  
#The new() method parses GET and POST method variables and all of the parameters from the input stream
#does all URI decoding, and then stores the results as a new CGI object into the variable named $query.
my $query = new CGI;
my $sql;
my $stmt;
my @row;

#Generate "Content-type:text/html\n\n";
print $query->header;

#Access parameters using the CGI object and store them in the $variables.  This is param() method of CGI module.
my $id = $query->param('id');


#Establish database connection 
my $dbh = MyConnectStaff::ConnectDB();
if(!$dbh) {die("Database Connection failed. Please contact the Webmaster.");}
#print "<p>Connected successfully!<br /><br />\n";

$query = qq{SELECT picadm.vw_nonpii_pers_v.lastname, picadm.vw_nonpii_pers_v.firstname, picadm.vw_nonpii_pers_v.email_addr, picadm.vw_nonpii_pers_v.workph1,
		picadm.vw_nonpii_pers_v.worksite, picadm.vw_nonpii_pers_v.room_num, picadm.vw_nonpii_pers_v.div_name, picadm.vw_nonpii_pers_v.div_abbr, 
		picadm.vw_nonpii_pers_v.program,
		picadm.vw_nonpii_pers_v.position_name,
		employees_pic.emp_rsch1, employees_pic.emp_rsch2, employees_pic.emp_rsch3, employees_pic.emp_rsch4,
		employees_pic.emp_educ1, employees_pic.emp_educ2, employees_pic.emp_educ3, employees_pic.emp_educ4,
		employees_pic.photo_opt, employees_pic.photo_file,
		picadm.vw_nonpii_pers_v.workph2
		FROM picadm.vw_nonpii_pers_v, employees_pic
		WHERE picadm.vw_nonpii_pers_v.id=$id AND employees_pic.emp_id=$id 
		};
			
		
		$stmt = $dbh->prepare($query);
		
		$stmt->execute() || die "The query was not made: $DBI::errstr";
		
		my @count = $stmt->fetchrow_array();
		my $count = $#count+1;
		#print $count;	
		$stmt->finish();

		header();

		###############If they haven't submitted info yet to employees_pic table, use info from PEEPS databases only########################
		if ($count==0)
		{
			$query = qq{SELECT picadm.vw_nonpii_pers_v.lastname, picadm.vw_nonpii_pers_v.firstname, picadm.vw_nonpii_pers_v.email_addr, picadm.vw_nonpii_pers_v.workph1, picadm.vw_nonpii_pers_v.worksite, 
			picadm.vw_nonpii_pers_v.room_num, picadm.vw_nonpii_pers_v.div_name, picadm.vw_nonpii_pers_v.div_abbr, picadm.vw_nonpii_pers_v.program, picadm.vw_nonpii_pers_v.position_name, picadm.vw_nonpii_pers_v.workph2
			FROM picadm.vw_nonpii_pers_v
			WHERE picadm.vw_nonpii_pers_v.id=$id };

			$stmt = $dbh->prepare($query);
		
			$stmt->execute() || die "The query was not made: $DBI::errstr";

			

			while (@row = $stmt->fetchrow_array)
			{
				my $div = "($row[7]";
				my $prog = "-$row[8])";
		

			#These columns have the potential to be null
			
			if ($row[3] eq "")
				{$row[3]="none";} #phone1
			if ($row[4] eq "")
				{$row[4]="Other";}#site
			if ($row[5] eq "")
				{$row[5]="none";}#room num
			if ($row[6] eq "")
				{ $row[6]="n/a"; $row[7]=""; $row[8]="";}#division
			if ($row[7] eq "")
				{$div = "";}#div abbr
			if ($row[8] eq "")
				{$prog = "";}#program 
			if ($row[10] eq "")
				{$row[10] = "none";} #phone2
		
	
			#Name (First, Last)
			print "<p>&nbsp;</p><center><span class=\"style45\">$row[1] $row[0]</span> <p>"; 
				
			#Title
			print "<span class=\"style41\">$row[9]</span><br>";

			print "<p>";

			print "<div id=\"content\"><center><table border=\"0\" width=\"65\%\">";
			print "<tr><td colspan=\"2\" align=\"center\" valign=\"top\"><span class=\"style44\">Contact Information</span><p><p></td></tr>";
			if ($row[5] ne "") { print "<tr><td align=\"right\" valign=\"top\"><span class=\"style42\">Division:&nbsp;</span></td><td><span class=\"style43\">$row[6] <br>$div$prog</span> </td></tr>";}
			print"<tr><td align=\"right\"><span class=\"style42\">Work Site:&nbsp;</span></td><td><span class=\"style43\">$row[4]</span> </td></tr>
			<tr><td align=\"right\"><span class=\"style42\">Room/Floor:&nbsp;</span></td><td><span class=\"style43\">$row[5]</span> </td></tr>
			
			<tr><td align=\"right\"><span class=\"style42\"> Phone #1:&nbsp;</span></td><td><span class=\"style43\">$row[3]</span> </td></tr>
			<tr><td align=\"right\"><span class=\"style42\"> Phone #2:&nbsp;</span></td><td><span class=\"style43\">$row[10]</span> </td></tr>
			";

			#Email
	
			if ($row[2] eq "")
				{print "<tr><td align=\"right\"><span class=\"style42\">Email:&nbsp;</span></td><td><span class=\"style43\">none</span></td></tr>";} 
			else
				{print "<tr><td align=\"right\"><span class=\"style42\">Email:&nbsp;</span></td><td><a href=\"mailto:$row[2]\"><font size=\"2\">$row[2]</font></a></td></tr>";}
			
			print "<tr><td>&nbsp;</td></tr>
			</table>
			";
	
			$stmt->finish();	
			#disconnect from the database.
			$dbh->disconnect();
			footer();
			exit();
			}
		

		} #end of IF

############if they have submitted info to employees_pic table, display info as follows##############
else {
	$stmt = $dbh->prepare($query);
		
	#Execute sql
	$stmt->execute() || die "The query was not made: $DBI::errstr";

	print "<p>&nbsp;</p>";

	while  (@row = $stmt->fetchrow_array)
		{
			my $div = "($row[7]";
			my $prog = "-$row[8])";
		

			#These columns have the potential to be null
					
			if ($row[2] eq "")
				{$row[2]="none";} #none
			if ($row[3] eq "")
				{$row[3]="none";} #phone1
			if ($row[4] eq "")
				{$row[4]="Other";}#site
			if ($row[5] eq "")
				{$row[5]="none";}#room num
			if ($row[6] eq "")
				{$row[6]="";}#division
			if ($row[7] eq "")
				{$div = "";}#div abbr
			if ($row[8] eq "")
				{$prog = "";}#program 
			if ($row[20] eq "")
				{$row[20] = "none";} #phone2
	
	
		
			####This is when they have submitted their information####################################
			#Name
			print "<center><span class=\"style45\">$row[1] $row[0]</span> <p>"; 
				
			#Title
			print "<span class=\"style41\">$row[9]</span><br>";

			#Do they want to include their photo, and if the photo has been taken yet
			if ($row[18] eq "yes" || $row[18] eq "yes_")
			{

				if ($row[19] eq "")
				{my $photo = "<img class=\"img\" src=\"/staffdir/img/comingsoon.gif\"/>";
				print "<p>$photo";
				}
				elsif($row[19] ne "")
				{my $photo = "<img class=\"img\" src=\"/staffdir/img/$row[19]\"/>";
				print "<p>$photo";
				}
			}
			
			print "<p>";

			print "<div id=\"content\"><center><table border=\"0\" width=\"65\%\">";

			print "<tr><td colspan=\"2\" align=\"center\" valign=\"top\"><span class=\"style44\">Contact Information</span><p><p></td></tr>";
			if ($row[5] ne "") { print "<tr><td align=\"right\" valign=\"top\"><span class=\"style42\">Division:&nbsp;</span></td><td><span class=\"style43\">$row[6] <br>$div$prog</span> </td></tr>";}
			print"<tr><td align=\"right\"><span class=\"style42\">Work Site:&nbsp;</span></td><td><span class=\"style43\">$row[4]</span> </td></tr>
			<tr><td align=\"right\"><span class=\"style42\">Room/Floor:&nbsp;</span></td><td><span class=\"style43\">$row[5]</span> </td></tr>
			
			<tr><td align=\"right\"><span class=\"style42\"> Phone #1:&nbsp;</span></td><td><span class=\"style43\">$row[3]</span> </td></tr>
			<tr><td align=\"right\"><span class=\"style42\"> Phone #2:&nbsp;</span></td><td><span class=\"style43\">$row[20]</span> </td></tr>

			";

			#Email
	
			if ($row[2] eq "")
				{print "<tr><td align=\"right\"><span class=\"style42\">Email:&nbsp;</span></td><td><span class=\"style43\">none</span></td></tr>";} 
			else
				{print "<tr><td align=\"right\"><span class=\"style42\">Email:&nbsp;</span></td><td><a href=\"mailto:$row[2]\"><font size=\"2\">$row[2]</font></a></td></tr>";}
			
			print "<tr><td>&nbsp;</td></tr>
			";	
			
		

			
			if ($row[10]|| $row[11] || $row[12] || $row[13] ne "")
			{
			print "<tr><td colspan=\"2\"><span class=\"style44\"><center><p>Research Interests:</center></span>
				<ul>";
			
				if ($row[10] ne "")
				{print "<li><span class=\"style43\">$row[10]</span></li>";} 
				if ($row[11] ne "")
				{print "<li><span class=\"style43\">$row[11]</span></li>";} 
				if ($row[12] ne "")
				{print "<li><span class=\"style43\">$row[12]</span></li>";}
				if ($row[13] ne "") 
				{print "<li><span class=\"style43\">$row[13]</span></li>";}

			 print "</ul></td></tr>";
			}
			
			
			if ($row[14] || $row[15] || $row[16] || $row[17] ne "")
			{
				print "<tr><td colspan=\"2\"><span class=\"style44\"><center><p>Education:</center></span>
					<ul>";
				
				if ($row[14] ne "")
				{print "<li><span class=\"style43\">$row[14]</span></li>";}
				if ($row[15] ne "")
				{print "<li><span class=\"style43\">$row[15]</span></li>";}
				if ($row[16] ne "")
				{print "<li><span class=\"style43\">$row[16]</span></li>";}
				if ($row[17] ne "")
				{print "<li><span class=\"style43\">$row[17]</span></li>";}

			print "</ul></td></tr>";
			}

			print "</table></div></center><p></div>";
		} #end WHILE


	
$stmt->finish();

#disconnect from the database.
$dbh->disconnect();

footer();

} #end of ELSE


#####SUBROUTINES#######################################################		
sub header{
	#Start HTML Page
print "<HTML><HEAD><TITLE>PIFSC Staff Directory - Search Results</TITLE>\n";
print "<link rel=\"stylesheet\" type=\"text/css\" href=\"/style/staffdir_style.css\" />\n";
print "<link rel=\"SHORTCUT ICON\" href=\"/images/noaa_sm.jpg\" />\n";

print "</HEAD><BODY>

<div id=\"border\">
<div id =\"container\">
<div id=\"topmenu\"><a href=\"http://picahi.nmfs.local/staffsearch.html\">PIFSC Staff Directory</a>&nbsp; > &nbsp;<font color=\"black\">Search Results</font></div>
<div id=\"header\"></div>

<p>
</BODY></HTML>";
}




sub footer{
print "<HTML><HEAD>\n";

print "<link rel=\"stylesheet\" type=\"text/css\" href=\"/style/staffdir_style.css\" />\n";

print "</HEAD><BODY>



<center><b><a href=\"http://picahi.nmfs.local/staffsearch.html\">New Search</a></b>
</center>
<p>

<div id=\"footer\">
<p><span class=\"style8\">Please send questions or comments to <a href=\"mailto:PIFSC.Librarian\@noaa.gov\">PIFSC Librarian</a>.<br></span>
</div>     



</body>

</html>
";
}			
