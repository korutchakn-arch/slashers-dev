-- Slashers — Killer Abilities (Client)
-- All client-side HUD rendering, post-process effects, and net message handlers.

local GM = GM or GAMEMODE

-----------------------------------------------------------
-- GHOSTFACE — Door icons on HUD
-- Material: icons/icon_door.png
-----------------------------------------------------------

local ghostface_doors = {}

net.Receive("sls_kability_AddDoor", function(len)
    local pos = net.ReadVector()
    local endtime = net.ReadInt(16)
    table.insert(ghostface_doors, {
        pos     = pos,
        endtime = endtime,
    })
end)

local ICON_DOOR_GHOSTFACE = Material("icons/icon_door.png")

local function KA_ghostface_HUDPaintBackground()
    if LocalPlayer():Team() ~= TEAM_KILLER then return end
    local curtime = CurTime()

    for k, v in ipairs(ghostface_doors) do
        if curtime > v.endtime then
            table.remove(ghostface_doors, k)
            continue
        end
        local pos1 = v.pos:ToScreen()
        surface.SetDrawColor(Color(255, 255, 255))
        surface.SetMaterial(ICON_DOOR_GHOSTFACE)
        surface.DrawTexturedRect(pos1.x - 64, pos1.y - 64, 128, 128)
    end
end
hook.Add("HUDPaintBackground", "sls_ka_ghostface_HUDPaintBackground", KA_ghostface_HUDPaintBackground)

local function KA_ghostface_PreStart()
    ghostface_doors = {}
end
hook.Add("sls_round_PreStart", "sls_ka_ghostface_PreStart", KA_ghostface_PreStart)

local function KA_ghostface_End()
    ghostface_doors = {}
end
hook.Add("sls_round_End", "sls_ka_ghostface_End", KA_ghostface_End)

-----------------------------------------------------------
-- JASON — 3D Footprint rendering
-- Material: icons/footsteps.png
-----------------------------------------------------------

local jason_steps = {}

net.Receive("sls_kability_AddStep", function(len)
    local ply = net.ReadEntity()
    local pos = net.ReadVector()
    local ang = net.ReadAngle()
    local endtime = net.ReadInt(16)

    ang.p = 0
    ang.r = 0

    -- Offset left/right per step to simulate alternating feet
    local fpos = pos
    if ply.LastFoot then
        fpos = fpos + ang:Right() * 5
    else
        fpos = fpos + ang:Right() * -5
    end
    ply.LastFoot = not ply.LastFoot

    local trace = {}
    trace.start   = fpos
    trace.endpos  = fpos + Vector(0, 0, -10)
    trace.filter  = ply
    local tr = util.TraceLine(trace)

    if tr.Hit then
        table.insert(jason_steps, {
            pos     = tr.HitPos,
            endtime = endtime,
            angle   = ang.y,
            normal  = Vector(0, 0, 1),
        })
    end
end)

local ICON_STEP_JASON = Material("icons/footsteps.png")
local maxDistSqr = 600 * 600

local function KA_jason_PostDrawTranslucentRenderables()
    local pos = EyePos()

    cam.Start3D(pos, EyeAngles())
        render.SetMaterial(ICON_STEP_JASON)
        for k, v in ipairs(jason_steps) do
            if CurTime() > v.endtime then
                table.remove(jason_steps, k)
                continue
            end
            if (v.pos - pos):LengthSqr() < maxDistSqr then
                render.DrawQuadEasy(v.pos + v.normal, v.normal, 10, 20, Color(255, 255, 255), v.angle)
            end
        end
    cam.End3D()
end
hook.Add("PostDrawTranslucentRenderables", "sls_ka_jason_PostDrawTranslucentRenderables", KA_jason_PostDrawTranslucentRenderables)

local function KA_jason_PreStart()
    jason_steps = {}
end
hook.Add("sls_round_PreStart", "sls_ka_jason_PreStart", KA_jason_PreStart)

local function KA_jason_End()
    jason_steps = {}
end
hook.Add("sls_round_End", "sls_ka_jason_End", KA_jason_End)

-----------------------------------------------------------
-- MYERS — Target icon + wallhack status sounds
-- Material: icons/icon_target.png
-----------------------------------------------------------

