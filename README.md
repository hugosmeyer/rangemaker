# rangemaker
Create C7 NTP range entries for ranges with many exceptions using convenient inputs

usage: rangemaker -b bigpieces.txt -s smallpieces.txt -c example_config.ini
    -r will print the ranges for verification
    -t will show and add up the range sizes as a control.
    -e will print the commands you may want to run

Example files are provided:

example_config.ini
example_bigpieces.txt 
example_smallpieces.txt 
example_output.txt 

It is assumed that the NS entries will start with CC and NDC followed by MSIN.

Big Pieces File:
    Lines in the big pieces file should only have CC and NDC concatenated followed by GTRC.

Small Pieces File:
    FROM and TO values in the small pieces file may start with:
        - CC, NDC and MSIN (full or partial)
        - MCC, NS and MSIN (full or partial MSIN)
    Lines may contain:
        - FROM GTRC (TO will be set to the same value as FROM automatically)
        - FROM TO GTRC
   
I was told that the E/// software requires NS values to be sequential and never overlap. Measuring the size of each and adding that up should always be 10,000,000,000 or 1,000,000,000 per range, based on MNC length. This is for you to check. The total is printed and no warnings will appear if it is wrong. If the ranges add up nicely it shows that there are no missing or overlapping pieces, that is, if there are no equal and opposite mistakes... It is your network, you need to be sure.

How it works:

1) Build "FROM TO GTRC" ranges based on the config, big pieces and small pieces.
2) Create the NS entries for each range created in 1) with the range_squash function.
3) Stich them all together and print them out based on the command line flags.

This is free stuff, there is no warranty.
