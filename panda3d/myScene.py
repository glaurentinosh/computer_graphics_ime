# imports
from direct.showbase.ShowBase import ShowBase
from direct.actor.Actor import Actor
from direct.interval.FunctionInterval import Func
from direct.interval.IntervalGlobal import Sequence
from panda3d.core import Point3

# definitions
cameras = []
activeCam = 0;

# toggleCam task
def toggleCam(task):
    global cameras,activeCam
    cameras[activeCam].node().getDisplayRegion(0).setActive(0)
    activeCam = (activeCam + 1)%len(cameras)
    cameras[activeCam].node().getDisplayRegion(0).setActive(1)
    return task.again


# Set framework up
framework = ShowBase()

# Load the environment model.
scene = loader.loadModel("models/environment")
# Reparent the model to render.
scene.reparentTo(render)
# Apply scale and position transforms on the model.
scene.setScale(0.25, 0.25, 0.25)
scene.setPos(-8, 42, 0)

pandaActor = Actor("panda", {"walk": "panda-walk"})
pandaActor.reparentTo(render)
pandaActor.loop("walk")

# Create the four lerp intervals needed for the panda to
# walk back and forth.
posInterval1 = pandaActor.posInterval(3,
                                           Point3(0, -10, 0),
                                           startPos=Point3(0, 10, 0))
posInterval2 = pandaActor.posInterval(3,
                                           Point3(0, 10, 0),
                                           startPos=Point3(0, -10, 0))
hprInterval1 = pandaActor.hprInterval(1,
                                           Point3(180, 0, 0),
                                           startHpr=Point3(0, 0, 0))
hprInterval2 = pandaActor.hprInterval(1,
                                           Point3(0, 0, 0),
                                           startHpr=Point3(180, 0, 0))

# Create and play the sequence that coordinates the intervals.
pandaPace = Sequence(posInterval1, hprInterval1,
                          posInterval2, hprInterval2,
                          name="pandaPace")
pandaPace.loop()

# set cameras up (first camera = default)
cameras = [framework.cam, framework.makeCamera(framework.win), framework.makeCamera(framework.win)]

# initially first camera is on and second one is off
cameras[1].node().getDisplayRegion(0).setActive(0)
activeCam = 0

# locate cameras

cameras[1].reparentTo(pandaActor)
cameras[1].setPos(0, 10, 15)
cameras[1].lookAt(cameras[1].getPos() + (0,-2,-1))

cameras[0].setPos(30, -30, 20)
cameras[0].lookAt(0, 0, 6)

cameras[2].setPos(40, -40, 40)
cameras[2].lookAt(2, 0, 6)

# set toggleCamera task = toggle every 3 secs
framework.taskMgr.doMethodLater(2, toggleCam, "toggle camera")

# Do the main loop
framework.run()