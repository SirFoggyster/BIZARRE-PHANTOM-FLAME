-- The Phantom's World – Echo Mimicry
local s,id=GetID()
local SET_BIZARRE=0xBA5
local SET_PHANTOM=0xBA6

s.listed_series={SET_BIZARRE,SET_PHANTOM}

function s.initial_effect(c)
    -- Treated as "Bizarre" in Deck, Field, GY, hand, banished
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_SETCODE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e0:SetRange(LOCATION_DECK+LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
    e0:SetValue(SET_BIZARRE)
    c:RegisterEffect(e0)

    -- Unique on field
    c:SetUniqueOnField(1,0,id)

    -- Copy effect (Quick Effect, once per turn)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.cptg)
    e1:SetOperation(s.cpop)
    c:RegisterEffect(e1)
end

-- Targeting function
function s.filter(c)
    return c:IsFaceup() or c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
end

-- Copy operation
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,1,1,nil)
    local tc=g:GetFirst()
    if tc and c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e) then
        local code=tc:GetOriginalCode()
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_CODE)
        e1:SetValue(code)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
        -- Copy types, attribute, ATK/DEF
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
        e2:SetValue(tc:GetOriginalAttribute())
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e2)

        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetCode(EFFECT_CHANGE_RACE)
        e3:SetValue(tc:GetOriginalRace())
        e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e3)

        local e4=Effect.CreateEffect(c)
        e4:SetType(EFFECT_TYPE_SINGLE)
        e4:SetCode(EFFECT_SET_BASE_ATTACK)
        e4:SetValue(tc:GetBaseAttack())
        e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e4)

        local e5=Effect.CreateEffect(c)
        e5:SetType(EFFECT_TYPE_SINGLE)
        e5:SetCode(EFFECT_SET_BASE_DEFENSE)
        e5:SetValue(tc:GetBaseDefense())
        e5:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e5)

        -- Copy original effects (once per turn)
        local effs={tc:GetCardEffect()}
        for _,eff in ipairs(effs) do
            local e6=eff:Clone()
            e6:SetOwnerPlayer(tp)
            e6:SetCountLimit(1)
            e6:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            c:RegisterEffect(e6)
        end
    end
end
