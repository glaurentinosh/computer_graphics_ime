using Images
include("Vec3.jl")

# IMAGE
aspectRatio = 16/9
height = 600
width = trunc(Int64, height * aspectRatio )
image = RGB.(zeros(height, width))

# CAMERA
vpHeigth = 2.0
vpWidth = vpHeigth * aspectRatio
origin = Vec3(0.0, 0.0, 0.0)
focalLength = 1.0
horizontal = Vec3(vpWidth, 0.0, 0.0)
vertical = Vec3(0.0, vpHeigth, 0.0)
lowerLeftCorner = origin - Vec3(0.0, 0.0, focalLength) - horizontal/2 - vertical/2

# LIGHT SOURCE
lightPos = Vec3(1.0, 0.0, 0.0)
Kdr = 0.5
Kdg = 0.7
Kdb = 0.2
Ks = 0.0

I = [1.0, 1.0, 1.0]
Iamb = [0.1, 0.1, 0.1]

n = 1

# COLORS
function reflection(dir::Vec3, normal::Vec3)
    return dir - 2*dot(dir, normal)*normal
end

function backgroundColor(dir)
    # t in [0,1]
    t = 0.5 * (dir[2] + 1.0)
    white = RGB(1.0, 1.0, 1.0)
    lightBlue = RGB(0.5, 0.7, 1.0)
    return (1-t)*white + t*lightBlue
end

function rayColor(ray::Ray, sphere::Sphere)
    t = hit(sphere, ray)

    if t > 0.0
        p = rayAt(ray, t)
        normal = unitVector(p - sphere.center)

        ncolor = 0.5 * (normal .+ 1.0)
        return RGB(ncolor...)
    end
    return backgroundColor(ray.direction)
end

s1 = Sphere(Vec3(0.0, 0.0, -1.0), 0.5)


# RENDER
for i = 1:height
    for j = 1:width
        u = (j - 1) / (width - 1)
        v = 1.0 - (i - 1) / (height - 1)
        
        dir = lowerLeftCorner + u*horizontal + v*vertical - origin

        ray = Ray(origin, dir)

        

        image[i, j] = rayColor(ray, s1)
    end
end

save("imgs/step3.png", image)