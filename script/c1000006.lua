-- Red the Bizarre Tactician
local s,id=GetID()
local SET_BIZARRE/PHANTOM = 0xBA8

s.listed_series={SET_BIZARRE,SET_PHANTOM}

function s.initial_effect(c)
    
    -- Treated as "Bizarre" in Deck, hand, GY, banished
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
    
    
    -- Normal Summon is allowed (default)

    -- Special Summon from hand if Bizarre or Phantom monster on field
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetRange(LOCATION_HAND)
    e0:SetCondition(s.spcon)
    c:RegisterEffect(e0)

    -- Search 1 "Bizarre" Spell/Trap on Summon
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
end

-- Special Summon condition
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.cfilter(c)
    return c:IsSetCard(SET_BIZARRE) or c:IsSetCard(SET_PHANTOM)
end

-- Search filter
function s.thfilter(c)
    return c:IsSetCard(SET_BIZARRE)
        and c:IsType(TYPE_SPELL+TYPE_TRAP)
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
