extends Node
class_name Pathfinder

const DIRECTIONS = [Vector2(0, -1), Vector2(0, 1), Vector2(-1, 0), Vector2(1, 0), Vector2(-1, -1), Vector2(-1, 1), Vector2(1, -1), Vector2(1, 1)]
const DIRECTIONS_MANHATTAN = [Vector2(0, -1), Vector2(0, 1), Vector2(-1, 0), Vector2(1, 0),]

var ROW
var COL
var room_borders : Rect2
var floor_history : Array
var maze_original : Array
var maze : Array
var scale : int
var debug : bool
var sail_history:Array
var sail_routes:Array
var harbour_history:Array
var enemy_spawn_history:Array

# 地块表征参数：
# 0：未占用水域
# 1：未占用陆地
# 2：航道
# 3：码头
# 4：敌人出生点
# 5：null
# 6：被建造水域
# 7: 被占用陆地
# 8：有船的水域

# 直接传入tile_map，debug模式默认关闭
func _init(s:Object, new_debug := false):
	# 初始化maze
	ROW = s.tile_map.get_viewport().size.x
	COL = s.tile_map.get_viewport().size.y
	for x in ROW:
		var maze_column : Array = []
		maze_column.resize(COL)
		maze_column.fill(0)
		maze_original.append(maze_column)
	# 添加陆地、航线、码头、出生点信息
	var ground_history = s.tile_map.get_used_cells(1)
	for ground_position in ground_history:
		maze_original[ground_position.x][ground_position.y] = 1
	sail_history = s.tile_map.get_used_cells(2)
	for sail_position in sail_history:
		maze_original[sail_position.x][sail_position.y] = 2
	harbour_history = s.tile_map.get_used_cells(3)
	for harbour_position in harbour_history:
		maze_original[harbour_position.x][harbour_position.y] = 3
	enemy_spawn_history = s.tile_map.get_used_cells(3)
	for enemy_spawn_position in enemy_spawn_history:
		maze_original[enemy_spawn_position.x][enemy_spawn_position.y] = 3
	debug = new_debug
	scale = s.tile_map.tile_set.tile_size.x
	room_borders.position = Vector2.ZERO
	room_borders.size = Vector2(s.tile_map.get_used_rect().size)
	maze = maze_original
	print(maze)
	reload_map_data(s)
	initialize_sail_routes()


# 等效于tilemap的map_to_local方法
func get_standard_position(current_position):
	return Vector2(int(current_position.x/scale), int(current_position.y/scale)) - room_borders.position

# 等效于tilemap的local_to_map方法	
func get_global_position(normalized_position):
	return Vector2(normalized_position.x * scale + scale/2, normalized_position.y * scale + scale/2)
		
# 获取当前坐标所处地块的中心点，用来建造建筑用
func get_tile_center(position:Vector2):
	return get_global_position(get_standard_position(position))
	
func reload_map_data(s:Object):
	# 清除所有舰船地图信息
	for i in ROW:
		for j in COL:
			if maze[i-1][j-1] == 8:
				maze[i-1][j-1] = 0
	# 清洗地图数据和重新整理地图要素
	for map_object in s.tile_map.get_children():
		if map_object.is_in_group("Ship"):
			var temp = get_standard_position(map_object.global_position)
			maze[temp.x][temp.y] = 8
			map_object.start_location = get_tile_center(map_object.global_position)
			map_object.reparent(s.get_node("ShipLayer"))
		if map_object.is_in_group("Building"):
			var temp = get_standard_position(map_object.global_position)
			maze[temp.x][temp.y] += 6
			map_object.start_location = get_tile_center(map_object.global_position)
			map_object.reparent(s.get_node("BuildingLayer"))
	# 重新加载所有舰船地图信息
	for ship in s.get_node("ShipLayer").get_children():
		if ship.is_in_group("Ship"):
			var temp = get_standard_position(ship.global_position)
			maze[temp.x][temp.y] = 8
		
