const Vec3{T <: Real} = Array{T, 1}

function Vec3{T}(x::T, y::T, z::T) where T
    [x, y, z]
end

function Vec3(x::T, y::T, z::T) where T
    Vec3{T}(x, y, z)
end

normSquared(vector::Vec3) = sum(map(x -> x^2, vector))

norm(vector::Vec3) = sqrt(normSquared(vector))

function dot(v1::Vec3, v2::Vec3)
    sum(v1 .* v2)
end

unitVector(vector) = vector / norm(vector)

struct Ray{T <: AbstractFloat}
    origin::Vec3{T}
    direction::Vec3{T}

    function Ray{T}(origin::Vec3{T}, dir::Vec3{T}) where T
        new(origin, unitVector(dir))
    end
end

function Ray(origin::Vec3{T}, dir::Vec3{T}) where T
    Ray{T}(origin, dir)
end

# myRay = Ray(Vec3(1.0, 2.0, 3.0), Vec3(7.0, 0.0, 0.0))

# println(myRay)

function rayAt(ray::Ray, t)
    return ray.origin + t * ray.direction
end

### SPHERE

struct Sphere{T <: AbstractFloat}
    center::Vec3{T}
    radius::T

    function Sphere{T}(c::Vec3{T}, r::T) where T
        new(c, r)
    end
end

function Sphere(c::Vec3, r::T) where T
    Sphere{T}(c, r)
end

function hit(sphere::Sphere, ray::Ray)
    a = normSquared(ray.direction)
    CO = ray.origin - sphere.center
    b = dot(CO, ray.direction)
    c = normSquared(CO) - sphere.radius^2

    delta = b*b - a*c

    if delta <= 0
        return -1.0
    else
        return (-b - sqrt(delta))/a
    end
end

### CYLINDER

struct Cylinder{T <: AbstractFloat}
    center::Vec3{T}
    axis::Vec3{T}
    radius::T
    height::T

    function Cylinder{T}(c::Vec3{T}, a::Vec3{T}, r::T, h::T) where T
        new(c, unitVector(a), r, h)
    end
end

function Cylinder(c::Vec3, a::Vec3, r::T, h::T) where T
    Cylinder{T}(c, a, r, h)
end

function hit(cylinder::Cylinder, ray::Ray)
    a = normSquared(ray.direction) - (dot(ray.direction, cylinder.axis))^2
    CA = ray.origin - cylinder.center
    b = dot(CA, ray.direction) - dot(CA, cylinder.axis)*dot(ray.direction, cylinder.axis)
    #b = dot(ray.origin, ray.direction) - dot(ray.origin, cylinder.axis)*dot(ray.direction, cylinder.axis)
    #c = normSquared(ray.origin) - (dot(ray.origin, cylinder.axis))^2 + (dot(cylinder.center, cylinder.axis))^2 - (cylinder.radius)^2
    c = normSquared(CA) - (dot(CA, cylinder.axis))^2 - cylinder.radius^2

    delta = b*b - a*c

    if delta <= 0
        return -1.0
    else
        t = (-b - sqrt(delta))/a
        if abs(dot(ray.origin + t*ray.direction - cylinder.center, cylinder.axis)) < cylinder.height
            return t
        end
        return -1.0
    end
end

### CONE

struct Cone{T <: AbstractFloat}
    vertex::Vec3{T}
    axis::Vec3{T}
    angle::T
    height::T

    function Cone{T}(v::Vec3{T}, a::Vec3{T}, g::T, h::T) where T
        new(v, unitVector(a), g, h)
    end
end

function Cone(v::Vec3{T}, a::Vec3{T}, g::T, h::T) where T
    Cone{T}(v, a, g, h)
end

function hit(cone::Cone, ray::Ray)
    a = normSquared(ray.direction)*(cos(cone.angle))^2 - (dot(ray.direction, cone.axis))^2
    VA = ray.origin - cone.vertex
    b = dot(VA, ray.direction)*(cos(cone.angle))^2 - dot(VA, cone.axis)*dot(ray.direction, cone.axis)
    c = normSquared(VA)*(cos(cone.angle))^2 - (dot(VA, cone.axis))^2

    delta = b*b - a*c

    if delta <= 0
        return -1.0
    else
        t = (-b - sqrt(delta))/a
        if abs(dot(ray.origin + t*ray.direction - cone.vertex, cone.axis) - cone.height/2) < cone.height/2
            return t
        end
        return -1.0
    end
end

# PARABOLLOID

struct Parabolloid{T <: AbstractFloat}
    vertex::Vec3{T}
    axis::Vec3{T}
    radius::T
    height::T

    function Parabolloid{T}(v::Vec3{T}, a::Vec3{T}, k::T, h::T) where T
        new(v, unitVector(a), k, h)
    end
end

function Parabolloid(v::Vec3{T}, a::Vec3{T}, k::T, h::T) where T
    Parabolloid{T}(v, a, k, h)
end

function hit(parabolloid::Parabolloid, ray::Ray)
    k = parabolloid.radius^2
    VA = ray.origin - parabolloid.vertex

    a = normSquared(ray.direction)*k - (dot(ray.direction, parabolloid.axis))^2*(1 + k)
    b = dot(VA, ray.direction)*k - dot(VA, parabolloid.axis)*dot(ray.direction, parabolloid.axis)*(1 + k)
    c = normSquared(VA)*k - (dot(VA, parabolloid.axis))^2*(1 + k)

    delta = b*b - a*c

    if delta <= 0
        return -1.0
    else
        t = (-b - sqrt(delta))/a
        if abs(dot(ray.origin + t*ray.direction - parabolloid.vertex, parabolloid.axis) - parabolloid.height/2) < parabolloid.height/2
            return t
        end
        return -1.0
    end
end

