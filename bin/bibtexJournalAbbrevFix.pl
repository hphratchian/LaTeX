#!/usr/bin/perl
#
#   Load arguments.
#
    ($journalList,$input_file,$output_file,$strings_file) = @ARGV;
    $journalColumn = 2;
    $DEBUG = 0;
#
#   Process the journal list file to build the bibtexJournalString hash.
#
    open JOURNALFILE,"< $journalList";
    while (<JOURNALFILE>){
      $temp = $_;
      chomp($temp);
      @tempList = split /\t/, $temp;
      unless($tempList[$journalColumn-1]){
        $bibtexJournalFullName = $tempList[0];
      }else{
        $bibtexJournalFullName = $tempList[$journalColumn-1];
      }
      unless($bibtexJournalFullNameCheckHash{$bibtexJournalFullName}){
        push(@listOfJournals,$bibtexJournalFullName);
      }
      $bibtexJournalFullNameCheckHash{$bibtexJournalFullName} += 1;
      $bibtexJournalTagName = $bibtexJournalFullName;
      $bibtexJournalTagName = &standardizeJournalName($bibtexJournalTagName);
      if($DEBUG){
        print "\nbibtexJournalFullName = $bibtexJournalFullName\n";
        print "bibtexJournalTagName  = $bibtexJournalTagName\n";
      }
      foreach $journalName (@tempList){
        $journalName = &standardizeJournalName($journalName);
        if($DEBUG){print "\tWorking on -->$journalName<--\n";}
        $journalName2fullName{$journalName} = $bibtexJournalFullName;
        $journalName2tagName{$journalName} = $bibtexJournalTagName;
      }
    }
    close JOURNALFILE;

#
#   Print out the full journals list...
#
    if($DEBUG){
      foreach $temp (@listOfJournals){
        print "$temp\n";
      }
    }
#
#   Go through the BibTeX file looking for all journal BibTeX fields.
#
    print "Reading through file $input_file\n";
    open INFILE,"< $input_file";
    while (<INFILE>){
      $temp = $_;
      chomp($temp);
      if($temp =~ /^\s*\@.+\{(.*),\s*$/){
        $currentBibTag = $1;
      }
      if($temp =~ /^(\s*journal\s*=\s*)\{(.*)\},\s*$/i){
        $journalFieldPrefix = $1;
        $journalField = $2;
        $journalField = &standardizeJournalName($journalField);
        if($DEBUG){
          print "Found journal in standardized form: $journalField\n";
          print "\tTag Name: $journalName2tagName{$journalField}\n\n";
        }
        unless($journalName2tagName{$journalField}){
          $unknownJournals += 1;
          $newLine = "$temp";
          push(@unknownJournalsList,$journalField);
          push(@unknownBibTags,$currentBibTag);
        }else{
          $newLine = "$journalFieldPrefix$journalName2tagName{$journalField},";
          $tagJournalName = $journalName2tagName{$journalField};
          unless($journalCounter{$tagJournalName}){
            $journalCounter{$tagJournalName} += 1;
            push(@foundJournalList,$tagJournalName);
          }else{
            $journalCounter{$tagJournalName} += 1;
          }
        }
        push(@outputBibTeX,$newLine)
      }else{
        push(@outputBibTeX,$temp)
      }
    }
    close INFILE;
#
#   If an output file was provided on the command line, write out a new
#   BibTeX file.
#
    if($output_file){
      open OUTFILE,"> $output_file";
      foreach $temp (@outputBibTeX){
        print OUTFILE "$temp\n";
      }
      close OUTFILE;
    }
#
#   Report how many distinct journals were found. If requested, also write
#   the file of BibTeX @STRINGS lines for the journal tags.
#
    if($unknownJournals){
      print "N UNKNOWN Journals Found = $unknownJournals\n";
      foreach $temp (@unknownBibTags){
        print "\t$temp\n";
      }
    }else{
      print "0 UNKNOWN Journals Found!\n";
    }
    $nJournals = @foundJournalList;
    print "N Journals Found = $nJournals\n";
    if($strings_file){open STRINGSFILE,"> $strings_file"};
    foreach $temp (@foundJournalList){
      $journalFullName = $journalName2fullName{$temp};
      print "\t$journalCounter{$temp}\t$journalFullName\n";
      if($strings_file){
        $journalFullName =~ s/ /~/g;
        print STRINGSFILE "\@string\{$temp = \{$journalFullName\}\}\n";
      }
    }
    if($strings_file){close STRINGSFILE};


    sub standardizeJournalName{
#
#   This subroutine takes a journal name, removes special symbols, removes
#   spaces, and makes all letters uppercase.
#
      use strict;
      my($inName) = @_;
      chomp($inName);
      $inName =~ s/\(//g;
      $inName =~ s/\)//g;
      $inName =~ s/\.//g;
      $inName =~ s/,//g;
      $inName =~ s/://g;
      $inName =~ s/-//g;
      $inName =~ s/ //g;
      $inName = uc($inName);
      return ($inName);
    }
      

