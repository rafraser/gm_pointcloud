SWEP.PrintName = "Point Scanning Gun"
SWEP.Spawnable = true

SWEP.Primary.Sound = Sound("buttons/button15.wav")
SWEP.Primary.Delay = 0.1
SWEP.Primary.Automatic = true
SWEP.Primary.Density = 100

SWEP.Secondary.Sound = Sound("buttons/button17.wav")
SWEP.Secondary.Delay = 1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Density = 10000

SWEP.CallbackEndpoint = CreateConVar("pointcloud_url", "", FCVAR_REPLICATED)
SWEP.TraceDistance = 10000

if CLIENT then
    SWEP.SpriteMaterial = Material("sprites/sent_ball")
end

function SWEP:RegisterPoint(tr)
    -- Only track points that hit the world
    if not tr.HitWorld then return end
    if tr.HitSky then return end

    -- Get the colour from the hit surface
    -- This isn't a perfect implementation but it works well enough for standard brushes
    local details = render.GetSurfaceColor(tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
    local r = math.floor(details.x * 255)
    local g = math.floor(details.y * 255)
    local b = math.floor(details.z * 255)

    if not self.points then self.points = {} end
    table.insert(self.points, {tr.HitPos.x, tr.HitPos.y, tr.HitPos.z, r, g, b})
end

function SWEP:SpreadVector(spread, up)
    -- Create a normal vector for aiming
    local base = Vector(math.Rand(-1, 1), math.Rand(-1, 1), 0):GetNormalized() * spread
    base:Rotate(up:Angle())

    -- Rotate randomly to add some spread
    local ang = base:Angle()
    ang.x = ang.x * math.Rand(-1, 1)
    ang.y = ang.y * math.Rand(-1, 1)
    base:Rotate(ang)
    return base
end

function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end
    self:EmitSound(self.Primary.Sound, 75, math.random(80, 110), 0.1)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    if SERVER then return end

    -- Run traces on the client
    local owner = self:GetOwner()
    local startpos = owner:EyePos()
    local up = owner:EyeAngles():Up()
    local numpoints = self.Primary.Density * 1

    for i = 1, numpoints do
        -- Create random points in a rough cone shape
        local direction = owner:EyeAngles():Forward()
        direction:Add(self:SpreadVector(0.5, up))

        local tr = util.TraceLine({
            start = startpos,
            endpos = startpos + (direction * self.TraceDistance),
            filter = {owner}
        })
        self:RegisterPoint(tr)
    end
end

function SWEP:SecondaryAttack()
    if not self:CanSecondaryAttack() then return end
    self:EmitSound(self.Secondary.Sound, 75, math.random(80, 110), 0.21)
    self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
    if SERVER then return end

    local owner = self:GetOwner()
    local startpos = owner:EyePos()
    local numpoints = self.Secondary.Density * 1

    for i = 1, self.Secondary.Density do
        -- Create random points in a rough sphere shape
        local direction = Vector(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(-1, 1)):GetNormalized()

        local tr = util.TraceLine({
            start = startpos,
            endpos = startpos + (direction * self.TraceDistance),
            filter = {owner}
        })
        self:RegisterPoint(tr)
    end
end

function SWEP:BroadcastPoints(data)
    if #data < 1 then return end
    local json = util.TableToJSON(self.points)
    local url = self.CallbackEndpoint:GetString() .. "/points"

    -- Ensure our body is marked as json
    local headers = {
        ['Accept'] = 'application/json',
        ['Content-Type'] = 'application/json',
    }

    -- Send a post request to the server
    local request = {
        url = url,
        method = "post",
        body = json,
        headers = headers,
        success = function() end,
        failed = function(err)
            print(err)
        end
    }
    HTTP(request)
end

function SWEP:Think()
    if SERVER then return end

    -- Every few seconds, broadcast our points up to the server
    if not self.NextThinkTime or CurTime() > self.NextThinkTime then
        if self.points then
            self:BroadcastPoints(self.points)
        end

        self.points = {}
        self.NextThinkTime = CurTime() + 3
    end
end

function SWEP:Reload()
end

if CLIENT then
    SWEP.SpriteMaterial = Material("sprites/sent_ball")
end

function SWEP:DrawHUD()
    -- Render any points we haven't sent to the server yet in glorious 3D
    -- Todo: track more points? Possibly add some nice fading effects?
    cam.Start3D()
    render.SetMaterial(self.SpriteMaterial)
    if self.points then
        for _, v in pairs(self.points) do
            local pos = Vector(v[1], v[2], v[3])
            local col = Color(v[4], v[5], v[6])
            render.DrawSprite(pos, 4, 4, col)
        end
    end
    cam.End3D()
end