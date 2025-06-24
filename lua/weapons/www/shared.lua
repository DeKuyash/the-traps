


if SERVER then
    AddCSLuaFile('shared.lua');
end


if CLIENT then
    SWEP.PrintName = 'WAWWW-grenade';
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


--function SWEP:Deploy()
--end



--function SWEP:Holster()
--end





        --[[local endPosEnt = ents.Create('prop_physics')
        endPosEnt:SetModel('models/props_c17/column02a.mdl')
        endPosEnt:SetPos(Vector(0, 50, 0))
        endPosEnt:SetMaterial('phoenix_storms/metalset_1-2')

        endPosEnt:Spawn()

        endPosEnt:SetModelScale(endPosEnt:GetModelScale() * 0.02, 0.01)

        endPosEnt:SetCollisionGroup(COLLISION_GROUP_WORLD)
        endPosEnt:GetPhysicsObject():Sleep()

        ---

        local grenadeEnt = ents.Create('prop_physics')
        grenadeEnt:SetModel('models/weapons/w_eq_fraggrenade.mdl')
        grenadeEnt:SetPos(Vector(0, 0, 0))
        grenadeEnt:Spawn()

        grenadeEnt:SetCollisionGroup(COLLISION_GROUP_WORLD)
        grenadeEnt:GetPhysicsObject():Sleep()]]


        --constraint.Rope(grenadeEnt, endPosEnt, 0, 0, grenadeEnt:GetPos() + Vector(0, 0, 10) , endPosEnt:GetPos() - Vector(0, 50, -10), 1, 0, 0, 0.5, 'cable/cable2', false)



local function grenadeClientInit()

    grenade = ents.CreateClientside('stretch_base')
    if grenade:IsValid() then
        grenade:SetModel('models/weapons/w_eq_fraggrenade.mdl')
        grenade:SetMaterial('models/wireframe')
        grenade:Spawn()

    end
end



local function endPosEntClientInit()

    endPosEnt = ents.CreateClientside('stretch_base')
    if endPosEnt:IsValid() then
        endPosEnt:SetModel('models/props_c17/column02a.mdl')
        endPosEnt:SetMaterial('models/wireframe')
        endPosEnt:Spawn()
        endPosEnt:SetModelScale(endPosEnt:GetModelScale() * 0.02, 0.01)

    end
end


local doInit = false

local firstStage = true

function SWEP:Initialize()
    if CLIENT then
        self:SetWeaponHoldType('grenade')
        
        if not doInit then
            --if firstStage then

            grenadeClientInit()

            --else

                --[[endPosEnt = ents.CreateClientside('stretch_base')
                if endPosEnt:IsValid() then
                    endPosEnt:SetModel('models/props_c17/column02a.mdl')
                    endPosEnt:SetMaterial('models/wireframe')

                    endPosEnt:Spawn()

                    endPosEnt:SetModelScale(endPosEnt:GetModelScale() * 0.02, 0.01)


                end
                
                endPosEnt:Remove()]]

            --end

            doInit = true

        end
    end
end


function SWEP:Deploy()
    if CLIENT then
        if firstStage then
            if not grenade:IsValid() then
                grenadeClientInit()
            end

        else

            if not endPosEnt:IsValid() then
                endPosEntClientInit()
            end

        end
    end

    return true
end



function SWEP:Holster()
    if CLIENT then 
        if grenade:IsValid() then
            grenade:Remove() 

        elseif endPosEnt:IsValid() then
            endPosEnt:remove()

        end
    end

    return true
end


if SERVER then
    util.AddNetworkString('spawnEnt')
end


function SWEP:PrimaryAttack()

    if ( CurTime() < self.NextStrike) then return; end

    self.NextStrike = (CurTime() + 1); 

    if CLIENT then

        local trace = LocalPlayer():GetEyeTrace()
        local targetPos = trace.HitPos

        net.Start('spawnEnt')
            net.WriteVector(targetPos)
            net.WriteEntity(LocalPlayer())
        net.SendToServer()


        if firstStage then
            if grenade:IsValid() then
                grenade:Remove()
            end

            endPosEntClientInit()

        else
            if endPosEnt:IsValid() then
                endPosEnt:Remove()
            end

        end

        

    elseif SERVER then
        net.Receive('spawnEnt', function()
            local targetPos = net.ReadVector()

            if firstStage then

                local grenadeEnt = ents.Create('prop_physics')
                grenadeEnt:SetModel('models/weapons/w_eq_fraggrenade.mdl')
                grenadeEnt:SetPos(targetPos)
                grenadeEnt:Spawn()
        
                grenadeEnt:SetCollisionGroup(COLLISION_GROUP_WORLD)
                grenadeEnt:GetPhysicsObject():Sleep()


            else
                local endPos = ents.Create('prop_physics')
                endPos:SetModel('models/props_c17/column02a.mdl')
                endPos:SetMaterial('phoenix_storms/metalset_1-2')

                endPos:SetPos(targetPos)

                endPos:Spawn()

                endPos:SetModelScale(endPos:GetModelScale() * 0.02, 0.01)

                endPos:SetCollisionGroup(COLLISION_GROUP_WORLD)
                endPos:GetPhysicsObject():Sleep()

                local ply = net.ReadEntity()
                ply:StripWeapon('strech_grenade')

            end

            firstStage = not firstStage

        end)
        
    end
end




function SWEP:Think()
    if CLIENT then
        

        local trace = LocalPlayer():GetEyeTrace()
        local targetPos = trace.HitPos

        if firstStage then
            if not grenade:IsValid() then return end
            grenade:SetPos(targetPos)

        else
            if not endPosEnt:IsValid() then return end
            endPosEnt:SetPos(targetPos)

        end

    end
end