local myers_victimPos = nil

net.Receive("sls_kability_update_myersability", function(len)
    local status = net.ReadInt(2)
    if status == 2 then
        -- Ability available
    elseif status == 1 then
        surface.PlaySound("slashers/effects/michael_ability_on.wav")
    elseif status == 0 then
        -- Deactivated
    end
end)

net.Receive("sls_kability_Wallhack", function(len)
    local tempPos = net.ReadVector()
    if tempPos == Vector(42, 42, 42) then
        myers_victimPos = nil
    else
        myers_victimPos = tempPos
    end
end)

local ICON_TARGET_MYERS = Material("icons/icon_target.png")

local function KA_myers_HUDPaintBackground()
    if LocalPlayer():Team() ~= TEAM_KILLER or not GM.ROUND.Active or not myers_victimPos then return end
    local pos = myers_victimPos:ToScreen()
    surface.SetDrawColor(Color(255, 255, 255))
    surface.SetMaterial(ICON_TARGET_MYERS)
    surface.DrawTexturedRect(pos.x - 64, pos.y - 64, 128, 128)
    -- Also draw the static icon in the top-right corner
    surface.DrawTexturedRect(ScrW() - 110, 10, 100, 100)
end
hook.Add("HUDPaintBackground", "sls_ka_myers_HUDPaintBackground", KA_myers_HUDPaintBackground)

local function KA_myers_PreStart()
    myers_victimPos = nil
end
hook.Add("sls_round_PreStart", "sls_ka_myers_PreStart", KA_myers_PreStart)

local function KA_myers_End()
    myers_victimPos = nil
end
hook.Add("sls_round_End", "sls_ka_myers_End", KA_myers_End)

-----------------------------------------------------------
-- PROXY — Invisibility visual effect + killer icon for shy girl
-- Effect:  DrawMaterialOverlay + DrawSharpen when invisible
-- Indicator: proxy icon shown to shy girl when killer in LoS
-----------------------------------------------------------

local proxy_PlyInvisible = false
local proxy_Visible      = false
local proxyPos           = nil
local proxyShowIcon      = false
local proxyTimerView     = 0

net.Receive("sls_kability_Invisible", function(len)
    proxy_PlyInvisible = net.ReadBool()
end)

net.Receive("sls_kability_InvisibleIndic", function(len)
    proxy_Visible = net.ReadBool()
end)

-- When invisible, apply a post-process overlay for the killer
local function KA_proxy_InvisibleVision()
    if not GM.ROUND.Active or not GM.ROUND.Survivors then return end
    if LocalPlayer():Team() ~= TEAM_KILLER then return end
    if proxy_PlyInvisible and LocalPlayer():Alive() then
        DrawMaterialOverlay("effects/dodge_overlay.vmt", -0.42)
        DrawSharpen(1.2, 1.2)
    end
end
hook.Add("RenderScreenspaceEffects", "sls_ka_proxy_InvisibleVision", KA_proxy_InvisibleVision)

-- Shy girl client: tell server when she sees the killer (so killer can stay visible)
local function KA_proxy_CheckKillerInSight()
    local killer = team.GetPlayers(TEAM_KILLER)[1]
    if not IsValid(killer) then return end
    local ply = LocalPlayer()
    local curtime = CurTime()

    if not ply:Alive() or killer == ply or not ply:IsLineOfSightClear(killer) then return end

    local TargetPosMax    = killer:GetPos() + killer:OBBMaxs() - Vector(10, 0, 0)
    local TargetPosCenter = killer:GetPos() + killer:OBBCenter()
    local TargetPosMin    = killer:GetPos() + killer:OBBMins() + Vector(10, 0, 0)

    local ScreenPosMax    = TargetPosMax:ToScreen()
    local ScreenPosCenter = TargetPosCenter:ToScreen()
    local ScreenPosMin    = TargetPosMin:ToScreen()

    local posPlayer = ply:GetPos()
    if proxyTimerView < curtime and posPlayer:Distance(killer:GetPos()) < 150 then
        net.Start("sls_kability_survivorseekiller")
            net.WriteFloat(curtime)
        net.SendToServer()
        proxyTimerView = curtime + 0.2

    elseif proxyTimerView < curtime
       and ScreenPosMax.x < ScrW() and ScreenPosMax.y < ScrH()
       and ScreenPosMin.x > 0 and ScreenPosMin.y > 0 then
        net.Start("sls_kability_survivorseekiller")
            net.WriteFloat(curtime)
        net.SendToServer()
        proxyTimerView = curtime + 0.2
    end
