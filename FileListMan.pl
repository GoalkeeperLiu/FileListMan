#!/usr/bin/perl
use strict;

#Global Variables
my @DEF;
my @INC;
my @RTL_VERILOG;
my @RTL_VHDL;


###############################################################################
#Main Process
#   1. Check parameters
#   2. Get filelist format
#   3. Loop each files
#   4. Analyze the file and generate Defines, Includes, and files
#   5. Output filelist format
###############################################################################

#Check Input parameters 
my $argc = @ARGV;
if( $argc < 2 )
{
    &PrintUsage;
}

#Get filelist format
my $filefmt = shift @ARGV;

#Loop each files
foreach ( @ARGV )   #Loop each filelist
{
    &AnalyzeFile();
}

#Output Filelist format
&OutputFileListFormat( );

#Print Statistic Data
my $def_cnt = @DEF;
my $inc_cnt = @INC;
my $rtl_cnt = @RTL;
print "$def_cnt Macros\n";
print "$inc_cnt Include Directories\n";
print "$rtl_cnt RTL files\n";
print "Finish!\n";




#Sub Functions
###############################################################################
# Print Usage
###############################################################################
sub PrintUsage()
{
    print" FileListMan Usage: \n";
    print"     \.\/FileListMan.pl <file format> <filelist0> <filelist1> ... <filelistn>\n";
    print"     <file format>: \n";
    print"            sim       : simulation file list with fpga memory model in default;\n";
    print"            sim_asic  : simulation file list with asic memory model;\n";
    print"            dc        : DC file list;\n";
    print"            qsf       : quartus qsf file list;\n";
    print"            zebu      : zebu file list;\n";
    exit;
}


###############################################################################
# Analyze Filelist
#    Generate DEFs, INCs, Files
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
    
    print "Analyzing $fl\n";
    
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
                if( /^\/\//)  #Comments
                {
                    next;
                }
                
                if( /^\+define/ )    #Macro defines
                {
                    if( !(&HaveExist( $_, @DEF )) )
                    {
                        push $_, @DEF;
                    }
                }
                else {
                    if( /^\+incdir/ ) #Include directories
                    {
                        if( !(&HaveExist( $_, @INC ) ) )
                        {
                            push $_, @INC;
                        }
                    }
                    else {
                        if( /^[-|\+]/ ) #Some eda tools options
                        {
                            next;
                        }
                        else {     #RTL
                            #Check if file exist
                            if( -f $_ )
                            {
                                if( !(&HaveExist( $_, @RTL )) )
                                {
                                    push $_, @RTL;
                                }
                            }
                            else {
                                print "$_ is not a real file. Please check it.";
                                exit;
                            }
                        }
                    }
                }
            }
        }
    }
    
    close FLIN;
}