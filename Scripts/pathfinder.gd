extends Node
class_name Pathfinder

const DIRECTIONS = [Vector2(0, -1), Vector2(0, 1), Vector2(-1, 0), Vector2(1, 0), Vector2(-1, -1), Vector2(-1, 1), Vector2(1, -1), Vector2(1, 1)]

var ROW
var COL
var room_borders : Rect2
var floor_history : Array
var maze_original : Array
var maze : Array
var scale : int
var debug : bool

# 直接传入tile_map，debug模式默认关闭
func _init(tile_map:Object, new_debug := false):
	# 初始化maze
	ROW = tile_map.get_viewport().size.x
	COL = tile_map.get_viewport().size.y
	for x in ROW:
		var maze_column : Array = []
		maze_column.resize(COL)
		maze_column.fill(0)
		maze_original.append(maze_column)
	# 添加陆地信息
	var ground_history = tile_map.get_used_cells(1)
	for ground_position in ground_history:
		maze_original[ground_position.x][ground_position.y] = 1
	debug = new_debug
	scale = tile_map.tile_set.tile_size.x
	room_borders.position = Vector2.ZERO
	room_borders.size = Vector2(tile_map.get_viewport().size/scale)
	maze = maze_original


# 等效于tilemap的map_to_local方法
func get_standard_position(current_position):
	return Vector2(int(current_position.x/scale), int(current_position.y/scale)) - room_borders.position
		
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
		if path_normalized[i][0] == 0:
			path_normalized[i] = (room_borders.position + path_normalized[i]) * scale + Vector2(scale*3/4, scale/2)
			continue
		if path_normalized[i][0] == maze.size() - 1:
			path_normalized[i] = (room_borders.position + path_normalized[i]) * scale + Vector2(scale*1/4, scale/2)
			continue
		if path_normalized[i][1] == 0:
			path_normalized[i] = (room_borders.position + path_normalized[i]) * scale + Vector2(scale*1/2, scale*3/4)
			continue
		if path_normalized[i][1] == maze[0].size() - 1:
			path_normalized[i] = (room_borders.position + path_normalized[i]) * scale + Vector2(scale*1/2, scale/4)
			continue
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
	return grid[row][col] == 0
 
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
	maze_update(position_array)
	return find_path(start, end)
	
# 重置地图信息为初始化时的值并重新寻路
func maze_reset_and_reroute(start, end):
	maze_reset()
	return find_path(start, end)
			
# 更新地图信息，传入的变量为新的陆地阻挡
func maze_update(position_array:PackedVector2Array):
	for i in position_array:
		var temp = get_standard_position(i)
		maze[temp.x][temp.y] = 1

# 重置地图信息为初始化时的值
func maze_reset():
	maze = maze_original
	
# 判断当前位置是否是近海地块，传入全局坐标
func is_shallow_water(position:Vector2):
	var temp = get_standard_position(position)
	if maze[temp.x][temp.y] != 0:
		return false
	if temp.x == 0:
		if temp.y == 0:
			return maze[temp.x + 1][temp.y] == 1 || maze[temp.x][temp.y + 1] == 1
		if temp.y == maze[0].size() - 1:
			return maze[temp.x + 1][temp.y] == 1 || maze[temp.x][temp.y - 1] == 1
		return maze[temp.x + 1][temp.y] == 1 || maze[temp.x][temp.y - 1] == 1 || maze[temp.x][temp.y + 1] == 1
	if temp.x == maze[0].size() - 1:
		if temp.y == 0:
			return maze[temp.x - 1][temp.y] == 1 || maze[temp.x][temp.y + 1] == 1
		if temp.y == maze[0].size() - 1:
			return maze[temp.x - 1][temp.y] == 1 || maze[temp.x][temp.y - 1] == 1
		return maze[temp.x - 1][temp.y] == 1 || maze[temp.x][temp.y - 1] == 1 || maze[temp.x][temp.y + 1] == 1
	return maze[temp.x + 1][temp.y] == 1 || maze[temp.x - 1][temp.y] == 1 || maze[temp.x][temp.y + 1] == 1 || maze[temp.x][temp.y - 1] == 1