#!/usr/bin/perl

#
# $Id: ftw.pl,v 1.2 2001/01/25 19:53:21 raptor Exp $
#
# ftw.cgi v1.0 - Antifork ftp to web html generator
# Copyright (c) 2000 Raptor <raptor@antifork.org>
#
# Simple Perl script that generates web pages
# from ftp directory trees and special comment files. 
# Written for http://www.antifork.org website.
#
# Based on an idea of Cyberknight <cyberk@antifork.org>
#


# CGI stuff
$|=1;
print "Content-type:text/html\n\n";


# Local vars
$rootdir = "/home/ftp/pub";
$baseurl = "ftp://ftp.antifork.org/pub";
$tfile = ".ftw"; # define the title file (also used for security reasons)
$maxclength = 1000; # max comment file length
$maxtlength = 1000; # max title file length
&error("ERROR: $ARGV[0] is not a valid directory") if ($ARGV[0] =~ /\.\./);
$dir = $ARGV[0];

# Check if subdir is a valid ftw directory and fetch page description
$tfile = $rootdir."/$dir"."/".$tfile;
open TITLE, $tfile or &error("ERROR: $dir is not a valid directory");
read TITLE, $title, $maxtlength;
close TITLE;

# Open and scan the directory
opendir DIR, $rootdir."/$dir" or &error("ERROR: Temporary database problem, try again later");
@files = grep { !/^\./ } readdir(DIR); # we don't want special dirs
closedir DIR;
@files = sort @files; # sort the files alphabetically

# Error control (empty directory)
&error("ERROR: No files found.") if !@files;

# Generate the HTML page header
&header;

# Get files info and print it formatted
foreach $entry (@files) {
	@fstat = stat $rootdir."/$dir"."/$entry"; 
	$size = $fstat[7]; 
	$mtime = $fstat[9];
	$time = gmtime($mtime);
	$cfile = $rootdir."/$dir"."/.$entry";
	open COMMENT, $cfile or $comment = "Sorry, a description is unavailable.";
	read COMMENT, $comment, $maxclength;
	close COMMENT;

# Handle files and directories separately
	if (-d $rootdir."/$dir"."/$entry") {
		&directory; 
	} else {
		&file;
	}
}

# Generate the HTML page footer
&footer;

exit(0);


#################### Local Functions #######################


# Print HTML header
sub header {
    	print <<END;
    	<html>
    	<head>
	<title>Antifork Research, Inc.</title>
    	</head>
    	<body bgcolor=black text=white link=skyblue vlink=lightblue marginwidth=0 marginheight=0 topmargin=0 leftmargin=0 marginright=0border=0>
	<table align=center border=0 cellspacing=1 cellpadding=1 width=90% cols=4><tr><td>&nbsp;</td></tr><tr><td><img src=/img/afk03.gif alt=Antifork></td><td colspan=3 align=center><h1>Antifork Research FTP to WEB Gateway</h1>[ <a href=/index.php>home</a> | <a href=/about.html>about</a> | <a href=/members.html>members</a> | <a href=/cgi-bin/ctw.cgi>projects</a> | <a href=/cgi-bin/ftw.cgi?/papers>papers</a> | <a href=/cgi-bin/ftw.cgi>archive</a> ]</td></tr><tr><td>&nbsp;</td></tr>
	</table>
	<table align=center border=0 cellspacing=1 cellpadding=1 width=90% cols=3><tr><td>&nbsp;</td></tr><tr><td colspan=3>$title</td></tr><tr><td>&nbsp;</td></tr>
	<tr><td bgcolor=#333399 align=left>Filename</td><td bgcolor=#333399 align=center>File Size</td><td bgcolor=#333399 align=center>Last Modified</td>
	<!--end html header-->
END
}


# Print HTML footer
sub footer {
	print <<END;
	<!--begin html footer-->
	<tr><td>&nbsp;</td></tr>
	<tr><td>&nbsp;</td></tr>
	<tr><td bgcolor=black colspan=3 align=center>Copyright (c) 2000
	<a href=mailto:info\@antifork.org>Antifork Research</a>, Inc.</td></tr>
	<tr><td>&nbsp;</td></tr>
	</table>
	<!-- Generated by FTW by raptor\@antifork.org -->
	</body>
	</html>
END
}


# Print file entry
sub file {
	$link = $baseurl."$dir"."/$entry";
	print <<END
	<tr><td align=left bgcolor=#333366><a href=$link>$entry</a></td><td align=center bgcolor=#333366>$size</td><td align=center bgcolor=#444477>$time</td></tr><tr><td align=left colspan=3 bgcolor=#000033>$comment</td></tr>
END
}


# Print directory entry
sub directory {
	$link = $dir."/$entry";
	print <<END
	<tr><td align=left bgcolor=#333366><a href=/cgi-bin/ftw.cgi?$link><i>$entry</i></a></td><td align=center bgcolor=#333366>$size</td><td align=center bgcolor=#444477>$time</td></tr><tr><td align=left colspan=3 bgcolor=#000033>Directory: $comment</td></tr>
END
}


# Error handling routine
sub error {
        print <<END;
        <html>
        <head>
	<title>Antifork Research, Inc.</title>
        </head>
        <body bgcolor=black text=white link=skyblue vlink=lightblue marginwidth=0 marginheight=0 topmargin=0 leftmargin=0 marginright=0border=0>
	<table align=center border=0 cellspacing=1 cellpadding=1 width=90% cols=4><tr><td>&nbsp;</td></tr><tr><td><img src=/img/afk03.gif alt=Antifork></td><td colspan=3 align=center><h1>Antifork Research FTP to WEB Gateway</h1>[ <a href=/index.php>home</a> | <a href=/about.html>about</a> | <a href=/members.html>members</a> | <a href=/cgi-bin/ftw.cgi?/projects>projects</a> | <a href=/cgi-bin/ftw.cgi?/papers>papers</a> | <a href=/cgi-bin/ftw.cgi>archive</a> ]</td></tr><tr><td>&nbsp;</td></tr>
	</table>
        <table align=center border=0 cellspacing=1 cellpadding=1 width=90% cols=3><tr><td>&nbsp;</td></tr><tr><td align=center colspan=3><font color=darkred><br><h3>$_[0]</h3></font></td></tr><tr><td>&nbsp;</td></tr>
END
	&footer;
	exit(-1);
}
