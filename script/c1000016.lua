-- Heatwave Eruption
local s,id=GetID()
local SET_BIZARRE=0xabc

function s.initial_effect(c)
    -- Activate: negate attack
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- Targeting
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end

-- Operation
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Negate the attack
    Duel.NegateAttack()

    -- Count "Bizarre" monsters in your deck
    local ct=Duel.GetMatchingGroupCount(function(c) return c:IsSetCard(SET_BIZARRE) end,tp,LOCATION_DECK,0,nil)
    if ct>0 then
        Duel.Damage(1-tp,ct*600,REASON_EFFECT)
    end
end
