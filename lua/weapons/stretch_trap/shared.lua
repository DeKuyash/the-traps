

SWEP = SWEP or {}
SWEP.Primary = SWEP.Primary or {}
SWEP.Secondary = SWEP.Secondary or {}



if SERVER then
    util.AddNetworkString('traps.stretch.spawnEnt')
    resource.AddFile('sound/grenade/stretch_active.wav')

    sound.Add({
        name = 'stretch_active',
        channel = CHAN_AUTO,
        volume = 1.0,
        level = 80,
        sound = 'grenade/stretch_active.wav'
    })
end

if CLIENT then
    SWEP.PrintName = 'Растяжка Реворк';
    SWEP.Slot = 2;
    SWEP.SlotPos = 4;
    SWEP.DrawAmmo = false;
    SWEP.DrawCrosshair = false;
end

SWEP.Purpose = 'Бум!'
SWEP.Instructions = 'ЛКМ - Установить растяжку'
SWEP.Author = 'Kuyash'
SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip  = false
SWEP.Category = 'Портфолио'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.NextStrike  = 0
SWEP.ViewModel = 'models/items/grenadeammo.mdl'
SWEP.WorldModel = 'models/items/grenadeammo.mdl'

SWEP.Primary.Delay = 0.01
SWEP.Primary.Recoil = 0
SWEP.Primary.Damage = 0
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = 'none'

SWEP.Secondary.Delay = 0.01
SWEP.Secondary.Recoil = 0
SWEP.Secondary.Damage = 0
SWEP.Secondary.NumShots = 1
SWEP.Secondary.Cone = 0
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = 'none'



local function cl_grenadeInit()
    local grenadeClient = ents.CreateClientside('stretch_base')
    grenadeClient:SetModel('models/weapons/w_eq_fraggrenade.mdl')
    grenadeClient:SetMaterial('models/wireframe')
    grenadeClient:Spawn()
    
    return grenadeClient
end



local function cl_stickInit()
    local stickClient = ents.CreateClientside('stick_base')
    stickClient:SetModel('models/props_c17/column02a.mdl')
    stickClient:SetMaterial('models/wireframe')
    stickClient:Spawn()
    stickClient:SetModelScale(stickClient:GetModelScale() * 0.02) 

    return stickClient
end



local function sv_grenadeInit(targetPos)
    local grenadeServer = ents.Create('prop_physics')
    grenadeServer:SetModel('models/weapons/w_eq_fraggrenade.mdl')
    grenadeServer:SetPos(targetPos + Vector(0, 0, 8))
    grenadeServer:Spawn()
    grenadeServer:DrawShadow(false)

    grenadeServer:SetCollisionGroup(COLLISION_GROUP_WORLD)
    grenadeServer:GetPhysicsObject():EnableMotion(false)

    --
    
    local gStickServer = ents.Create('prop_physics')
    gStickServer:SetModel('models/props_c17/column02a.mdl')
    gStickServer:SetMaterial('null')
    gStickServer:DrawShadow(false)

    gStickServer:SetModelScale(gStickServer:GetModelScale() * 0.02, 0.00001)
    gStickServer:SetCollisionGroup(COLLISION_GROUP_WORLD)
    gStickServer:Spawn()
    gStickServer:SetPos(targetPos)
    gStickServer:GetPhysicsObject():EnableMotion(false)
    timer.Simple(0.01, function()
        gStickServer:SetMaterial('phoenix_storms/metalset_1-2')
    end)


    return {
        ['grenade'] = grenadeServer, 
        ['stick'] = gStickServer
    }
end



local function sv_stickInit(targetPos)
    local stickServer = ents.Create('prop_physics')
    stickServer:SetModel('models/props_c17/column02a.mdl')
    stickServer:SetMaterial('null')
    stickServer:SetPos(targetPos)
    stickServer:DrawShadow(false)

    stickServer:SetModelScale(stickServer:GetModelScale() * 0.02, 0.01)
    stickServer:SetCollisionGroup(COLLISION_GROUP_WORLD)
    stickServer:Spawn()
    stickServer:GetPhysicsObject():EnableMotion(false)
    timer.Simple(0.01, function()
        stickServer:SetMaterial('phoenix_storms/metalset_1-2')
    end)

    return stickServer
end



local function ropeInit(grenade, stick)
    local dotConnect_1 = ents.Create('prop_physics')
    dotConnect_1:SetPos(grenade:GetPos())
    dotConnect_1:SetModel('models/hunter/plates/plate.mdl')
    dotConnect_1:SetMaterial('null')
    dotConnect_1:SetCollisionGroup(COLLISION_GROUP_WORLD)
    dotConnect_1:Spawn()
    dotConnect_1:GetPhysicsObject():EnableMotion(false)

    local dotConnect_2 = ents.Create('prop_physics')
    dotConnect_2:SetPos(stick:GetPos() + Vector(0, 0, 8))
    dotConnect_2:SetModel('models/hunter/plates/plate.mdl')
    dotConnect_2:SetMaterial('null')
    dotConnect_2:SetCollisionGroup(COLLISION_GROUP_WORLD)
    dotConnect_2:Spawn()
    dotConnect_2:GetPhysicsObject():EnableMotion(false)

    constraint.Rope(dotConnect_1, dotConnect_2, 0, 0, Vector(0, 0, 0), Vector(0, 0, 0), 1, 0, 0, 0.0001, 'cable/cable2', false)


    return {
        dotConnect_1, 
        dotConnect_2 
    }
