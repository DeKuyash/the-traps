


AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')




function ENT:Initialize()
    self:SetModel('models/props_c17/column02a.mdl')
    self:SetMaterial('phoenix_storms/metalset_1-2')
    self:PhysicsInit(SOLID_VPHYSICS)

    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    self:GetPhysicsObject():SetMass(10)

    self:SetModelScale(self:GetModelScale() * 0.02, 0.01)

    if self:GetPhysicsObject():IsValid() then self:GetPhysicsObject():Wake() end

end

