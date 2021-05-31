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
# Use spherical or euclidian coordinates
phi = 0
psi = 5*pi/12
rho = 1.2
lightPos = Vec3(rho*cos(phi)*sin(psi), rho*sin(phi)*sin(psi), rho*cos(psi))
#lightPos = Vec3(0.0, 1.0, 1.0)

# MATERIAL AND LIGHT PROPERTIES
I = [0.8, 0.8, 0.8]
Iamb = [0.0, 0.0, 0.0]

factor = 0.6

Kdr = 1.0*factor
Kdg = 0.0*factor
Kdb = 0.0*factor

# SPECULAR
Ks = 0.8
n = 25

#################
##### SCENE #####

# Sphere
s1 = Sphere(Vec3(0.0, 0.0, -1.0), 0.5)

# Cylinder
c1 = Cylinder(Vec3(0.0, 0.0, -1.0), Vec3(1.0, 1.0, 0.0), 0.5, 0.3)


# COLORS
function reflection(dir::Vec3, normal::Vec3)
    return dir - 2*dot(dir, normal)*normal
end

function backgroundColor(dir)
    # t in [0,1]
    t = 0.5 * (dir[2] + 1.0)
    color1 = RGB(0.0, 0.0, 0.0)
    color2 = RGB(0.1, 0.1, 0.1)
    return (1-t)*color1 + t*color2
end

function rayColor(ray::Ray, sphere::Sphere)
    t = hit(sphere, ray)
    bckCol = backgroundColor(ray.direction)
    k = 0.0

    if t > 0.0
        p = rayAt(ray, t)
        normal = unitVector(p - sphere.center)

        L = unitVector(lightPos - p)
        R = unitVector(reflection( p - lightPos , normal))
        V = unitVector(origin - p)

        NL = dot(normal, L)
        #if (NL < 0) println(NL) end
        KsRVn = Ks*dot(R, V)^n

        r = (Kdr*NL + KsRVn)*I[1] + Iamb[1] 
        g = (Kdg*NL + KsRVn)*I[2] + Iamb[2]
        b = (Kdb*NL + KsRVn)*I[3] + Iamb[3]

        r = min(max(r, 0), 1) 
        g = min(max(g, 0), 1)
        b = min(max(b, 0), 1)

        return (1 - k) * RGB(r, g, b) + k * bckCol

        #ncolor = 0.5 * (normal .+ 1.0)
        #return RGB(ncolor...)
    end
    return bckCol
end

function rayColor(ray::Ray, cylinder::Cylinder)
    t = hit(cylinder, ray)
    bckCol = backgroundColor(ray.direction)
    k = 0.0

    if t > 0.0
        p = rayAt(ray, t)
        CP = p - cylinder.center
        normal = unitVector(CP - dot(CP, cylinder.axis)*cylinder.axis)

        L = unitVector(lightPos - p)
        R = unitVector(reflection( p - lightPos , normal))
        V = unitVector(origin - p)

        NL = dot(normal, L)
        #if (NL < 0) println(NL) end
        KsRVn = Ks*dot(R, V)^n

        r = (Kdr*NL + KsRVn)*I[1] + Iamb[1] 
        g = (Kdg*NL + KsRVn)*I[2] + Iamb[2]
        b = (Kdb*NL + KsRVn)*I[3] + Iamb[3]

        r = min(max(r, 0), 1) 
        g = min(max(g, 0), 1)
        b = min(max(b, 0), 1)

        return (1 - k) * RGB(r, g, b) + k * bckCol

        #ncolor = 0.5 * (normal .+ 1.0)
        #return RGB(ncolor...)
    end
    return bckCol
end

# RENDER
for i = 1:height
    for j = 1:width
        u = (j - 1) / (width - 1)
        v = 1.0 - (i - 1) / (height - 1)
        
        dir = lowerLeftCorner + u*horizontal + v*vertical - origin

        ray = Ray(origin, dir)

        image[i, j] = rayColor(ray, c1)
    end
end

#persistentPath = string("imgs/img", "Ks", string(Ks), "n", string(n), "Kdr-Kdg-Kdb", string(Kdr),string(Kdg),string(Kdb), "lightPos", string(lightPos...), "I", string(I...), "Iamb", string(Iamb...) , ".png")
persistentPath = "imgs/out.png"
save(persistentPath, image)