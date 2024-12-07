extends Camera2D

var list = []
var listy =[]
var x =0
var y =0;
var largestx:float;
var smallestx;
var largesty;
var smallesty;
var margin = 200;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	list.clear()
	listy.clear()
	var player1 = get_parent().get_node("players").get_child(0)
	largestx = player1.global_position.x;
	smallestx = player1.global_position.x;
	largesty = player1.global_position.y;
	smallesty = player1.global_position.y;
	for n in get_parent().get_node("players").get_children():
		var playerx = n.global_position.x
		var playery = n.global_position.y
		list.push_back(playerx)
		listy.push_back(playery)
		if(n.get_node("Chain").get_node("Tip").is_visible_in_tree()):
			playerx = n.get_node("Chain").get_node("Tip").global_position.x
			playery = n.get_node("Chain").get_node("Tip").global_position.y
			
		#getting all values of x and y of players to get average
		
		# getting largest and smallest values of x and y of the players
		if playerx>largestx:largestx = playerx
		if playerx<smallestx:smallestx = playerx
		if playery>largesty:largesty = playery
		if playery<smallesty:smallesty = playery
	var changex = clamp(1152/(abs(largestx-smallestx)+margin*2),.001,.6)
	var changey = clamp(648/(abs(largesty-smallesty)+margin*2),.001,.6)
	if(changex>changey): 
		zoom = Vector2(changey,changey)
		$huds.scale = Vector2(1/changey,1/changey)
	else:
		zoom = Vector2(changex, changex)
		$huds.scale = Vector2(1/changex,1/changex)
	#make so negatives dont matter
	x=0
	y=0
	for n in list:
		x+=n
	x/=list.size()
	for n in listy:
		y+=n
	y/=listy.size()
	global_position = Vector2(x,y)
	
	
