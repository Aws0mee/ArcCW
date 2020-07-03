
function SWEP:SelectUBGL()
    self:SetNWBool("ubgl", true)
    self:EmitSound(self.SelectUBGLSound)
    self:SetNWInt("firemode", 1)

    if CLIENT then
        if !ArcCW:ShouldDrawHUDElement("CHudAmmo") then
            self:GetOwner():ChatPrint("Selected " .. self:GetBuff_Override("UBGL_PrintName") or "UBGL")
        end
        if !self:GetLHIKAnim() then
            self:DoLHIKAnimation("enter")
        end
    end
end

function SWEP:DeselectUBGL()
    self:SetNWBool("ubgl", false)
    self:EmitSound(self.ExitUBGLSound)

    if CLIENT then
        if !ArcCW:ShouldDrawHUDElement("CHudAmmo") then
            self:GetOwner():ChatPrint("Deselected " .. self:GetBuff_Override("UBGL_PrintName") or "UBGL")
        end
        if !self:GetLHIKAnim() then
            self:DoLHIKAnimation("exit")
        end
    end
end

function SWEP:RecoilUBGL()
    if !game.SinglePlayer() and !IsFirstTimePredicted() then return end
    if game.SinglePlayer() and self:GetOwner():IsValid() and SERVER then
        self:CallOnClient("RecoilUBGL")
    end

    local amt = self:GetBuff_Override("UBGL_Recoil")

    local r = math.Rand(-1, 1)
    local ru = math.Rand(0.75, 1.25)

    local m = 1 * amt
    local rs = 1 * amt * 0.1
    local vsm = 1

    local vpa = Angle(0, 0, 0)

    vpa = vpa + (Angle(1, 0, 0) * amt * m * vsm)

    vpa = vpa + (Angle(0, 1, 0) * r * amt * m * vsm)

    self:GetOwner():ViewPunch(vpa)
    -- self:SetNWFloat("recoil", self.Recoil * m)
    -- self:SetNWFloat("recoilside", r * self.RecoilSide * m)

    local ang = self:GetOwner():GetViewPunchAngles()

    ang[1] = math.Clamp(ang[1], -180, 180)
    ang[2] = math.Clamp(ang[2], -180, 180)
    ang[3] = math.Clamp(ang[3], -180, 180)

    self:GetOwner():SetViewPunchAngles(ang)

    if CLIENT or game.SinglePlayer() then

        self.RecoilAmount = self.RecoilAmount + (amt * m)
        self.RecoilAmountSide = self.RecoilAmountSide + (r * amt * m * rs)

        self.RecoilPunchBack = amt * 1 * m

        if self.MaxRecoilBlowback > 0 then
            self.RecoilPunchBack = math.Clamp(self.RecoilPunchBack, 0, self.MaxRecoilBlowback)
        end

        self.RecoilPunchSide = rs * rs * m * 0.1 * vsm
        self.RecoilPunchUp = ru * amt * m * 0.3 * vsm
    end
end

function SWEP:ShootUBGL()
    if self:GetNextSecondaryFire() > CurTime() then return end

    self.Primary.Automatic = self:GetBuff_Override("UBGL_Automatic")

    local ubglammo = self:GetBuff_Override("UBGL_Ammo")

    if self:Clip2() <= 0 and self:GetOwner():GetAmmoCount(ubglammo) <= 0 then
        self.Primary.Automatic = false
        self:DeselectUBGL()
        return
    end

    if self:Clip2() <= 0 then
        return
    end

    self:RecoilUBGL()

    local func, slot = self:GetBuff_Override("UBGL_Fire")

    if func then
        func(self, self.Attachments[slot].VElement)
    end

    self:SetNextSecondaryFire(CurTime() + (60 / self:GetBuff_Override("UBGL_RPM")))
end

function SWEP:ReloadUBGL()
    if self:GetNextSecondaryFire() > CurTime() then return end

    local reloadfunc, slot = self:GetBuff_Override("UBGL_Reload")

    if reloadfunc then
        reloadfunc(self, self.Attachments[slot].VElement)
    end
end