#输入起点和终点，获得一条路径，路径的坐标为全局坐标，可以直接拿来用		
func find_path(start, end):
	if end == Vector2.ZERO:
		return null
	var start_normalized = get_standard_position(start)
	var end_normalized = get_standard_position(end)
	var path_normalized = astar(maze, start_normalized, end_normalized)
	if path_normalized == null:
		return null
	for i in path_normalized.size():
		path_normalized[i] = (room_borders.position + path_normalized[i]) * scale + Vector2(scale/2, scale/2)
	#debug_node在node_tree中的位置根据项目而异，需要灵活变通，先全部注释掉了，防止出bug
	#if debug == true:
		#for child in self.get_parent().get_children():
			#if child.is_in_group("debug"):
				#child.queue_free()
		#for i in path_normalized:
			#var debug_scene = load("res://Scenes/Debug/debug_node.tscn")
			#var debug = debug_scene.instantiate()
			#debug.position = i
			#self.get_parent().add_child(debug)
	return path_normalized

 
# Check if a cell is valid (within the grid)
func is_valid(row, col):
	return (row >= 0) and (row < ROW) and (col >= 0) and (col < COL)
 
# Check if a cell is unblocked
func is_unblocked(grid, row, col):
	return grid[row][col] != 1 && grid[row][col] != 3
 
# Check if a cell is the destination
func is_destination(row, col, dest):
	return row == dest[0] and col == dest[1]
 
# Calculate the heuristic value of a cell (Euclidean distance to destination)
func calculate_h_value(row, col, dest):
	return ((row - dest[0]) ** 2 + (col - dest[1]) ** 2) ** 0.5
 
# Trace the path from source to destination
func trace_path(cell_details, dest):
	print("The Path is ")
	var path : Array
	var row = dest[0]
	var col = dest[1]
 
	# Trace the path from destination to source using parent cells
	while not (cell_details[row][col].parent.x == row and cell_details[row][col].parent.y == col):
		path.append(Vector2(row, col))
		var temp_row = cell_details[row][col].parent.x
		var temp_col = cell_details[row][col].parent.y
		row = temp_row
		col = temp_col
 
	# Add the source cell to the path
	path.append(Vector2(row, col))
	# Reverse the path to get the path from source to destination
	path.reverse()
 
	# Print the path
	for i in path:
		print("->" + str(i) + " ")
	print()
	return path
 
