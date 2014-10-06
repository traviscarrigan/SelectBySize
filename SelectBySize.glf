# =============================================================================
# SELECTION SCRIPT - SELECT ENTITIES BY SIZE
# =============================================================================
# Written by Travis Carrigan
# 
# v1: Dec. 12, 2012
# v2: Jan. 04, 2013
# v3: Jan. 07, 2013
#



###############################################################
#-- INITIALIZATION 
#--
#-- Load Glyph package and prepare Pointwise. Also define
#-- the working directory.
#--
###############################################################
# Load Glyph package and Tk
package require PWI_Glyph
pw::Script loadTk



###############################################################
#-- USER INTERFACE DEFINITION
#--
#-- Define the graphical user interface.
#--
###############################################################
global type size compOper name

# Entity type: Database, Connector, Domain, Block
set type "Database"

# Basic size specification
set size 2.9
set compOper "<"
set oper "done"

# Advanced size specification (use $length variable)
# Overwrites basic size specification
#set size {($length < 1.5) || ($length > 3.0 && $length < 10.0)}

# Group name
set name "SelectedEntities"








wm title . "Select Entities By Size"

set labelWidth 10
set entryWidth 10
set buttonWidth 10

set entTypes [list "Database" "Connector" "Domain" "Block"]
set compOpers [list "<" ">"]
set opers [list "or" "and" "done"]

grid [ttk::frame .f -padding "5 5 5 5"]
grid [ttk::combobox .f.cb1 -state readonly -textvariable type -values $entTypes -width $labelWidth] -column 0 -row 0 -sticky w

grid [ttk::frame .f.sf -padding "5 5 5 5" -borderwidth 2 -relief sunken] -column 0 -row 1 -sticky nwes
grid [ttk::label .f.sf.lb1 -text "Size" -width 5] -column 0 -row 1 -sticky w
grid [ttk::combobox .f.sf.cb2 -state readonly -justify center -textvariable compOper -values $compOpers -width 3] -column 1 -row 1 -sticky w
grid [ttk::entry .f.sf.e1 -justify right -width 15 -textvariable size] -column 2 -row 1 -sticky e
grid [ttk::combobox .f.sf.cb3 -state readonly -textvariable oper -values $opers -width 5] -column 3 -row 1 -sticky w

set seprow 3
set grprow 4

bind .f.sf.cb3 <<ComboboxSelected>> { 

    if {[.f.sf.cb3 get]== "or"} {

        grid [ttk::label .f.sf.lb3 -text "Size" -width 5] -column 0 -row 2 -sticky w
        grid [ttk::combobox .f.sf.cb4 -state readonly -justify center -textvariable compOper -values $compOpers -width 3] -column 1 -row 2 -sticky w
        grid [ttk::entry .f.sf.e3 -justify right -width 15 -textvariable size] -column 2 -row 2 -sticky e
        grid [ttk::combobox .f.sf.cb5 -state readonly -textvariable oper -values $opers -width 5] -column 3 -row 2 -sticky w

        set seprow 4
        set grprow 5

        foreach w [winfo children .f.sf] {grid configure $w -padx 5 -pady 5}

    }

}

grid [ttk::separator .f.sf.sep -orient horizontal] -column 0 -row $seprow -columnspan 4 -sticky ew
grid [ttk::label .f.sf.lb2 -text "Group Name"] -column 0 -row $grprow -columnspan 2 -sticky ew
grid [ttk::entry .f.sf.e2 -justify right -textvariable name] -column 2 -row $grprow -columnspan 2 -sticky ew

grid [ttk::frame .f.bf] -column 0 -row 2 -sticky e
grid [ttk::button .f.bf.b2 -text "Group" -width $buttonWidth -command Main] -column 0 -row 0 -padx 10 -sticky e
grid [ttk::button .f.bf.b3 -text "Cancel" -width $buttonWidth -command exit] -column 1 -row 0 -sticky e


foreach w [winfo children .f] {grid configure $w -padx 5 -pady 5}
foreach w [winfo children .f.sf] {grid configure $w -padx 5 -pady 5}
::tk::PlaceWindow . widget








###############################################################
#-- PROC: SelectByType
#--
#-- Select all entities of a given type.
#--
###############################################################
proc SelectByType {type} {

    switch -exact $type {

        Database { set ents [pw::Database getAll] }

        Connector { set ents [pw::Grid getAll -type pw::Connector] }

        Domain { set ents [pw::Grid getAll -type pw::Domain] }

        Block { set ents [pw::Grid getAll -type pw::Block] }

    }

    return $ents

}



###############################################################
#-- PROC: SearchBySize
#--
#-- Search for entities by extents box size.
#--
###############################################################
proc SearchBySize {ents size compOper} {

    set found {}

    foreach ent $ents {

        set vec  [$ent getExtents]
        set vecA [lindex $vec 0]
        set vecB [lindex $vec 1]

        set length [pwu::Vector3 length [pwu::Vector3 subtract $vecA $vecB]]

        if {[expr $length $compOper $size]} {
            lappend found $ent
        }

    }

    return $found

}



###############################################################
#-- PROC: CreateGroup
#--
#-- Create a group for selection purposes.
#--
###############################################################
proc CreateGroup {type ents name} {

    switch -exact $type {

        Database { set entType pw::DatabaseEntity }

        Connector { set entType pw::Connector }

        Domain { set entType pw::Domain }

        Block { set entType pw::Block } 

    }

    set group [pw::Group create]

        $group setName $name
        $group setEntityType $entType

        foreach ent $ents {
            $group addEntity $ent
        }

}



###############################################################
#-- MAIN SCRIPT
#--
#-- Main script body or procedure.
#--
###############################################################
proc Main {} {

    global type size compOper name

    set allEnts [SelectByType $type]
    set selEnts [SearchBySize $allEnts $size $compOper]
    CreateGroup $type $selEnts $name
    exit

}



#
# END
#
