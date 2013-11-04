import SimpleOpenNI.*;

SimpleOpenNI kinect;
PVector[] depthMap;
float[] projectorMatrix;
ArrayList<User> users;
PGraphics pg;

void setup()
{
  size(displayWidth, displayHeight, P2D); 
  imageMode(CENTER);
  
  // set up kinect
  kinect = new SimpleOpenNI(this);
  kinect.setMirror(false);
  kinect.enableDepth();
  kinect.enableUser();
  
  projectorMatrix = loadCalibration("calib1.txt");
  
  users = new ArrayList<User>();
  pg = createGraphics(400, 400);
}

void draw()
{
  renderFireball();  
  kinect.update();
  depthMap = kinect.depthMapRealWorld();
  
  background(255);
  for (User user : users) {
    drawProjectedSkeleton(user.userId);
    user.lookForFireballMotion();
    user.drawFireballs();
  }
}

void renderFireball() {
  int nk = 36;
  int n = 180;
  pg.beginDraw();
  pg.clear();
  pg.colorMode(HSB);
  pg.noStroke();
  pg.translate(pg.width/2, pg.height/2);
  for (int k=0; k<nk; k++) {
    pg.fill(map(k, 0, nk, 5, 40),
            map(noise(0.01*k+10, 0.01*frameCount+15), 0, 1, 180, 250), 
            map(noise(0.01*k+20, 0.01*frameCount+25), 0, 1, 180, 250), 100);
    pg.rotate(noise(k));
    pg.beginShape();
    for (int i=0; i<n; i++) {
      float ang = map(i, 0, n, 0, TWO_PI);
      float rad = map(noise(0.04*i+k, 0.03*frameCount+5), 0, 1, 
                      map(k, 0, nk, pg.width/6, 0),
                      map(k, 0, nk, pg.width/2, 10));
      float x = rad * cos(ang);
      float y = rad * sin(ang);
      pg.curveVertex(x, y);
    }
    pg.endShape(CLOSE);
  }
  pg.endDraw();  
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
