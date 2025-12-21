-- Phantom's Mirror – Inverse Reflection
local s,id=GetID()

function s.initial_effect(c)
    -- Activate: negate effect and gain control of attacking monster
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_CONTROL+CATEGORY_NEGATE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_BE_BATTLE_TARGET)  -- Can also use EVENT_CHAINING for effect-based
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- Condition: must be attacked
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local at=Duel.GetAttacker()
    return at and at:IsOnField() and at:IsControler(1-tp)
end

-- Targeting
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local at=Duel.GetAttacker()
    if chk==0 then return at:IsControler(1-tp) and at:IsAbleToChangeControler() end
    Duel.SetTargetCard(at)
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,at,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,nil,0,0,0)
end

-- Operation
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local at=Duel.GetAttacker()
    if at and at:IsRelateToBattle() then
        -- Negate any effect if attacking
        Duel.NegateAttack()

        -- Take control until it leaves the field
        if Duel.GetControl(at,tp,PHASE_END,1) then
            -- Optional: flag to track until leaves field
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UNRELEASABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            at:RegisterEffect(e1)
        end
    end
end
