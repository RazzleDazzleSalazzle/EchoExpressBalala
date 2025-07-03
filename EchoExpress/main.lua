

----------------------------------------------
------------MOD CODE -------------------------

SMODS.Atlas{
	key = 'Jokers',
	path = 'Jokers.png',
	px = 71,
	py = 95
}

-- Reepiecheep

SMODS.Joker{
    key = 'reepiecheep',
    loc_txt = {
        name = 'Reepiecheep',
        text = {
            'Played {C:attention}Queens{} give',
            '{C:chips}+52{} Chips when scored'
        }
    },
    rarity = 1,
    cost = 6,
    atlas = 'Jokers',
    pos = { x = 0, y = 1 },
    config = { extra = { chips = 52 } },
    loc_vars = function(self,info_queue,center)
        return { vars = { center.ability.extra.chips } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:get_id() == 12 then
            return {
                chip_mod = card.ability.extra.chips,
                message = "+"..card.ability.extra.chips.." Chips",
                colour = G.C.CHIPS
            }
        end
    end
}

-- Pierce

SMODS.Joker{
    key = 'pierce',
    loc_txt = {
        name = 'Pierce',
        text = {
            'Played cards that are',
            '{C:attention}not scored{} are {C:mult}destroyed{}'
        }
    },
    rarity = 3,
    cost = 7,
    atlas = 'Jokers',
    pos = {
        x = 9, y = 0
    },
    config = {
        extra = {
            Xmult = 100
        }
    },
    loc_vars = function(self,info_queue,center)
        return {
            vars = {
                center.ability.extra.Xmult
            }
        }
    end,
    calculate = function(self, card, context)
        if context.after and context.main_eval and not context.blueprint then
            local scored = {}
            for _, c in ipairs(context.scoring_hand or {}) do
                scored[c] = true
            end
            local to_destroy = {}
            for _, played in ipairs(context.full_hand or {}) do
                if not scored[played] and played.area == G.play then
                    table.insert(to_destroy, played)
                end
            end
            if #to_destroy > 0 then
                SMODS.destroy_cards(to_destroy)
            end
        end
    end
}

SMODS.Joker{
    key = 'zerza',
    loc_txt = {
        name = 'Zerza',
        text = {
            'This Joker gains {X:mult,C:white}X#2#{} Mult',
            'upon entering a shop',
            'Resets if you buy or sell a {C:attention}Joker{}',
            '{C:inactive}(Currently{} {X:mult,C:white}X#1#{}{C:inactive} Mult){}'
        }
    },
    rarity = 2,
    atlas = 'Jokers',
    pos = {x = 2, y = 1},
    config = { 
        extra = {
            Xmult = 1,
            Xmult_mod = 0.25
        }
    },

    loc_vars = function(self,info_queue,center)
        return {
            vars = {
                center.ability.extra.Xmult, center.ability.extra.Xmult_mod
            }
        }
    end,

    calculate = function(self, card, context)
        if context.starting_shop then
            card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_mod
            return {
                message = ":)",
            }
        end

        if (
            (context.buying_card and context.card and context.card.config and context.card.config.center and context.card.config.center.set == "Joker") or
            (context.selling_card and context.card and context.card.config and context.card.config.center and context.card.config.center.set == "Joker")
        ) then
            if card.ability.extra.Xmult > 1 then
                card.ability.extra.Xmult = 1
                G.hasajokerbeendestroyedthistick = false
                return {
                    message = ">:("
                }
            end
        end

        if context.cry_press then
            if card.ability.extra.Xmult > 1 then
                card.ability.extra.Xmult = 1
                return {
                    message = ">:("
                }
            end
        end

        if context.joker_main and card.ability.extra.Xmult > 1 then
            return {
                message = localize({ type = "variable", key = "a_xmult", vars = { card.ability.extra.Xmult } }),
                Xmult_mod = card.ability.extra.Xmult
            }
        end
    end
}

-- Schmoof

SMODS.Joker{
    key = 'schmoof',
    loc_txt = {
        name = 'Schmoof',
        text = {
            '{C:mult}+#1#{} Mult for every {C:money}${}',
            'below {C:money}$#2#{} you have',
            '{C:inactive}(Currently{} {C:mult}+#3#{}{C:inactive} Mult){}'
        }
    },
    rarity = 1,
    cost = 2,
    atlas = 'Jokers',
    pos = {x = 1, y = 1},
    config = { extra = {
        mult_per_dollar = 1,
        dollar_threshold = 30,
        current_mult = 0
    }
    },
    loc_vars = function(self,info_queue,center)
        local dollars = G.GAME and (G.GAME.dollars or 0) or 0
        local threshold = center.ability.extra.dollar_threshold or 30
        local mult_per = center.ability.extra.mult_per_dollar or 1
        local below = math.max(0, threshold - dollars)
        local total_mult = below * mult_per
        return {vars = {mult_per, threshold, total_mult}}
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local dollars = G.GAME and (G.GAME.dollars or 0) or 0
            local threshold = card.ability.extra.dollar_threshold or 30
            local mult_per = card.ability.extra.mult_per_dollar or 1
            local below = math.max(0, threshold - dollars)
            local total_mult = below * mult_per
            if total_mult > 0 then
                return {
                    message = localize{type='variable', key='a_mult', vars={total_mult}},
                    mult_mod = total_mult
                }
            end
        end
    end
}

-- Étoile

SMODS.Joker{
    key = 'etoile',
    loc_txt = {
        name = 'Étoile',
        text = {
            'This Joker gains {C:mult}+#2#{} Mult',
            'each time you clear a {C:attention}Blind{} in one hand',
            '{C:inactive}(Currently{} {C:mult}+#1#{}{C:inactive} Mult){}'
        }
    },
    rarity = 1,
    cost = 5,
    atlas = 'Jokers',
    pos = {x = 8, y = 0},
    config = { extra = {
        mult = 0,
        mult_mod = 4
    }
    },
    loc_vars = function(self,info_queue,center)
        return {vars = {center.ability.extra.mult, center.ability.extra.mult_mod}}
    end,
    calculate = function(self, card, context)
        if context.joker_main and card.ability.extra.mult > 0 then
            return {
                message = "+" .. card.ability.extra.mult .. " Mult",
                mult_mod = card.ability.extra.mult
            }
        end

        if context.end_of_round and context.game_over == false and context.main_eval and G.GAME.current_round.hands_played == 1 then
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
            return {
                message = localize('k_upgrade_ex')
            }
        end
    end
}

-- Nagana

SMODS.Joker{
	key = 'nagana',
	loc_txt = {
		name = 'Nagana',
		text = {
			'Gains {X:mult,C:white}X0.5{} Mult whenever a',
			'Joker is destroyed or sold',
			'On exceeding {X:mult,C:white}X3{} Mult,',
			'destroy all Jokers and self-destruct',
			'{C:inactive}(Currently{} {X:mult,C:white}X#2#{}{C:inactive} Mult){}'
		}
	},
	atlas = 'Jokers',
	rarity = 2,
    cost = 6,
	eternal_compat = false,
	pos = {x = 0, y = 0},
	config = { extra = {Xmult = 1, additional = 0.5}},

    loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.additional , center.ability.extra.Xmult}  }
	end,

    

    calculate = function(self, card, context)
		if context.joker_main and (card.ability.extra.Xmult > 1) then
			return {
				message = localize({ type = "variable", key = "a_xmult", vars = { card.ability.extra.Xmult } }),
				Xmult_mod = card.ability.extra.Xmult
			}
		end

        if G.hasajokerbeendestroyedthistick == true then
            G.hasajokerbeendestroyedthistick = false
            card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.additional
            if (card.ability.extra.Xmult <= 3) then
                return {
                    message = "Upgrade!",
                }
            else
                for i = #G.jokers.cards, 1, -1 do
                    local j = G.jokers.cards[i]
                    if j ~= nil and not j.getting_sliced and not (j.ability and j.ability.eternal == true) then
                        j:start_dissolve({G.C.RED})
                    end
                end
                return {
                    message = "Het universum zingt voor mij!",
                }
            end
        end

        if context.selling_card and context.card.config.center.set == "Joker" and context.card ~= card then
            card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.additional
            if (card.ability.extra.Xmult <= 3) then
                return {
                    message = "Upgrade!",
                }
            else
                for i = #G.jokers.cards, 1, -1 do
                    local j = G.jokers.cards[i]
                    if j ~= nil and not j.getting_sliced and not (j.ability and j.ability.eternal == true) then
                        j:start_dissolve({G.C.RED})
                    end
                end
                return {
                    message = "Het universum zingt voor mij!",
                }
            end
        end

        if context.using_consumeable then
            if context.consumeable.ability.name == 'Hex' or context.consumeable.ability.name == 'Ankh' then
                G.hasajokerbeendestroyedthistick = true
            end
        end

		if card.ability.extra.Xmult > 3 then
            for i = #G.jokers.cards, 1, -1 do
                local j = G.jokers.cards[i]
                if j ~= nil and not j.getting_sliced and not (j.ability and j.ability.eternal == true) then
                    j:start_dissolve({G.C.RED})
                end
            end
        end

    end
}

