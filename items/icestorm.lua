SMODS.Tag {
    key = "icestorm",
    loc_txt = {
        name = "Ice Storm",
        text = {"Played cards give", "{C:chips}+40{} Chips when scored", "in the next hand"}
    },
    in_pool = false,
    no_collection = true,
    loc_vars = function(self, info_queue, tag)
        return {vars = {(tag.ability.kill_col)}}
    end,
    set_ability = function(self, tag)
        tag.ability.kill_col = G.C.BLUE
    end
}

SMODS.Consumable {
    key = "icestorm",
    set = "item",
    loc_txt = {
        name = "Ice Storm",
        text = {"Played cards give", "{C:chips}+40{} Chips when scored", "for 1 hand"}
    },
    unlocked = true,
    discovered = true,
    atlas = "SpmItems",
    pos = {x = 0, y = 0},
    cost = 3,
    can_use = function(self, card) return G.hand and G.GAME.blind.in_blind end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            func = (function()
                add_tag(Tag('tag_spm_icestorm'))
                play_sound('generic1', 0.9 + math.random() * 0.1, 0.8)
                play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
                return true
            end)
        }))
        return true
    end
}
