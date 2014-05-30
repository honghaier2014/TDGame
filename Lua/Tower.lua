require "Lua/GameObject"  

	--�̳�
	Tower = {}
	setmetatable(Tower, GameObject)  
	--���Ǻ��ඨ��һ�����������趨Ϊ����  
	Tower.__index = Tower  
	function Tower:create()  
	   local self = {}            --��ʼ����������  
	   self = GameObject:create() --�����������趨Ϊ���࣬�������൱���������Ե�super   
	   setmetatable(self, Tower) --����������Ԫ���趨ΪMain��  
	   return self  
	end   
	function Tower:initTower(map,x,y)  
	   self.towerNode = cc.Node:create()
	   self.towerPos=cc.p(x,y)
	   self.starte=0
	   map:addChild(self.towerNode)
       self.initModle =cc.Sprite:createWithSpriteFrameName("enemyRight1_3.png")
	    if self.initModle ~= nil then
		    self.initModle:setPosition(self.towerPos)
			self.towerNode:addChild(self.initModle)
			cclog("��������,λ��: %0.2f, %0.2f", x,y) 
		end 
   end 
   -- function Tower:getTowerCurPos()  
         -- if self.initModle ~= nil then
		   -- local cx, cy = self.initModle:getPosition()
		   -- return cc.p(cx,cy)
		 -- end 
   -- end 
  function  Tower:containsTouchLocation(x,y)
  
     --��ʼ״̬
     if self.starte ==0  then
	      if self.initModle ~= nil then
	       local rect = self.initModle:getBoundingBox()
		   return cc.rectContainsPoint(rect,cc.p(x,y))
	     end
	 elseif self.starte ==1  then
	      if self.buildTower ~= nil then
	       local rect = self.buildTower:getBoundingBox()
		   return cc.rectContainsPoint(rect,cc.p(x,y))
	     end
	 end
	  return false
  end
   --������
  function  Tower:buildTower()
  -- ���������
    if self.starte ==1  then
	 return 
	 end
    self.buildPercentage=0
	self.hpBgSprite =cc.Sprite:createWithSpriteFrameName("hpBg1.png")
	self.hpBgSprite:setPosition(self.towerPos)
	--self.hpBgSprite:setPosition(cc.p(self.initModle:getContentSize().width / 2, self.initModle:getContentSize().height ))
	self.hpBar = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName("hp1.png"))
	self.hpBar:setType(cc.PROGRESS_TIMER_TYPE_BAR);
	self.hpBar:setMidpoint(cc.p(0, 0.5))
	self.hpBar:setBarChangeRate(cc.p(1, 0))
	self.hpBar:setPercentage(self.buildPercentage)
    self.hpBar:setPosition(cc.p(self.hpBgSprite:getContentSize().width / 2, self.hpBgSprite:getContentSize().height / 3 * 2 ))
	local to1 = cc.ProgressTo:create(2, 100)
	--������ɻص�����
	 function callback()
         cclog("�������") 
         self:buildTowerDone()		 
	 end
	self.hpBar:runAction(cc.Sequence:create( cc.ProgressTo:create(2, 100), cc.CallFunc:create(callback)))
    self.hpBgSprite:addChild(self.hpBar);
	self.towerNode:addChild(self.hpBgSprite)
   end
   --���������
    function  Tower:buildTowerDone()
	    self.buildTower =cc.Sprite:createWithSpriteFrameName("baseplate.png")
	    if self.buildTower ~= nil then
		  self.buildTower:setPosition(self.towerPos)
		  self.towerNode:removeChild(self.hpBgSprite)
		  self.towerNode:removeChild(self.initModle)
          self.towerNode:addChild(self.buildTower)
		  self.starte=1
		end 
    end
   