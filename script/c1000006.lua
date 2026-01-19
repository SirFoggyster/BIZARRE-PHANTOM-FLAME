-- Red the Bizarre Tactician
local s,id=GetID()
local SET_BIZARRE = 0xBA5
local SET_PHANTOM = 0xBA6

s.listed_series={SET_BIZARRE,SET_PHANTOM}

function s.initial_effect(c)
    
    -- Treated as "Bizarre" in Deck, hand, M.Zone, GY, banished
   local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_SETCODE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e0:SetRange(LOCATION_DECK+LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
    e0:SetValue(SET_BIZARRE)
    c:RegisterEffect(e0)
    
    
    -- Normal Summon is allowed (default)

    -- Special Summon from hand or GY if "Bizarre" or "Phantom" monster is on the field
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e1:SetCondition(s.spcon)
    e1:SetCountLimit(1,id+100) -- Once per turn
    c:RegisterEffect(e1)

    -- Once per turn: Search 1 "Bizarre" Spell/Trap
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+200) -- Once per turn
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
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
