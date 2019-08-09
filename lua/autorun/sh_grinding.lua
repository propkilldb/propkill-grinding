local ducking = {}

function HandleGrinding(ply, mv, cmd)
	if ducking[ply] and ply:IsOnGround() and ply:GetGroundEntity() != NULL then
		local dist = 70
		local minSpeed = 210
		local trace = {}
		trace.start = ply:GetPos() + Vector(-dist, 0, 15)
		trace.endpos = ply:GetPos() - Vector(dist, 0, 20)
		trace.filter = ply
		local trLeft = util.TraceLine(trace)

		local trace = {}
		trace.start = ply:GetPos() + Vector(dist, 0, 15)
		trace.endpos = ply:GetPos() - Vector(-dist, 0, 20)
		trace.filter = ply
		local trRight = util.TraceLine(trace)

		local trace = {}
		trace.start = ply:GetPos() + Vector(0, -dist, 15)
		trace.endpos = ply:GetPos() - Vector(0, dist, 20)
		trace.filter = ply
		local trFront = util.TraceLine(trace)

		local trace = {}
		trace.start = ply:GetPos() + Vector(0, dist, 15)
		trace.endpos = ply:GetPos() - Vector(0, -dist, 20)
		trace.filter = ply
		local trBack = util.TraceLine(trace)

		soundId = nil
		if (!trLeft.Hit or !trRight.Hit or !trFront.Hit or !trBack.Hit) and ((ply:GetVelocity().x > minSpeed or ply:GetVelocity().x < -minSpeed) or (ply:GetVelocity().y > minSpeed or ply:GetVelocity().y < -minSpeed)) then
			mv:SetVelocity(Vector(mv:GetVelocity().x * 1.13, mv:GetVelocity().y * 1.13, mv:GetVelocity().z))
			local pullForce = 5
			if trLeft.Hit then mv:SetVelocity(mv:GetVelocity() + Vector(-pullForce,0,0)) end
			if trRight.Hit then mv:SetVelocity(mv:GetVelocity() + Vector(pullForce,0,0)) end
			if trFront.Hit then mv:SetVelocity(mv:GetVelocity() + Vector(0,-pullForce,0)) end
			if trBack.Hit then mv:SetVelocity(mv:GetVelocity() + Vector(0,pullForce,0)) end
			ply:SetCrouchedWalkSpeed(0.2)
			if CLIENT then
				ply:SetAnimTime(CurTime() + 1)
			end
			if !timer.Exists("PK_GrindingSound") then
				grindSound = CreateSound(ply, "grinding/grindconcrete01.wav")
				ply.grindSound = grindSound
				//ply:EmitSound("grinding/grindconcrete01.wav", 75, 100, 0.2)
				grindSound:ChangeVolume(0.2)
				grindSound:Play()
				grindSound:ChangeVolume(0.2)
				timer.Create("PK_GrindingSound", 0.2, 0, function()
					grindSound:ChangeVolume(0.2)
					grindSound:Play()
					grindSound:ChangeVolume(0.2)
				end)
			end
			hook.Add("PlayerFootstep", "PK_Grinding", function(ply2, pos, foot,sound, volume, rf)
				if ply == ply2 then
					return true
				end
			end)
		else
			timer.Destroy("PK_GrindingSound")
			hook.Remove("PlayerFootstep", "PK_Grinding")
			if IsValid(grindSound) then
				grindSound:Stop()
			end
			ply:SetCrouchedWalkSpeed(0.60000002384186)
		end

		//print(trLeft.Hit, trRight.Hit, trFront.Hit, trBack.Hit, ply:GetVelocity(), ply:OnGround())
	else
		timer.Destroy("PK_GrindingSound")
		hook.Remove("PlayerFootstep", "PK_Grinding")
		if IsValid(grindSound) then
			grindSound:Stop()
		end
		ply:SetCrouchedWalkSpeed(0.60000002384186)
	end
end

resource.AddFile("sound/grinding/grindconcrete01.wav")
resource.AddFile("sound/grinding/ollie.wav")

local function StartPossibleGrind(ply, key)
	if key == IN_DUCK then
		hook.Add("SetupMove", "PK_Grinding", HandleGrinding)
		ducking[ply] = true
	elseif key == IN_JUMP and ducking[ply] then
		local dist = 70
		local minSpeed = 210
		local trace = {}
		trace.start = ply:GetPos() + Vector(-dist, 0, 15)
		trace.endpos = ply:GetPos() - Vector(dist, 0, 20)
		trace.filter = ply
		local trLeft = util.TraceLine(trace)

		local trace = {}
		trace.start = ply:GetPos() + Vector(dist, 0, 15)
		trace.endpos = ply:GetPos() - Vector(-dist, 0, 20)
		trace.filter = ply
		local trRight = util.TraceLine(trace)

		local trace = {}
		trace.start = ply:GetPos() + Vector(0, -dist, 15)
		trace.endpos = ply:GetPos() - Vector(0, dist, 20)
		trace.filter = ply
		local trFront = util.TraceLine(trace)

		local trace = {}
		trace.start = ply:GetPos() + Vector(0, dist, 15)
		trace.endpos = ply:GetPos() - Vector(0, -dist, 20)
		trace.filter = ply
		local trBack = util.TraceLine(trace)

		if (!trLeft.Hit or !trRight.Hit or !trFront.Hit or !trBack.Hit) and ((ply:GetVelocity().x > minSpeed or ply:GetVelocity().y < -minSpeed) or (ply:GetVelocity().y > minSpeed or ply:GetVelocity().y < -minSpeed))
		and ply:OnGround() and SERVER then
			ply:EmitSound("grinding/ollie.wav")
		end
	end
end
hook.Add("KeyPress", "PK_Grinding", StartPossibleGrind)

local function StopGrind(ply, key)
	if key == IN_DUCK then
		hook.Remove("SetupMove", "PK_Grinding")
		hook.Remove("PlayerFootstep", "PK_Grinding")
		timer.Destroy("PK_GrindingSound")
		ply:StopSound("grinding/grindconcrete01.wav")
		ducking[ply] = false
		if IsValid(ply.grindSound) then
			ply.grindSound:Stop()
		end
		ply:SetCrouchedWalkSpeed(0.60000002384186)
	end
end
hook.Add("KeyRelease", "PK_Grinding", StopGrind)


//function SWEP:CanGrab() -- This too, but modified it somewhat.
//
//    // We'll detect whether we can grab onto the ledge.
//    local trace = {}
//    trace.start = self.Owner:GetShootPos() + Vector( 0, 0, 15 )
//    trace.endpos = trace.start + self.Owner:GetAimVector() * 30
//    trace.filter = self.Owner
//
//    local trHi = util.TraceLine(trace)
//
//    local trace = {}
//    trace.start = self.Owner:GetShootPos()
//    trace.endpos = trace.start + self.Owner:GetAimVector() * 30
//    trace.filter = self.Owner
//
//    local trLo = util.TraceLine(trace)
//
//    // Is the ledge actually grabbable?
//    if trLo and trHi and trLo.Hit and !trHi.Hit then
//        return {true, trLo}
//    else
//        return {false, trLo}
//    end
//
//end