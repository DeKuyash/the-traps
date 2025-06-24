


if SERVER then
    AddCSLuaFile('shared.lua')
    util.AddNetworkString('spawnEnt')
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



local function grenadeClientInit()
    grenadeClient = ents.CreateClientside('stretch_base')
    grenadeClient:SetModel('models/weapons/w_eq_fraggrenade.mdl')
    grenadeClient:SetMaterial('models/wireframe')
    grenadeClient:Spawn()

end



local function stickClientInit()
    stickClient = ents.CreateClientside('stick_base')
    stickClient:SetModel('models/props_c17/column02a.mdl')
    stickClient:SetMaterial('models/wireframe')
    stickClient:Spawn()
    stickClient:SetModelScale(stickClient:GetModelScale() * 0.02) 

end



local function grenadeEntInit(targetPos)
    grenadeEnt = ents.Create('prop_physics')
    grenadeEnt:SetModel('models/weapons/w_eq_fraggrenade.mdl')
    grenadeEnt:SetPos(targetPos + Vector(0, 0, 8))
    grenadeEnt:Spawn()
    grenadeEnt:DrawShadow(false)

    grenadeEnt:SetCollisionGroup(COLLISION_GROUP_WORLD)
    grenadeEnt:GetPhysicsObject():EnableMotion(false)


    grenadeStickEnt = ents.Create('prop_physics')
    grenadeStickEnt:SetModel('models/props_c17/column02a.mdl')
    grenadeStickEnt:SetMaterial('null')
    grenadeStickEnt:DrawShadow(false)

    grenadeStickEnt:SetModelScale(grenadeStickEnt:GetModelScale() * 0.02, 0.00001)
    grenadeStickEnt:SetCollisionGroup(COLLISION_GROUP_WORLD)
    grenadeStickEnt:Spawn()
    grenadeStickEnt:SetPos(targetPos)
    grenadeStickEnt:GetPhysicsObject():EnableMotion(false)
    timer.Simple(0.01, function()
        grenadeStickEnt:SetMaterial('phoenix_storms/metalset_1-2')
    end)
end



local function stickEntInit(targetPos)
    stickEnt = ents.Create('prop_physics')
    stickEnt:SetModel('models/props_c17/column02a.mdl')
    stickEnt:SetMaterial('null')
    stickEnt:SetPos(targetPos)
    stickEnt:DrawShadow(false)

    stickEnt:SetModelScale(stickEnt:GetModelScale() * 0.02, 0.01)
    stickEnt:SetCollisionGroup(COLLISION_GROUP_WORLD)
    stickEnt:Spawn()
    stickEnt:GetPhysicsObject():EnableMotion(false)
    timer.Simple(0.01, function()
        stickEnt:SetMaterial('phoenix_storms/metalset_1-2')
    end)
end



local function ropeInit(grenadeEnt, stickEnt)
    local dotConnection_1 = ents.Create('prop_physics')
    dotConnection_1:SetPos(grenadeEnt:GetPos())
    dotConnection_1:SetModel('models/hunter/plates/plate.mdl')
    dotConnection_1:SetMaterial('null')
    dotConnection_1:SetCollisionGroup(COLLISION_GROUP_WORLD)
    dotConnection_1:Spawn()
    dotConnection_1:GetPhysicsObject():EnableMotion(false)

    local dotConnection_2 = ents.Create('prop_physics')
    dotConnection_2:SetPos(stickEnt:GetPos() + Vector(0, 0, 8))
    dotConnection_2:SetModel('models/hunter/plates/plate.mdl')
    dotConnection_2:SetMaterial('null')
    dotConnection_2:SetCollisionGroup(COLLISION_GROUP_WORLD)
    dotConnection_2:Spawn()
    dotConnection_2:GetPhysicsObject():EnableMotion(false)

    constraint.Rope(dotConnection_1, dotConnection_2, 0, 0, Vector(0, 0, 0), Vector(0, 0, 0), 1, 0, 0, 0.0001, 'cable/cable2', false)

    local check = true

    hook.Add('Think', 'rope.triggerCheck', function()
        local trace = util.TraceLine({
        start = dotConnection_1:GetPos(),
        endpos = dotConnection_2:GetPos(),
        collisiongroup = COLLISION_GROUP_PLAYER
        })

        if trace.Entity ~= NULL then
            if check then 
                grenadeEnt:EmitSound('stretch_active')
                check = false
                timer.Simple(1, function()
                    util.BlastDamage(grenadeEnt, grenadeEnt, grenadeEnt:GetPos(), 2000, math.random(50, 80))
                    local effectdata = EffectData()
                    effectdata:SetOrigin(grenadeEnt:GetPos())
                    util.Effect('Explosion', effectdata)
                    grenadeEnt:Remove()
                    stickEnt:Remove()
                    dotConnection_1:Remove()
                    dotConnection_2:Remove()
                    grenadeStickEnt:Remove()
                    check = true
                
                end)
            end 
        end
    end)

end


local doInit = false
local phase = 1

function SWEP:Initialize()
    if CLIENT then
        self:SetWeaponHoldType('grenade') 
        grenadeClientInit()
        stickClientInit()
        stickClient:Remove()
        doInit = true

    end


end



function SWEP:Deploy()
    if CLIENT then
        if not doInit then
            grenadeClientInit()
            stickClientInit()
            stickClient:Remove()
            doInit = true

        end
    end

    return true
end



function SWEP:Holster()
    if CLIENT then 
        if grenadeClient:IsValid() then
            grenadeClient:Remove()
            doInit = false

        else
            doInit = false

        end

        if stickClient:IsValid() then
            stickClient:Remove()
            doInit = false
            phase = 1

        else
            doInit = false

        end
    end

    return true
end



function SWEP:PrimaryAttack()
    if ( CurTime() < self.NextStrike) then return end
    self.NextStrike = (CurTime() + 1)

    if SERVER then
        local trace = self.Owner:GetEyeTrace()
        local targetPos = trace.HitPos

        if phase == 1 then
            grenadeEntInit(targetPos)
            phase = 2
            net.Start('spawnEnt')
                net.WriteInt(phase, 3)
            net.Send(self.Owner)

        else
            stickEntInit(targetPos)
            phase = 1
            net.Start('spawnEnt')
                net.WriteInt(phase, 3)
            net.Send(self.Owner)
            self.Owner:StripWeapon('rework_grenade')
            ropeInit(grenadeEnt, stickEnt)

        end
    end



    if CLIENT then
        net.Receive('spawnEnt', function()
            local phaseCheck = net.ReadInt(3)

            if phaseCheck == 1 then
                doInit = false
                stickClient:Remove()

            else
                grenadeClient:Remove()
                stickClientInit()

            end


        end)
    end
end



function SWEP:Think()
    if CLIENT then
        local trace = LocalPlayer():GetEyeTrace()
        local targetPos = trace.HitPos

        if grenadeClient:IsValid() then
            grenadeClient:SetPos(targetPos)

        elseif stickClient:IsValid() then
            stickClient:SetPos(targetPos)
        end


    end
end