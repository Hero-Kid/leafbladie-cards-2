--Kali, The Destroyer of Light
local WIN_REASON_KALI=0x30
local s,id=GetID()
function s.initial_effect(c)
	-- Fusion Materials
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,21208154,62180201,57793869)
	-- Summon cannot be negated
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
	c:RegisterEffect(e0)
	
	-- Send as many cards from hands and field to GY
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)

	-- Negate effects in GY and banishment
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
	e3:SetTarget(s.negfilter)
	c:RegisterEffect(e3)

	-- ATK/DEF gain
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.atkval)
	c:RegisterEffect(e4)
	local e4b=e4:Clone()
	e4b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4b)

	-- Replacement: lose 1000 ATK/DEF instead of leaving field
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_NO_TURN_RESET)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTarget(s.reptg)
	c:RegisterEffect(e5)
    
    local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_NO_TURN_RESET)
	e6:SetCode(EFFECT_SEND_REPLACE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTarget(s.reptg2)
	c:RegisterEffect(e6)

	-- End Phase win condition
    local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e7:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_DELAY)
	e7:SetCode(EVENT_PHASE+PHASE_END)
	e7:SetRange(LOCATION_MZONE)
    e7:SetCountLimit(1)
    e7:SetCondition(s.wincon)
	e7:SetOperation(s.winop)
	c:RegisterEffect(e7)
end

s.listed_names={21208154,62180201,57793869,id}


function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_HAND+LOCATION_ONFIELD,LOCATION_HAND+LOCATION_ONFIELD,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end


function s.negfilter(e,c)
	return not (
		c:ListsCode(21208154)
		or c:ListsCode(62180201)
		or c:ListsCode(57793869)
		or c:ListsCode(id)
	)
end


function s.atkval(e,c)
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED)*1000
end


function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and (c:IsReason(REASON_EFFECT) or c:IsReason(REASON_BATTLE))
		and c:GetAttack()>=1000 and c:GetDefense()>=1000 end
	if Duel.SelectEffectYesNo(tp,c,96) then
        local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_UPDATE_DEFENSE)
        c:RegisterEffect(e2)
		return true
	else return false end
end

function s.reptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetDestination()==LOCATION_REMOVED or LOCATION_GRAVE or LOCATION_EXTRA and c:GetAttack()>=1000 and c:GetDefense()>=1000 end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
        local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_UPDATE_DEFENSE)
        c:RegisterEffect(e2)
		return true
	else return false end
end


function s.wincon(e,tp)
	local c=e:GetHandler()
	return c:GetAttack()>=20000 and c:GetDefense()>=20000
end

function s.winop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Win(tp,WIN_REASON_KALI)
end
