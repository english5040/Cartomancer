-- EXPAND JOKERS CARDAREA


function Cartomancer.align_G_jokers()
    -- Refresh controls
    G.jokers.children.cartomancer_controls:remove()
    G.jokers.children.cartomancer_controls = nil
    G.jokers:align_cards()
    G.jokers:hard_set_cards()

    Cartomancer.add_visibility_controls()
end

local old_slider_value = 0

-- TODO : mod compat
--  current patch completely overrides logic

function Cartomancer.expand_G_jokers()
    G.jokers.cart_zoom_slider = G.jokers.cart_zoom_slider or 0

    local self_T_w = math.max(4.9*G.CARD_W, 0.6*#G.jokers.cards * G.CARD_W)
    local self_T_x = G.jokers.T.x - self_T_w * G.jokers.cart_zoom_slider / 100

    local self = G.jokers

    for k, card in ipairs(self.cards) do
        if card.states.drag.is then
            local sign = nil
            if card.T.x < -1 then
                sign = -1
            elseif card.T.x > G.TILE_W then
                sign = 1
            end

            if sign then
                G.jokers.cart_zoom_slider = math.max(0, math.min(100, G.jokers.cart_zoom_slider + sign * 4 / self_T_w))
            end
        else
            card.T.r = 0.1*(-#self.cards/2 - 0.5 + k)/(#self.cards)+ (G.SETTINGS.reduced_motion and 0 or 1)*0.02*math.sin(2*G.TIMERS.REAL+card.T.x)
            local max_cards = math.max(#self.cards, self.config.temp_limit)
            card.T.x = self_T_x + (self_T_w-self.card_w)*((k-1)/math.max(max_cards-1, 1) - 0.5*(#self.cards-max_cards)/math.max(max_cards-1, 1)) + 0.5*(self.card_w - card.T.w)
            if #self.cards > 2 or (#self.cards > 1 and self == G.consumeables) or (#self.cards > 1 and self.config.spread) then
                card.T.x = self_T_x + (self_T_w-self.card_w)*((k-1)/(#self.cards-1)) + 0.5*(self.card_w - card.T.w)
            elseif #self.cards > 1 and self ~= G.consumeables then
                card.T.x = self_T_x + (self_T_w-self.card_w)*((k - 0.5)/(#self.cards)) + 0.5*(self.card_w - card.T.w)
            else
                card.T.x = self_T_x + self_T_w/2 - self.card_w/2 + 0.5*(self.card_w - card.T.w)
            end
            local highlight_height = G.HIGHLIGHT_H/2
            if not card.highlighted then highlight_height = 0 end
            card.T.y = self.T.y + self.T.h/2 - card.T.h/2 - highlight_height+ (G.SETTINGS.reduced_motion and 0 or 1)*0.03*math.sin(0.666*G.TIMERS.REAL+card.T.x)
            card.T.x = card.T.x + card.shadow_parrallax.x/30
        end
    end
    
    table.sort(self.cards, function (a, b) return a.T.x + a.T.w/2 - 100*(a.pinned and a.sort_id or 0) < b.T.x + b.T.w/2 - 100*(b.pinned and b.sort_id or 0) end)

    if not (old_slider_value == G.jokers.cart_zoom_slider) then
        old_slider_value = G.jokers.cart_zoom_slider
        G.jokers:hard_set_cards()
    end
end




--*--------------------------
--*------HIDE JOKERS
--*--------------------------
-- TODO : popup below joker to hide it

local JOKER_RARITY = {
    'common',
    'uncommon',
    'rare',
    'legendary',
}

function Cartomancer.add_visibility_controls()
    if not G.jokers then
        return
    end

    if not Cartomancer.SETTINGS.jokers_visibility_buttons then
        return
    end

    if not G.jokers.children.cartomancer_controls then
        local settings = Sprite(0,0,0.425,0.425,G.ASSET_ATLAS["cart_settings"], {x=0, y=0})
        settings.states.drag.can = false

        local joker_slider = nil
        if G.jokers.cart_jokers_expanded then
            joker_slider = create_slider({w = 6, h = 0.4,
                ref_table = G.jokers, ref_value = 'cart_zoom_slider', min = 0, max = 100,
                decimal_places = 1,
                hide_val = true,
            })
            joker_slider.config.padding = 0
        end

        G.jokers.children.cartomancer_controls = UIBox {
            definition = {
                n = G.UIT.ROOT,
                func = function ()
                    return Cartomancer.SETTINGS.jokers_visibility_buttons
                end,
                config = { align = 'cm', padding = 0.07, colour = G.C.CLEAR, },
                nodes = {
                    {n=G.UIT.R, config={align = 'tm', padding = 0.07, no_fill = true}, nodes={
                        {n=G.UIT.C, config={align = "cm"}, nodes={
                            UIBox_button({id = 'hide_all_jokers', button = 'cartomancer_hide_all_jokers', label ={localize('carto_jokers_hide')},
                                                                      minh = 0.45, minw = 1, col = false, scale = 0.3,
                                                                      colour = G.C.CHIPS,
                                                                      })
                        }},
                        {n=G.UIT.C, config={align = "cm"}, nodes={
                            UIBox_button({id = 'show_all_jokers', button = 'cartomancer_show_all_jokers', label = {localize('carto_jokers_show')},
                                                                      minh = 0.45, minw = 1, col = false, scale = 0.3,
                                                                      })
                        }},
                        
                        {n=G.UIT.C, config={align = "cm"}, nodes={
                            UIBox_button({id = 'zoom_jokers', button = 'cartomancer_zoom_jokers', label = {'Zoom'},
                                                                      minh = 0.45, minw = 1, col = false, scale = 0.3,
                                                                      })
                        }},
                        joker_slider,
                        
                        Cartomancer.INTERNAL_jokers_menu and {n=G.UIT.C, config={align = "cm"}, nodes={
                            {n=G.UIT.C, config={align = "cm", padding = 0.01, r = 0.1, hover = true, colour = G.C.BLUE, button = 'cartomancer_joker_visibility_settings', shadow = true}, nodes={
                                {n=G.UIT.O, config={object = settings}},
                              }},
                        }} or nil,
                    }}
                }
            },
            config = {
                align = 't',
                
                bond = 'Strong',
                parent = G.jokers
            },
        }
    end

    G.jokers.children.cartomancer_controls:draw()
end

G.FUNCS.cartomancer_hide_all_jokers = function(e)
    Cartomancer.hide_all_jokers()
end

G.FUNCS.cartomancer_show_all_jokers = function(e)
    Cartomancer.show_all_jokers()
end

G.FUNCS.cartomancer_zoom_jokers = function(e)
    G.jokers.cart_jokers_expanded = not G.jokers.cart_jokers_expanded
    Cartomancer.align_G_jokers()
end


G.FUNCS.cartomancer_joker_visibility_settings = function(e)

    G.CARTO_JOKER_VISIBILITY = UIBox{
        definition = Cartomancer.jokers_visibility_standalone_menu(),
        config = {align="cm", offset = {x=0,y=10},major = G.ROOM_ATTACH, bond = 'Weak', instance_type = "POPUP"}
    }
    G.CARTO_JOKER_VISIBILITY.alignment.offset.y = 0
    G.ROOM.jiggle = G.ROOM.jiggle + 1
    G.CARTO_JOKER_VISIBILITY:align_to_major()
    -- TODO : REMOVE WHEN APPLY/CANCEL IS PRESSED
end

local function hide_card(card)
    card.states.visible = false
end

function Cartomancer.hide_hovered_joker(controller)
    if not G.jokers then
        return
    end

    local selected = controller.focused.target or controller.hovering.target
    
    if not selected or not selected:is(Card) then
        return
    end

    if selected.area ~= G.jokers then
        return
    end

    hide_card(selected)
end

-- Returns true if joker should be hidden due to settings 
function Cartomancer.should_hide_joker(card)
    
    
end

function Cartomancer.update_jokers_visibility()
    if not G.jokers then
        return
    end

    local settings = Cartomancer.SETTINGS.hide_jokers

    local total_jokers = #G.jokers.cards

    for i = 1, total_jokers do
        local joker = G.jokers.cards[i]
        if not settings.enabled then
            joker.states.visible = true
        else
            local hide = false

            if settings.all then
                hide = true

            elseif total_jokers >= settings.hide_after_total then
                hide = true

            elseif settings.rarities[JOKER_RARITY[joker.config.center.rarity]] then
                Cartomancer.log("hiding joker with rarity " .. JOKER_RARITY[joker.config.center.rarity])
                hide = true
            
            elseif joker.edition and settings.editions[next(joker.edition)] then
                Cartomancer.log("hiding joker with edition " .. next(joker.edition))
                hide = true
            end

            if hide then
                hide_card(joker)
            end
        end
    end
end


function Cartomancer.hide_all_jokers()
    if not G.jokers then
        print("no jokers")
        return
    end

    local total_jokers = #G.jokers.cards

    for i = 1, total_jokers do
        hide_card(G.jokers.cards[i])
    end
end

function Cartomancer.show_all_jokers()
    if not G.jokers then
        Cartomancer.log("no jokers")
        return
    end

    local total_jokers = #G.jokers.cards

    for i = 1, total_jokers do
        G.jokers.cards[i].states.visible = true
    end

end