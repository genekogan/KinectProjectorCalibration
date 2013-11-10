import SimpleOpenNI.*;

SimpleOpenNI kinect;
PVector[] depthMap;
float[] projectorMatrix;

void setup()
{
  size(displayWidth, displayHeight, P2D); 
  
  // set up kinect
  kinect = new SimpleOpenNI(this);
  kinect.setMirror(false);
  kinect.enableDepth();
  kinect.enableUser();
  kinect.alternativeViewPointDepthToImage();
  
  projectorMatrix = loadCalibration("calib1.txt");
}

void draw()
{
  kinect.update();
  depthMap = kinect.depthMapRealWorld();
  
  background(255);
  drawProjectedSkeletons();

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
