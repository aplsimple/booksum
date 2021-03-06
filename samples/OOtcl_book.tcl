#! /usr/bin/env tclsh

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# Code snippets from "Object Oriented Programming in Tcl"
# written and published 2017 by Ashok P. Nadkarni.
#
# Snipped by Alex Plotnikov.
#
# Prerequisites to use the code snippets:
#   - text of "Object Oriented Programming in Tcl"
#       available here:
#       http://www.magicsplat.com/articles/oo.html
#   - Tcl 8.6
#       available here:
#       http://www.tcl.tk
#
# Use the script in terminal as:
#   tclsh ./OOtcl_book.tcl
# or, to redirect its output to a text file,
#   tclsh ./OOtcl_book.tcl > ./OOtcl_output.txt
#
# Also runnable in Geany IDE if its 'Execute command' set as:
#   "./%f"
# or, more pedantly,
#   tclsh "./%f"
#
# The terminal outputs contain:
#   - an underline             (     ~~~~~~~~~~~~~~~~~~~~~~~~ )
#   - an info message          (     MESSAGE                  )
#   - a command to execute     (   % command                  )
#   - a command result         (     ==> result               )
#   - a catched error message  (     ==> ERROR: error message )
#
# All other terminal outputs (starting at 1st column) belong to
# commands.
#
# Commands to test are bundled in the bundle variable (see below).
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
#     d   ;# this suspends the execution till pressing Enter key
#     ...
#     % myObject do something
#     ...
#     d 2 ;# 2nd stop-over shown as 2:
#     ...
#     ... End of commands bundle
#     ...
#     }
#
# All of this can be used as a template for future developments or
# examples with the bundle variable (just below) being substituted.
#
# See e.g. "TclOO Tricks" article available here:
#   http://wiki.tcl.tk/21595
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

####################################################################
# Begin of commands bundle

