String[] shaders = new String[]
  { "shade1.glsl", "shade2.glsl", "shade3.glsl", "shade4.glsl" };


class User
{
  int userId;
  int gfxWidth, gfxHeight;
  PVector boxTL, boxBR;
  float boxRatio;
  color maskColor;
  PGraphics gfx, gfx_mask;
  PShader mask, shade;
  int shaderIdx;
  
  User(int userId) 
  {
    this.userId = userId;
    
    boxRatio = 0.75;
    gfxHeight = 800; 
    gfxWidth = (int) (boxRatio * gfxHeight);
    shaderIdx = (int) random(shaders.length);
    
    gfx = createGraphics(gfxWidth, gfxHeight, P2D);
    gfx_mask  = createGraphics(gfxWidth, gfxHeight, P2D);    

    mask = loadShader("mask.glsl");
    mask.set("resolution", float(gfxWidth), float(gfxHeight));
    mask.set("maskTex", gfx_mapped);

    // set shader    
    shade = loadShader(shaders[shaderIdx]);
    shade.set("resolution", float(gfxWidth), float(gfxHeight));
    if (shaderIdx < 3) {
      shade.set("color", 0.5, 0.2, 0.9);
      shade.set("rate", 0.01);
      shade.set("center", gfxWidth/2.0, gfxHeight/4.0);
    } else if (shaderIdx == 3) {
      shade.set("freq", 70.0, 50.0);
    }    
    setMaskColor();
  }
  
  void setShader(int idx) {
    if (idx!=shaderIdx) {
      shaderIdx = idx;
      shade = loadShader(shaders[shaderIdx]);
      shade.set("resolution", float(gfxWidth), float(gfxHeight));
      if (shaderIdx < 3) {
        shade.set("color", 0.5, 0.2, 0.9);
        shade.set("rate", 0.01);
        shade.set("center", gfxWidth/2.0, gfxHeight/4.0);
      } else if (shaderIdx == 3) {
        shade.set("freq", 70.0, 50.0);
      }    
    }
  }
  
  void setMaskColor() 
  {
    float[] col = userColors[userId % userColors.length];
    maskColor = color(255*col[0], 255*col[1], 255*col[2]);
    mask.set("maskColor", col[0], col[1], col[2]);
    //PVector torso = getJointProjective(userId, SimpleOpenNI.SKEL_TORSO);
    //maskColor = kinect.sceneImage().get((int)torso.x, (int)torso.y);
    //mask.set("maskColor", red(maskColor)/255.0, green(maskColor)/255.0, blue(maskColor)/255.0);
  }
  
  void getBoundingBox() 
  {    
    float minX = width;
    float minY = height; 
    float maxX = 0;
    float maxY = 0;
    for (int jointIdx : kinectSkeletonJoints) {
      PVector joint = convertKinectToProjector(getJoint(userId, jointIdx));
      if      (joint.x < minX)  minX = joint.x;
      else if (joint.x > maxX)  maxX = joint.x;
      if      (joint.y < minY)  minY = joint.y;
      else if (joint.y > maxY)  maxY = joint.y;
    }    
    float w = maxX - minX;
    float h = maxY - minY;
    boxTL = new PVector(minX - w*0.1, minY - h*0.1);
    boxBR = new PVector(maxX + w*0.1, maxY + h*0.1);
    w = boxBR.x - boxTL.x;
    h = boxBR.y - boxTL.y;
    float margin = 0.5 * (h * boxRatio - w);
    if (margin > 0) {
      boxTL.x -= margin;
      boxBR.x += margin;
    } else {
      boxTL.y += margin;
      boxBR.y -= margin;
    } 
  }
  
  void draw() 
  {
    getBoundingBox();
    
    // set graphics shader
    shade.set("time", millis()/1000.0); 

    // set mask shader
    mask.set("boxTL", map(boxTL.x, 0, width, 0, 1.0), map(boxTL.y, height, 0, 0, 1.0));
    mask.set("boxBR", map(boxBR.x, 0, width, 0, 1.0), map(boxBR.y, height, 0, 0, 1.0));
    mask.set("thresh", 0.1);

    // draw graphics
    gfx.beginDraw();
    gfx.shader(shade);
    gfx.rect(0, 0, gfx.width, gfx.height);
    gfx.endDraw();
    
    // mask graphics
    gfx_mask.beginDraw();
    gfx_mask.shader(mask);
    gfx_mask.clear();
    gfx_mask.image(gfx, 0, 0);
    gfx_mask.endDraw();

    image(gfx_mask, boxTL.x, boxTL.y, boxBR.x - boxTL.x, boxBR.y - boxTL.y);
  }
  
  void drawBoundingBox() 
  {
    pushStyle();
    strokeWeight(8);
    stroke(maskColor);
    noFill();
    rect(boxTL.x, boxTL.y, boxBR.x - boxTL.x, boxBR.y - boxTL.y);
    popStyle();
  }
}

