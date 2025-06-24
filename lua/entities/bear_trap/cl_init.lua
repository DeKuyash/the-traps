
include('shared.lua')

function ENT:Draw() 
    self:DrawModel()
end


surface.CreateFont('trapFont', {
    font = 'CreditsText',
    size = 25,
    outilne = true
})


local centerX = ScrW() / 2
local centerY = ScrH() / 2



net.Receive('startProgressBar', function()
    local seconds = net.ReadInt(5)
    local progress = (0.1/(8*seconds))
    
    hook.Add('HUDPaint', 'drawProgressBar', function()
        draw.RoundedBox(5, centerX + 100, centerY, 200, 20, Color(255, 255, 255, 240)) -- рамка прогрессбара

        draw.RoundedBox(5, centerX + 100, centerY, math.Clamp(200*progress, 0, 200), 20, Color(0, 195, 255)) -- прогрессбар

        draw.SimpleTextOutlined('Взводим ловушку...', 'trapFont', centerX + 100, centerY - 30, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0))

        progress = progress + (0.1/(8*seconds))
    end)

    timer.Simple(seconds, function()
        hook.Remove('HUDPaint', 'drawProgressBar')
    end)


end)











--[[
net.Receive('delayProgressBar', function()
    local key = net.ReadBool()
    local progress = 0

    if key then
        hook.Add('HUDPaint', 'delayProgressBar', function()
            draw.RoundedBox(5, centerX + 100, centerY, 200, 20, Color(255, 255, 255, 240)) -- рамка прогрессбара

            draw.RoundedBox(5, centerX + 100, centerY, math.Clamp(progress, 0, 200), 20, Color(0, 195, 255)) -- прогрессбар

            draw.SimpleTextOutlined('Взводим ловушку...', 'trapFont', centerX + 100, centerY - 30, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0))

            progress = progress + 2

        end)

    else
        hook.Remove('HUDPaint','delayProgressBar')

    end
end)


]]