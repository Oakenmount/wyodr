
local helpdocs = {
	["Jailbreak"] = {
		icon = "icon16/map.png",
		articles = {
			["Quickstart"] = {
				icon = "icon16/time_go.png",
				content = [[
					<h2>Quickstart</h2>
					<ol>
						<li>Two teams: guards and prisoners</li>
						<li>Guards can give prisoners orders which they have to obey</li>
						<li>If prisoners don't obey, guards can punish prisoners</li>
						<li>Prisoners can rebel against guards, which basically means killing each other</li>
						<li>However guards should only attack prisoners when they're clearly disobeying orders</li>
					</ol>
				]]
			},
			["Terms"] = {
				icon = "icon16/script.png",
				content = [[
					<h2>Terms</h2>
					<ul>
					<li>Last reaction [action]: The last person to do the action will die</li>
					<li>First reaction [action]: The first person to do the action will die</li>
					</ul>
				]]
			},
			["Achievements"] = {
				icon = "icon16/script.png",
				content = [[
				<h2>Achievements</h2>
				<ul id="el_achs"></ul>
				<script>
				    var achs = JSON.parse(ejb.ListAchievements());
				    for (var key in achs) {
				        var ach = achs[key];
				        var liel = create_el("li", "el_achs");
				        create_el("span", liel).innerHTML = ach.name.padRight(50);
				        if (ach.achieved) {
				            var achspan = create_el("span", liel);
				            achspan.innerHTML = " ✔ Achieved!";
				            achspan.style.color = "green";
				        }
				    }
				</script>
				]]
			},
			["Special rounds"] = {
				icon = "icon16/script.png",
				content = [[
					<h2>Zombie Freeday</h2>
					<ul>
					<li>All prisoners must walk (NO HOLDING SHIFT) around at all times. If a prisoner runs, a guard may shoot them.</li>
					<li>Prisoners may not use weapons (will result in punishment)</li>
					<li>Prisoners may punch or knife guards at all times, and prisoners may not shoot them for it.</li>
					<li>Guards may only shoot prisoners for running, and must attempt to run from prisoners.</li>
					</ul>
					<br>
				]]
			},
			["Controls"] = {
				icon = "icon16/controller.png",
				content = [[
					<h2>Controls</h2>
					<h3>Guards</h3>
					<ul>
					<li><span id="cmd_warden">F3</span> - Opt in for becoming warden</li>
					<li>Suitzoom (<span id="cmd_wp"></span>) - Place a waypoint (Warden only)</li>
					</ul>
					<h3>Everyone</h3>
					<ul>
					<li>Spawn Menu (<span id="cmd_drop">Q</span>) - Drop your weapon</li>
					<li><span id="cmd_help">F1</span> - Toggle this menu</li>
					</ul>
					<script>
						var bindings = {
							"help": "gm_showhelp",
							"drop": "+menu",
							"wp": "+zoom",
							"warden": "gm_showspare1"
						};
						for (var idx in bindings)
							document.querySelector("#cmd_" + idx).innerHTML = ejb.LookupBinding(bindings[idx]);
					</script>
				]]
			},
			["Chat Commands"] = {
			icon = "icon16/script.png",
			content = [[
			<h2>Chat Commands</h2>
			<ul>
			<li>!votebanguard <name> - Vote to get a player banned from playing guard</li>
			<li>!playtime - Shows your playtime on the server in minutes</li>
			</ul>
			<h2>Supporter Chat Commands</h2>
			<ul>
			<li>(img www.yourwebiste/yourimage.png) - to post an image in chat.</li>
			<li>Your message here (use tts) - Use text to speech (may not always work)</li>
			</ul>
			]]
			},
			["Console Commands"] = {
			icon = "icon16/script.png",
			content = [[
			<h2>Console Commands</h2>
			<ul>
			<li>jb_taunt - Emits a taunt sound if your model has one</li>
			<li>jb_openwardenmenu - Opens warden menu... shit sherlock.</li>
			</ul>
			]]
			}
		}	
	},
	["Server"] = {
		icon = "icon16/rosette.png",
		articles = {
			["How to get admin"] = {
				icon = "icon16/star.png",
				content = [[
<style>body {background-color: black;}</style>
<audio autoplay>
<source src="http://a.tumblr.com/tumblr_mascpn4kyJ1qejfr7o1.mp3" type="audio/mp3">
</audio>
<img src="http://24.media.tumblr.com/tumblr_mcqdv13yny1qcuxfvo1_500.gif">
<img src="http://24.media.tumblr.com/tumblr_mcqdv13yny1qcuxfvo1_500.gif">
<img src="http://24.media.tumblr.com/tumblr_mcqdv13yny1qcuxfvo1_500.gif">
<img src="http://24.media.tumblr.com/tumblr_mcqdv13yny1qcuxfvo1_500.gif">
<img src="http://24.media.tumblr.com/tumblr_mcqdv13yny1qcuxfvo1_500.gif">
<img src="http://24.media.tumblr.com/tumblr_mcqdv13yny1qcuxfvo1_500.gif">
<img src="http://24.media.tumblr.com/tumblr_mcqdv13yny1qcuxfvo1_500.gif">
				]]
			}
		}
	}
}
local default_html = [[
	<h1>Jailbreak Help</h1><br>
]]

