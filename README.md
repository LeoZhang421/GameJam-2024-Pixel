# GameJam-2024-Pixel
 
## 碰撞层约定
层1：玩家建筑
层2：玩家船只
层3：活动的水面敌人
层4：活动的水下敌人

例如，制作一个对水面炮塔建筑，它自身将位于层1，其攻击范围将搜寻位于层3的Area2D，若有则设置为攻击目标。

同时各元件也将用group进行分类。
