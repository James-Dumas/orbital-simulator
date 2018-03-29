Vector2d = {}

function Vector2d:new(x, y)
    obj = {
      x = x,
      y = y
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function vFromPolar(r, theta)
    -- return a new vector given polar coordinates
    return Vector2d:new(math.cos(theta) * r, math.sin(theta) * r)
end

function vDot(a, b)
    -- dot product of two vectors
    return a.x * b.x + a.y * b.y
end

function vProduct(v, c)
    -- product of vector and constant
    x = v.x * c
    y = v.y * c
    return Vector2d:new(x, y)
end

function vSum(a, b)
    -- sum of two vectors or a vector and a constant
    if type(b) == "number" then
        x = a.x + b
        y = a.y + b
    elseif type(b) == "table" then
        x = a.x + b.x
        y = a.y + b.y
    end

    return Vector2d:new(x, y)
end

function Vector2d:magnitude()
    return math.pow(dot(self, self), 0.5)
end

function Vector2d:angle()
    -- angle of the vector
    return math.atan2(self.y, self.x)
end

