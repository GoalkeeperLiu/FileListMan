#!/usr/bin/perl
use strict;

#Global Variables
my @DEF;
my @INC;
my @RTL;


###############################################################################
#Main Process
#   1. Check parameters
#	2. Get filelist format
#	3. Loop each files
#	4. Analyze the file and generate Defines, Includes, and files
###############################################################################

#Check Input parameters 
my $argc = @ARGV;
if( $argc < 2 )
{
	&PrintUsage;
}




#Sub Functions
sub PrintUsage()
{
	print" FileListMan Usage: \n";
	print"     \.\/FileListMan.pl <file format> <filelist0> <filelist1> ... <filelistn>\n";
	print"     <file format>: \n";
	print"			sim		: simulation file list, fpga memory model in default;\n";
	print"			sim_asic: simulation file list, asic memory model;\n";
	print"			dc 		: DC file list;\n";
	print"			qsf		: quartus qsf file list;\n";
	print"			zebu	: zebu file list;\n";
	exit;
}


###############################################################################
# Analyze Filelist
#	Generate DEFs, INCs, Files
###############################################################################
sub AnalyzeFile()
{
	my $fl = @_[0];
	#check if exist
	if( open FLIN, "<$fl" )
	{
		print "Failed to open $fl. Please check it.";
		exit;
	}
	
	while( <FLIN> )
	{
		chomp;
		#remove the heading space characters. 
		/^\s*//;
		if( /^\/\// ) #comments
		{
			last;
		}
		else
		{
			my @parts = split "\s*", $_;	
			foreach (@parts)
			{
				if( /^\+define/ )	#Macro defines
			{
				my @parts = split "\s*", $_;
				if( !(&HaveExist( $parts[0], @DEF )) )
				{
					push $parts[0], @DEF;
				}
			}
			else {
				if( /^\+incdir/ ) #Include directories
				{
					my @parts = split "\s*", $_;
					if( !(&HaveExist( $parts[0], @INC ) ) )
					{
						push $parts[0], @INC;
					}
				}
				else {
					if( /^[-|\+]/ ) #Some eda tools options
					{
						;
					}
					else { 	#RTL
						my @parts = split
					}
				}
			}
		} 
			}
	}
	
	close FLIN;
}