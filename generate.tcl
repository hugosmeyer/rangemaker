#!//usr/bin/tclsh
interp recursionlimit {} 20000
proc debug {str} { 
    global argv
    if {[lsearch $argv debug ] >= 0} {
        puts $str
    }
}

proc commify {num {sep ,}} {
    while {[regsub {^([-+]?\d+)(\d\d\d)} $num "\\1$sep\\2" num]} {}
    return $num
}

proc range_squash { start end } {

    if {$start == $end} {
        return $start 
    }
    set output {}

    set len [string length $start]

    #calculate the base
    set cnt 0
    while {$cnt < $len} {
        if {[string range $start 0 $cnt] != [string range $end 0 $cnt]} {
            set baselen [expr $cnt -1]
            break
        }
        incr cnt 1
    }

    set base  [string range $start 0 $baselen]
    set left  [string trimright [string range $start $cnt end] 0]
    set right [string trimright [string range $end   $cnt end] 9]
   
    while {[string length $left]  < [string length $right] } { append left  0}
    while {[string length $right] < [string length $left]  } { append right 9}

    debug base=$base
    debug left=$left
    debug right=$right

    if {$left == $right} { 
        return [list $base$left ] 
    }

    #build the centre piece
   
    set bigleft  [string range $left 0 0]
    set bigright [string range $right 0 0]

    if {[regexp {^0*$} $left]} {
        set bigleft 0
        set  left {}
    }

    if {[regexp {^9*$} $right]} {
        if {$bigright < 9} { 
            incr bigright 1
        }
        set right {}
    }

    while {$bigright >= $bigleft} {
         debug "centre $base$bigleft"
        lappend output $base$bigleft
        incr bigleft 1
    }
    
    # build the left side
    while {[string length $left] >= 2} {
        set digcnt [string range $left end end]
        set left [string range $left 0 [expr [string length $left] - 2]]
        while {$digcnt <= 9} {
            debug "adding left $base$left$digcnt"
            lappend output $base$left$digcnt
            incr digcnt
        }
    }
    #build the right side
    # we don't want 9999 at the end, one is enough.
    while {[string length $right] >= 2} {
    debug right=$right
        set digcnt [string range $right end end]
        set right  [string range $right 0 [expr [string length $right] - 2]]
        while {$digcnt >= 0} {
            if {[lsearch -glob $output $base$right$digcnt?] < 0 } {
                debug "adding right  $base$right$digcnt"
                lappend output $base$right$digcnt
            }
            incr digcnt -1
        }
        if {[regexp {^0*$} $right]} {
            set right 0
        }
    }
    # Strip the damage done be the right side
    set new_output {}
    set found 1
    foreach entry $output { 
        if {[lsearch -regexp $output ^$entry\[0-9\] ] < 0} {
            lappend new_output $entry
        } else {
            set found 1
        }
    }
       
    return $new_output
}

proc expand {str dig len} {
    regsub {^65510} $str {2783} str
    regsub {^65512} $str {2773} str
    regexp {(\d*)} $str dump str
    while { [string length $str] < $len } { 
        append str $dig
    }
    debug "expand string length = [string length $str]"
    return $str
}



proc makearange {range} { 
    global smallpieces
    global ranges
    lassign $range biggerfirst biggerlast biggerdest
    set count 0
    set biggerlastplace $biggerfirst
    foreach smallpiece [lsort -index 0 $smallpieces] {

        lassign $smallpiece smallerfirst smallerlast smallerdest

        if {$smallerfirst < $biggerfirst || $smallerlast > $biggerlast } {
            # The range don't fit so let it go
            continue
        }

        if {$smallerfirst == $biggerfirst && $smallerlast == $biggerlast} {
            #Range overlap
            #puts "discard $smallpiece overlap"
            continue
        }

        if {$smallerdest == $biggerdest} {
            # This range goes to the same place as the containing range so skip it
            #discard $smallpiece "same as containing"
            continue
        }
        if {$smallerfirst >= $biggerfirst && $smallerlast <= $biggerlast } {

            #The range fits, so process it
        
            if {$smallerfirst != $biggerfirst} {
                if {[makearange    [list $biggerfirst [expr $smallerfirst - 1] $biggerdest] ] == 0} {               
                    lappend ranges [list $biggerfirst [expr $smallerfirst - 1] $biggerdest]
                    
                }
                incr count 1
            }
            
            if {[makearange    [list $smallerfirst $smallerlast $smallerdest] ] == 0} {
                lappend ranges [list $smallerfirst $smallerlast $smallerdest]
                
            }
            incr count 1

            if {$smallerlast != $biggerlast} {
                if {[makearange    [list [expr $smallerlast + 1] $biggerlast $biggerdest] ] == 0} {
                    lappend ranges [list [expr $smallerlast + 1] $biggerlast $biggerdest]
                    
                }
                incr count 1
            }
            set biggerfirst $biggerlast
        }
    }
    return $count
}

proc rangify {line} {
     if {[llength $line] == 2} { 
        set start [expand [lindex $line 0] 0 14 ]
        set end   [expand [lindex $line 0] 9 14 ]
        set dest  [lindex $line 1]
    } elseif {[llength $line] == 3} { 
        set start [expand [lindex $line 0] 0 14 ]
        set end   [expand [lindex $line 1] 0 14 ]
        set dest  [lindex $line 2] 
    } 
    return [list $start $end $dest]
}

# set ranges [list [list 27830000000003 27830000009999 5001]]
# foreach range $ranges {
#     lassign $range start end dest 
#     foreach ething [range_squash $start $end] {
#         puts [format {%-15s %s} $ething $dest]
#     }
# }

#exit


set bigpieces {} 
set bh [open [lindex $argv 0]]
while {[gets $bh line] >= 0} {
    lappend bigpieces [rangify $line]
}
close $bh

set smallpieces {} 
set sh [open [lindex $argv 1]]
while {[gets $sh line] >= 0} {
    lappend smallpieces [rangify $line]
}
close $sh
set smallpieces [lsort -index 0 $smallpieces]

set ranges {}
foreach bigpiece $bigpieces {
    if {[makearange $bigpiece] == 0} {
        lappend ranges $bigpiece
    }
}

set total 0
foreach range $ranges {
    lassign $range start end dest 
    set size [expr $end - $start + 1]
    incr total $size
    puts [format {%14d %14d %-10s %15s} $start $end $dest [commify $size]]
}
puts [format {%14s %14s %-10s %15s} "" "" "" [commify $total]]

set total 0
puts "range count = [llength $ranges]"
foreach range [lsort -unique $ranges] {
    lassign $range start end dest 
    foreach ething [range_squash $start $end] {
        set size [expr int(pow(10,[expr 14 - [string length $ething]]))]
        incr total $size
        puts [format {%-15s %-8s %16s} $ething $dest [commify $size]]
    }
}
puts [format {%-15s %-8s %16s} "" "" [commify $total]]