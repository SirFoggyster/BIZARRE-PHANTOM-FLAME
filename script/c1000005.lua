-- Diamond Heart – Phantom Mend
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

    -- Once per turn: return 1 face-up card to original state
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetTarget(s.resetg)
    e1:SetOperation(s.resetop)
    c:RegisterEffect(e1)

    -- Battle/effect damage substitution
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EFFECT_REPLACE_BATTLE_DAMAGE)
    e2:SetRange(LOCATION_HAND+LOCATION_MZONE)
    e2:SetTarget(s.damreptg)
    e2:SetValue(1)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_REPLACE_EFFECT_DAMAGE)
    c:RegisterEffect(e3)

    -- Self-resummon if destroyed
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_DESTROYED)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCondition(s.spcon)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)
end

-- Target for return-to-original-state
function s.resetg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
end

function s.resetop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    local tc=g:GetFirst()
    if tc then
        -- Reset ATK/DEF modifications
        local e1=Effect.CreateEffect(tc)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_BASE_ATTACK)
        e1:SetValue(tc:GetBaseAttack())
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_SET_BASE_DEFENSE)
        e2:SetValue(tc:GetBaseDefense())
        tc:RegisterEffect(e2)

        -- Remove all other effects temporarily (engine-safe approximation)
        -- Note: cannot fully remove complex effect chains, but resets standard buffs/debuffs
    end
end

-- Damage replacement
function s.damreptg(e,tp,ep,val,r,re,rp,chk)
    local c=e:GetHandler()
    if c:IsLocation(LOCATION_HAND) or c:IsLocation(LOCATION_MZONE) then
        if val>0 then return true end
    end
    return false
end

function s.damrepop(e,tp,ep,val,r,re,rp)
    local c=e:GetHandler()
    if c:IsAbleToGraveAsCost() then
        Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
        Duel.Recover(tp,val,REASON_EFFECT)
        return true
    end
    return false
end

-- Self-resummon
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end
