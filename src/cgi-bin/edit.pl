#!/usr/bin/perl -wT

use DBI;
use strict;
use File::Copy;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use lib qw(.);
use MyConnectStaff; 

my $query = new CGI;

my ($id, $employee, $lastname, $firstname, $email, $research1, $research2, $research3, $research4, $education1, $education2,
	$education3, $education4, $photo);

#Generate "Content-type:text/html\n\n";
print $query->header;


	#Access parameters using the CGI object and store them in the variables
	$id = $query->url_param('id');
	
	

#Establish database connection 
my $dbh = MyConnectStaff::ConnectDB();
if(!$dbh) {die("Database Connection failed. Please contact the Webmaster.");}
#print "<p>Connected successfully!<br /><br />\n";

#Search database for the employee's id and email
$query = qq{SELECT picadm.vw_nonpii_pers_v.lastname, picadm.vw_nonpii_pers_v.firstname, picadm.vw_nonpii_pers_v.email_addr,
		employees_pic.emp_rsch1, employees_pic.emp_rsch2, employees_pic.emp_rsch3, employees_pic.emp_rsch4,
		employees_pic.emp_educ1, employees_pic.emp_educ2, employees_pic.emp_educ3, employees_pic.emp_educ4,
		employees_pic.photo_opt
		FROM picadm.vw_nonpii_pers_v, employees_pic
		WHERE picadm.vw_nonpii_pers_v.id=$id AND employees_pic.emp_id=$id
		};

my $stmt = $dbh->prepare($query);
		
$stmt->execute() || die "The query was not made: $DBI::errstr";

my @row;
while  (@row = $stmt->fetchrow_array) 
{
	$lastname=$row[0];
	$firstname=$row[1];
	$email=$row[2];
	$research1=$row[3];
	$research2=$row[4];
	$research3=$row[5];
	$research4=$row[6];
	$education1=$row[7];
	$education2=$row[8];
	$education3=$row[9];
	$education4=$row[10];
	$photo=$row[11];
}
	
$stmt->finish();

$stmt->finish();

#disconnect from the database.
$dbh->disconnect();
	
header();


print" 
<center><span class=\"style44\">Please Edit Your Information $firstname</span>
</center>
<p>&nbsp;</p>

<center>
<form action=\"/cgi-bin/editfinal.pl?id=$id\" method=\"post\">
<div class=\"pub_tb\">
<table border=0>

<tr>
<td align=\"right\"><span class=\"style42\">First Name\:</span> </td>
<td><span class=\"style43\">$firstname</span>
<input type=\"hidden\" name=\"firstname\" value=\"$firstname\">
</td>
</tr>

<tr>
<td align=\"right\"><span class=\"style42\">Last Name\: </span></td>
<td><span class=\"style43\">$lastname</span>
<input type=\"hidden\" name=\"lastname\" value=\"$lastname\">
</td>
</tr>

<tr>
<td align=\"right\"><span class=\"style42\">Email\: </span></td>
<td><span class=\"style43\">$email</span>
<input type=\"hidden\" name=\"email\" value=\"$email\">
</td> 
</tr>

<tr><td colspan=2><hr></td></tr>
<tr>
<td align=\"right\" valign=\"top\"><span class=\"style33\"><u>Briefly</u> Describe Your Research Interests at PIFSC:<br><i>(optional)</i></span>
</td>
<td>#1 <span class=\"style8\">(Ex: Stock assessment of tuna and billfish) </span><br><textarea name=\"research1\" rows=1 cols=40>$research1</textarea><p>
#2 <span class=\"style8\">(Ex: Population dynamics of the Hawaiian monk seal)</span><br><textarea name=\"research2\" rows=1 cols=40>$research2</textarea><p>
#3 <span class=\"style8\">(Ex: Marine debris accumulation in the NWHI)</span><br><textarea name=\"research3\" rows=1 cols=40>$research3</textarea><p>
#4 <span class=\"style8\">(Ex: Satellite remote sensing for fisheries oceanography)</span><br><textarea name=\"research4\" rows=1 cols=40>$research4</textarea>
</td>
</tr>

<tr><td colspan=2><hr></td></tr>

