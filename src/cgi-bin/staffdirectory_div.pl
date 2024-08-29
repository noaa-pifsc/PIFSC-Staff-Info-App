#!/usr/bin/perl -wT

use DBI;
use strict;
use File::Copy;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use lib qw(.);
use MyConnectStaff;


my $query = new CGI;

print $query->header;

#Establish database connection
my $dbh = MyConnectStaff::ConnectDB();
if(!$dbh) {die("Database Connection failed. Please contact the Webmaster.");}

		my @search; #array that contains the search criteria $search[0] or $search[1] or $search[2]
		my $search_string;
		my $sql;
		my @keywords1;
		my @keywords2;
		# my @search;
		my @searchfields;
		my @searchphrase1;
		my @searchphrase2;
		my $string_final;
		my $string;
		my $m;
		my $n;
		my $string1;
		my $string2;

	$query = qq{SELECT picadm.vw_nonpii_pers_v.lastname, picadm.vw_nonpii_pers_v.firstname, picadm.vw_nonpii_pers_v.email_addr, picadm.vw_nonpii_pers_v.workph1,
		picadm.vw_nonpii_pers_v.worksite, picadm.vw_nonpii_pers_v.room_num, picadm.vw_nonpii_pers_v.div_name, picadm.vw_nonpii_pers_v.div_abbr,
		picadm.vw_nonpii_pers_v.program,
		picadm.vw_nonpii_pers_v.position_name,
		picadm.vw_nonpii_pers_v.workph2
		FROM picadm.vw_nonpii_pers_v
		WHERE NOT picadm.vw_nonpii_pers_v.worksite = 'DC'
                AND NOT picadm.vw_nonpii_pers_v.worksite = 'WPRFMC'
		AND NOT picadm.vw_nonpii_pers_v.worksite like 'PIR%'
		AND NOT picadm.vw_nonpii_pers_v.worksite like 'NOAA-PRC'
		ORDER BY div_abbr, program, lastname asc
		};

		my $stmt = $dbh->prepare($query);

		#Execute sql
		$stmt->execute() || die "The query was not made: $DBI::errstr";

		my $alink;
		my @row;
		my $i;
		my $p;
		my @count;
		my $count;
		my $row;



		@count = $stmt->fetchrow_array();
		$count = $#count+1;

		#frees up any resources associated with the query we just ran.
		$stmt->finish();


		#Execute sql
		$stmt->execute();

		header();


				print "<center><table id='table1' class='display' border='1' bordercolor='#999999' cellpadding='3' bgcolor='#FFFFFF'>";
				print "<thead><tr bgcolor='dddddd'>
				<th align='left'><a href=\"../cgi-bin/staffdirectory.pl\"><span class=\"style46\"><b><u>NAME</u></b></span></th>
				<th align='left'><span class=\"style42\">EMAIL</span></th>
				<th align='left'><span class=\"style42\">PHONE</span></th>
				<th align='left'><a href=\"../cgi-bin/staffdirectory_div.pl\"><span class=\"style46\"><b><u>DIVISION</u></b></span></a></th>
				<th align='left'><a href=\"../cgi-bin/staffdirectory_loc.pl\"><span class=\"style46\"><b><u>LOCATION</u></b></span></th>
				<th align='left'><span class=\"style42\">POSITION TITLE</span></th></tr>
				</thead>



				";


		while (@row = $stmt->fetchrow_array)
			{
				my $div = "$row[7]";
				my $prog = "-$row[8]";


			#These columns have the potential to be null

			if ($row[3] eq "")
				{$row[3]="";} #phone1
			if ($row[4] eq "")
				{$row[4]="Other";}#site
			if ($row[5] eq "")
				{$row[5]="";}#room num
			if ($row[6] eq "")
				{ $row[6]=""; $row[7]=""; $row[8]="";}#division
			if ($row[7] eq "")
				{$div = "";}#div abbr
			if ($row[8] eq "")
				{$prog = "";}#program
			if ($row[10] eq "")
				{$row[10] = "";} #phone2




		print "<tbody>
		<tr><td><span class=\"style46\">$row[0], $row[1]</span></td>
			<td><span class=\"style46\"><a href=\"mailto:$row[2]\">$row[2]</a></span></td>
		<td><span class=\"style46\">$row[3]<br>$row[10]</span></TD>
		<TD><span class=\"style46\">$div$prog</span></td>
		<td><span class=\"style46\">$row[4]<br>$row[5]</span></td>
		<td><span class=\"style46\">$row[9]</span></td> </tr>
		</tbody>

"
;






		}#End of While

print "</table></center><p></div>
";

$stmt->finish();

#disconnect from the database.
$dbh->disconnect();



footer();




#####SUBROUTINES#######################################################
sub header{
	#Start HTML Page
print "<HTML><HEAD><TITLE>PIFSC Staff Directory - Full List</TITLE>\n";

print "</HEAD><BODY>
<a name=\"top\"></a>

<center><br>
<span class=\"style24\">PIFSC Staff Directory</span>
<br><br>
<span class=\"style32\"><font color=\"white\"><b>Click the appropriate column header to sort by name, division, or work location.<br>
For corrections, contact <a href=\"mailto:Jeffrey.Jones\@noaa.gov\"><font color=\"orange\">Jeffrey.Jones\@noaa.gov</font></a></b></font></span>

</center>

<br>

</BODY></HTML>";
}




sub footer{
print "<HTML><HEAD>\n";

print "<link rel=\"stylesheet\" type=\"text/css\" href=\"../style/staffdir_style.css\" />\n";

print "</HEAD><BODY>

<a href=\"#top\"><img src=\"../img/blue_arrow.gif\" border=\"0\"></a>

<center><b><a href=\"http://picahi.nmfs.local/staffsearch.html\">New Search</a></b>
</center>
<p>

<div id=\"footer\">
<p><span class=\"style8\">Please send questions or comments to <a href=\"mailto:Katie.Davis\@noaa.gov\">Katie Davis</a><br></span>
</div>



</body>

</html>
";
}












