-- Red Avdol – The Standborn Flame
local s,id=GetID()

-- Archetype SetCodes
local SET_BIZARRE = 0xBA5
local SET_PHANTOM = 0xBA6 -- adjust if needed

s.listed_series={SET_BIZARRE}

function s.initial_effect(c)
  -- Treated as "Bizarre" while in GY, hand, and banished
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetCode(EFFECT_ADD_SETCODE)
  e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
  e0:SetRange(LOCATION_GRAVE+LOCATION_HAND+LOCATION_REMOVED)
  e0:SetValue(SET_BIZARRE)
  c:RegisterEffect(e0)

   
    -- You can only control 1 Red Avdol
    c:SetUniqueOnField(1,0,id)

    -- Unaffected by opponent's Trap effects (1+ Bizarre)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetCondition(s.immcon)
    e1:SetValue(s.immval)
    c:RegisterEffect(e1)

    -- Burn damage (3+ Bizarre)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.burncon)
    e2:SetOperation(s.burnop)
    c:RegisterEffect(e2)

    -- Search on destroy (5+ Bizarre)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCondition(s.thcon)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
end

-- Count Bizarre cards in GY
function s.bizarrecount(tp)
    return Duel.GetMatchingGroupCount(
        Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,SET_BIZARRE
    )
end

-- Trap immunity condition
function s.immcon(e)
    return s.bizarrecount(e:GetHandlerPlayer())>=1
end

-- Trap immunity value
function s.immval(e,re)
    return re:IsActiveType(TYPE_TRAP) and re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

-- Burn condition
function s.burncon(e,tp)
    return s.bizarrecount(tp)>=3
end

-- Burn operation
function s.burnop(e,tp)
    local ct=Duel.GetMatchingGroupCount(
        Card.IsAttribute,tp,LOCATION_MZONE,0,nil,ATTRIBUTE_FIRE
    )
    if ct>0 then
        Duel.Damage(1-tp,ct*500,REASON_EFFECT)
    end
end

-- Search condition (5+ Bizarre)
function s.thcon(e,tp)
    return s.bizarrecount(tp)>=5
end

-- Search Phantom’s World S/T
function s.thfilter(c)
    return c:IsSetCard(SET_PHANTOM)
        and c:IsType(TYPE_SPELL+TYPE_TRAP)
        and c:IsAbleToHand()
end

function s.thop(e,tp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(
        tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil
    )
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
