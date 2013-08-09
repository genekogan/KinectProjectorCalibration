import SimpleOpenNI.*;

SimpleOpenNI kinect;
PVector[] depthMap;
float[] projectorMatrix;
PGraphics pg;
int w, h;
float downSampleFactor = 0.333;

void setup()
{
  size(displayWidth, displayHeight, P2D); 
  
  // set up kinect
  kinect = new SimpleOpenNI(this);
  kinect.setMirror(false);
  kinect.enableDepth();
  kinect.enableScene();
  
  // load calibration
  projectorMatrix = loadCalibration("calib1.txt");

  // this PGraphics object will contain the warped (reprojected) sceneImage
  w = (int)(downSampleFactor*kinect.depthWidth());
  h = (int)(downSampleFactor*kinect.depthHeight());
  pg = createGraphics(w, h, P2D);
}

void draw()
{
  kinect.update();
  depthMap = kinect.depthMapRealWorld();

  pg.beginDraw();
  pg.background(0);
  pg.loadPixels();
  for (int i=0; i<w; i++) {
    for (int j=0; j<h; j++) {
      int x = (int) map(i, 0, w, 0, kinect.depthWidth());
      int y = (int) map(j, 0, h, 0, kinect.depthHeight());
      PVector k = getDepthMapAt(x, y);
      PVector p = convertKinectToProjector(k);
      if (p.x > 0 && p.x < width && p.y >0 && p.y < height) {
        p.x = map(p.x, 0, width,  0, w);
        p.y = map(p.y, 0, height, 0, h);
        pg.pixels[(int)p.x+(int)p.y*w] = kinect.sceneImage().get(x, y);
      }
    }
  }  
  pg.updatePixels();
  pg.endDraw();
  image(pg, 0, 0, width, height);

  textSize(15);
  fill(0);
  rect(2, 2, 110, 17);
  fill(255);
  text("FPS: "+frameRate, 5, 15);
}

PVector convertKinectToProjector(PVector kp) {
  PVector pp = new PVector();
  float denom = projectorMatrix[8]*kp.x + projectorMatrix[9]*kp.y + projectorMatrix[10]*kp.z + 1.0;
  pp.x = (projectorMatrix[0]*kp.x + projectorMatrix[1]*kp.y + projectorMatrix[2]*kp.z + projectorMatrix[3]) / denom;
  pp.y = (projectorMatrix[4]*kp.x + projectorMatrix[5]*kp.y + projectorMatrix[6]*kp.z + projectorMatrix[7]) / denom;
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
