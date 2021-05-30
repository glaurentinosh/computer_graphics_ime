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