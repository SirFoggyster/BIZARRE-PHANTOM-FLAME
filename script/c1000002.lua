-- Magician Red – Incineration Soul
local s,id=GetID()

-- Archetype
local SET_BIZARRE = 0xBA5

s.listed_series={SET_BIZARRE}

function s.initial_effect(c)

    -- Treated as "Bizarre" in Deck, hand, GY, banished
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_SETCODE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e0:SetRange(LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
    e0:SetValue(SET_BIZARRE)
    c:RegisterEffect(e0)

    -- Must be Special Summoned by a Bizarre card effect
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetValue(s.splimit)
    c:RegisterEffect(e1)

    -- ATK gain: 300 per Bizarre monster in GY
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(s.atkval)
    c:RegisterEffect(e2)

    -- Destroy all opponent S/T (hard effect)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetOperation(s.stdesop)
    c:RegisterEffect(e3)

    -- On destroyed with Red Avdol on field
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_DESTROYED)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCondition(s.rdcon)
    e4:SetOperation(s.rdop)
    c:RegisterEffect(e4)

    -- Rage Mode (Once per Duel)
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1,id+1000)
    e5:SetCondition(s.ragecon)
    e5:SetCost(s.ragecost)
    e5:SetOperation(s.rageop)
    c:RegisterEffect(e5)
end

-- Special Summon restriction
function s.splimit(e,se,sp,st)
    return se and se:GetHandler():IsSetCard(SET_BIZARRE)
end

-- Count Bizarre monsters in GY
function s.atkval(e,c)
    return Duel.GetMatchingGroupCount(
        function(tc) return tc:IsMonster() and tc:IsSetCard(SET_BIZARRE) end,
        c:GetControler(),LOCATION_GRAVE,0,nil
    )*300
end

-- Destroy all opponent face-up S/T
function s.stdesop(e,tp)
    local g=Duel.GetMatchingGroup(
        Card.IsFaceup,tp,0,LOCATION_SZONE,nil
    )
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end

-- Destroyed condition (Red Avdol on field)
function s.rdcon(e,tp)
    return Duel.IsExistingMatchingCard(
        function(c) return c:IsFaceup() and c:GetName():find("Red Avdol") end,
        tp,LOCATION_MZONE,LOCATION_MZONE,1,nil
    )
end

-- Destroyed operation
function s.rdop(e,tp)
    Duel.Damage(1-tp,2000,REASON_EFFECT)

    -- Opponent cannot activate monster effects
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(0,1)
    e1:SetValue(function(e,re) return re:IsActiveType(TYPE_MONSTER) end)
    e1:SetReset(RESET_PHASE+PHASE_END,2)
    Duel.RegisterEffect(e1,tp)

    -- All opponent monsters lose 1500 ATK
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetTargetRange(0,LOCATION_MZONE)
    e2:SetValue(-1500)
    e2:SetReset(RESET_PHASE+PHASE_END,2)
    Duel.RegisterEffect(e2,tp)
end

-- Rage Mode condition
function s.ragecon(e,tp)
    return Duel.GetLP(tp)<=2000
end

-- Rage Mode cost
function s.ragefilter(c)
    return (c:IsAttribute(ATTRIBUTE_FIRE) or c:IsAttribute(ATTRIBUTE_DARK))
        and c:IsSetCard(SET_BIZARRE)
        and c:IsAbleToRemoveAsCost()
end

function s.ragecost(e,tp)
    local g=Duel.GetMatchingGroup(
        aux.FaceupFilter(s.ragefilter),
        tp,LOCATION_DECK+LOCATION_GRAVE,0,nil
    )
    if #g<5 then return false end
    Duel.Remove(g:Select(tp,5,5,nil),POS_FACEUP,REASON_COST)
end

-- Rage Mode operation
function s.rageop(e,tp)
    local c=e:GetHandler()

    -- ATK becomes 6000
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SET_ATTACK)
    e1:SetValue(6000)
    e1:SetReset(RESET_PHASE+PHASE_END)
    c:RegisterEffect(e1)

    -- Effects cannot be negated
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_DISABLE)
    e2:SetReset(RESET_PHASE+PHASE_END)
    c:RegisterEffect(e2)

    -- Banish during End Phase
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_MZONE)
    e3:SetOperation(function(e) Duel.Remove(c,POS_FACEUP,REASON_EFFECT) end)
    e3:SetReset(RESET_PHASE+PHASE_END)
    c:RegisterEffect(e3)
end