end
hook.Add("Think", "sls_ka_proxy_CheckKillerInSight", KA_proxy_CheckKillerInSight)

-- Receive killer position when invisible (shown only to shy girl)
net.Receive("sls_proxy_sendpos", function(len)
    proxyPos      = net.ReadVector()
    proxyShowIcon = net.ReadBool()
end)

-- Draw proxy icon for shy girl when she has LoS to invisible killer
local function KA_proxy_drawIconOnProxy()
    if not proxyShowIcon or not proxyPos then return end
    if LocalPlayer().ClassID ~= CLASS_SURV_SHY then return end

    local pos = proxyPos:ToScreen()
    local iconMat = GM.MAP.Killer.Icon or Material("icons/icon_proxy.png")
    surface.SetDrawColor(Color(255, 255, 255))
    surface.SetMaterial(iconMat)
    surface.DrawTexturedRect(pos.x - 64, pos.y - 64, 64, 64)
end
hook.Add("HUDPaintBackground", "sls_ka_proxy_drawIconOnProxy", KA_proxy_drawIconOnProxy)

-----------------------------------------------------------
-- BATES — Mother radar whisper audio
-- Sounds: whisper_loop_high/medium/small.wav
-----------------------------------------------------------

-- Keep a reference to the currently playing looped station
GM.SoundPlayed_bates = nil
GM.oldLevel_bates    = nil

local function PlaySoundMother_bates(file)
    if IsValid(GM.SoundPlayed_bates) then
        GM.SoundPlayed_bates:Stop()
    end
    sound.PlayFile(file, "", function(station, num, err)
        if IsValid(station) then
            station:Play()
            station:EnableLooping(true)
            GM.SoundPlayed_bates = station
        end
    end)
end

local function StopSoundMother_bates()
    if IsValid(GM.SoundPlayed_bates) then
        GM.SoundPlayed_bates:Stop()
        GM.SoundPlayed_bates = nil
    end
end

local function SoundToPlay_bates(level)
    if LocalPlayer():Team() == TEAM_SPECTATOR then return end
    if level == 3 then
        PlaySoundMother_bates("sound/slashers/effects/whisper_loop_high.wav")
    elseif level == 2 then
        PlaySoundMother_bates("sound/slashers/effects/whisper_loop_medium.wav")
    elseif level == 1 then
        PlaySoundMother_bates("sound/slashers/effects/whisper_loop_small.wav")
    else
        StopSoundMother_bates()
    end
end

-- Received from server when survivor→mother distance changes
net.Receive("sls_motherradar", function(len)
    local distLevel = net.ReadUInt(2)
    if GM.oldLevel_bates ~= distLevel then
        GM.oldLevel_bates = distLevel
        SoundToPlay_bates(distLevel)
    end
end)

-- Stop audio when round ends
local function KA_bates_autoEnd()
    StopSoundMother_bates()
end
hook.Add("sls_round_End", "sls_ka_bates_autoEnd", KA_bates_autoEnd)

-----------------------------------------------------------
-- INTRUDER — Red halo around nearby traps for shy girl
-- Net: sls_trapspos
-----------------------------------------------------------

local intruder_trapsEntity = {}

net.Receive("sls_trapspos", function(len)
    intruder_trapsEntity = net.ReadTable()
end)

local function KA_intruder_AddHalos()
    if LocalPlayer().ClassID ~= CLASS_SURV_SHY then return end
    if #intruder_trapsEntity == 0 then return end
    halo.Add(intruder_trapsEntity, Color(255, 0, 0), 5, 5, 2)
end
hook.Add("PreDrawHalos", "sls_ka_intruder_AddHalos", KA_intruder_AddHalos)
