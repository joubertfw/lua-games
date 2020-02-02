Input = class('Input')

function Input:initialize(buttons)
    if buttons then
        self.btLeft = buttons.left or 'left'
        self.btRight = buttons.right or 'right'
        self.btUp = buttons.up or 'up'
        self.btDown = buttons.down or 'down'
        self.btJump = buttons.jump or 'space'
        self.btAttack = buttons.attack or 'p'
        self.btInteract = buttons.interact or 'e'

        self.btJoyLeft = buttons.joyLeft or 'dpleft'
        self.btJoyRight = buttons.joyRight or 'dpright'
        self.btJoyUp = buttons.joyUp or 'dpup'
        self.btJoyDown = buttons.joyDown or 'dpdown'
        self.btJoyJump = buttons.joyJump or 'a'
        self.btJoyAttack = buttons.joyAttack or 'x'
        self.btJoyInteract = buttons.joyInteract or 'y'

    else
        self.btLeft = 'left'
        self.btRight = 'right'
        self.btUp = 'up'
        self.btDown = 'down'
        self.btJump = 'space'
        self.btAttack = 'p'
        self.btInteract = 'e'

        self.btJoyLeft = 'dpleft'
        self.btJoyRight = 'dpright'
        self.btJoyUp = 'dpup'
        self.btJoyDown = 'dpdown'
        self.btJoyJump = 'a'
        self.btJoyAttack = 'x'
        self.btJoyInteract = 'y'
    end
end