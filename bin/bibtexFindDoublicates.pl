#!/usr/bin/perl
#
#   Load arguments.
#
    @bibtexFileList = @ARGV;
    $DEBUG = 0;
    $duplicatesCount = 0;
#
#   Go through the BibTeX file looking for all of the key fields we use to
#   identify doublicate entries.
#
    $input_file = $bibtexFileList[0];
    print "Reading through file $input_file\n";
    $currentJournalField = "-";
    $currentYearField = "-";
    $currentPagesField = "-";
    open INFILE,"< $input_file";
    while (<INFILE>){
      $temp = $_;
      chomp($temp);
      if($DEBUG){print "temp: $temp\n"};
      if($temp =~ /^\s*\@.+\{(.*),\s*$/){
        $oldBibTag = $currentBibTag;
        $currentBibTag = $1;
        if($notFirst){
          $entryTag = "$currentJournalField.$currentYearField.$currentPagesField";
          if($DEBUG){print "\t\t$oldBibTag : $entryTag\n"};
          if($entryHash{$entryTag}){
            print "Duplicates: $oldBibTag / $entryHash{$entryTag}\n";
            $duplicatesCount += 1;
          }else{
            $entryHash{$entryTag} = $oldBibTag;
            if($DEBUG){print "*** Filling entryHash, $entryTag with $oldBibTag\n"};
          }
          $currentJournalField = "-";
          $currentYearField = "-";
          $currentPagesField = "-";
        }else{
          $notFirst = 1;
        }
      }elsif($temp =~ /^\s*journal\s*=\s*[\{\"]?(.*)[\}\"]?,?\s*$/i){
        $currentJournalField = $1;
        if($DEBUG){print "FOUND JOURNAL = $currentJournalField\n"};
      }elsif(/^\s*year\s*=\s*[\{\"](\d+)[\}\"],?\s*$/i){
        $currentYearField = $1;
        if($DEBUG){print "FOUND YEAR    = $currentYearField\n"};
      }elsif(/^\s*pages\s*=\s*[\{\"](\d+)[\}\"],?\s*$/i){
        $currentPagesField = $1;
        if($DEBUG){print "FOUND PAGE 1  = $currentPagesField\n"};
      }elsif(/^\s*pages\s*=\s*[\{\"](\d+)\s*-+\s*.*[\}\"],?\s*$/i){
        $currentPagesField = $1;
        if($DEBUG){print "FOUND PAGE 2  = $currentPagesField\n"};
      }
    }
    $entryTag = "$currentJournalField.$currentYearField.$currentPagesField";
    if($DEBUG){print "\t\t$currentBibTag : $entryTag\n"};
    if($entryHash{$entryTag}){
      print "Duplicates: $currentBibTag / $entryHash{$entryTag}\n";
      $duplicatesCount += 1;
    }else{
      $entryHash{$entryTag} = $currentBibTag;
      if($DEBUG){print "*** Filling entryHash, $entryTag with $currentBibTag\n"};
    }
    close INFILE;
    print "\n\nNumber of Duplicates = $duplicatesCount\n";
    print "\nAll Done!\n";