-- Balthazar Boule's Big Boullionaire Basino

SMODS.Joker{
    key = 'basino',
    loc_txt = {
        name = 'Balthazar Boule\'s Big Boullionaire Basino',
        text = {
            'If played hand is a {C:attention}Three of a Kind{},',
            'all scoring cards become {C:attention}Lucky Cards{}'
        }
    },
    rarity = 2,
    cost = 7,
    atlas = 'Jokers',
    pos = {x = 7, y = 0},
    config = { extra = {
        Xmult = 100
    }
    },
    loc_vars = function(self,info_queue,center)
        return {vars = {center.ability.extra.Xmult}}
    end,
    calculate = function(self, card, context)
        if context.before and context.main_eval and not context.blueprint and context.scoring_name == 'Three of a Kind' then
            for _, scored_card in ipairs(context.scoring_hand) do
                scored_card:set_ability('m_lucky', nil, true)
				G.E_MANAGER:add_event(Event({
                    func = function()
                    	scored_card:juice_up()
                    	return true
                    end
                }))
            end
            return {
                message = "Let's go gambling!",
                colour = G.C.LUCKY
            }
        end
    end
}

-- Power Core

SMODS.Sound({key = "powerstar", path = "powerstar.ogg",})

SMODS.Joker{
	key = 'powercore',
	loc_txt = {
		name = 'Power Core',
		text = {
			'Creates a {C:attention}Black Hole{}',
			'when {C:attention}Boss Blind{} is defeated',
			'{C:inactive}(Must have room){}'
		}
	},
	rarity = 3,
    cost = 7,
	atlas = 'Jokers',
	pos = {x = 5, y = 0},

	calculate = function(self, card, context)
		if context.end_of_round and context.game_over == false and context.main_eval and G.GAME.blind.boss then
			if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
				local black_hole = create_card(nil, G.consumeables, nil, nil, nil, nil, 'c_black_hole', 'powercore')
				black_hole:add_to_deck()
				G.consumeables:emplace(black_hole)
				play_sound('echo_powerstar', 1, 0.5)
				return {
					message = 'Level Up!',
				}
			end
		end
	end
}

