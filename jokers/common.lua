-- Flipside Tower
SMODS.Joker {
    key = "flipside_tower",
    loc_txt = {
        name = "Flipside Tower",
        text = {
            "Earn {C:money}$8{} at end of", "round after beating a", "{C:attention}Boss Blind{}",
        }
    },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    rarity = 1,
    atlas = "SpmJokers",
    pos = {x = 0, y = 0},
    cost = 4,
    config = {extra = {dollars = 8}, giveDollars = false},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.dollars}}
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and
            context.beat_boss and context.main_eval and not context.blueprint then
            card.ability.giveDollars = true
            return true
        end
    end,
    calc_dollar_bonus = function(self, card)
        if card.ability.giveDollars == true then
            card.ability.giveDollars = false
            return card.ability.extra.dollars
        end
    end
}