set bundle {

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** START

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** 2.2. Creating a class

% oo::class create Account
% Account destroy

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** Check bank namespace, then creating it with 'oo:class create'

% namespace exist bank
% oo::class create bank::Account
% bank::Account destroy
% namespace exist bank

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** Creating bank namespace and Account class in it

% namespace eval bank {oo::class create Account}

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** 2.3. Destroying classes
% bank::Account destroy

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** 2.4. Defining data members

% oo::class create Account
% oo::define Account {
    variable AccountNumber Balance
}

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** 2.5. Defining methods

% oo::define Account {
    method UpdateBalance {change} {
        set Balance [+ $Balance $change]
        return $Balance
    }
    method balance {} { return $Balance }
    method withdraw {amount} {
        return [my UpdateBalance -$amount]
    }
    method deposit {amount} {
        return [my UpdateBalance $amount]
    }
}

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** The following code will crash Tcl versions prior to 8.6.2
** due to a bug in the Tcl core

% oo::class create C {method print args {puts "class: $args"}}
% C create c

**
** OK: the object calls the class print method

% c print some nonsense
% oo::define C {deletemethod print}

**
** NOT OK: print method was deleted, it's unknown for 'c' object

% c print more of the same

**
** OK: redefine print method IN OBJECT

% oo::objdefine c {method print args {puts "object: $args"}}
% c print more of the same

**
** Delete print method IN OBJECT

% oo::objdefine c {deletemethod print}

**
** NOT OK: there is NO print method IN OBJECT

% c print more of the same

**
** NOT OK: there is NO OBJECT after destroying class

% C destroy
% c print some nonsense

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** 2.6. Constructors and destructors

% oo::define Account {
    constructor {account_no} {
        puts "Reading account data for $account_no from database"
        set AccountNumber $account_no
        set Balance 1000000
    }
    destructor {
        puts "[self] saving account data to database"
    }
}

**
** Now Account class was oo::defineD with constructor & destructor
**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** 3.1. Creating an object
**
** - 1st way:
% set acct [Account new 3-14159265]
**
** - 2nd way:
% Account create smith_account 2-71828182

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** The created objects are Tcl commands
** and as such can be created in any namespace

% namespace eval my_ns {Account create my_account 1-11111111}
% Account create my_ns::another_account 2-22222222

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** 3.2. Destroying objects
** (and namespaces)

% my_ns::my_account destroy
% my_ns::my_account balance
% namespace delete my_ns
% my_ns::another_account balance

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** 3.3. Invoking methods

% $acct balance
% $acct deposit 1000

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** 3.4. Accessing data members

% set [info object namespace $acct]::Balance 5000
% $acct balance

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** 4. Inheritance

% oo::class create SavingsAccount {
    superclass Account
    variable MaxPerMonthWithdrawals WithdrawalsThisMonth
    constructor {account_no {max_withdrawals_per_month 3}} {
        next $account_no
        set MaxPerMonthWithdrawals $max_withdrawals_per_month
    }
    method monthly_update {} {
        my variable Balance
        my deposit [format %.2f [* $Balance 0.005]]
        set WithdrawalsThisMonth 0
    }
    method withdraw {amount} {
        if {[incr WithdrawalsThisMonth] > $MaxPerMonthWithdrawals} {
            error "You are only allowed $MaxPerMonthWithdrawals\
                   withdrawals a month"
        }
        next $amount
    }
}

% oo::class create CheckingAccount {
    superclass Account
    method cash_check {payee amount} {
        my withdraw $amount
        puts "Writing a check to $payee for $amount"
    }
}

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** 4.2. Data members in derived classes

% SavingsAccount create savings S-12345678 2
% CheckingAccount create checking C-12345678
% savings withdraw 1000
% savings withdraw 1000
% savings withdraw 1000
% savings monthly_update
% checking cash_check Payee 500
% savings cash_check Payee 500

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** 4.3. Multiple inheritance
** Buy high, sell low.
** Historically, the author's trading strategy :)

% oo::class create BrokerageAccount {
    superclass Account
    method buy {ticker number_of_shares} {
        puts "Buy high"
    }
    method sell {ticker number_of_shares} {
        puts "Sell low"
    }
}

% oo::class create CashManagementAccount {
    superclass CheckingAccount BrokerageAccount
}

% CashManagementAccount create cma CMA-00000001
% cma cash_check Payee 500
% cma buy GOOG 100

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** 5.1. Object-specific methods

% proc freeze {account_obj} {
    oo::objdefine $account_obj {
        method UpdateBalance {args} {
            error "Account is frozen. Don't mess with the IRS, dude!"
        }
        method unfreeze {} {
            oo::objdefine [self] { deletemethod UpdateBalance unfreeze }
        }
    }
}

% proc unfreeze {account_obj} {
    oo::objdefine $account_obj {deletemethod UpdateBalance}
}

% smith_account withdraw 100
% freeze smith_account
% smith_account withdraw [smith_account balance]
% $acct withdraw 100
% smith_account unfreeze
% smith_account withdraw 100

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** 5.2. Changing an object's class

% set acct [SavingsAccount new C-12345678]
% $acct monthly_update
% $acct cash_check Payee 100
% oo::objdefine $acct class CheckingAccount
% $acct cash_check Payee 100
% $acct monthly_update
% $acct destroy

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** 6. Using Mixins

% oo::class create EFT {
    variable ef1
    constructor {args} {
      variable ef1
      set ef1 2
      next {*}$args
    }
    method transfer_in {from_account amount} {
        puts "Pretending $amount received from $from_account"
        my deposit $amount
    }
    method transfer_out {to_account amount} {
        my withdraw $amount
        puts "Pretending $amount sent to $to_account"
    }
    method setf1 {{i 1}} {
      incr ef1 $i
    }
    method getf1 {} {
      puts ef1=$ef1
    }
}

% oo::define CheckingAccount {mixin EFT}
% checking transfer_out 0-12345678 100
% checking balance
% CheckingAccount create checking2 acc2-N123001000

# % oo::objdefine savings {mixin EFT}
% oo::define SavingsAccount {mixin EFT}
% savings transfer_in 0-12345678 100
% savings balance
% savings setf1
% savings setf1 3
% savings getf1
% checking setf1 10
% checking getf1
% checking2 getf1
% savings getf1

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** 6.1. Using multiple mixins

% oo::class create BillPay {}  ; # empty class for demo only
% oo::define CheckingAccount {mixin BillPay EFT}
% oo::define CheckingAccount {
    mixin EFT
    mixin -append BillPay
}

**
** Note the use of -append above.
** By default, the mixin command overwrites existing mixin
**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** 7. Filter methods

% oo::objdefine smith_account {
    method Log args {
        my variable AccountNumber
        puts "Log([info level]): $AccountNumber [self target]: $args"
        return [next {*}$args]
    }
    filter Log
}

% smith_account deposit 100

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** 7.1. Defining a filter class

% oo::objdefine smith_account {
    filter -clear
    deletemethod Log
}

**
** Note -clear option to clear any currently defined filters

% oo::class create Logger {
    method Log args {
        my variable AccountNumber
        puts "Log([info level]): $AccountNumber [self target]: $args"
        return [next {*}$args]
    }
}
% oo::objdefine smith_account {
    mixin Logger
    filter Log
}
% smith_account withdraw 500

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** 8.1. Method chain order

% oo::class create ClassMixin { method m {} {} }
% oo::class create ObjectMixin { method m {} {} }
% oo::class create Base {
    mixin ClassMixin
    method m {} {}
    method classfilter {} {}
    filter classfilter
    method unknown args {}
}
% oo::class create SecondBase { method m {} {} }
% oo::class create Derived {
    superclass Base SecondBase
    method m {} {}
}
% Derived create o
% oo::objdefine o {
    mixin ObjectMixin
    method m {} {}
    method objectfilter {} {}
    filter objectfilter
}

**
** Introspection via the info object call command:

% print_list [info object call o m]

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** 8.2. Method chain for unknown methods

% print_list [info object call o nosuchmethod]

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** 8.3. Retrieving the method chain for a class

% print_list [info class call Derived m]

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** 8.4. Inspecting method chains within method contexts

% catch {Base destroy} 1
% oo::class create Base {
    constructor {} {puts [self call]}
    method m {} {puts [self call]}
}
% oo::class create Derived {
    superclass Base
    constructor {} {puts [self call]; next}
    method m {} {
        puts [self call]; next
    }
}
% Derived create o
% o m

**
** Note the special form <constructor> for constructors.
** Destructors similarly have the form <destructor>.
**
** Constructor and destructor method chains are only available
** through self call, not through info class call.

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** 8.5. Looking up the next method in a chain

% oo::define Derived {
    method m {} { puts "Next method in chain is [self next]" }
}
% o m

% oo::class create GeneralPurposeMixin {
    constructor args {
        puts "Initializing GeneralPurposeMixin";
        next {*}$args
    }
}
% oo::class create MixerA {
    mixin GeneralPurposeMixin
    constructor {} {puts "Initializing MixerA"}
}
% MixerA create mixa

**
** So far so good.
** Now let us define another class that also uses the mixin.

% oo::class create MixerB {mixin GeneralPurposeMixin}
% MixerB create mixb

**
** This is where self next can help.
** Let us redefine the constructor for GeneralPurposeMixin

% oo::define GeneralPurposeMixin {
    constructor args {
        puts "Initialize GeneralPurposeMixin";
        if {[llength [self next]]} {
            next {*}$args
        }
    }
}
% MixerB create mixb

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** 8.6. Controlling invocation order of methods

% oo::class create ClassWithOneArg {
    constructor {onearg} {puts "Constructing [self class] with $onearg"}
}
% oo::class create ClassWithNoArgs {
    constructor {} {puts "Constructing [self class]"}
}
% oo::class create DemoNextto {
    superclass ClassWithNoArgs ClassWithOneArg
    constructor {onearg} {
        nextto ClassWithOneArg $onearg
        nextto ClassWithNoArgs
        puts "[self class] successfully constructed"
    }
}

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** 9.1. Enumerating objects

% info class instances Account
% info class instances SavingsAccount
% info class instances Account ::oo::*

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** 9.2. Enumerating classes

% info class instances oo::class
% info class instances oo::class *Mixin

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** 9.3. Introspecting class relationships

% info class superclasses CashManagementAccount
% info class superclasses ::oo::class
% info class subclasses Account
% info class mixin CheckingAccount

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** 9.4. Checking class membership

% info object class savings

% info object class savings SavingsAccount
% info object class savings Account
% info object class savings CheckingAccount

% info object mixins savings

% catch {Base destroy}
% oo::class create Base {
    method m {} {
        puts "Object class: [info object class [self object]]"
        puts "Method class: [self class]"
    }
}
% oo::class create Derived { superclass Base }
% Derived create o
% o m

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** 9.5. Enumerating methods

% info class methods CheckingAccount
% info class methods CheckingAccount -private
% info class methods CheckingAccount -all
% info class methods CheckingAccount -all -private
% info object methods smith_account -private

% info object filters smith_account

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** 9.6. Retrieving method definitions

% info class definition Account UpdateBalance
% info class constructor Account

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** 9.8. Introspecting filter contexts

% oo::define Logger {
    method Log args {
        if {[lindex [self target] 1] eq "withdraw"} {
            my variable AccountNumber
            puts "Log([info level]): $AccountNumber [self target]: $args"
        }
        return [next {*}$args]
    }
}

% smith_account deposit 100
% smith_account withdraw 100

% oo::define Logger {
    method Log args {
        puts [self filter]
        return [next {*}$args]
    }
}
% smith_account withdraw 1000

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** 9.9. Object identity

% oo::define Account {method get_ns {} {return [self namespace]}}
% savings get_ns
% set acct [Account new 0-0000000]
% $acct get_ns
% info object namespace $acct

**
** Notice when we create an object using new
** the namespace matches the object command name.
**
** This is an artifact of the implementation and
** this should not be relied on.
**
** In fact, like any other Tcl command,
** the object command can be renamed.

% rename $acct temp_account
% temp_account get_ns

**
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** 9.10. Enumerating data members

% info class variables SavingsAccount

% info object variables smith_account
% info object vars smith_account

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
    # printing MESSAGES
    print_text 1 $args
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

####################################################################
# main program, huh

set com ""
set SPACE "    "
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
