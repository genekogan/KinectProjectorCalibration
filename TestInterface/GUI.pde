void setupGui() {
  cp5 = new ControlP5(this);
  cp5.setFont(createFont("Courier", 14));

  int cp5Offset = (int)(screenScale.x*(2*kinect.depthWidth()+30));
  PVector cp5bar = new PVector(270, 20); //180,16

  // ===== Kinect ====== //
  cp5.addSlider("depThresh").setLabel("Threshold").setPosition(cp5Offset, 40).setValue(0.19).setRange(0, 1).setSize((int)cp5bar.x, (int)cp5bar.y);
  cp5.addSlider("kinectFade").setLabel("Fade").setPosition(cp5Offset, 70).setValue(255).setRange(0, 256).setSize((int)cp5bar.x, (int)cp5bar.y);
  cp5.addButton("bgDepthSnapshot").setLabel("snapBG").setValue(1.0).setPosition(cp5Offset+150, 100).setSize(100, (int)cp5bar.y);
  cp5.addToggle("subtractBG").setPosition(cp5Offset, 100).setSize(100, (int)cp5bar.y).setValue(false);  
  
  // ====== Contours ====== //
  cp5.addSlider("numBlobs").setLabel("numBlobs").setPosition(cp5Offset, 185).setSize((int)cp5bar.x, (int)cp5bar.y).setRange(0,10).setValue(4).setNumberOfTickMarks(10);
  cp5.addRange("blobRange").setLabel("Size Range").setPosition(cp5Offset, 215).setSize((int)cp5bar.x, (int)cp5bar.y).setHandleSize(20).setRange(8, 0.3*kinect.depthWidth()*kinect.depthHeight()).setRangeValues(0.03*kinect.depthWidth()*kinect.depthHeight(), 0.1*kinect.depthWidth()*kinect.depthHeight());
   
  //  cp5.addSlider("blobSkip").setLabel("Skip").setPosition(cp5Offset, 185).setValue(1).setRange(1, 50).setSize((int)cp5bar.x, (int)cp5bar.y);
  cp5.addSlider("blobWindow").setLabel("Smoothness").setPosition(cp5Offset, 245).setValue(25).setRange(0, 50).setSize((int)cp5bar.x, (int)cp5bar.y);
  cp5.addSlider("blobDilate").setLabel("Dilation").setPosition(cp5Offset, 275).setValue(1.0).setRange(0.0, 2.0).setSize((int)cp5bar.x, (int)cp5bar.y);
}

void controlEvent(ControlEvent theControlEvent) {
  if (theControlEvent.isFrom("blobRange")) {
    blobMin = int(theControlEvent.getController().getArrayValue(0));
    blobMax = int(theControlEvent.getController().getArrayValue(1));
    float s1 = 2*sqrt(blobMin / PI);
    float s2 = 2*sqrt(blobMax / PI);
    pushMatrix();
    ellipseMode(CENTER);
    translate(width/2, height/2);
    fill(255, 0, 0);
    ellipse(0, 0, s2, s2);
    fill(0, 0, 255);
    ellipse(0, 0, s1, s1);
    popMatrix();
  }  
  else if (theControlEvent.isFrom("subtractBG")) {
    toSubtractBg = theControlEvent.getController().getValue() > 0.5;
    if (toSubtractBg)   cp5.getController("bgDepthSnapshot").show();
    else                cp5.getController("bgDepthSnapshot").hide();
    setupBlobShader();
  }
  else if (theControlEvent.isFrom("blobWindow")) {
    setupBlobWindow();
  }
}

