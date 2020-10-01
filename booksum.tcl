#! /usr/bin/env tclsh

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# Run Tcl commands showing them and their output in terminal
# (for Geany IDE esp.).
#
# Scripted by Alex Plotnikov.
#
# Use the script in terminal as:
#   tclsh ./booksum.tcl
# or, to redirect its output to a text file,
#   tclsh ./booksum.tcl > ./output.txt
#
# Also runnable in Geany IDE if its 'Execute command' set as:
#   "./%f"
# or, more pedantly,
#   tclsh "./%f"
#
# The terminal outputs contain:
#   - an underline             (     ~~~~~~~~~~~~~~~~~~~~~~~~ )
#   - an info message          (     MESSAGE (COMMENTS ETC.)  )
#   - a command to execute     (   % command                  )
#   - a command result         (     ==> result               )
#   - a catched error message  (     ==> ERROR: error message )
#
# All other terminal outputs (starting at 1st column) belong to
# commands.
#
# Commands to test are bundled into the bundle variable (see below).
#
# You can insert your own commands into the bundle variable as well as
# the d command that makes a debugging pause in the flow of commands.
#
# You should place "% " before commands to visualize them in terminal.
#
# Example of using % and d:
#
#     set bundle {
#     ...
#     ... Begin of commands bundle
#     ...
#     % oo::class create MyOwnClass {
#         ...
#         # all code from % to the end of command
#         # (i.e. enclosing brace) is visible in terminal
#         ...
#     }
#     % d   ;# this suspends the execution till pressing Enter key
#     ...
#     % myObject do something
#     ...
#     % d 2 ;# 2nd stop-over shown in terminal as 2:
#     ...
#     ... End of commands bundle
#     ...
#     }
#
# You can use also ** and ## to make a comment BEFORE % blocks.
# ** makes uppercased comment (title), ## makes a usual comment.
#
# All of this can be used for playing with scripts or examples while
# the bundle variable (just below) being stuffed your code.
#
# You can also prepare a separate "bundle" file and pass its name
# to booksum.tcl as if it were the bundle variable's value.
#
# For example, try this:
#   tclsh booksum.tcl samples/OOtcl_book.bundle
#
# See also:
#   - "TclOO Tricks" article available here:
#       http://wiki.tcl.tk/21595
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

####################################################################
# Begin of commands bundle

set bundle {

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** START

## Class Variables
% oo::class create foo {
    self export varname
    constructor {} {
        my eval upvar [[self class] varname v] v
        my eval upvar [[self class] varname w] w
    }
    method bar {} {
        variable v
        variable w
        incr v
        incr w 2
        puts "v=$v, w=$w"
    }
}
## Demoing it...
% foo create x
% x bar
% x bar
% foo create y
% y bar

% d 1st_example

## DKF: Here's how to do it by leveraging the scripted guts of TclOO (from my Tcl2k9 paper):
% proc ::oo::Helpers::classvar {name args} {
    # Get reference to class’s namespace
    set ns [info object namespace [uplevel 1 {self class}]]

    # Double up the list of varnames
    set vs [list $name $name]
    foreach v $args {lappend vs $v $v}

    # Link the caller’s locals to the
    # class’s variables
    tailcall namespace upvar $ns {*}$vs
}

% d 2nd_example_of_DKF

## Demonstrating:
% oo::class create Foo {
    method bar {z} {
        classvar x y
        return [incr x $z],[incr y]
    }
}
% Foo create a
% Foo create b
% a bar 2
% a bar 3
% b bar 7
% b bar -1
% a bar 0

**
** FINISH
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
**
}

# End of commands bundle
####################################################################

# few common procs

proc print_text {up args} {
    # outputting messages passed in args
    if {[llength args] > 0} {
        puts -nonewline "   "
        foreach a $args {
            if {$up} {
                puts -nonewline [string toupper " $a"]
            } else {
                puts -nonewline " $a"
            }
        }
    }
    puts ""
}

proc print_list {args} {
    # outputting messages passed in args as list
    global HALLO
    if {[llength args] > 0} {
        foreach a $args {
            foreach b $a { print_text 0 "$HALLO$b" }
        }
    }
}

