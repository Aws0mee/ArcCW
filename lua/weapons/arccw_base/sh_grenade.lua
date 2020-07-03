SWEP.GrenadePrimeTime = 0

function SWEP:PreThrow()
    if self:Clip1() == 0 then
        if self:Ammo1() == 0 then
            return
        else
            self:SetClip1(1)
            self:GetOwner():SetAmmo(self:Ammo1() - 1, self.Primary.Ammo)
        end
    end
    if self:GetNWBool("grenadeprimed") then return end

    self:PlayAnimation("pre_throw", 1, false, 0, true)

    self:SetNextPrimaryFire(CurTime() + self.PullPinTime)

    self:SetNWBool("grenadeprimed", true)

    self.GrenadePrimeTime = CurTime()
end

function SWEP:Throw()
    if self:GetNextPrimaryFire() > CurTime() then return end

    self:SetNWBool("grenadeprimed", false)

    self:PlayAnimation("throw", 1, false, 0, true)

    local heldtime = (CurTime() - self.GrenadePrimeTime)

    local windup = heldtime / 0.5

    windup = math.Clamp(windup, 0, 1)

    local force = Lerp(windup, self.MuzzleVelocity * 0.25, self.MuzzleVelocity)

    self:SetTimer(0.25, function()
        local rocket = self:FireRocket(self.ShootEntity, force)

        if !rocket then return end

        if self.FuseTime then
            rocket.FuseTime = self.FuseTime - heldtime
        end

        local phys = rocket:GetPhysicsObject()

        phys:AddAngleVelocity( Vector(0, 750, 0) )

        self:TakePrimaryAmmo(1)

        if self:Clip1() == 0 and self:Ammo1() >= 1 and !self.Singleton then
            self:SetClip1(1)
            self:GetOwner():SetAmmo(self:Ammo1() - 1, self.Primary.Ammo)
        else
            self:GetOwner():StripWeapon(self:GetClass())
        end
    end)
    self:SetTimer(self:GetAnimKeyTime("throw"), function()
        self:PlayAnimation("draw")
    end)

    self:SetNextPrimaryFire(CurTime() + 1)
end