local function AddHelpComponents(frame)
	local ctrl = vgui.Create( "DTree", frame )
	
	ctrl:Dock(LEFT)
	ctrl:SetSize( 200, 300 )
	
	local html = vgui.Create("DHTML", frame)
	html:Dock(FILL)
	html:AddFunction("ejb", "LookupBinding", function(b)
		return string.upper(input.LookupBinding(b) or "")
	end)
	html:AddFunction("ejb", "ListAchievements", function(b)
	    local my_achievements = LocalPlayer():GetAchievementTable()
	    if not my_achievements then return end
	    local ret = {}
	    for achid, ach in SortedPairs(wyodr.NAchievements) do
	        table.insert(ret, {achid=achid, name=ach.name, achieved=table.HasValue(my_achievements, achid)}) 
	    end
	    return util.TableToJSON(ret)
	end)
	
	local function SetHtml(content)
		local fcontent = {
		[[
		<html>
		<head>
		<link rel="stylesheet" href="http://yui.yahooapis.com/pure/0.3.0/base-min.css">
		<link href='http://fonts.googleapis.com/css?family=Hammersmith+One' rel='stylesheet' type='text/css'>
		<style>
		body {
			background-color: white;
			color: black;
			text-align: center;
		}
		h1, h2 {
			font-family: 'Hammersmith One', sans-serif;
		}
		ol, ul {
			text-align: left;	
		}
		</style>
		<script>
    		function create_el(tag, parent_id) {
    		    var el = document.createElement(tag);
    		    if (typeof parent_id == "string")
    		        document.getElementById(parent_id).appendChild(el);
    		    else
    		        parent_id.appendChild(el);
    		    return el;
    		}
    		String.prototype.padRight = function(l,c) {return this+Array(l-this.length+1).join(c||" ")}
		</script>
		</head>
		<body>
		<div id="main">
		]],
		content,
		[[
		</div>
		</body>
		</html>
		]]
		}
		html:SetHTML(table.concat(fcontent, ""))
	end
	
	SetHtml(default_html)
	do
		local homenode = ctrl:AddNode("Home")
		homenode.Icon:SetImage("icon16/house.png")
		homenode.DoClick = function() SetHtml(default_html) end
	end
	
	local function AddCat(cat, cattbl, par)
		local catnode = (par or ctrl):AddNode(cat)
		if cattbl.icon then catnode.Icon:SetImage(cattbl.icon) end
		catnode:SetExpanded(true)
		if cattbl.content then
			catnode.DoClick = function()
				SetHtml(cattbl.content)
			end	
		end
		for art, arttbl in pairs(cattbl.articles) do
			if arttbl.articles then
				AddCat(art, arttbl, catnode)
			else
				local artnode = catnode:AddNode(art)
				if arttbl.icon then artnode.Icon:SetImage(arttbl.icon) end
				artnode.DoClick = function()
					SetHtml(arttbl.content)
				end
			end
		end
	end
	
	for cat, cattbl in pairs(helpdocs) do
		AddCat(cat, cattbl)
	end
end

local function ToggleHelpMenu()
	if IsValid(wyodr.HelpMenu) then return wyodr.HelpMenu:Remove() end
	local frame = vgui.Create("DFrame")
	wyodr.HelpMenu = frame
	frame:SetSize(800, 700)
	frame:Center()
	frame:SetTitle("Help Menu")
	frame:ShowCloseButton(true)
	
	local halpkey = _G["KEY_" .. (input.LookupBinding("gm_showhelp") or "F1")]
	local halpstatus = input.IsKeyDown(halpkey)
	frame.Think = function(self)
		local isdown = input.IsKeyDown(halpkey)
		if isdown ~= halpstatus then
			if isdown then self:Remove() return  end
			halpstatus = isdown
		end
	end
	
	AddHelpComponents(frame)
	
	frame:MakePopup()
end

hook.Add("PlayerBindPress", "OpenHelpMenu", function(ply, bind, press)
	if bind == "gm_showhelp" and press then
		ToggleHelpMenu()
		return true	
	end
end)
