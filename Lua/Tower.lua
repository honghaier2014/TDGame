require "Lua/Object"  
require"Lua/GameManager"
	Tower = { nearestMonster=nil}
	setmetatable(Tower, GameObject)  
	--���Ǻ��ඨ��һ�����������趨Ϊ����  
	Tower.__index = Tower  
	function Tower:create()  
	   local self = {}            --��ʼ����������  
	   self = GameObject:create() --�����������趨Ϊ���࣬�������൱���������Ե�super   
	   setmetatable(self, Tower) --����������Ԫ���趨ΪMain��  
	   self.nearestMonster=nil  ---������Ұ������ĵ���
	   return self  
	end   
	function Tower:initTower(map,x,y)  
	   self.baseNode:setPosition(x,y)
	   self.state=0   --���״̬
	   --��ʼδ������ͼ��
	   local initTowerTexture = cc.Director:getInstance():getTextureCache():addImage("res/battle_0003s_0001_skill-resource-counter.png")
	   self.initTowerIcon =cc.Sprite:createWithTexture(initTowerTexture)
	    if self.initTowerIcon ~= nil then
		    --self.initTowerIcon:setPosition(self.towerPos)
			self.baseNode:addChild(self.initTowerIcon)
			cclog("����δ��������,λ��: %0.2f, %0.2f", x,y) 
		end 
   end 
   --�õ����ĵ�ǰ״̬
   function Tower:getTowerState()  
		   return self.state
   end
   --����Ƿ�������
  function  Tower:containsTouchLocation(x,y)
     --��ʼ״̬
     if self.state ==0  then
	      if self.initTowerIcon ~= nil then
	       local rect = self.initTowerIcon:getBoundingBox()
		    rect.x=rect.x+self:GetCurPos().x
		    rect.y=rect.y+self:GetCurPos().y
		
		   return cc.rectContainsPoint(rect,cc.p(x,y))
	     end
	 elseif self.state ==1  then
	      if self.buildTower ~= nil then
	       local rect = self.buildTower:getBoundingBox()
		    rect.x=rect.x+self:GetCurPos().x
		    rect.y=rect.y+self:GetCurPos().y
		   return cc.rectContainsPoint(rect,cc.p(x,y))
	     end
	 end
	  return false
  end
   --������
  function  Tower:buildTower()
	self.attackRange=400             ---�������߷�Χ
    self.buildPercentage=0
    self.nearestMonster=0
	--��������Ѫ������
	self.hpBgSprite =cc.Sprite:createWithSpriteFrameName("hpBg1.png")
	self.baseNode:addChild(self.hpBgSprite)
	--��������Ѫ������������
	self.hpBar = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName("hp1.png"))
	self.hpBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	self.hpBar:setMidpoint(cc.p(0, 0.5))
	self.hpBar:setBarChangeRate(cc.p(1, 0))
	self.hpBar:setPercentage(self.buildPercentage)
    self.hpBar:setPosition(cc.p(self.hpBgSprite:getContentSize().width / 2, self.hpBgSprite:getContentSize().height / 3 * 2 ))
	--������ɻص�����
	 function callback()
         cclog("�������") 
         self:buildTowerDone()		 
	 end
	self.hpBar:runAction(cc.Sequence:create( cc.ProgressTo:create(10, 100), cc.CallFunc:create(callback)))
    self.hpBgSprite:addChild(self.hpBar)
	
   end
   --���������
    function  Tower:buildTowerDone()
	    local buildTowerTexture = cc.Director:getInstance():getTextureCache():addImage("res/battle_0001s_0002_T1-icon.png")
	    self.buildTower =cc.Sprite:createWithTexture(buildTowerTexture)
	    if self.buildTower ~= nil then		 
		  self.baseNode:removeChild(self.hpBgSprite)
		  self.baseNode:removeChild(self.initTowerIcon)
          self.baseNode:addChild(self.buildTower)
		  self.state=1
		  self.rotateArrow =cc.Sprite:createWithSpriteFrameName("arrow.png")
		  self.rotateArrow:setPosition(0, self.buildTower:getContentSize().height /4)
	      self.baseNode:addChild(self.rotateArrow)
		   local function callback()
			    self:rotateAndattack() 	
		  end
		  cc.Director:getInstance():getScheduler():scheduleScriptFunc(callback, 0.8, false)
		end 
    end
	--����������Ĺ���
	function  Tower:checkNearestMonster()
	       self.nearestMonster=0
		   local maxDistant=WinSize.width
		   for k,monster in pairs(MonsterArray)  do
		         local curDistance =cc.pGetDistance(self:GetCurPos(),monster:GetCurPos())
				   if curDistance < maxDistant  then	
			           maxDistant = curDistance	
					   	if maxDistant <self.attackRange then	
		                   self.nearestMonster=monster
		                end				   
				   end 
	       end
	 end
	 function  Tower:attack()
	        if self.nearestMonster ~= 0 and self.nearestMonster.hp > 0 then
			     local shootVector1 = cc.pSub(self.nearestMonster:GetCurPos(),self:GetCurPos()) 
				 cclog("%d,%d",shootVector1.x,shootVector1.y) 
				 local normalizedShootVector =cc.pNormalize(shootVector1)
				 normalizedShootVector.x=-normalizedShootVector.x
				 normalizedShootVector.y=-normalizedShootVector.y
				 local farthestDistance = WinSize.width
				 local overshotVector = cc.pMul(normalizedShootVector,farthestDistance)
				 local rotateArrowPosX,rotateArrowPosY=self.rotateArrow:getPosition()
		         local offscreenPoint = cc.pSub(cc.p(rotateArrowPosX,rotateArrowPosY),overshotVector)
				 local currBullet = self:createTowerBullet()
				  function callback(sender)
                    self:removeBullet(sender)		 
	              end
				 currBullet:runAction(cc.Sequence:create(cc.MoveTo:create(2, offscreenPoint),cc.CallFunc:create(callback)))
			end
	 end
	  function  Tower:rotateAndattack()
	  
	           self:checkNearestMonster()
		      if self.nearestMonster ~= 0 then
				 local shootVector1 = cc.pSub(self.nearestMonster:GetCurPos(),self:GetCurPos())
			     local shootRadians = math.atan2(shootVector1.y,shootVector1.x)
			     local shootDegrees = -shootRadians / math.pi * 180.0
			     local speed = 0.5 / math.pi;
		         local rotateDuration = math.abs(shootRadians * speed)
			     function callback()
			        self:attack() 	
			    end
			      self.rotateArrow:runAction(cc.Sequence:create(cc.RotateTo:create(rotateDuration, shootDegrees), cc.CallFunc:create(callback)))
			 end
	 end
	 --�����ӵ�
    function  Tower:createTowerBullet()
	     local bullet = cc.Sprite:createWithSpriteFrameName("arrowBullet.png");
		 local rotateArrowPosX,rotateArrowPosY=self.rotateArrow:getPosition()
         bullet:setPosition(rotateArrowPosX,rotateArrowPosY)
         bullet:setRotation(self.rotateArrow:getRotation())
         self.baseNode:addChild(bullet)
		 table.insert(BulletArray,bullet)
         return bullet;
	end 
    function  Tower:removeBullet(bullet)
	    if bullet ~= nil then
		    for i,bulletObject in pairs(BulletArray)  do
		         if  nil ~= bulletObject and bulletObject == bullet then
			  
	                  table.remove(BulletArray, i)
		              len     = table.getn(BulletArray)
	                  bullet:removeFromParent()
					  break
				  end
		   end
		  end
	 end
   