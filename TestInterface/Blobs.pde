float[] contourWindow;
float contourWindowTotal;

ArrayList<Contour> getContours(Blob[] blobs) {
  ArrayList<Contour> contours = new ArrayList<Contour>();
  for(int i=0; i<blobs.length; i++)
    contours.add(new Contour(blobs[i]));
  return contours;
}

class Contour 
{
  Point[] bPoints;
  PVector centroid;
  PVector bbPos, bbSize, bbPosMapped, bbSizeMapped;
  float area, circumference;
  ArrayList<PVector> points, pointsMapped, pointsMappedSmooth;
  
  Contour(Blob blob) {
    bbPos = new PVector(blob.rectangle.x, blob.rectangle.y);
    bbSize = new PVector(blob.rectangle.width, blob.rectangle.height); 
    centroid = new PVector(blob.centroid.x, blob.centroid.y);
    area = blob.area;
    circumference = blob.length;
    points = new ArrayList<PVector>();
    pointsMapped = new ArrayList<PVector>();
    bPoints = blob.points;
    
    // map points according to calibration and find bounding box
    PVector TL = new PVector(width, height);
    PVector BR = new PVector(0, 0);
    for (Point p : bPoints) {
      PVector pk = getDepthMapAt((int)p.x, (int)p.y);
      PVector pp = convertKinectToProjector(pk);
      points.add(new PVector(p.x, p.y));
      pointsMapped.add(pp);
      if      (pp.x < TL.x)  TL.x = pp.x;
      else if (pp.x > BR.x)  BR.x = pp.x;
      if      (pp.y < TL.y)  TL.y = pp.y;
      else if (pp.y > BR.y)  BR.y = pp.y;
    }
    bbPosMapped = new PVector(TL.x, TL.y);
    bbSizeMapped = new PVector(BR.x-TL.x, BR.y-TL.y);
    
    // smooth contours
    pointsMappedSmooth = new ArrayList<PVector>();
    for (int j=0; j<pointsMapped.size(); j++) {
      float x = pointsMapped.get(j).x;
      float y = pointsMapped.get(j).y;
      for (int k=1; k<=blobWindow; k++) {
          int idx1 = (pointsMapped.size()+j-k) % pointsMapped.size();
          int idx2 = (j+k) % pointsMapped.size();          
          x += (contourWindow[k] * pointsMapped.get(idx1).x + contourWindow[k] * pointsMapped.get(idx2).x);
          y += (contourWindow[k] * pointsMapped.get(idx1).y + contourWindow[k] * pointsMapped.get(idx2).y);
        }
        x /= contourWindowTotal;
        y /= contourWindowTotal;
        pointsMappedSmooth.add(new PVector(x, y));
    }

    // dilate smooth contours
    PVector dilatedTL = new PVector(bbPosMapped.x + 0.5*(1.0-blobDilate)*bbSizeMapped.x,
                                    bbPosMapped.y + 0.5*(1.0-blobDilate)*bbSizeMapped.y);
    PVector dilatedBR = new PVector(bbPosMapped.x + (0.5+0.5*blobDilate)*bbSizeMapped.x,
                                    bbPosMapped.y + (0.5+0.5*blobDilate)*bbSizeMapped.y);
    for (PVector p : pointsMappedSmooth) {
      p.x = (int) map(p.x, bbPosMapped.x, bbPosMapped.x + bbSizeMapped.x, dilatedTL.x, dilatedBR.x);
      p.y = (int) map(p.y, bbPosMapped.y, bbPosMapped.y + bbSizeMapped.y, dilatedTL.y, dilatedBR.y);      
    }
    bbPosMapped.x = bbPosMapped.x + 0.5*(1.0-blobDilate)*bbSizeMapped.x;
    bbPosMapped.y = bbPosMapped.y + 0.5*(1.0-blobDilate)*bbSizeMapped.y;
    bbSizeMapped.mult(blobDilate);    
  }

  void drawOriginalBlobs() {
    noFill();
    stroke(160);
    rect(bbPos.x, bbPos.y, bbSize.x, bbSize.y);
    stroke(0,0,255);
    line(centroid.x-5, centroid.y, centroid.x+5, centroid.y );
    line(centroid.x, centroid.y-5, centroid.x, centroid.y+5 );
    noStroke();
    fill(0,0,255);
    text(area, centroid.x+5, centroid.y+5 );
    fill(255,0,255,64);
    stroke(255,0,255);
    beginShape();
    for(PVector p : points)
      vertex(p.x, p.y);
    endShape(CLOSE);    
    noStroke();
    fill(255,0,255);
    text(circumference, centroid.x+5, centroid.y+15 );  
  }
  
  void drawContour() {
    pushStyle();
    noFill();
    strokeWeight(4);
    stroke(255, 100);
    beginShape();
    for (PVector p : pointsMappedSmooth)
      vertex(p.x, p.y);
    endShape();
    stroke(0,255,0);
    rect(bbPosMapped.x, bbPosMapped.y, bbSizeMapped.x, bbSizeMapped.y);
    popStyle();
  }
}

void setupBlobWindow() {
  contourWindowTotal = 1.0;
  contourWindow = new float[blobWindow+1];
  contourWindow[0] = 1.0;
  for (int i=1; i<=blobWindow; i++) {
    contourWindow[i] = 1.0 - float(i)/(blobWindow+1);
    contourWindowTotal += 2*contourWindow[i];
  }
}