-- MALUS-Mobile

SMODS.Joker{
    key = 'malusmobile',
    loc_txt = {
        name = 'MALUS-Mobile',
        text = {
            '{X:mult,C:white}-X#3#{} Mult for each hand played',
            'Resets to {X:mult,C:white}X#1#{} Mult after reaching {X:mult,C:white}X1{} Mult',
            '{C:attention}Eternal{} while not at {X:mult,C:white}X#1#{} Mult',
            '{C:inactive}(Currently{} {X:mult,C:white}X#2#{} Mult{C:inactive}){}'
        }
    },
    rarity = 2,
    cost = 5,
    atlas = 'Jokers',
    pos = {x = 4, y = 0},

    config = {
        extra = {
            max_mult = 3,
            Xmult = 3,
            Xmult_decrease = 0.25
        }
    },
    loc_vars = function(self, info_queue, center)
        return {
            vars = {
                center.ability.extra.max_mult,
                center.ability.extra.Xmult,
                center.ability.extra.Xmult_decrease
            }
        }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            if card.ability.extra.Xmult > 1 then
                return {
                    message = localize({ type = "variable", key = "a_xmult", vars = { card.ability.extra.Xmult } }),
                    Xmult_mod = card.ability.extra.Xmult
                }
            else
                return {
                    message = localize('k_reset'),
                }
            end
        end

        if context.after and context.main_eval and not context.blueprint then
            if card.ability.extra.Xmult > 1 then
				card:set_eternal(true)
                card.ability.extra.Xmult = math.max(1, card.ability.extra.Xmult - card.ability.extra.Xmult_decrease)
			else
				card.ability.extra.Xmult = 3
				card.ability.eternal = nil
            end
        end
    end,
}

