local s,id=GetID()

local SET_BIZARRE = 0xBA5

s.listed_series={SET_BIZARRE}

function s.initial_effect(c)
	
	
	-- Treated as "Bizarre"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
	e1:SetValue(SET_BIZARRE) -- Replace with the ID of a card named "Bizarre" if one exists
	c:RegisterEffect(e1)

	-- Must be Special Summoned by "Bizarre" card effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(s.splimit)
	c:RegisterEffect(e2)

	-- ATK Gain
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)

	-- Destroy Spells/Traps
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.descon)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)

	-- Destruction Trigger
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_DAMAGE+CATEGORY_ATKCHANGE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCondition(s.vocalcon)
	e5:SetTarget(s.vocaltg)
	e5:SetOperation(s.vocalop)
	c:RegisterEffect(e5)

	-- Rage Mode (Once per Duel)
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
	e6:SetCondition(s.ragecon)
	e6:SetCost(s.ragecost)
	e6:SetOperation(s.rageop)
	c:RegisterEffect(e6)
end

-- Archetype definition
s.listed_series={0xBA5} 

-- Special Summon limit
function s.splimit(e,se,sp,st)
	return se:GetHandler():IsSetCard(0xBA5)
end

-- ATK boost logic
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsSetCard,c:GetControler(),LOCATION_GRAVE,0,nil,0xBA6)*300
end

-- Spell/Trap Destruction logic
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_SZONE,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_SZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	-- Chain restriction
	Duel.SetChainLimit(aux.FALSE)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_SZONE,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

-- Destruction logic (Red Avdol check)
function s.vocalcon(e,tp,eg,ep,ev,re,r,rp)
	-- Assuming "Red Avdol" monsters have a specific archetype or name string
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode, 1000001),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) -- Replace 1000003 with actual Red Avdol ID
end
function s.vocaltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,2000)
end
function s.vocalop(e,tp,eg,ep,ev,re,r,rp)
	-- Inflict 2000
	if Duel.Damage(1-tp,2000,REASON_EFFECT) then
		-- Lock monster effects
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(0,1)
		e1:SetValue(aux.FilterBoolFunction(Card.IsType,TYPE_MONSTER))
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		Duel.RegisterEffect(e1,tp)
		-- Lose 1500 ATK
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		for tc in aux.Next(g) do
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetValue(-1500)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	end
end

-- Rage Mode logic
function s.ragecon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(tp)<=2000
end
function s.costfilter1(c)
	return c:IsAbleToBanishAsCost() and c:IsSetCard(0xBA5) and (c:IsAttribute(ATTRIBUTE_FIRE) or c:IsAttribute(ATTRIBUTE_DARK))
end
function s.costfilter2(c)
	return c:IsAbleToBanishAsCost() and c:IsAttribute(ATTRIBUTE_FIRE)
end
function s.ragecost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetMatchingGroup(s.costfilter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	local g2=Duel.GetMatchingGroup(s.costfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if chk==0 then return #g1>=3 or #g2>=4 end
	local g=Group.CreateGroup()
	if #g1>=3 and (#g2<4 or Duel.SelectYesNo(tp,aux.Stringid(id,3))) then -- "Banish 3 Bizarre?"
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		g=g1:Select(tp,3,3,nil)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		g=g2:Select(tp,4,4,nil)
	end
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.rageop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- ATK becomes 6000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(6900)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- Cannot be negated
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
		-- Banish during End Phase
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetCountLimit(1)
		e3:SetRange(LOCATION_MZONE)
		e3:SetOperation(s.banop)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e3)
	end
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end