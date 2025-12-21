-- Void Hand – Phantom Ripper
local s,id=GetID()
local SET_BIZARRE=0xBA5

s.listed_series={SET_BIZARRE}

function s.initial_effect(c)
     
    
    -- Treated as "Bizarre" and "Phantom" in Deck, hand, GY, banished
     local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_SETCODE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e0:SetRange(LOCATION_DECK+LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
    e0:SetValue(SET_BIZARRE)
    c:RegisterEffect(e0)
    local e0b=e0:Clone()
    e0b:SetValue(SET_PHANTOM)
   
    -- Quick Effect: Banish all opponent S/T
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetTarget(s.rmtg)
    e1:SetOperation(s.rmop)
    c:RegisterEffect(e1)

    -- If targeted: discard 1; negate & destroy that monster
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.negcon)
    e2:SetCost(s.negcost)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)

    -- If sent to GY: add 1 Bizarre Quick-Play Spell
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
end

-- =========================
-- Effect 1: Banish all S/T
-- =========================
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_SZONE,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_SZONE)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_SZONE,nil)
    if #g>0 then
        Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
    end
end

-- =========================================
-- Effect 2: If targeted → negate & destroy
-- =========================================
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    if rp==tp then return false end
    if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
    local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
    return g and g:IsContains(e:GetHandler())
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
    Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return re:GetHandler():IsDestructable() end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,nil,0,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,re:GetHandler(),1,0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) then
        Duel.Destroy(re:GetHandler(),REASON_EFFECT)
    end
end

-- =================================
-- Effect 3: Search Bizarre Quick-Play
-- =================================
function s.thfilter(c)
    return c:IsSetCard(SET_BIZARRE)
        and c:IsType(TYPE_SPELL)
        and c:IsType(TYPE_QUICKPLAY)
        and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