SMODS.Joker{
    key = 'arthur',
    loc_txt = {
        name = 'Arthur',
        text = {
            'Gives Mult equal to scoring cards',
            '{C:attention}squared{} if scoring hand',
            'contains exactly one {C:attention}#1#{}, rank',
            'changes every round'
        }
    },
    rarity = 1,
    cost = 4,
    atlas = 'Jokers',
    pos = { x = 0, y = 2 },
    config = { extra = {} },

    loc_vars = function(self, info_queue, card)
        local rank = (G.GAME.current_round and G.GAME.current_round.vremade_arthur_rank) or 1
        local rank_name = ({'Ace','2','3','4','5','6','7','8','9','10','Jack','Queen','King'})[rank] or tostring(rank)
        return { vars = { rank_name } }
    end,

    calculate = function(self, card, context)
        if context.joker_main and context.scoring_hand and G.GAME.current_round and G.GAME.current_round.vremade_arthur_rank then
            local rank = G.GAME.current_round.vremade_arthur_rank
            local count = 0
            for _, c in ipairs(context.scoring_hand) do
                if c:get_id() == rank then
                    count = count + 1
                end
            end
            if count == 1 then
                local n = #context.scoring_hand
                return {
                    message = "+" .. (n * n) .. " Mult",
                    mult_mod = n * n
                }
            end
        end
    end,
}

SMODS.Joker{
    key = 'karla',
    loc_txt = {
        name = 'Karla',
        text = {
            'Earn {C:money}$#1#{} when you clear',
            'a {C:attention}Blind{} in exactly three hands'
        }
    },
    rarity = 1,
    cost = 4,
    atlas = 'Jokers',
    pos = {x = 4, y = 1},
    config = { extra = {
        dollars = 6
    }
    },
    loc_vars = function(self,info_queue,center)
        return {vars = {center.ability.extra.dollars}}
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval and G.GAME.current_round.hands_played == 3 then
            return {
                dollars = card.ability.extra.dollars,
                message = "$" .. card.ability.extra.dollars,
                colour = G.C.MONEY
            }
        end
    end
}

-- MALUS

SMODS.Joker{
    key = 'malus',
    loc_txt = {
        name = 'MALUS',
        text = {
            'Gains +1 {C:attention}hand size{}',
            'when {C:attention}Boss Blind{} is defeated',
            '{C:inactive}(Currently{} {X:mult,C:white}+#1#{}{C:inactive} hand size){}'
        }
    },
    rarity = 4,
    cost = 20,
    atlas = 'Jokers',
    pos = { x = 8, y = 1 },
    soul_pos = { x = 7, y = 1 },
    config = { extra = { h_size = 0 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.h_size } }
    end,
    add_to_deck = function(self, card, from_debuff)
        G.hand:change_size(card.ability.extra.h_size)
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.hand:change_size(-card.ability.extra.h_size)
    end,
    calculate = function(self, card, context)
        if context.joker_main and card.ability.extra.h_size > 0 then
            return {
                message = localize({ type = "variable", key = "a_xmult", vars = { card.ability.extra.h_size } }),
            }
        end
        if context.end_of_round and context.game_over == false and context.main_eval and G.GAME.blind.boss then
            card.ability.extra.h_size = (card.ability.extra.h_size or 0) + 1
            G.hand:change_size(1)
            return {
                message = "+5 ft. Reach!",
                colour = G.C.CHIPS
            }
        end
    end
}