proc ** {args} {
    # outputting MESSAGES
    set tmp ""; foreach a $args {append tmp "$a "}
    set up [expr [string match #* $tmp] ? 0 : 1]
    print_text $up $tmp
}

proc + {args} {
    # adding numbers
    # use: + num1 ?num2 num3 ...?
    set res 0
    foreach a $args { set res [expr $res + $a] }
    return $res
}

proc * {args} {
    # multiplying numbers
    # use: * num1 ?num2 num3 ...?
    set res 1
    foreach a $args { set res [expr $res * $a] }
    return $res
}

proc % {incom} {
    # innocent mimicry of command line:
    # execute 'incom' and show its results or catched error
    global HALLO
    global com
    set com $incom
    if {[string length $com] > 0} {
        if { [catch {set rez [uplevel #0 $com]} err] } {
            set err [string map {\" \'} $err] 
            print_text 0 "${HALLO}ERROR: $err"
        } else {
            if {[llength $rez] > 0} {
                print_text 0 "${HALLO}$rez"
            }
        }
    }
}

proc Exe {com} {
    # showing and executing command 'com'
    global SPACE
    global COMMD
    set com [string trimright $com "\n"]    
    set FRICK "<ABRAcadABRA>"
    set repl {"\n"}
    set repl [lappend repl $FRICK]
    set com [string map $repl $com]
    set repl $FRICK
    set repl [lappend repl "\n$SPACE"]
    set com [string map $repl $com]
    print_text 0 "\n$COMMD$com"
    % $com
}

proc d { {arg ""} } {
    # 'stop machine' - for debugging only
    puts -nonewline "\n$arg: "
    gets stdin
}

proc trim_bundle {} {
    # preparing the bundle for processing
    global bundle
    global indent
    global SPACE
    set bun [set prevt ""]
    foreach l [split $bundle \n] {
        set t [string trimleft $l]
        if {$indent==0 && [set ind [expr [string len $l]-[string len $t]]]>0} {
            set indent $ind
            set SPACE [string repeat " " $indent]
        }
        if {[string match "% *" $t]} {
            set l $t
        } elseif {[regexp {^##\s+} $t]} {
          set l "**\n** [string range $t 1 end]"
        } elseif {[regexp {^\*\*\s*} $t]} {
          set l $t
        }
        if {$bun!=""} {
            append bun \n
        }
        append bun [string trimright $l]
        set prevt $t
    }
    set bundle "**\n$bun"
}

####################################################################
# main program, huh

set SPACE "    "  ;# sets indent = 4 spaces by default
if {$::argc} {
  # read from a file (its name - 1st argument of this)
  # and put its contents into 'bundle' variable to process
  if {[catch {
    set ch [open [lindex $::argv 0]]
    chan configure $ch -encoding utf-8
    set bundle [read $ch]   ;# take samples from a file
    close $ch
  } e]} {
    puts "\n${SPACE}Error:\n${SPACE}$e\n"
  }
}

set indent 0
trim_bundle
set com ""
set COMMD "  % "
set HALLO "==> "
set COM_STRING "\n% "
set PUT_STRING "\n**"
set COM_LENGTH [string length $COM_STRING]
set PUT_LENGTH [string length $PUT_STRING]
set BUN_LENGTH [string length $bundle]
for {set i 0} {$i < $BUN_LENGTH} {} {
    set ifound [string first $COM_STRING $bundle $i]
    if {$ifound<0} {
        % [string range $bundle $i end]
        break
    } else {
        % [string range $bundle $i $ifound]
        incr ifound $COM_LENGTH
        set ifound2 [string first $COM_STRING $bundle $ifound]
        set ifound3 [string first $PUT_STRING $bundle $ifound]
        if {$ifound2 < 0} { set ifound2 $BUN_LENGTH }
        if {$ifound3 < $ifound2 && $ifound3 >= 0} {
            Exe [string range $bundle $ifound [expr $ifound3 - 1]]
            set i $ifound3
        } elseif {$ifound2 >= 0} {
            Exe [string range $bundle $ifound [expr $ifound2 - 1]]
            set i $ifound2
        } else {
            Exe [string range $bundle $ifound end]
            break
        }
    }  
}