# Implement the A* search algorithm
func astar(grid, src, dest):
	var steps = 0
	# Check if the source and destination are valid
	if not is_valid(src[0], src[1]) or not is_valid(dest[0], dest[1]):
		print("Source or destination is invalid")
		return
 
	# Check if the source and destination are unblocked，这段根据需求可能会删除
	if not is_unblocked(grid, src[0], src[1]) or not is_unblocked(grid, dest[0], dest[1]):
		print("Source or the destination is blocked")
		return
 
	# Check if we are already at the destination
	if is_destination(src[0], src[1], dest):
		print("We are already at the destination")
		return
 
	# Initialize the closed list (visited cells)
	# Initialize the details of each cell
	var closed_list = []
	var cell_details = []
	for i in ROW:
		closed_list.append([])
		cell_details.append([])
		for j in COL:
			closed_list[i].append(false)
			cell_details[i].append(Pathfinding_Node.new())
 
	# Initialize the start cell details
	var i = src[0]
	var j = src[1]
	cell_details[i][j].f = 0
	cell_details[i][j].g = 0
	cell_details[i][j].h = 0
	cell_details[i][j].parent.x = i
	cell_details[i][j].parent.y = j
 
	# Initialize the open list (cells to be visited) with the start cell
	var open_list = []
	open_list.append([0.0, i, j])
 
	# Initialize the flag for whether destination is found
	var found_dest = false
 
	# Main loop of A* search algorithm
	while len(open_list) > 0:
		# Pop the cell with the smallest f value from the open list
		var p = open_list[0]
		var current_index = 0
		for index in len(open_list):
			if open_list[index][0] < p[0]:
				p = open_list[index]
				current_index = index
		open_list.pop_at(current_index)
		# Mark the cell as visited
		i = p[1]
		j = p[2]
		closed_list[i][j] = true
 
		# For each direction, check the successors
		for dir in DIRECTIONS:
			var new_i = i + dir[0]
			var new_j = j + dir[1]
 
			# If the successor is valid, unblocked, and not visited
			if is_valid(new_i, new_j) and is_unblocked(grid, new_i, new_j) and is_unblocked(grid, new_i, new_j - dir[1]) and is_unblocked(grid, new_i - dir[0], new_j) and not closed_list[new_i][new_j]:
				# If the successor is the destination
				if is_destination(new_i, new_j, dest):
					# Set the parent of the destination cell
					cell_details[new_i][new_j].parent.x = i
					cell_details[new_i][new_j].parent.y = j
					print("The destination cell is found")
					# Trace and print the path from source to destination
					var result = trace_path(cell_details, dest)
					found_dest = true
					return result
				else:
					# Calculate the new f, g, and h values
					var g_new = cell_details[i][j].g + 1.0
					var h_new = calculate_h_value(new_i, new_j, dest)
					var f_new = g_new + h_new
 
					# If the cell is not in the open list or the new f value is smaller
					if cell_details[new_i][new_j].f == float('inf') or cell_details[new_i][new_j].f > f_new:
						# Add the cell to the open list
						steps += 1
						print(steps)
						open_list.append([f_new, new_i, new_j])
						# Update the cell details
						cell_details[new_i][new_j].f = f_new
						cell_details[new_i][new_j].g = g_new
						cell_details[new_i][new_j].h = h_new
						cell_details[new_i][new_j].parent.x = i
						cell_details[new_i][new_j].parent.y = j
 
	# If the destination is not found after visiting all cells
	if not found_dest:
		print("Failed to find the destination cell")


# 更新地图信息，并重新寻路
func maze_update_and_reroute(start, end, position_array:PackedVector2Array):
	for i in position_array:
		maze_update("ground", i)
	return find_path(start, end)
	
# 重置地图信息为初始化时的值并重新寻路
func maze_reset_and_reroute(start, end):
	maze_reset()
	return find_path(start, end)
			
# 更新地图信息，传入的变量为新的陆地阻挡
func maze_update(type:String, position:Vector2):
		var temp = get_standard_position(position)
		if type == "ground":
			maze[temp.x][temp.y] = 1
		if type == "water":
			maze[temp.x][temp.y] = 0
		
# 更新地图信息，传入的变量为新的建筑
func maze_add_building(position:Vector2):
	var temp = get_standard_position(position)
	maze[temp.x][temp.y] += 6

func maze_add_ship(position:Vector2):
	var temp = get_standard_position(position)
	maze[temp.x][temp.y] = 8
	
	
# 重置地图信息为初始化时的值
func maze_reset():
	maze = maze_original
	
func initialize_sail_routes():
	var sail_destination = []
	for i in harbour_history:
		if maze[i.x + 1][i.y] == 2:
			sail_destination.append(Vector2(i.x + 1, i.y))
		if maze[i.x][i.y + 1] == 2:
			sail_destination.append(Vector2(i.x, i.y + 1))
		if maze[i.x - 1][i.y] == 2:
			sail_destination.append(Vector2(i.x - 1, i.y))
		if maze[i.x][i.y - 1] == 2:
			sail_destination.append(Vector2(i.x, i.y - 1))
	for i in sail_destination:
		var single_sail_route = []
		get_next_route(single_sail_route, i)
		sail_routes.append(single_sail_route)
		