<tr>
<td align=\"right\" valign=\"top\"><span class=\"style33\">Educational Background:<br><i>(optional)</i></span></td>
<td>
<span class=\"style6\">List Most Recent First</span><br>
<span class=\"style8\">(Ex: Ph.D. Biostatistics, Oregon State University, 2008)</span><br><input type=\"text\" name=\"education1\" value=\"$education1\" size=\"60\" maxlength=\"150\"><p>
<span class=\"style8\">(Ex: M.S. Biology, University of Washington, 2006)</span><br><input type=\"text\" name=\"education2\" value=\"$education2\" size=\"60\" maxlength=\"150\"><p>
<span class=\"style8\">(Ex: B.A. Economics, University of Hawai'i, 2003)</span><br><input type=\"text\" name=\"education3\" value=\"$education3\" size=\"60\" maxlength=\"150\"><p>
<span class=\"style8\">(Ex: A.A.S. Fisheries Technology, Kapiolani Community College, 2000)</span><br><input type=\"text\" name=\"education4\"  value=\"$education4\" size=\"60\" maxlength=\"150\">
</td>
</tr>

<tr><td colspan=2><hr></td></tr>


<tr>

<td align=\"right\" valign=\"top\"><span class=\"style33\">Do You Want to Display Your Photo?</span>
";

if ($photo eq 'yes')
{
print "<td><input type=\"radio\" name=\"photo\" value=\"yes\" checked>&nbsp;<span class=\"style4\">Yes\! (Please take my photo for me)</span> 

<br><input type=\"radio\" name=\"photo\" value=\"yes_\">&nbsp;<span class=\"style4\">Yes! (I'll provide my own photo) </span> 

<br><input type=\"radio\" name=\"photo\" value=\"no\">&nbsp;<span class=\"style4\">No Thanks.</span><p>
</td>
</tr>
";}

elsif ($photo eq 'yes_')
{
print "<td><input type=\"radio\" name=\"photo\" value=\"yes\">&nbsp;<span class=\"style4\">Yes\! (Please take my photo for me)</span> 

<br><input type=\"radio\" name=\"photo\" value=\"yes_\" checked>&nbsp;<span class=\"style4\">Yes! (I'll provide my own photo) </span> 

<br><input type=\"radio\" name=\"photo\" value=\"no\">&nbsp;<span class=\"style4\">No Thanks.</span><p>
</td>
</tr>
";}


else
{
print "<td><input type=\"radio\" name=\"photo\" value=\"yes\">&nbsp;<span class=\"style4\">Yes\! (Please take my photo for me)</span> 

<br><input type=\"radio\" name=\"photo\" value=\"yes_\">&nbsp;<span class=\"style4\">Yes! (I'll provide my own photo) </span> 

<br><input type=\"radio\" name=\"photo\" value=\"no\" checked>&nbsp;<span class=\"style4\">No Thanks.</span><p>
</td>
</tr>
";}


print "<tr><td colspan=\"2\"><center><input value=\"SUBMIT EDITS\" type=\"submit\" name=\"requestType\"</center></td></tr>
</table>
</div>	
</form>
<center>
";

footer();

# Clear the variables.  Otherwise they will show up in the form.
	$firstname = "";
	$lastname = "";
	$email = "";
	$research1 = "";
	$research2 = "";
	$research3 = "";
	$research4 = "";
	$education1 = "";
	$education2 = "";
	$education3 = "";
	$education4 = "";


						
		







#####SUBROUTINES#######################################################		
sub header{
	#Start HTML Page
print "<HTML><HEAD><TITLE>PIFSC Staff Directory - Search Results</TITLE>\n";
print "<link rel=\"stylesheet\" type=\"text/css\" href=\"/style/staffdir_style.css\" />\n";
print "<link rel=\"SHORTCUT ICON\" href=\"/images/noaa_sm.jpg\" />\n";

print "</HEAD><BODY>

<div id=\"border\">
<div id =\"container\">
<div id=\"topmenu\"></div>
<div id=\"header\"></div>

<div id=\"content\">
<p>
<center>
<span class=\"style24\">PIFSC Staff Directory</span> 
</center>
<p>&nbsp;</p>
</div>




</BODY></HTML>";
}




sub footer{
print "<HTML><HEAD>\n";

print "<link rel=\"stylesheet\" type=\"text/css\" href=\"/style/staffdir_style.css\" />\n";

print "</HEAD><BODY>

<p>&nbsp;</p>


<div id=\"footer\">
<p><span class=\"style8\">Please send questions or comments to <a href=\"mailto:PIFSC.Librarian\@noaa.gov\">Allyson Ora</a>.<br></span>
</div>     



</body>

</html>
";
}			
	
		










