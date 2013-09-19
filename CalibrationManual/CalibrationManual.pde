import SimpleOpenNI.*;

SimpleOpenNI kinect;
PVector[] depthMap;
boolean calibrated = false;
ArrayList<PVector> ptsK, ptsP;
PVector pk, pk0, pp0;

void setup()
{
  size(displayWidth, displayHeight, P2D); 
  
  // set up kinect
  kinect = new SimpleOpenNI(this);
  kinect.setMirror(false);
  kinect.enableIR();
  kinect.enableDepth();
  kinect.enableScene();
  
  // matching pairs
  ptsK = new ArrayList<PVector>();
  ptsP = new ArrayList<PVector>();
  pk  = new PVector();
  pk0 = new PVector();
  pp0 = new PVector();
}

void draw()
{
  kinect.update();
  depthMap = kinect.depthMapRealWorld();

  // draw the IR image
  image(kinect.irImage(), 0, 0, width, height);  

  // draw kinect point
  fill(255, 0, 0);    
  ellipse(pk.x, pk.y, 15, 15);

  // draw projector point
  fill(0, 255, 0);    
  ellipse(pp0.x, pp0.y, 15, 15);

  // draw mouse point
  fill(0, 0, 255);
  ellipse(mouseX, mouseY, 15, 15);

  // gui
  translate(8, 8);
  pushStyle();
  fill(0, 200);
  rect(0, 0, 200, 60);
  fill(255);
  text("current depth: "+pk0.x+", "+pk0.y+", "+pk0.z, 5, 14);
  text("current proj: "+pp0.x+", "+pp0.y, 5, 28);
  text("number pairs: "+ptsK.size(), 5, 42);
  popStyle();
}

void keyPressed() 
{
  // add a point pair
  if (key==' ') {
    ptsK.add(new PVector(pk0.x, pk0.y, pk0.z));
    ptsP.add(new PVector(pp0.x, pp0.y));
  }
  
  // select point on depth map, and (if calibrated) corresponding projector point
  else if (key=='1') {
    pk = new PVector(mouseX, mouseY);
    int x = (int) map(mouseX, 0, width, 0, kinect.depthWidth());
    int y = (int) map(mouseY, 0, height, 0, kinect.depthHeight());
    pk0 = getDepthMapAt(x, y);
    if (pk0.z == 0)  pk.set(0, 0, 0);
    if (calibrated) pp0 = convertKinectToProjector(pk0);
  }
  
  // select projector point
  else if (key=='2') {
    pp0 = new PVector(mouseX, mouseY);
  }
  
  // calculate calibration
  else if (key=='c')  calibrate();
  else if (key=='s')  saveCalibration("calib1.txt");
  else if (key=='l')  loadCalibration("calib1.txt");
}

PVector getDepthMapAt(int x, int y) {
  PVector dm = depthMap[kinect.depthWidth() * y + x];
  return new PVector(dm.x, dm.y, dm.z);
}

void saveCalibration(String filename) {
  String[] coeffs = getCalibrationString();
  saveStrings(dataPath(filename), coeffs);
}

void loadCalibration(String filename) {
  String[] s = loadStrings(dataPath(filename));
  x = new Matrix(11, 1);
  for (int i=0; i<s.length; i++)
    x.set(i, 0, Float.parseFloat(s[i]));
  calibrated = true;
}
