import SimpleOpenNI.*;

SimpleOpenNI kinect;
PVector[] depthMap;
float[] projectorMatrix;
PGraphics gfx_lookup, gfx_mapped;
PShader shade;
int mode = 0;

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
  gfx_lookup = createGraphics(kinect.depthWidth(), kinect.depthHeight(), P2D);
  gfx_mapped = createGraphics(kinect.depthWidth(), kinect.depthHeight(), P2D);

  setupOpenCL();

  shade = loadShader("lut.glsl");
  shade.set("resolution", float(kinect.depthWidth()), float(kinect.depthHeight()));
}

void draw()
{
  kinect.update();
  depthMap = kinect.depthMapRealWorld();
   
  gfx_lookup.beginDraw();
  gfx_lookup.background(0);
  gfx_lookup.loadPixels();
  drawOpenCL();
  gfx_lookup.updatePixels();
  gfx_lookup.endDraw();
  
  shade.set("lutexture", gfx_lookup);
  gfx_mapped.beginDraw();
  gfx_mapped.shader(shade);
  gfx_mapped.image(kinect.sceneImage(), 0, 0);
  gfx_mapped.endDraw();
  
  if        (mode==0) {
    image(kinect.sceneImage(), 0, 0, width, height);
  } else if (mode==1) {
    image(gfx_lookup, 0, 0, width, height);
  } else if (mode==2) {
    image(gfx_mapped, 0, 0, width, height);
  }
  
  textSize(15);
  fill(0);
  rect(2, 2, 110, 17);
  fill(255);
  text("FPS: "+frameRate, 5, 15);   
}


float[] loadCalibration(String filename) {
  String[] s = loadStrings(dataPath(filename));
  float[] projectorMatrix = new float[11];
  for (int i=0; i<s.length; i++)
  projectorMatrix[i] = Float.parseFloat(s[i]);
  return projectorMatrix;
}

void keyPressed() {
  if      (key=='1')  mode=0;
  else if (key=='2')  mode=1;
  else if (key=='3')  mode=2;
}

