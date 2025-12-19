function BizarreCount(tp)
    return Duel.GetMatchingGroupCount(
        Card.IsSetCard,
        tp,
        LOCATION_GRAVE,
        0,
        nil,
        SET_BIZARRE
    )
end

function HasAvdol(tp)
    return Duel.IsExistingMatchingCard(
        function(c)
            return c:IsSetCard(SET_BIZARRE) and c:IsCode(1000001)
        end,
        tp,
        LOCATION_MZONE,
        0,
        1,
        nil
    )
end