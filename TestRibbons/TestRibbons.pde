import gab.opencv.*;
import processing.video.*;
import java.awt.*;
import SimpleOpenNI.*;

OpenCV opencv;
SimpleOpenNI kinect;
PGraphics pgKinect;
ArrayList<ArrayList<PVector>> contours;
PVector[] depthMapRealWorld;
float[] projectorMatrix;

void setup() 
{
  size(displayWidth, displayHeight, P2D);
  opencv = new OpenCV(this, 640, 480);
  projectorMatrix = loadCalibration("calib1.txt");

  // set kinect
  kinect = new SimpleOpenNI(this);   
  kinect.setMirror(false);
  kinect.enableDepth(); 
  kinect.alternativeViewPointDepthToImage();

  // initialize pgraphics objects
  pgKinect = createGraphics(kinect.depthWidth(), kinect.depthHeight());

  setupBlobWindow();
  
  ribbonWidth = 4;
  ribbonNoise = 0.01;
  ribbonRate = 4;
  ribbonAge = 15;
  ribbonSpeed = 6;
  ribbonLength = 60;
  ribbonMargin = 30;
  ribbonColored = false;
  ribbonCurved = false;

}

void draw() 
{
  float MIN_BB = map(mouseY, 0, height, 0, width*height/10);
  int KINECT_THRESH = (int) map(mouseX, 0, width, 0, 255);

  // get kinect contours
  kinect.update();
  depthMapRealWorld = kinect.depthMapRealWorld();
  pgKinect.beginDraw();
  pgKinect.image(kinect.depthImage(), 0, 0);
  pgKinect.endDraw();
  opencv.loadImage(pgKinect);
  opencv.threshold(KINECT_THRESH);
  contours = getContours(opencv.findContours());


  background(0);
  image(kinect.depthImage(), 0, 0);
  renderContours();
  addNewRibbon();
  
    /*
  for (ArrayList<PVector> contour : contours) {
    stroke(255, 0, 0);
    strokeWeight(4);
    noFill();
    beginShape();
    for (PVector p : contour) {
      vertex(p.x, p.y);
    }
    endShape();
  }
  */
  /*
  for (Contour contour : contours) {
    Rectangle bb = contour.getBoundingBox();
    if (bb.width * bb.height > MIN_BB) {
      ArrayList<PVector> pts = contour.getPoints();
      beginShape();
      stroke(255, 0, 0);
      strokeWeight(4);
      noFill();
      for (PVector p : pts) {
        vertex(p.x, p.y);
      }
      endShape();
    }
  }    
  */

}

PVector getDepthMapAt(int x, int y) {
  PVector dm = depthMapRealWorld[kinect.depthWidth() * y + x];
  return new PVector(dm.x, dm.y, dm.z);
}

PVector convertKinectToProjector(PVector kp) {
  PVector pp = new PVector();
  float denom = projectorMatrix[8]*kp.x + projectorMatrix[9]*kp.y + projectorMatrix[10]*kp.z + 1.0;
  pp.x = width * (projectorMatrix[0]*kp.x + projectorMatrix[1]*kp.y + projectorMatrix[2]*kp.z + projectorMatrix[3]) / denom;
  pp.y = height * (projectorMatrix[4]*kp.x + projectorMatrix[5]*kp.y + projectorMatrix[6]*kp.z + projectorMatrix[7]) / denom;
  return pp;
}

float[] loadCalibration(String filename) {
  String[] s = loadStrings(dataPath(filename));
  float[] projectorMatrix = new float[s.length];
  for (int i=0; i<s.length; i++)
    projectorMatrix[i] = Float.parseFloat(s[i]);
  return projectorMatrix;
}

