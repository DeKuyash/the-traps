


AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')




function ENT:Initialize()
    self:SetModel('models/weapons/w_eq_fraggrenade.mdl')
    self:PhysicsInit(SOLID_VPHYSICS)

    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    self:GetPhysicsObject():SetMass(10)

    if self:GetPhysicsObject():IsValid() then self:GetPhysicsObject():Wake() end

end

