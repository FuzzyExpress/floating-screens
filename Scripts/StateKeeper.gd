class_name StateKeeper
extends Node

var Controller : XRController3D

var ID : int
var clickL : float = 0
var clickR : float = 0
var clickM : float = 0
var clickSettings : float = 0

var hit : bool = false
var str : float = 0

var c : Color

func getController():
	return Controller

func update() -> void: 
	str = max(clickL, clickR, clickM, clickSettings)
	if   clickL >= G.PinchThresh:			c = G.click
	elif clickR >= G.PinchThresh:			c = G.erase
	elif clickM >= G.PinchThresh:			c = G.middle
	elif clickSettings >= G.PinchThresh:	c = G.setting
	elif hit:								c = G.hover
	else:									c = G.idle
