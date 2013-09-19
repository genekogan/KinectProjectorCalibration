import SimpleOpenNI.*;
import hypermedia.video.*;
import processing.video.*;
import java.awt.*;
import controlP5.*;

ControlP5 cp5;
SimpleOpenNI  kinect;
OpenCV opencv;
Blob[] blobs;
ArrayList<Contour> contours;
PVector[] depthMapRealWorld;
float[] projectorMatrix;
PShader threshFilter;
PGraphics pgKinect, pgThresh, pgRender;
PImage bgDepthTex;
float blobDilate, depThresh, kinectFade;
int numBlobs, blobMin, blobMax, blobWindow;
PVector screenScale;
boolean toSubtractBg = true;
boolean debug = true;


void setup()
{
  size(displayWidth, displayHeight, P2D);
  kinect = new SimpleOpenNI(this);   
  kinect.setMirror(false);
  kinect.enableDepth(); 
  opencv = new OpenCV(this);
  opencv.allocate(kinect.depthWidth(), kinect.depthHeight());  
  
  pgKinect = createGraphics(kinect.depthWidth(), kinect.depthHeight());
  pgThresh = createGraphics(kinect.depthWidth(), kinect.depthHeight(), P2D);
  pgRender = createGraphics(width, height);
  
  projectorMatrix = loadCalibration("calib1.txt");  
  screenScale = new PVector((float)width/1680, (float)height/1050);
  setupGui();
  setupBlobShader();
}

void setupBlobShader() {
  if (toSubtractBg) {
    bgDepthTex = loadImage("bgDepth.png");
    threshFilter = loadShader("bgThreshPicture.glsl");
    threshFilter.set("bgTex", bgDepthTex.get());
  } else {
    threshFilter = loadShader("bgThresh.glsl");
  }
  threshFilter.set("resolution", float(pgKinect.width), float(pgKinect.height));
}

void update()
{
  kinect.update();
  depthMapRealWorld = kinect.depthMapRealWorld();
  
  // original kinect image
  pgKinect.beginDraw();
  pgKinect.tint(255, kinectFade);
  pgKinect.image(kinect.depthImage(), 0, 0);
  pgKinect.endDraw();
  
  // subtract bgDepth and threshold
  threshFilter.set("depthThresh", depThresh);
  pgThresh.beginDraw();
  pgThresh.shader(threshFilter);
  pgThresh.image(pgKinect, 0, 0);
  pgThresh.endDraw();
  
  // detect blobs with opencv and derive contours from blobs  
  opencv.copy(pgThresh.get());
  blobs = opencv.blobs(blobMin, blobMax, numBlobs, false);
  contours = getContours(blobs);
  
  drawPresentation();
}

void drawPresentation() {
  pgRender.beginDraw();
  pgRender.background(0);
  pgRender.fill(0, 0, 255);
  pgRender.strokeWeight(5);
  pgRender.stroke(0, 0, 200);
  for (Contour contour : contours) {
    pgRender.beginShape();
    for (PVector p : contour.pointsMappedSmooth)
      pgRender.vertex(p.x, p.y);
    pgRender.endShape();
  }
  pgRender.fill(255);
  pgRender.textSize(36);
  pgRender.text("presentation mode: press 'p' to toggle full-screen", 20, 40);
  pgRender.text("do something with these contours!", 20, 80);
  pgRender.endDraw();
}

void draw() {
  update();

  if (debug) {
    pushMatrix();
    background(32);
    scale(screenScale.x, screenScale.y);
    translate(10, 10);

    // top left: kinect depth image
    image(pgKinect, 0, 0);
    if (toSubtractBg) 
      image(bgDepthTex, kinect.depthWidth()-160, 0, 160, 120);

    // top right: thresh image, original blobs
    translate(kinect.depthWidth()+10, 0);
    image(pgThresh, 0, 0);
    for (Contour c : contours)  c.drawOriginalBlobs();

    // bottom left: mapped contours
    translate(-kinect.depthWidth()-10, kinect.depthHeight()+10);
    fill(0);
    rect(0, 0, kinect.depthWidth(), kinect.depthHeight());
    pushMatrix();
    scale((float) kinect.depthWidth() / width, (float) kinect.depthHeight() / height);
    for (Contour c : contours)  c.drawContour();
    popMatrix();

    // bottom right: preview render
    translate(kinect.depthWidth()+10, 0);
    image(pgRender, 0, 0, kinect.depthWidth(), kinect.depthHeight());
    popMatrix();
  }
  else {
    background(0);
    image(pgRender, 0, 0);
  }
  fpsGui();
}

void fpsGui() {
  fill(255);
  textSize(18);
  text("fps: "+nfs(frameRate,2,1), width-100, 20);
}

void keyPressed() 
{
  if (key=='p')  {                     // toggle presentation/debug mode
    debug = !debug;
    if (debug)  cp5.show();
    else        cp5.hide();
  }  
  else if (key=='g') {                 // toggle GUI
    if (cp5.isVisible())  cp5.hide();
    else                  cp5.show();
  }
}

float[] loadCalibration(String filename) {
  String[] s = loadStrings(dataPath(filename));
  float[] projectorMatrix = new float[s.length];
  for (int i=0; i<s.length; i++)
    projectorMatrix[i] = Float.parseFloat(s[i]);
  return projectorMatrix;
}

PVector getDepthMapAt(int x, int y) {
  PVector dm = depthMapRealWorld[kinect.depthWidth() * y + x];
  return new PVector(dm.x, dm.y, dm.z);
}

PVector convertKinectToProjector(PVector kp) {
  PVector pp = new PVector();
  float denom = projectorMatrix[8]*kp.x + projectorMatrix[9]*kp.y + projectorMatrix[10]*kp.z + 1.0;
  pp.x = (projectorMatrix[0]*kp.x + projectorMatrix[1]*kp.y + projectorMatrix[2]*kp.z + projectorMatrix[3]) / denom;
  pp.y = (projectorMatrix[4]*kp.x + projectorMatrix[5]*kp.y + projectorMatrix[6]*kp.z + projectorMatrix[7]) / denom;
  return pp;
}

void bgDepthSnapshot() {
  kinect.depthImage().save(savePath("data/bgDepth.png"));
  bgDepthTex = loadImage("bgDepth.png");
  setupBlobShader();
}