-- Odd Toward

SMODS.Joker{
    key = 'odd',
    loc_txt = {
        name = 'Odd Toward',
        text = {
            'This Joker gains sell value equal to',
            'the sell value of each card {C:attention}sold{}',
        }
    },
    rarity = 2,
    cost = 6,
    atlas = 'Jokers',
    pos = {x = 6, y = 0},
    config = { extra = {
        sell_value = 0
    }
    },
    loc_vars = function(self,info_queue,center)
        return {vars = {center.ability.extra.sell_value}}
    end,
    calculate = function(self, card, context)
        if context.selling_card and context.card ~= card then
            card.ability.extra.sell_value = (card.ability.extra.sell_value or 0) + (context.card.sell_cost or 0)
            card.sell_cost = (card.sell_cost or 0) + (context.card.sell_cost or 0)
            return {
				message = "Skyrim sold!"
			}
        end
    end,
    sell_cost = function(self, card)
        return (card.config.sell_cost or 0) + (card.ability.extra.sell_value or 0)
    end
}

SMODS.Joker{
    key = 'piii',
    loc_txt = {
        name = 'P-III',
        text = {
            'When {C:attention}Blind{} is selected,',
            'create a random {C:attention}Consumable{}'
        }
    },
    rarity = 2,
    cost = 6,
    atlas = 'Jokers',
    pos = { x = 3 , y = 1 },
    config = { extra = { Xmult = 100 } },
    loc_vars = function(self,info_queue,center)
        return { vars = { center.ability.extra.Xmult } }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
            local pools = {}
            for _, pool in ipairs({"Planet", "Tarot", "Spectral"}) do
                for _, c in ipairs(G.P_CENTER_POOLS[pool]) do
                    if c.discovered and not c.locked then
                        table.insert(pools, c.key)
                    end
                end
            end
            if #pools > 0 then
                local chosen_key = pseudorandom_element(pools, pseudoseed('piii'..tostring(os.clock())))
                local new_card = create_card(nil, G.consumeables, nil, nil, nil, nil, chosen_key, 'piii')
                new_card:add_to_deck()
                G.consumeables:emplace(new_card)
                return {
                    message = "The Sinister Potion...",
                    colour = G.C.SECONDARY_SET.Tarot
                }
            end
        end
    end
}