end



function SWEP:Initialize()
    self.phase = self.phase or 1
    self.isInit = self.isInit or false

    self.cl_stick = self.cl_stick or nil
    self.cl_grenade = self.cl_grenade or nil

    self.sv_stick = self.sv_stick or nil
    self.sv_grenade = self.sv_grenade or {} -- тк состоит из палки и гранаты (два энтити)

    if CLIENT then
        self:SetWeaponHoldType('grenade') 
        self.cl_grenade = cl_grenadeInit()

        self.cl_stick = cl_stickInit()
        self.cl_stick:Remove()

        self.isInit = true
    end
end



function SWEP:Deploy()
    if CLIENT then
        if not self.isInit then
            self.cl_grenade = cl_grenadeInit()
            
            self.cl_stick = cl_stickInit()
            self.cl_stick:Remove()

            self.isInit = true
        end
    end

    return true
end



function SWEP:Holster()
    if CLIENT then 
        if IsValid(self.cl_grenade) then self.cl_grenade:Remove() end
        if IsValid(self.cl_stick) then self.cl_stick:Remove() end  
        self.phase = 1  

        self.isInit = false
    end

    if SERVER then
        if IsValid(self.sv_grenade.grenade) and not IsValid(self.sv_grenade.stick) then 
            self.sv_grenade.grenade:Remove() 
            self.phase = 1
            self.isInit = false
        end
    end

    return true
end



function SWEP:PrimaryAttack()
    if CurTime() < self.NextStrike then return end
    self.NextStrike = CurTime() + 1

    if SERVER then
        local dots = {}
        local dotPos_1, dotPos_2

        local ply = self.Owner
        if not IsValid(ply) then return end

        local trace = ply:GetEyeTrace()
        local targetPos = trace.HitPos

        if self.phase == 1 then
            self.sv_grenade = sv_grenadeInit(targetPos)
            self.phase = 2
            net.Start('traps.stretch.spawnEnt')
                net.WriteInt(2, 8)
            net.Send(ply)

        elseif self.phase == 2 then
            self.sv_stick = sv_stickInit(targetPos)
            
            net.Start('traps.stretch.spawnEnt')
                net.WriteInt(1, 8)
            net.Send(ply)

            self.isInit = false
            self.phase = 1

            dots = ropeInit(self.sv_grenade.grenade, self.sv_stick)
            dotPos_1 = dots[1]:GetPos()
            dotPos_2 = dots[2]:GetPos()

            local check = true
            local hookID = string.format('stretch.rope.trigger%d_%d', self:EntIndex(), CurTime())


            hook.Add('Think', hookID, function()
                local trace = util.TraceLine({
                    start = dotPos_1,
                    endpos = dotPos_2,
                    collisiongroup = COLLISION_GROUP_PLAYER
                })
                
                if IsValid(trace.Entity) then
                    if check then 
                        if not IsValid(self.sv_grenade.grenade) then return end
                        self.sv_grenade.grenade:EmitSound('stretch_active')
                        
                        check = false
                        timer.Simple(1, function()
                            util.BlastDamage(self.sv_grenade.grenade, self.sv_grenade.grenade, self.sv_grenade.grenade:GetPos(), 2000, math.random(50, 80))
                            local effectdata = EffectData()
                            effectdata:SetOrigin(self.sv_grenade.grenade:GetPos())
                            util.Effect('Explosion', effectdata)

                            self.sv_grenade.grenade:Remove()
                            self.sv_grenade.stick:Remove()

                            self.sv_stick:Remove()

                            dots[1]:Remove()
                            dots[2]:Remove()

                            hook.Remove('Think', hookID)
                            check = true
                        end)
                    end 
                end
            end)
        end
    end



    if CLIENT then
        net.Receive('traps.stretch.spawnEnt', function()
            local phase = net.ReadInt(8)
            local swep = LocalPlayer():GetActiveWeapon()
                
            if not IsValid(swep) or swep:GetClass() ~= self.ClassName then return end

            if phase == 1 then
                self.isInit = false
                if IsValid(self.cl_stick) then self.cl_stick:Remove() end
                self.cl_grenade = cl_grenadeInit()
                        
            else
                if IsValid(self.cl_grenade) then self.cl_grenade:Remove() end

                self.cl_stick = cl_stickInit()
            end
        end)
    end
end



function SWEP:Think()
    if CLIENT then
        local trace = LocalPlayer():GetEyeTrace()
        local targetPos = trace.HitPos

        if IsValid(self.cl_grenade) then
            self.cl_grenade:SetPos(targetPos)

        elseif IsValid(self.cl_stick) then
            self.cl_stick:SetPos(targetPos)
        end
    end
end



function SWEP:OnRemove()
    if CLIENT then
        if IsValid(self.cl_grenade) then self.cl_grenade:Remove() end
        if IsValid(self.cl_stick) then self.cl_stick:Remove() end
        self.phase = 1
        self.isInit = false
    end
end