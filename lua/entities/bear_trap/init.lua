


AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')


sound.Add({
    name = 'btrap_activated',
    channel = CHAN_AUTO,
    volume = 1.0,
    level = 80,
    sound = 'b_trap/b_trap_activated.wav'

})


sound.Add({
    name = 'btrap_catch',
    channel = CHAN_AUTO,
    volume = 1.0,
    level = 80,
    sound = 'b_trap/b_trap_catch.wav'

})


util.AddNetworkString('startProgressBar')


function ENT:Initialize()
    self:SetModel('models/trap/trap.mdl')
    self:PhysicsInit(SOLID_VPHYSICS)

    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    self:GetPhysicsObject():SetMass(10)

    if self:GetPhysicsObject():IsValid() then self:GetPhysicsObject():Wake() end

end

function ENT:Use(activator, caller)
    local seconds = 2 -- Настройка времени активации капкана, но звук 2 секунды идет
    if activator:IsPlayer() and caller:IsValid() and self:GetModel() == 'models/trap/trap_close.mdl' then
        net.Start('startProgressBar')
            net.WriteInt(seconds, 5)
        net.Send(activator)

        activator:Freeze(true)
        self:EmitSound('btrap_activated')

        timer.Simple(seconds, function()
            self:SetModel('models/trap/trap.mdl')
            activator:Freeze(false)
        end)
    end    
end




hook.Add('EntityTakeDamage', 'bearTrapDamaged', function(target, info)
    if target:GetClass() == 'bear_trap' and target:GetModel() == 'models/trap/trap.mdl' then
        target:SetModel('models/trap/trap_close.mdl')
        target:EmitSound('btrap_catch')

    end
end)


function ENT:Touch(ent)
    if ent:IsValid() and ent:IsPlayer() then
        if not ent:GetVar('beingTouch') and self:GetModel() == 'models/trap/trap.mdl' then

            self:SetModel('models/trap/trap_close.mdl')
            self:EmitSound('btrap_catch')

            ent:SetHealth(ent:Health() - 35)

            if ent:Health() <= 0 then
                ent:SetHealth(1)
            end

            ent:Freeze(true)
            ent:EmitSound('vo/npc/male01/pain0' .. math.random(1, 9) .. '.wav') -- не стал делать на female

            ent:SetPos(self:GetPos())

            ent:SetVar('beingTouch', true)

            timer.Simple(2.5, function()
                ent:Freeze(false)
                ent:EmitSound('vo/npc/male01/pain0' .. math.random(1, 9) .. '.wav')
            end)

            local wSpeed, rSpeed, jPower = ent:GetWalkSpeed(), ent:GetRunSpeed(), ent:GetJumpPower()
            ent:SetWalkSpeed(wSpeed / 10)
            ent:SetRunSpeed(rSpeed / 10)
            ent:SetJumpPower(0)

            self:GetPhysicsObject():Sleep()
            self:SetCollisionGroup(COLLISION_GROUP_WORLD)


            local touchTime = CurTime()

            hook.Add('Think', 'trapDebuff', function()
                if self:IsValid() then
                    local endTouchTime = CurTime()

                    if endTouchTime - touchTime >= 20 then

                        ent:SetWalkSpeed(wSpeed)
                        ent:SetRunSpeed(rSpeed)
                        ent:SetJumpPower(jPower)
                        
                        self:GetPhysicsObject():Wake()
                        self:SetCollisionGroup(COLLISION_GROUP_NONE)

                        hook.Remove('Think', 'trapDebuff')

                    end
            
                else
                    ent:SetWalkSpeed(wSpeed)
                    ent:SetRunSpeed(rSpeed)
                    ent:SetJumpPower(jPower)
                    hook.Remove('Think', 'trapDebuff')

                end
            end)
        end
    end
end

function ENT:EndTouch(ent)
    if ent:IsValid() and ent:IsPlayer() and ent:GetVar('beingTouch') then
        ent:SetVar('beingTouch', false)

    end
end