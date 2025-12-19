-- Wonder Phantom – Avatar of Calamity
local s,id=GetID()
local SET_BIZARRE=0xBA5
local SET_PHANTOM=0xBA6

s.listed_series={SET_BIZARRE,SET_PHANTOM}

function s.initial_effect(c)
    -- Treated as Bizarre & Phantom everywhere
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_SETCODE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e0:SetRange(LOCATION_DECK+LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
    e0:SetValue(SET_BIZARRE)
    c:RegisterEffect(e0)

    local e0b=e0:Clone()
    e0b:SetValue(SET_PHANTOM)
    c:RegisterEffect(e0b)

    -- Indestructible by battle or effects
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    local e2=e1:Clone()
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    c:RegisterEffect(e2)

    -- Restrict Special Summons after this card is on field
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetTargetRange(1,0)
    e3:SetTarget(s.splimit)
    e3:SetReset(RESET_PHASE+PHASE_END)
    c:RegisterEffect(e3)

    -- Opponent cannot attack
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_CANNOT_ATTACK)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(0,LOCATION_MZONE)
    e4:SetCondition(function(e) return e:GetHandler():IsFaceup() end)
    c:RegisterEffect(e4)

    -- Calamity counters
    c:SetCounterLimit(0x1,5) -- Custom counter type, max 5
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,0))
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1)
    e5:SetOperation(s.addcounter)
    c:RegisterEffect(e5)
end

-- Special summon restriction target
function s.splimit(e,c)
    return not (c:IsAttribute(ATTRIBUTE_FIRE) or c:IsAttribute(ATTRIBUTE_DARK) or c:IsSetCard(SET_BIZARRE) or c:IsSetCard(SET_PHANTOM))
end

-- Add Calamity Counter & handle effects
function s.addcounter(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:GetCounter(0x1)>=5 then return end

    -- Increase counter
    c:AddCounter(0x1,1)
    local ct=c:GetCounter(0x1)

    -- Effects based on counter count
    if ct==3 then
        -- Skip opponent's next Battle Phase during your next Standby Phase
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
        e1:SetCountLimit(1)
        e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
        e1:SetOperation(function(e,tp) Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_STANDBY,1) end)
        e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
        Duel.RegisterEffect(e1,tp)
    elseif ct==5 then
        -- Destroy all opponent monsters during your next Standby Phase
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
        e2:SetCountLimit(1)
        e2:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
        e2:SetOperation(function(e,tp)
            local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
            if #g>0 then Duel.Destroy(g,REASON_EFFECT) end
        end)
        e2:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
        Duel.RegisterEffect(e2,tp)
    end

    -- Once per Duel 5th counter special banish effect
    if ct==5 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
        local g1=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
        if #g1>0 then Duel.Destroy(g1,REASON_EFFECT) end
        local g2=Duel.GetMatchingGroup(Card.IsDiscardable,tp,0,LOCATION_HAND,nil)
        if #g2>0 then
            local sg=g2:Select(1-tp, #g2, #g2, nil)
            Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
        end
    end
end
