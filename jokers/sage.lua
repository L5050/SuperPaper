-- Merlight

SMODS.Joker {
    key = "merlight",
    loc_txt = {
        name = "Merlight",
        text = {
            "Creates a {C:attention}playing card{} with a",
            "random {C:dark_edition}Edition{}, {C:enhanced}Enhancement{}, and",
            "{C:attention}Seal{} and draws it to hand when",
            "an {C:tarot}Arcana Pack{} or {C:spectral}Spectral Pack{}",
            "is opened"
        }
    },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = true,
    rarity = 'spm_sage',
    atlas = "SpmJokers",
    pos = {x = 0, y = 0},
    cost = 1,
    calculate = function(self, card, context)
        if context.other_drawn then
            -- 55% Foil, 30% Holographic, 12% Polychrome, 3% Negative
            local rand = pseudorandom(pseudoseed('merlight_edition')) -- Random number from 0 to 100
            local ed = nil
            if rand > 0.97 then
                ed = "e_negative"
            elseif rand > 0.85 then
                ed = "e_polychrome"
            elseif rand > 0.55 then
                ed = "e_holo"
            else
                ed = "e_foil"
            end

            local _card = SMODS.create_card {
                set = "Base",
                seal = SMODS.poll_seal({
                    guaranteed = true,
                    type_key = 'merlight_seal'
                }),
                enhancement = SMODS.poll_enhancement({
                    guaranteed = true,
                    type_key = 'merlight_enhancement'
                }),
                edition = ed,
                area = G.discard
            }
            G.playing_card = (G.playing_card and G.playing_card + 1) or 1
            _card.playing_card = G.playing_card
            table.insert(G.playing_cards, _card)

            G.E_MANAGER:add_event(Event({
                func = function()
                    G.hand:emplace(_card)
                    _card:start_materialize()
                    G.GAME.blind:debuff_card(_card)
                    G.hand:sort()
                    if context.blueprint_card then
                        context.blueprint_card:juice_up()
                    else
                        card:juice_up()
                    end
                    SMODS.calculate_context({
                        playing_card_added = true,
                        cards = {_card}
                    })
                    return true
                end
            }))
            card_eval_status_text(context.blueprint_card or card, 'extra', nil,
                                  nil, nil,
                                  {message = 'Create!', colour = G.C.PURPLE})
            return nil, true
        end
    end
}

-- Merlimbis

SMODS.Joker {
    key = "merlimbis",
    loc_txt = {
        name = "Merlimbis",
        text = {
            "Playing cards become {C:hearts}Hearts{}", "when scored",
            "{C:green}#1# in #2#{} chance for each scoring {C:attention}8{} to",
            "be given {C:dark_edition}Polychrome{}"
        }
    },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = true,
    rarity = 'spm_sage',
    atlas = "SpmJokers",
    pos = {x = 1, y = 1},
    cost = 1,
    config = {extra = {odds = 8}},
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1,
                                                                  card.ability
                                                                      .extra
                                                                      .odds,
                                                                  'merlimbis_poly')
        return {vars = {numerator, denominator}}
    end,
    calculate = function(self, card, context)
        -- Suit change routine
        if context.before and not context.blueprint then
            local convert = 0
            for _, k in ipairs(context.scoring_hand) do
                if not k:is_suit('Hearts') then
                    convert = convert + 1 -- thunk please reprogram balatro in C++ so i can use compound operators
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            SMODS.change_base(k, "Hearts")
                            k:juice_up()
                            return true
                        end
                    }))
                end
            end
            if convert > 0 then
                return {message = "Love!", colour = G.C.RED}
            end
        end

        -- Polychrome 8 routine
        if context.final_scoring_step then
            cardarea = G.play
            scoring_hand = scoring_hand
            local kiss = 0
            for _, k in ipairs(context.scoring_hand) do
                if not k.edition and not k.debuff then
                    if (k:get_id() == 8) and
                        SMODS.pseudorandom_probability(card, "merlimbis_poly",
                                                       1,
                                                       card.ability.extra.odds) then
                        kiss = kiss + 1
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                k:juice_up()
                                k:set_edition("e_polychrome", true)
                                return true
                            end
                        }))
                    end
                end
            end
            if kiss > 0 then
                return {message = "Mwah!", colour = G.C.PURPLE}
            end
        end
    end
}


-- Merloo

local GenerateSpectral = false

SMODS.Joker {
    key = "merloo",
    loc_txt = {
        name = "Merloo",
        text = {
            "Creates a random {C:spectral}Spectral{}",
            "card if first played hand contains a",
            "{C:attention}Straight{} and beats the {C:attention}Blind{}",
            "{C:inactive}Must have room{}"
        }
    },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = true,
    rarity = "spm_sage",
    atlas = "SpmJokers",
    pos = {x = 1, y = 0},
    cost = 1,
    calculate = function(self, card, context)
        --[[   if context.cardarea == G.play then
            sendDebugMessage("Hands played: " .. G.GAME.current_round.hands_played, "KQLOVE")
        end ]]
        if context.cardarea == G.play then
            if G.GAME.current_round.hands_played == 0 and next(context.poker_hands["Straight"]) then -- Don't ask me why it needs hands played to be 0. I guess it means hands completed here
                GenerateSpectral = true
            else
                GenerateSpectral = false
            end
        end
        if context.end_of_round and context.game_over == false and
            context.main_eval and GenerateSpectral == true then
            if #G.consumeables.cards + G.GAME.consumeable_buffer <
                G.consumeables.config.card_limit then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
                    func = (function()
                        SMODS.add_card {
                            set = 'Spectral',
                            key_append = 'merloo_spectral'
                        }
                        G.GAME.consumeable_buffer = 0
                        return true
                    end)
                }))
                return {
                    message = "Create!",
                    colour = G.C.SECONDARY_SET.Spectral
                }
            end
        end
    end
}

-- Merlumina

hearts = function()
    if G.deck ~= nil then
        local hearts = {}
        for _, k in ipairs(G.deck.cards or 0) do
            if k:is_suit('Hearts') then table.insert(hearts, k) end
        end
        local j = #hearts or 0
        return (j * 0.02) + 1
    end
    return 1
end

SMODS.Joker {
    key = "merlumina",
    loc_txt = {
        name = "Merlumina",
        text = {
            "Played {C:hearts}Hearts{} give {C:money}$2{}",
            "and {X:red,C:white}X1.02{} Mult for each {C:hearts}Heart{}",
            "remaining in deck when scored",
            "{C:inactive}Currently{} {X:red,C:white}X#1#{} {C:inactive}Mult{}"
        }
    },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = true,
    rarity = 'spm_sage',
    atlas = "SpmJokers",
    pos = {x = 0, y = 1},
    cost = 1,
    config = {extra = {xmult = 1, dollars = 2}},
    loc_vars = function(self, info_queue, card)
        return {vars = {hearts(), card.ability.extra.dollars}}
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and
            context.other_card:is_suit("Hearts") then
            card.ability.extra.xmult = hearts()
            return {
                xmult = card.ability.extra.xmult,
                dollars = card.ability.extra.dollars
            }
        end
    end
}
