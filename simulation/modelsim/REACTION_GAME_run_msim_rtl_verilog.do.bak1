transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+E:/altera/15.0/practice_stuff/reaction_game {E:/altera/15.0/practice_stuff/reaction_game/REACTION_GAME_MCOUNTER.sv}
vlog -sv -work work +incdir+E:/altera/15.0/practice_stuff/reaction_game {E:/altera/15.0/practice_stuff/reaction_game/REACTION_GAME.sv}

