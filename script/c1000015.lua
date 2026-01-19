-- Phantom's Mirror – Inverse Reflection
local s,id=GetID()
local SET_PHANTOM = 0xBA6
function s.initial_effect(c)
    -- Activate Continuous Trap
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    -- When opponent declares an attack
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetRange(LOCATION_SZONE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(4,id)
    e1:SetCondition(s.atkcon)
    e1:SetTarget(s.atktg)
    e1:SetOperation(s.atkop)
    c:RegisterEffect(e1)
end

-- Condition: opponent's monster attacks
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    local at=Duel.GetAttacker()
    return at and at:IsControler(1-tp)
end

-- Target the attacking monster
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
    local at=Duel.GetAttacker()
    if chk==0 then return at:IsRelateToBattle() and at:IsAbleToChangeControler() end
    Duel.SetTargetCard(at)
end

-- Operation
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local at=Duel.GetAttacker()
    if not at or not at:IsRelateToBattle() then return end

    -- Negate the attack
    Duel.NegateAttack()

    -- Negate attacking monster's effects
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_DISABLE)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    at:RegisterEffect(e1)

    local e2=e1:Clone()
    e2:SetCode(EFFECT_DISABLE_EFFECT)
    at:RegisterEffect(e2)

    -- Take control until it leaves the field
    Duel.GetControl(at,tp)
end
