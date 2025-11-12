-- Flopside Tower
SMODS.Joker {
    key = "flopside_tower",
    loc_txt = {
        name = "Flopside Tower",
        text = {
            "{X:red,C:white}X#1#{} Mult during a", "{C:attention}Boss Blind{}"
        }
    },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    rarity = 2,
    atlas = "SpmJokers",
    pos = {x = 0, y = 0},
    cost = 4,
    config = {extra = {xmult = 3}},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.xmult}}
    end,
    calculate = function(self, card, context)
        if G.GAME.blind.boss and context.joker_main and not context.blueprint then
            return {xmult = card.ability.extra.xmult}
        end
    end
}
