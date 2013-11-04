import SimpleOpenNI.*;
import processing.video.*;

Movie movie;
SimpleOpenNI kinect;
PVector[] depthMap;
float[] projectorMatrix;

void setup()
{
  size(displayWidth, displayHeight, P2D); 
  imageMode(CENTER);
  
  // set up kinect
  kinect = new SimpleOpenNI(this);
  kinect.setMirror(false);
  kinect.enableDepth();
  kinect.enableUser();
  
  // load calibration
  projectorMatrix = loadCalibration("calib1.txt");
  
  // load KRANG!!
  movie = new Movie(this, "krang.mp4");
  movie.loop();

}

void draw()
{
  kinect.update();
  depthMap = kinect.depthMapRealWorld();
  
  background(255);
  PVector torsoKinectRealWorld = new PVector();
  PVector torsoProjected = new PVector();  
  int[] userList = kinect.getUsers();
  for(int i=0; i<userList.length; i++) {
    if(kinect.isTrackingSkeleton(userList[i])) {
      kinect.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_TORSO, torsoKinectRealWorld);
      torsoProjected = convertKinectToProjector(torsoKinectRealWorld);
      float x = torsoProjected.x;
      float y = torsoProjected.y;
      float w = map(torsoKinectRealWorld.z, 3500, 500, 80, 320);
      image(movie, x, y, w, w*(192.0/276.0));
    }
  } 
}

PVector convertKinectToProjector(PVector kp) {
  PVector pp = new PVector();
  float denom = projectorMatrix[8]*kp.x + projectorMatrix[9]*kp.y + projectorMatrix[10]*kp.z + 1.0;
  pp.x = width * (projectorMatrix[0]*kp.x + projectorMatrix[1]*kp.y + projectorMatrix[2]*kp.z + projectorMatrix[3]) / denom;
  pp.y = height * (projectorMatrix[4]*kp.x + projectorMatrix[5]*kp.y + projectorMatrix[6]*kp.z + projectorMatrix[7]) / denom;
  return pp;
}

PVector getDepthMapAt(int x, int y) {
  PVector dm = depthMap[kinect.depthWidth() * y + x];
  return new PVector(dm.x, dm.y, dm.z);
}

float[] loadCalibration(String filename) {
  String[] s = loadStrings(dataPath(filename));
  float[] projectorMatrix = new float[11];
  for (int i=0; i<s.length; i++)
    projectorMatrix[i] = Float.parseFloat(s[i]);
  return projectorMatrix;
}

void movieEvent(Movie m) {
  m.read();
}