SMODS.Joker{
    key = 'robyn',
    loc_txt = {
        name = 'Robyn',
        text = {
            '+1 {C:attention}hand size{} on {C:attention}even{} rounds',
            '+1 {C:attention}discard{} on {C:attention}odd{} rounds'
        }
    },
    rarity = 2,
    cost = 4,
    atlas = 'Jokers',
    pos = { x = 6, y = 1 },
    config = { extra = { h_size = 0, d_size = 0, last_round = -1 } },

    loc_vars = function(self, info_queue, card)
        local bonus = card.ability.extra.h_size > 0 and card.ability.extra.h_size or card.ability.extra.d_size
        return { vars = { bonus } }
    end,

    add_to_deck = function(self, card, from_debuff)
        local round = G.GAME and G.GAME.round or 1
        if (round + 1) % 2 == 0 then
            card.ability.extra.h_size = 1
            card.ability.extra.d_size = 0
            G.hand:change_size(1)
        else
            card.ability.extra.h_size = 0
            card.ability.extra.d_size = 1
            G.GAME.round_resets.discards = G.GAME.round_resets.discards + 1
            if ease_discard then ease_discard(1) end
        end
        card.ability.extra.last_round = round
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.hand:change_size(-card.ability.extra.h_size)
        if card.ability.extra.d_size > 0 then
            G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra.d_size
            if ease_discard then ease_discard(-card.ability.extra.d_size) end
        end
        card.ability.extra.h_size = 0
        card.ability.extra.d_size = 0
    end,

    calculate = function(self, card, context)
        if context.setting_blind then
            G.hand:change_size(-card.ability.extra.h_size)
            if card.ability.extra.d_size > 0 then
                G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra.d_size
                if ease_discard then ease_discard(-card.ability.extra.d_size) end
            end
            if (G.GAME.round + 1) % 2 == 0 then
                card.ability.extra.h_size = 1
                card.ability.extra.d_size = 0
                G.hand:change_size(1)
            else
                card.ability.extra.h_size = 0
                card.ability.extra.d_size = 1
                G.GAME.round_resets.discards = G.GAME.round_resets.discards + 1
                if ease_discard then ease_discard(1) end
            end
            card.ability.extra.last_round = G.GAME.round
            return {
                message = card.ability.extra.h_size > 0 and "+1 Hand Size!" or "+1 Discard!",
                colour = G.C.CHIPS
            }
        end
        if context.joker_main and (card.ability.extra.h_size > 0 or card.ability.extra.d_size > 0) then
            local bonus = card.ability.extra.h_size > 0 and card.ability.extra.h_size or card.ability.extra.d_size
            return {
                message = "+" .. bonus .. (card.ability.extra.h_size > 0 and " Hand" or " Discard"),
            }
        end
    end,
}

-- Slime Time

SMODS.Joker{
	key = 'slimetime',
	loc_txt = {
		name = 'Slime Time',
		text = {
			'{X:mult,C:white}X2{} Mult on {C:attention}first{}',
			'{C:attention}hand{} of the round'
		}
	},
	rarity = 1,
    cost = 3,
	atlas = 'Jokers',
	pos = {x = 2, y = 0},
	config = { extra = {
		Xmult = 2
	}
	},
	loc_vars = function(self,info_queue,center)
		return {vars = {center.ability.extra.Xmult}}
	end,

	calculate = function(self, card, context)
		if context.joker_main and G.GAME.current_round.hands_played == 0 then
			return {
				card = card,
				Xmult_mod = card.ability.extra.Xmult,
				message = 'X' .. card.ability.extra.Xmult .. ' Mult',
				colour = G.C.MULT
			}
		end
	end
}

-- Glass Cutter

SMODS.Joker{
    key = 'glasscutter',
    loc_txt = {
        name = 'Glass Cutter',
        text = {
            'Earn {C:money}$#1#{} when a',
            '{C:attention}Glass Card{} is broken'
        }
    },
    rarity = 1,
    cost = 4,
    atlas = 'Jokers',
    pos = {x = 3, y = 0},
    config = { extra = {
        dollars = 20
    }
    },
    loc_vars = function(self,info_queue,center)
        return {vars = {center.ability.extra.dollars}}
    end,
    calculate = function(self, card, context)
        if context.remove_playing_cards and not context.blueprint then
            local glass_cards = 0
            for _, removed_card in ipairs(context.removed) do
                if removed_card.shattered then glass_cards = glass_cards + 1 end
            end
            if glass_cards > 0 then
                return {
                    dollars = card.ability.extra.dollars * glass_cards,
                     func = function()
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                G.GAME.dollar_buffer = 0
                            return true
                        end
                    }))
                end,
            }
            end
        end
    end
}

-- The Fight House

