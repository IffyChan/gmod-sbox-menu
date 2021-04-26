file.CreateDir('sboxmenu')

local function saveImage(path, url, callback)
	http.Fetch(url, function(data)
		file.Write(path, data)
		callback(Material('../data/' .. path))
	end)
end

return function(workshopid, callback)
	local path = 'sboxmenu/' .. workshopid .. '.jpg'
	if file.Exists(path, 'DATA') then
		callback(Material('../data/' .. path))
	else
		http.Post('https://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1/', {
			['itemcount'] = '1',
			['publishedfileids[0]'] = tostring(workshopid),
		}, function(json)
			local info = util.JSONToTable(json)
			if info and info.response then
				local imageLink = info.response.publishedfiledetails[1].preview_url
				saveImage(path, imageLink, callback)
			end
		end)
	end
end