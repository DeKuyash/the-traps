


if SERVER then
    AddCSLuaFile('shared.lua');
end


if CLIENT then
    SWEP.PrintName = 'Установка капкана';
    SWEP.Slot = 2;
    SWEP.SlotPos = 3;
    SWEP.DrawAmmo = false;
    SWEP.DrawCrosshair = false;
end

SWEP.Purpose = 'Кусь за ногу'
SWEP.Instructions = 'ЛКМ — Установить'
SWEP.Author = 'Kuyash'

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip  = false

SWEP.Category = 'Портфолио'
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

local doInit = false
local mayPlace = nil

function SWEP:Initialize()
    if CLIENT then
        self:SetWeaponHoldType('grenade')

        if not doInit then
            beartrap = ents.CreateClientside('bear_trap')
            if beartrap:IsValid() then
                beartrap:SetModel('models/trap/trap.mdl')
                beartrap:SetMaterial('models/wireframe')
                beartrap:Spawn()
            end

            doInit = true

        end
    end
end



function SWEP:Deploy()
    if CLIENT then
        if not beartrap:IsValid() then
            beartrap = ents.CreateClientside('bear_trap')
            if beartrap:IsValid() then
                beartrap:SetModel('models/trap/trap.mdl')
                beartrap:SetMaterial('models/wireframe')
                beartrap:Spawn()


            end
        end
    end

    return true
end



function SWEP:Holster()
    if CLIENT then 
        if beartrap:IsValid() then
           beartrap:Remove() 
            doInit = false
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
        if mayPlace then
            local trace = LocalPlayer():GetEyeTrace()
            local targetPos = trace.HitPos
            local eyeAng = LocalPlayer():EyeAngles()
            local plyPos = LocalPlayer():GetPos()

            net.Start('spawnEnt')
                net.WriteVector(targetPos)
                net.WriteAngle(eyeAng)
                net.WriteEntity(LocalPlayer())
            net.SendToServer()

            if beartrap:IsValid() then
                beartrap:Remove()
                doInit = false
            end
        end

    end

    if SERVER then
        net.Receive('spawnEnt', function()
            local targetPos = net.ReadVector()
            local eyeAng = net.ReadAngle()

            local btrap = ents.Create('bear_trap')
            if btrap:IsValid() then
                btrap:SetModel('models/trap/trap.mdl')
                btrap:SetAngles(Angle(0, eyeAng.y, 0))
                btrap:SetPos(targetPos)
                btrap:Spawn()
                btrap:SetMoveType(MOVETYPE_NONE)

            end

            local ply = net.ReadEntity()
            ply:StripWeapon('bear_trap_set')
                
        end)

    end
end



function SWEP:Think()
    if CLIENT then
        if not beartrap:IsValid() then return end

        local trace = LocalPlayer():GetEyeTrace()
        local targetPos = trace.HitPos
        local plyPos = LocalPlayer():GetPos()
            
        beartrap:SetPos(targetPos)

        local eyeAng = LocalPlayer():EyeAngles()
        beartrap:SetAngles(Angle(0, eyeAng.y, 0))

        
        if plyPos:DistToSqr(targetPos) > 4500 and beartrap:GetColor() ~= Color(255, 0, 0) then
            beartrap:SetColor(Color(255, 0, 0))
            mayPlace = false
        end

        if plyPos:DistToSqr(targetPos) <= 4500 and beartrap:GetColor() ~= Color(255, 255, 255) then
            beartrap:SetColor(Color(255, 255, 255))
            mayPlace = true
        end

    end
end




