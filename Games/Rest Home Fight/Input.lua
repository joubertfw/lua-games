Input = Object:extend()

function Input:new(buttons)
    if buttons then
        self.btLeft = buttons.left or 'left'
        self.btRight = buttons.right or 'right'
        self.btUp = buttons.up or 'up'
        self.btDown = buttons.down or 'down'
        self.btJump = buttons.jump or 'space'
        self.btJump = buttons.jump or 'space'
        self.btPunch = buttons.punch or 'b'
        self.btKick = buttons.kick or 'v'
    else
        self.btLeft = 'left'
        self.btRight = 'right'
        self.btUp = 'up'
        self.btDown = 'down'
        self.btJump = 'space'
        self.btJump = 'space'
        self.btPunch = 'b'
        self.btKick = 'v'
    end
end