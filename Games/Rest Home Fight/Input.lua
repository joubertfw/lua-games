Input = Object:extend()

function Input:new(buttons)
    if buttons then
        self.btLeft = buttons.left or 'left'
        self.btRight = buttons.right or 'right'
        self.btUp = buttons.up or 'up'
        self.btDown = buttons.down or 'down'
        self.btJump = buttons.jump or 'space'
        self.btPunch = buttons.punch or 'k'
        self.btKick = buttons.kick or 'l'
    else
        self.btLeft = 'left'
        self.btRight = 'right'
        self.btUp = 'up'
        self.btDown = 'down'
        self.btJump = 'space'
        self.btPunch = 'k'
        self.btKick = 'l'
    end
end