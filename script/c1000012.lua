-- Magician's Revenge Flame
local s,id=GetID()
local ATTRIBUTE_FIRE=ATTRIBUTE_FIRE

function s.initial_effect(c)
    -- Activate: trigger when your FIRE monster is destroyed
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_DESTROYED)
    e1:SetRange(LOCATION_HAND+LOCATION_SZONE)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
end

-- Condition: a FIRE monster you control was destroyed
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(function(c,tp) return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsPreviousControler(tp) end,1,nil,tp)
end

-- Filter for Special Summon from Deck
function s.spfilter(c,e,tp)
    return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- Targeting
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,2000)
end

-- Operation
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    -- Deal 2000 damage
    Duel.Damage(1-tp,2000,REASON_EFFECT)

    -- Special Summon from Deck
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if tc then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    end
end
