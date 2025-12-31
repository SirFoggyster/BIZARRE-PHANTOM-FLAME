-- Mandom – Time Loop Trigger
local s,id=GetID()

function s.initial_effect(c)
    -- Hand trap negate & rewind
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
    e1:SetCondition(s.negcon)
    e1:SetCost(s.negcost)
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)
end

-- Ash Blossom–style condition
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    if rp==tp then return false end
    if not re:IsHasCategory(CATEGORY_SEARCH)
        and not re:IsHasCategory(CATEGORY_SPECIAL_SUMMON)
        and not re:IsHasCategory(CATEGORY_TOGRAVE) then
        return false
    end
    return Duel.IsChainNegatable(ev)
end

-- Discard itself
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        if c:IsLocation(LOCATION_HAND) then
            return c:IsDiscardable()
        else
            return c:IsReleasable()
        end
    end
    if c:IsLocation(LOCATION_HAND) then
        Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
    else
        Duel.Release(c,REASON_COST)
    end
end

-- Target is implicit (chain)
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

-- Negate and rewind
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) then
        local g=eg:Filter(Card.IsAbleToDeck,nil)
        if #g>0 then
            Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        end
    end
end
