import "CoreLibs/graphics"
import "CoreLibs/sprites"

local gfx = playdate.graphics

class('UIButton', {
    image = nil,
    imageSelected = nil,
    sprite = nil
}).extends(Object)

function UIButton:init(x, y, image, imageSelected)
    self.image = image
    self.imageSelected = imageSelected

    self.sprite = gfx.sprite.new()
    self.sprite:setImage(self.image)
    self.sprite:moveTo(x, y)
    self.sprite:setZIndex(2000)
    self.sprite:add()
end

function UIButton:setSelected(selected)
    if selected then
        self.sprite:setImage(self.imageSelected)
    else
        self.sprite:setImage(self.image)
    end
end
