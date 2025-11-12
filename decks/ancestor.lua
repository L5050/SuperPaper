SMODS.Back {
    key = "ancestor",
    loc_txt = {
        name = "Ancestor Deck",
        text = {
            "{C:legendary}Legendary{} Jokers are",
            "replaced with {C:gold}Sages{}",
            "{C:gold}Sages{} are always {C:purple}Perishable{}",
            "Start with a {C:spectral}Soul{} card"
        }
    },
    atlas = "SpmJokers", -- placeholder obviously
    pos = {x = 0, y = 0},
    config = {consumables = {"c_soul"}},
    unlocked = true,
    discovered = true
}

-- change Soul behavior and description for the ancestor deck
SMODS.Consumable:take_ownership("soul", {
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.4,
            func = function()
                play_sound("timpani")
                if G.GAME.selected_back.effect.center.key ~= "b_spm_ancestor" then
                    SMODS.add_card({set = "Joker", legendary = true})
                    check_for_unlock {type = "spawn_legendary"}
                else
                    local Sages = {
                        "j_spm_merlumina", "j_spm_merloo", "j_spm_merlight",
                        "j_spm_merlimbis"
                    }
                    local sage = pseudorandom_element(Sages, "soul_sage")
                    SMODS.add_card({
                        set = "Joker",
                        key = sage,
                        stickers = {"perishable"},
                        force_stickers = true
                    })
                end
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        delay(0.6)
    end
}, true -- silent
)
