#
# Wrapper routine for geometries that consist of a single molecule
#
namespace eval ::mbtools::system_generation {}

namespace eval ::mbtools::system_generation::singlemol {


    namespace export create_singlemol
}

# ::mbtools::system_generation::singlemol::create_singlemol --
#
# 
proc ::mbtools::system_generation::singlemol::create_singlemol { args } {
    ::mmsg::send [namespace current] "placing a single molecule"

    global ::mbtools::system_generation::moltypeskey
    global ::mbtools::system_generation::boxl
    global ::mbtools::system_generation::topology
    global ::mbtools::system_generation::notopo
    global ::mbtools::system_generation::trappedmols
    global ::mbtools::system_generation::trappedmolsupdated
    set options {
	{c.arg   "  0.0 0.0 0.0 "   "location of the molecule"  }
	{o.arg    "  0.0 0.0 1.0  " "orientation of the molecule" }
	{trapflag.arg {0 0 0} "which coordinates to trap molecule center of mass"}
	{ctrap.arg   ""   "position of the trap center"  }
	{trapspring.arg   "20"   "spring constant for the trap"  }
	{bondl.arg     "1.0"   "bond length between atoms"  }
    }
    set usage "Usage: create_singlemol  c:o:trap:ctrap:trapspring:bondl"
    array set params [::cmdline::getoptions args $options $usage]

    set trapflag $params(trapflag)
    set trapspring $params(trapspring)
    if { [llength $params(ctrap)] > 0 } {
	set ctrap $params(ctrap)
    } else {
	set ctrap $params(c)
    }


    # Retrieve the molecule information for this molecule type

    set mol [lindex $topology 0]
    set typekey [::mbtools::system_generation::matchtype [lindex $mol 0]]

#    puts "singlmol: placing lipid $mol $params(c) $params(o)"
    ::mbtools::system_generation::placemol $mol $params(c) -orient $params(o)



    # Check particle consistency
    if { [setmd n_part] != [expr [::mbtools::utils::maxpartid $topology] + 1] } {
	mmsg::err [namespace current] "espresso has [setmd n_part] particles but [expr [::mbtools::utils::maxpartid $topology] +1] were specified in topology "
    }

    # Special condition for constraints is that they
    # should not contribute to the topology
    if  { [lindex $typekey 1] == "sphericalconstraint" } {
	set notopo 1
	unset topology
    }

    # Give the first particle as the molid initially. Later it is substituted with a molecule number
    set trappedmolsupdated 0
    lappend trappedmols [list [lindex $mol 1] $ctrap $trapspring $trapflag ]

}