func get_next_route(result:Array, position:Vector2, parent_position:=Vector2(-1,-1)):
	var temp = []
	for direction in DIRECTIONS_MANHATTAN:
		if maze[(position + direction).x][(position + direction).y] == 2:
			temp.append(position + direction)
	# 当前有父节点，寻找与父节点不同的子节点
	if parent_position != Vector2(-1,-1):
		for i in temp.size():
			if temp[i - 1] == parent_position:
				temp.pop_at(i - 1)
		# 寻到终点了
		if temp == []:
			return
		else:
			result.append(temp[0])
			get_next_route(result, temp[0], position)
	# 当前无父节点，直接寻找下一个子节点
	else:
		result.append(temp[0])
		get_next_route(result, temp[0], position)
	
# 判断当前位置是否是可扩展的近海地块，传入全局坐标
func is_shallow_water(position:Vector2):
	var temp = get_standard_position(position)
	if maze[temp.x][temp.y] != 0:
		return false
	if temp.x == 0:
		if temp.y == 0:
			return maze[temp.x + 1][temp.y] % 2 || maze[temp.x][temp.y + 1] % 2 && not maze[temp.x][temp.y]
		if temp.y == maze[0].size() - 1:
			return maze[temp.x + 1][temp.y] % 2 || maze[temp.x][temp.y - 1] % 2 && not maze[temp.x][temp.y]
		return maze[temp.x + 1][temp.y] % 2 || maze[temp.x][temp.y - 1] % 2 || maze[temp.x][temp.y + 1] % 2 && not maze[temp.x][temp.y]
	if temp.x == maze[0].size() - 1:
		if temp.y == 0:
			return maze[temp.x - 1][temp.y] % 2 || maze[temp.x][temp.y + 1] % 2 && not maze[temp.x][temp.y]
		if temp.y == maze[0].size() - 1:
			return maze[temp.x - 1][temp.y] % 2 || maze[temp.x][temp.y - 1] % 2 && not maze[temp.x][temp.y]
		return maze[temp.x - 1][temp.y] % 2 || maze[temp.x][temp.y - 1] % 2 || maze[temp.x][temp.y + 1] % 2 && not maze[temp.x][temp.y]
	return maze[temp.x + 1][temp.y] % 2 || maze[temp.x - 1][temp.y] % 2 || maze[temp.x][temp.y + 1] % 2 || maze[temp.x][temp.y - 1] % 2 && not maze[temp.x][temp.y]
	
# 判断当前位置是否是不可扩展的深海地块，传入全局坐标
func is_deep_water(position:Vector2):
	var temp = get_standard_position(position)
	# 如果是航线或敌人出生点
	if maze[temp.x][temp.y] == 2 || maze[temp.x][temp.y] == 4:
		return true
	# 不是航线，水域和敌人出生点
	if maze[temp.x][temp.y] != 0:
		return false
	# 如果是码头
	if maze[temp.x][temp.y] == 3:
		return false
	return not is_shallow_water(position)
	
func is_building(position:Vector2):
	var temp = get_standard_position(position)
	# 如果是航线或敌人出生点
	if maze[temp.x][temp.y] != 7:
		return false
	else:
		return true
	
func is_constructable_land(position:Vector2):
	var temp = get_standard_position(position)
	# 如果不是空地块
	if maze[temp.x][temp.y] != 1:
		return false
	else:
		return true
	
# 获取港口的全局坐标
func get_harbour_position():
	var temp = []
	for i in harbour_history:
		temp.append(get_global_position(i))
	return temp
	
# 获取敌人出生点的全局坐标
func get_enemy_spawn_position():
	var temp = []
	for i in enemy_spawn_history:
		temp.append(get_global_position(i))
	return temp
	
# 获取所有航线的路径，从码头到终点，返回的是全局坐标
func get_sail_routes():
	var sail_routes_global = sail_routes.duplicate(true)
	for single_sail_route in sail_routes_global:
		for i in single_sail_route.size():
			single_sail_route[i - 1] = get_global_position(single_sail_route[i - 1])
	return sail_routes_global
		
