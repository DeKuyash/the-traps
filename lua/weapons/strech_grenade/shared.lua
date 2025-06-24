


if SERVER then
    AddCSLuaFile('shared.lua');
end


if CLIENT then
    SWEP.PrintName = 'Strech-grenade';
    SWEP.Slot = 2;
    SWEP.SlotPos = 4;
    SWEP.DrawAmmo = false;
    SWEP.DrawCrosshair = false;
end

SWEP.Purpose = 'Explode'
SWEP.Instructions = 'LMB - Set one of stretch parts \n RMB - Reset all'
SWEP.Author = 'Kuyash'

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip  = false

SWEP.Category = 'Portfolio'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.NextStrike  = 0;

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



-----Функции-----

local function grenadeEntInit(targetPos)
    grenadeEnt = ents.Create('prop_physics')

    grenadeEnt:SetModel('models/weapons/w_eq_fraggrenade.mdl')
    grenadeEnt:SetPos(targetPos + Vector(0, 0, 8))
    grenadeEnt:Spawn()

    grenadeEnt:SetCollisionGroup(COLLISION_GROUP_WORLD)
    grenadeEnt:GetPhysicsObject():EnableMotion(false)

    ---

    grenadeStickEnt = ents.Create('prop_physics')

    grenadeStickEnt:SetModel('models/props_c17/column02a.mdl')
    grenadeStickEnt:SetMaterial('phoenix_storms/metalset_1-2')

    grenadeStickEnt:SetPos(targetPos)

    grenadeStickEnt:Spawn()

    grenadeStickEnt:SetModelScale(grenadeStickEnt:GetModelScale() * 0.02, 0.01)

    grenadeStickEnt:SetCollisionGroup(COLLISION_GROUP_WORLD)
    grenadeStickEnt:GetPhysicsObject():EnableMotion(false)

end



local function stickEntInit(targetPos)
    stickEnt = ents.Create('prop_physics')

    stickEnt:SetModel('models/props_c17/column02a.mdl')
    stickEnt:SetMaterial('phoenix_storms/metalset_1-2')

    stickEnt:SetPos(targetPos)

    stickEnt:Spawn()

    stickEnt:SetModelScale(stickEnt:GetModelScale() * 0.02, 0.01)

    stickEnt:SetCollisionGroup(COLLISION_GROUP_WORLD)
    stickEnt:GetPhysicsObject():EnableMotion(false)

end



local function grenadeClientInit()
    grenade = ents.CreateClientside('stretch_base')

    if grenade:IsValid() then
        grenade:SetModel('models/weapons/w_eq_fraggrenade.mdl')
        grenade:SetMaterial('models/wireframe')
        grenade:Spawn()

    end
end



local function stickClientInit()
    stick = ents.CreateClientside('stick_base')

    if stick:IsValid() then
        stick:SetModel('models/props_c17/column02a.mdl')
        stick:SetMaterial('models/wireframe')
        stick:Spawn()
        stick:SetModelScale(stick:GetModelScale() * 0.02) 

    end
end



---------------------

local doInit = false
local firstStage = true

function SWEP:Initialize()
    if CLIENT then
        self:SetWeaponHoldType('grenade')
        
        if not doInit then
            grenadeClientInit()
            stickClientInit()

            stick:Remove()

            doInit = true

        end

    end
end

---------------------

function SWEP:Deploy()
    if CLIENT then
        if firstStage then
            if not grenade:IsValid() then
                grenadeClientInit()
            end

        else
            if not stick:IsValid() then
                stickClientInit()
            end

        end
    end

    return true
end

---------------------

function SWEP:Holster()
    if CLIENT then 
        if grenade:IsValid() then
            grenade:Remove() 

        elseif stick:IsValid() then
            stick:remove()

        end
    end

    return true
end

---------------------

if SERVER then
    util.AddNetworkString('spawnEnt')
end

---------------------

function SWEP:PrimaryAttack()

    if ( CurTime() < self.NextStrike) then return; end
    self.NextStrike = (CurTime() + 1); 

---------------------

    if CLIENT then
        local trace = LocalPlayer():GetEyeTrace()
        local targetPos = trace.HitPos

        net.Start('spawnEnt')
            net.WriteVector(targetPos)
            net.WriteBool(firstStage) 
            net.WriteEntity(LocalPlayer())
        net.SendToServer()


        if firstStage then
            if grenade:IsValid() then
                grenade:Remove()
            end

            stickClientInit()

            firstStage = false

        else
            if stick:IsValid() then
                stick:Remove()
            end

            firstStage = true 
            doInit = false


        end
    end

---------------------

    if SERVER then

        net.Receive('spawnEnt', function()
            local targetPos = net.ReadVector()
            local firstStage = net.ReadBool()

            if firstStage then
                grenadeEntInit(targetPos)

            else
                stickEntInit(targetPos)
                
                local ply = net.ReadEntity()
                ply:StripWeapon('strech_grenade')
   
                local prop1 = ents.Create('prop_physics')
                prop1:SetPos(grenadeEnt:GetPos())
                prop1:SetModel('models/hunter/plates/plate.mdl')
                prop1:SetMaterial('null')
                prop1:Spawn()
                prop1:GetPhysicsObject():EnableMotion(false)

                local prop2 = ents.Create('prop_physics')
                prop2:SetPos(stickEnt:GetPos() + Vector(0, 0, 8))
                prop2:SetModel('models/hunter/plates/plate.mdl')
                prop2:SetMaterial('null')
                prop2:Spawn()
                prop2:GetPhysicsObject():EnableMotion(false)

                constraint.Rope(prop1, prop2, 0, 0, Vector(0, 0, 0), Vector(0, 0, 0), 1, 0, 0, 0.0001, 'cable/cable2', false)
            


                	


                local tracedata = {}
                tracedata.start = prop2:GetPos()
                tracedata.endpos = prop1:GetPos()
                tracedata.collisongroup = COLLISION_GROUP_PLAYER

                local trace = util.TraceLine(tracedata)
                
                if trace.HitNonWorld then
                    local traceEnt = trace.Entity
                    print(traceEnt)  
                
                end





            end     
        end)   
    end
end

---------------------

function SWEP:Think()
    if CLIENT then
        local trace = LocalPlayer():GetEyeTrace()
        local targetPos = trace.HitPos

        if firstStage then
            if not grenade:IsValid() then return end
            grenade:SetPos(targetPos)

        else
            if not stick:IsValid() then return end
            stick:SetPos(targetPos)

        end

    end
end







-- СОЗДАЙ ТРИГГЕР ЗОНУ НА СЕРВЕРНОЙ СТОРОНЕ, ЧЕРЕЗ СКЕЙЛ МАТРИЦЫ