SMODS.Joker{
    key = 'fighthouse',
    loc_txt = {
        name = 'The Fight House',
        text = {
            'Gains {C:chips}+12{} Chips if played',
            'hand contains a {C:attention}Full House{}',
            '{C:inactive}(Currently{} {C:chips}+#1#{} {C:inactive}Chips){}'
        }
    },
    rarity = 1,
    cost = 3,
    atlas = 'Jokers',
    pos = {x = 5, y = 1},
    config = { extra = {
        chips = 0,
        chip_mod = 12
    }
    },
    loc_vars = function(self,info_queue,center)
        return {vars = {center.ability.extra.chips}}
    end,
    calculate = function(self, card, context)
        if context.joker_main and card.ability.extra.chips > 0 then
            return {
                message = localize{type='variable', key='a_chips', vars={card.ability.extra.chips}},
                chip_mod = card.ability.extra.chips
            }
        end

        if context.before and context.main_eval and not context.blueprint and next(context.poker_hands['Full House']) then
            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.CHIPS,
            }
        end
    end
}

-- Anti-Union Propaganda

SMODS.Joker{
    key = 'antiunionpropaganda',
    loc_txt = {
        name = 'Anti-Union Propaganda',
        text = {
            '{X:mult,C:white}X#1#{} if scoring hand contains exactly',
            '2 {C:attention}men{} and 0 {C:mult}women{}'
        }
    },
    rarity = 2,
    cost = 5,
    atlas = 'Jokers',
    pos = { x = 9, y = 1 },
    config = {
        extra = {
            Xmult = 3
        }
    },
    loc_vars = function(self,info_queue,center)
        return {
            vars = {
                center.ability.extra.Xmult
            }
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main and context.scoring_hand then
            local men_count = 0
            local women_count = 0
            for _, c in ipairs(context.scoring_hand) do
                local id = nil
                if c.get_id then
                    id = c:get_id()
                end
                if id == 11 or id == 13 then
                    men_count = men_count + 1
                elseif id == 12 then
                    women_count = women_count + 1
                end
            end
            if men_count == 2 and women_count == 0 then
                return {
                    Xmult_mod = card.ability.extra.Xmult,
                    message = 'X'..card.ability.extra.Xmult..' Mult',
                    colour = G.C.MULT
                }
            end
        end
    end
}

local function reset_vremade_arthur_rank()
    G.GAME.current_round.vremade_arthur_rank = 1
    local valid_ranks = {}
    for i = 1, 13 do valid_ranks[#valid_ranks+1] = i end
    G.GAME.current_round.vremade_arthur_rank = pseudorandom_element(valid_ranks, pseudoseed('arthur'..tostring(G.GAME.round or 1)))
end

--[[
SMODS.Joker{
    key = 'kiichi',
    loc_txt = {
        name = 'Kiichi',
        text = {
            'Kiichi is very strong!',
            'Kiichi has {X:mult,C:white}X0.5{} Mult',
            'for every Joker with',
            '"Joker" in its name',
            '{C:inactive}(Currently{} {X:mult,C:white}X#1#{}{C:inactive}){}'
        }
    },
    rarity = 2,
    atlas = 'Jokers',
    pos = { x = 1, y = 0 },
    config = {
        extra = {
            Xmult = 1
        }
    },
    loc_vars = function(self, info_queue, card)
        local count = 0
        for _, j in ipairs(G.jokers.cards or {}) do
            local name = j.config.center.loc_txt and j.config.center.loc_txt.name or ""
            if string.find(string.lower(name), "joker") then
                count = count + 1
            end
        end
        local mult = 1 + (math.max(0, count - 1) * 0.5)
        return { vars = { mult } }
    end,
    calculate = function(self, card, context)
        local count = 0
        for _, j in ipairs(G.jokers.cards or {}) do
            local name = j.config.center.loc_txt and j.config.center.loc_txt.name or ""
            if string.find(string.lower(name), "joker") then
                count = count + 1
            end
        end
        local mult = 1 + (math.max(0, count - 1) * 0.5)
        if context.joker_main and mult > 1 then
            return {
                message = localize({ type = "variable", key = "a_xmult", vars = { mult } }),
                Xmult_mod = mult
            }
        end
    end
}
    ]]

function SMODS.current_mod.reset_game_globals(run_start)
    reset_vremade_arthur_rank()
end

----------------------------------------------
------------MOD CODE END----------------------