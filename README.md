# GameJam-2024-Pixel
 
## 碰撞层约定
层1：玩家建筑</br>
层2：玩家船只</br>
层3：活动的水面敌人</br>
层4：活动的水下敌人</br>
</br>
例如，制作一个对水面炮塔建筑，它自身将位于层1，其攻击范围将搜寻位于层3的Area2D，若有则设置为攻击目标。</br>
</br>
同时各元件也将用group进行分类。</br>
</br>
## 地图层约定
层0：水域</br>
层1：陆地</br>
层2：航线</br>
层3：码头（终点）</br>
层4：敌人刷怪点</br>
</br>
码头，敌人刷怪点可以与其他层重叠，航线可以与水域重叠但不能与陆地重叠，水域不能与陆地重叠</br>
</br>
## Pathfinder类</br>
实例化: </br>
Pathfinder.new(Tilemap) 直接传入Tilemap</br>
方法：</br>
get_standard_position(current_position) -> Vector2: 等效于tilemap的map_to_local方法</br>
get_global_position(normalized_position) -> Vector2: 等效于tilemap的local_to_map方法</br>
find_path(start, end): -> Array of Vector2: 输入起点和终点的全局坐标，获得一条路径，路径也都为全局坐标</br>
maze_update_and_reroute(start, end, position_array:PackedVector2Array) -> Array of Vector2: 增加position_array中的地块为陆地并重新寻路</br>
maze_update(type:String, position:Vector2) -> void: 增加position中的地块为陆地或水域，根据type判断</br>
maze_add_building(position:Vector2) -> void: 增加position中的地块为建筑</br>
is_shallow_water(position:Vector2) -> bool: 判断当前位置是否是可扩展的近海地块，传入全局坐标</br>
is_deep_water(position:Vector2) -> bool: 判断当前位置是否是不可扩展的深海地块，传入全局坐标</br>
get_harbour_position() -> Array of Vector2: 获取地图上的所有港口全局坐标</br>
get_enemy_spawn_position() -> Array of Vector2: 获取地图上的所有敌人出生点</br>
get_sail_routes() -> Array of Array of Vector2: 获取所有航线的路径，从码头到终点，返回的是全局坐标</br>
get_tile_center(position) -> Vector2: 返回输入坐标所在地块的中心坐标，用来放置建筑物和船的</br>

## 笔记</br>
HUD场景下有一个测试用的定时器TestTimer，如果阻碍到开发了可以直接删除，回合结束用HUD.complete_turn()可以自动进下一轮，功能都已经调通</br>
个人属性：包括血量、金币、每回合可造船数 **现在全部做成全局变量Character上了**</br>
建筑物需要新增一个方法demolish，用以自我销毁和返还金币</br>
全局变量：目前有2个，个人属性Character和关卡进度Level</br>
EnemyShip，Building和Ship，Mercenary需要尽快先把开局的锁位置去掉，不然刷怪器没法正常刷怪，摆放的位置也不会生效，影响A人配关卡和测试</br>
