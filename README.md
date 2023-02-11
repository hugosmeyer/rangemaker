# rangemaker
Create C7 NTP range entries for ranges with many exceptions from easy inputs

It still needs a lot of work but if you are desperate, it is usable already.


usage: generate.tcl bigpieces.txt smallpieces.txt

Examples:

bigpieces.txt
1234 4040
1256 5050

You should have these things and know what they mean, it will be different for each operator and country.

smallpieces.txt
1234000000001 1234000000066 2020
1234010011246 2030

The output will be the ranges needed for the command file.
