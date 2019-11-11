Input = Object:extend()

function Input:new(buttons)
    self.btLeft = buttons.left or 'left'
    self.btRight = buttons.right or 'right'
    self.btUp = buttons.up or 'up'
    self.btDown = buttons.down or 'down'
    self.btJump = buttons.jump or 'space'
    self.btJump = buttons.jump or 'space'
    self.btPunch = buttons.punch or 'b'
    self.btKick = buttons.kick or 'v'
end