#! perl shebang line
# This script is used to automate the retrieval and extraction of student assignments from UTSOnline
# This script will work with 5 tutorial groups - edit parameters passed to setupAndExtract to increase or decrease number of tutorials
# Update the text files T1.txt to T5.txt with the student numbers for each tutorial each semester

#update this variable with the location of 7zip
$zip_path = 'C:\"Program Files"\7-Zip\7z';
#update this variable with the location of unrar
$rar_path = 'C:\"Program Files"\unrar\unrar';

# Remove or add any tutorials as required
# Make sure a matching txt file exists in the same diectory as this script
&setupAndExtract(T1, T2, T3);

#DO NOT CHANGE ANY CODE BELOW HERE!!!!

# This subroutine creates all required directories, move and extract all student assignments
sub setupAndExtract
{
	my(@tutorials) = @_;
	#create the directories for each tute and each student in each tute
	foreach my $tutorial (@tutorials)
	{
 		chomp($tutorial);
 		&buildDirectory($tutorial, "$tutorial.txt");
	} 
	#unzip the file(s) from UTSOnline
	system("$zip_path x *.zip");
	#move the student assignments to the correct tute and student number
	foreach my $tutorial (@tutorials)
	{
	 	chomp($tutorial);
	 	&moveZipFiles($tutorial, "$tutorial.txt");
	} 
	#unzip all the student assignments - 7z, zip & rar formats are handled using 7zip and unrar
	foreach my $tutorial (@tutorials)
	{
		 chomp($tutorial);
		 &unzipFiles($tutorial, "$tutorial.txt");
	} 
}

# This subroutine is used to create the following directory structure
# Tutorial Group
#	Student Number
sub buildDirectory 
{
	my($tute, $dat_file) = @_;
	mkdir("$tute");
	open(DAT, $dat_file) || die("Could not open file!");
	my @students = <DAT>;
	foreach my $student (@students)
	{
 		chomp($student);
 		system("mkdir $tute\\$student");
	} 
	close(DAT);
	print "$tute setup complete\n";
}

# This subroutine is used to recursively move files in the following directory structure
# Tutorial Group
#	Student Number
sub moveZipFiles
{
	my($tute, $dat_file) = @_;
	open(DAT, $dat_file) || die("Could not open file!");
	my @students = <DAT>;
	foreach my $student (@students)
	{
 		chomp($student); # remove carriage return from data
 		# search this directory ie root
 		# get the list of files to move - assume students dont follow instructions
 		my @lines = `dir /B *.zip *.rar *.7z *.txt *.java *.class *.ctxt *.pkg *.bluej *.doc *.docx *.jar`; 
 		use Cwd;
 		my $dir = getcwd; # need path to the root directory
 		foreach my $line (@lines) 
 		{
    			chomp($line);
    			if($line =~ m/$student/)
    			{
    				my $slash = '/';
    				my $backslash = "\\";
    				$dir =~ s/$slash/$backslash/g; #replace unix \ with / for DOS - really ugly but works :)
    				my $file = "$dir\\$line";
    				my $new_path = "$dir\\$tute\\$student\\$line";
				#print "Moving $file to $new_path\n"; # was used in debugging
				system("move $file $new_path");
    			}
 		} 
	} 
	close(DAT);
	print "$tute move complete\n";
}

# This setup subroutine is used to recursively unzip files in the following directory structure
# Tutorial Group
#	Student Number
sub unzipFiles
{
	my($tute, $dat_file) = @_;
	open(DAT, $dat_file) || die("Could not open file!");
	my @students = <DAT>;
	foreach my $student (@students)
	{
 
 		chomp($student);
 		chdir ("$tute\\$student");
 		#unzip all compressed files - errors will display 
 		#because at least one of the following types does not exist
 		#ie there will only be (at most) a zip, a rar or a 7z file for extraction
 		system("$zip_path x *.zip");
 		system("$zip_path x *.7z");
 		system("$rar_path e *.rar");
 		chdir('..\..');
	} 
	close(DAT);
	print "$tute unzip complete\n";
}