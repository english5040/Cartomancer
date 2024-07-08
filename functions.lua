
function Card:to_string()
    local result = (self.base and self.base.suit .. self.base.value) or ''

    if self.ability.name then
        -- enhancement?
        result = result .. self.ability.name
    end
    if self.edition then
        -- Should only have 1 edition, but they're implemented in a weird way.
        for edition, _ in pairs(self.edition) do
            result = result .. tostring(edition)
        end
    end
    if self.seal then
        -- self.seal == 'Gold'
        result = result .. self.seal
    end
    if self.ability.eternal then
        result = result .. "Eternal"
    end
    if self.ability.perishable then
        result = result .. "Perishable"
    end
    if self.ability.rental then
        result = result .. "Rental"
    end

    if self.debuff then
        result = result .. "Debuff"
    end
    
    if self.greyed then
        result = result .. "Greyed" -- greyed should be last!
    end

    return result
end

-- Util
function tablecopy(t)
    local t2 = {}
    for k,v in pairs(t) do
        t2[k] = v
    end
    return t2
end

-- Handle amount display

----- Copied from incantation
G.FUNCS.disable_quantity_display = function(e)
    local preview_card = e.config.ref_table
    e.states.visible = preview_card.stacked_quantity > 1
end

local X_COLOR = HEX(Cartomancer.SETTINGS.stack_x_color)

function Card:create_quantity_display()
    if not self.children.stack_display and self.stacked_quantity > 1 then
        self.children.stack_display = UIBox {
            definition = {
                n = G.UIT.ROOT,
                config = {
                    minh = 0.5,
                    maxh = 1.2,
                    minw = 0.43,
                    maxw = 2,
                    r = 0.001,
                    padding = 0.1,
                    align = 'cm',
                    colour = adjust_alpha(darken(G.C.BLACK, 0.2), Cartomancer.SETTINGS.stack_background_opacity / 100),
                    shadow = false,
                    func = 'disable_quantity_display',
                    ref_table = self
                },
                nodes = {
                    {
                        n = G.UIT.T, -- node type
                        config = { text = 'x', scale = 0.35, colour = X_COLOR }
                        , padding = -1
                    },
                    {
                        n = G.UIT.T, -- node type
                        config = {
                            ref_table = self, ref_value = 'stacked_quantity',
                            scale = 0.35, colour = G.C.UI.TEXT_LIGHT
                        }
                    }
                }
            },
            config = {
                align = Cartomancer.SETTINGS.stack_amount_position .. 'm',
                bond = 'Strong',
                parent = self
            },
            states = {
                collide = { can = false },
                drag = { can = true }
            }
        }
    end
end
