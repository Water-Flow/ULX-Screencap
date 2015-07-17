--[[
  Imgur API wrapper
--]]

Imgur = {}

Imgur.Base = "https://api.imgur.com/3/"
Imgur.Config = {}

Imgur.New = function(clientId)
    local object = {}

    for key, value in pairs(Imgur) do
        object[key] = value
    end

    if clientId then
        object.SetClientId(clientId)
    end

    return object
end

Imgur.SetClientId = function(self, clientId)
    self.Config.ClientId = clientId
end

Imgur.Upload = function(self, image, success, failure)
    assert(self.Config.ClientId, "Client-ID not set")

    local request = {}

    request.url = Imgur.Base .. "upload"

    request.method = "post"

    request.headers = {
        ["Authorization"] = "Client-ID " .. self.Config.ClientId
    }

    request.parameters = {
        ["image"] = image
    }

    if success then
        request.success = success
    end

    if failure then
        request.failed = failure
    end

    HTTP(request)
end
