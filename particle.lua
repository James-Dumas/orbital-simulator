require "vector2d"

Particle = {}

function Particle:new(position, mass, momentum)
  obj = {
      position = position,
      mass = mass,
      momentum = momentum
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end

function Particle:update()
    self.position = vSum(self.position, self.momentum)
end

function Particle:X()
    return self.position.x
end

function Particle:Y()
    return self.position.y
end

