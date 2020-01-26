Input = class('Input')

function Input:initialize(buttons)
    if buttons then
        self.btLeft = buttons.left or 'left'
        self.btRight = buttons.right or 'right'
        self.btUp = buttons.up or 'up'
        self.btDown = buttons.down or 'down'
        self.btJump = buttons.jump or 'space'
        self.btAttack = buttons.attack or 'p'
    else
        self.btLeft = 'left'
        self.btRight = 'right'
        self.btUp = 'up'
        self.btDown = 'down'
        self.btJump = 'space'
        self.btAttack = 'p'
    end
end