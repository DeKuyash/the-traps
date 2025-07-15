
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


net.Receive('startProgressbar', function()
    local seconds = net.ReadInt(5)
    local needToFill = seconds * 34
    local progress = 1
    
    hook.Add('Tick', 'count.Progressbar', function()
        progress = progress + 1

    end)

    hook.Add('HUDPaint', 'draw.Progressbar', function()
        draw.RoundedBox(5, centerX + 100, centerY, 200, 20, Color(255, 255, 255, 240)) -- рамка прогрессбара

        draw.RoundedBox(5, centerX + 100, centerY, math.Clamp(200*(progress/needToFill), 0, 200), 20, Color(0, 195, 255)) -- прогрессбар

        draw.SimpleTextOutlined('Взводим ловушку...', 'trapFont', centerX + 100, centerY - 30, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0))

    end)

    timer.Simple(seconds, function()
        hook.Remove('Tick', 'count.Progressbar')
        hook.Remove('HUDPaint', 'draw.Progressbar')
    end)
end)