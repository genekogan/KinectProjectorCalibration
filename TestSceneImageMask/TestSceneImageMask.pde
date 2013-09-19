import SimpleOpenNI.*;

SimpleOpenNI kinect;

PVector[] depthMap;
int[] sceneMap;
float[] projectorMatrix;
PGraphics gfx_mapped;
int gfxWidth, gfxHeight;
ArrayList<User> users;
float downSampleFactor = 0.3;
int mode = 0;

void setup()
{    
  size(displayWidth, displayHeight, P2D); 
  setupKinect();
  users = new ArrayList<User>();

  // load calibration
  projectorMatrix = loadCalibration("calib1.txt");

  // this PGraphics object will contain the warped (reprojected) sceneImage
  gfxWidth = (int)(downSampleFactor*kinect.depthWidth());
  gfxHeight = (int)(downSampleFactor*kinect.depthHeight());
  gfx_mapped = createGraphics(gfxWidth, gfxHeight, P2D);
}

void draw()
{
  kinect.update();
  depthMap = kinect.depthMapRealWorld();
  sceneMap = kinect.sceneMap();
  
  int n = gfxWidth*gfxHeight-2;
  // get bounding box for users
  gfx_mapped.beginDraw();
  gfx_mapped.rectMode(CENTER);
  gfx_mapped.noStroke();
  gfx_mapped.background(0);
  gfx_mapped.loadPixels();
  for (int i=0; i<gfxWidth; i++) {
    for (int j=0; j<gfxHeight; j++) {
      int x = (int) map(i, 0, gfxWidth, 0, kinect.depthWidth());
      int y = (int) map(j, 0, gfxHeight, 0, kinect.depthHeight());
      PVector k = getDepthMapAt(x, y);
      PVector p = convertKinectToProjector(k);
      if (p.x > 0 && p.x < width && p.y >0 && p.y < height) {
        p.x = map(p.x, 0, width,  0, gfxWidth);
        p.y = map(p.y, 0, height, 0, gfxHeight);        
        int idxScene = sceneMap[x+y*kinect.depthWidth()];
        if (idxScene > 0) {
          float[] col = userColors[idxScene % userColors.length];
          //gfx_mapped.pixels[(int)p.x+(int)p.y*gfxWidth] = color(255*col[0], 255*col[1], 255*col[2]);
          color c = color(255*col[0], 255*col[1], 255*col[2]);
          int idx1 = constrain((int)p.x+(int)p.y*gfxWidth, 1, n);
          int idx2 = idx1-1;
          int idx3 = idx1+1;
          int idx4 = constrain(idx1-gfxWidth, 1, n);
          int idx5 = constrain(idx1+gfxWidth, 1, n);
          int idx6 = idx4-1;
          int idx7 = idx4+1;
          int idx8 = idx5-1;
          int idx9 = idx5+1;
          gfx_mapped.pixels[idx1] = c;
          gfx_mapped.pixels[idx2] = c;
          gfx_mapped.pixels[idx3] = c;
          gfx_mapped.pixels[idx4] = c;
          gfx_mapped.pixels[idx5] = c;
          gfx_mapped.pixels[idx6] = c;
          gfx_mapped.pixels[idx7] = c;
          gfx_mapped.pixels[idx8] = c;
          gfx_mapped.pixels[idx9] = c;
        }
      }
    }
  }
  gfx_mapped.updatePixels();
  gfx_mapped.endDraw();

  background(0);
  if      (mode==0)  image(kinect.sceneImage(), 0, 0, width, height);
  else if (mode==1)  image(gfx_mapped, 0, 0, width, height);
  
  for (User u: users)  u.draw();
    
  fpsGui();
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

void fpsGui() {
  pushStyle();
  textSize(28);
  noStroke();
  fill(0);
  rect(2, 2, 200, 27);
  fill(255);
  text("FPS: "+ nf(frameRate, 0, 1), 5, 28);
  popStyle();
  
  int t = (int)(0.333*millis()/1000.0) % shaders.length;
  for (User u:users)  u.setShader(t);
}

void keyPressed() {
  if      (key=='1')  mode = 0;
  else if (key=='2')  mode = 1;
  else if (key=='3')  mode = 2;
}
