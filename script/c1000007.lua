-- Requiem Gold – Echo of Experience
     local s,id=GetID()
     local SET_REQUIEM = 0xBA9
     local SET_PHANTOM = 0xBA6
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
    c:RegisterEffect(e0b)
    
    -- Cannot be Normal Summoned/Set
    c:EnableUnsummonable()

    -- Must be Special Summoned if "The Phantom's World" is on the field
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetRange(LOCATION_HAND)
    e0:SetCondition(s.spcon)
    c:RegisterEffect(e0)

    -- Unaffected by other card effects
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetValue(s.immval)
    c:RegisterEffect(e1)

    -- Once per turn: banish 2 opponent monsters
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.rmtg)
    e2:SetOperation(s.rmop)
    c:RegisterEffect(e2)

    -- Battle: negate monster effects + banish instead of GY
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_BATTLE_CONFIRM)
    e3:SetOperation(s.battleop)
    c:RegisterEffect(e3)
end

-- Special Summon condition
function s.spcon(e,c)
    if c==nil then return true end
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_PHANTOM),
        c:GetControler(),LOCATION_FZONE+LOCATION_MZONE,0,1,nil)
end

-- Immunity filter
function s.immval(e,re)
    return re:GetOwner()~=e:GetOwner()
end

-- Target 2 opponent monsters to banish
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,2,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,1-tp,LOCATION_MZONE)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,2,2,nil)
    if #g>0 then
        Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
    end
end

-- Battle effect: negate + banish instead
function s.battleop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local bc=c:GetBattleTarget()
    if not bc or not bc:IsRelateToBattle() then return end

    -- Negate effects
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_DISABLE)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    bc:RegisterEffect(e1)

    local e2=e1:Clone()
    e2:SetCode(EFFECT_DISABLE_EFFECT)
    bc:RegisterEffect(e2)

    -- Banish instead of sending to GY
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_DESTROY_REPLACE)
    e3:SetReset(RESET_EVENT+RESETS_STANDARD)
    e3:SetValue(s.banreplace)
    bc:RegisterEffect(e3)
end

function s.banreplace(e,tp,eg,ep,ev,re,r,rp)
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
    return true
end
