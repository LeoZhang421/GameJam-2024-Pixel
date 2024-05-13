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

# Called when the node enters the scene tree for the first time.
func _init(new_room_borders, new_floor_history, new_scale, new_debug := false):
	debug = new_debug
	scale = new_scale
	room_borders.position = new_room_borders.position/scale
	room_borders.size = new_room_borders.size/scale
	floor_history = new_floor_history
	for x in room_borders.size.x:
		var maze_column : Array = []
		for y in room_borders.size.y:
			var point = room_borders.position + Vector2(x,y)
			if floor_history.has(point):
				maze_column.append(0)
			else:
				maze_column.append(1)
		maze_original.append(maze_column)
	maze = maze_original
	ROW = maze.size()
	COL = maze[maze.size() - 1].size()


#下面这条需要写测试用例(已在enemy.gd中添加）
func get_standard_position(current_position):
	return Vector2(int(current_position.x/scale), int(current_position.y/scale)) - room_borders.position
		
		
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
	if debug == true:
		for child in get_parent().get_parent().get_children():
			if child.is_in_group("debug"):
				child.queue_free()
		for i in path_normalized:
			var debug_scene = load("res://Scenes/Debug/debug_node.tscn")
			var debug = debug_scene.instantiate()
			debug.position = i
			get_parent().get_parent().add_child(debug)
	return path_normalized
		
#func astar(start, end):
#
#	# Create start and end node
#	print("finding from" + str(start) + "to" + str(end))
#	var start_node = Pathfinding_Node.new(null, start)
#	start_node.g = 0
#	start_node.h = 0
#	start_node.f = 0
#	var end_node = Pathfinding_Node.new(null, end)
#	end_node.g = 0
#	end_node.h = 0
#	end_node.f = 0
#
#	# Initialize both open and closed list
#	var open_list = []
#	var closed_list = []
#	var steps = 0
#	# Add the start node
#	open_list.append(start_node)
#
#	# Loop until you find the end
#	while len(open_list) > 0:
#
#		# Get the current node
#		var current_node = open_list[0]
#		var current_index = 0
#		for index in open_list.size():
#			if open_list[index].f < current_node.f:
#				current_node = open_list[index]
#				current_index = index
#
#		# Pop current off open list, add to closed list
#		open_list.pop_at(current_index)
#		closed_list.append(current_node)
#
#		# Found the goal
#		if current_node.position == end_node.position:
#			var path : Array = []
#			var current = current_node
#			while current != null:
#				path.append(current.position)
#				current = current.parent
#			path.reverse()
#			print("finding complete!")
#			return path # Return reversed path
#
#		# Generate children
#		var children : Array = []
#		for new_position in DIRECTIONS: # Adjacent squares
#			# Get node position
#			var node_position = Vector2(current_node.position.x + new_position.x, current_node.position.y + new_position.y)
#
#			# Make sure within range
#			if node_position.x > (maze.size() - 1) or node_position.x < 0 or node_position.y > ((maze[maze.size() - 1]).size() -1) or node_position.y < 0:
#				continue
#
#			# Make sure walkable terrain
#			if maze[node_position.x][node_position.y] != 0 or maze[node_position.x][node_position.y - new_position.y] != 0 or maze[node_position.x - new_position.x][node_position.y] != 0:
#				continue
#
#			# Create new node
#			steps += 1
#			print("walk" + str(steps))
#			var new_node = Pathfinding_Node.new(current_node, node_position)
#
#			# Append
#			children.append(new_node)
#
#		# Loop through children
#		for child in children:
#
#			# Child is on the closed list
#			for closed_child in closed_list:
#				if child == closed_child:
#					continue
#
#			# Create the f, g, and h values
#			child.g = current_node.g + 1
#			var dx : float = abs(child.position.x - end_node.position.x)
#			var dy : float = abs(child.position.y - end_node.position.y)
#			child.h = dx + dy + (1.414 - 2) * min(dx, dy)
#			child.h *= (1.0 + 1/room_borders.get_area())
#			child.f = child.g + child.h
#
#			# Child is already in the open list
#			for open_node in open_list:
#				if child == open_node and child.g > open_node.g:
#					continue
#
#			# Add the child to the open list
#			open_list.append(child)
			


 
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
 
	# Check if the source and destination are unblocked
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


			
func maze_update_and_reroute(start, end, position_array:PackedVector2Array):
	maze_update(position_array)
	return find_path(start, end)
	
func maze_reset_and_reroute(start, end):
	maze_reset()
	return find_path(start, end)
			
func maze_update(position_array:PackedVector2Array):
	for i in position_array:
		var temp = get_standard_position(i)
		maze[temp.x][temp.y] = 1
		
func maze_reset():
	maze = maze_original
