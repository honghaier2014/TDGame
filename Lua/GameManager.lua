require "Lua/MonsterConfig" 
--��������
 MonsterArray = {}
--Ч������
 EffectArray = {}
--��������
TowerArray = {}
--��������·������
PointArray = {}
--�ӵ�����
BulletArray = {}
--��Ϸ������
GameMainScene=nil 
WinSize = cc.Director:getInstance():getWinSize()
Play1Hp=20
Play2Hp=20
play1HpUI=nil
play2HpUI=nil
RefreshMonsterNum=20
--��Ϸ������
GameMainUI=nil
GameMap=nil 
--��Ϸ״̬   0  ����״̬  1 ս��״̬ 2ս������״̬
GameState=0 