--[[
    Addon: Screencap
    Author: Timmy
    Contact: hello[at]timmy[dot]ws
--]]

if SERVER then
    util.AddNetworkString("screencap")

    local buffer = ""
    net.Receive("screencap", function()
        local finished = net.ReadBool()
        local size = net.ReadUInt(16)
        local chunk = net.ReadData(size)
        local calling_ply = net.ReadEntity()
        local target_ply = net.ReadEntity()

        buffer = buffer .. chunk

        if not finished then return false end

        local imgur = Imgur.New()
        imgur:SetClientId(file.Read("data/imgur_clientid.txt", "GAME"))
        imgur:Upload(util.Base64Encode(util.Decompress(buffer)), function(code, body, headers)
            local response = util.JSONToTable(body)

            if not response.success then
                ULib.tsayError(calling_ply, "Failed to upload image to Imgur.")
                return false
            end

            ULib.tsayColor(calling_ply, false, Color(255, 105, 180), "[Screencap] ", Color(255, 255, 255), "Screen capture from " .. target_ply:Nick() .. ": " .. response.data.link)
        end, function(error)
            ULib.tsayError(calling_ply, error)
        end)
        buffer = ""
    end)
end

if CLIENT then

    local function capture()
        local settings = {}
        settings.format = "jpeg"
        settings.quality = 80
        settings.w = ScrW()
        settings.h = ScrH()
        settings.x = 0
        settings.y = 0

        return render.Capture(settings)
    end

    net.Receive("screencap", function()
        local calling_ply = net.ReadEntity()

        local capture = util.Compress(capture())
        local capsize = string.len(capture)
        local chunksize = 60000
		local chunks = math.ceil(capsize / chunksize)
        local time = 0

        local progress = 0
        for i = 1, chunks do
            local endbyte = math.min(progress + chunksize, capsize)
            local size = endbyte - progress

            net.Start("screencap")
            net.WriteBool(i == chunks)
            net.WriteUInt(size, 16)
            net.WriteData(capture:sub(progress + 1, endbyte + 1), size)
            net.WriteEntity(calling_ply)
            net.WriteEntity(LocalPlayer())
            net.SendToServer()

            progress = endbyte
            time = CurTime() + 1
        end
    end)
end

function ulx.screencap(calling_ply, target_ply)
    if not IsValid(target_ply) then return false end
    net.Start("screencap")
    net.WriteEntity(calling_ply)
    net.Send(target_ply)
end
local screencap = ulx.command("Utility", "ulx screencap", ulx.screencap, {"!sc", "/sc", "!screencap", "/screencap"}, true)
screencap:addParam{type=ULib.cmds.PlayerArg}
screencap:defaultAccess(ULib.ACCESS_SUPERADMIN)
screencap:help("Take a screenshot of the players game.")
