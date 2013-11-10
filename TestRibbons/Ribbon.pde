float blobDilate = 1.0;
int blobSkip = 4;
int blobWindow = 20;

ArrayList<Ribbon> ribbons = new ArrayList<Ribbon>();
float[] window;
float totalWindow;

// ===== get contours ======//
ArrayList<ArrayList<PVector>> getContours(ArrayList<Contour> blobs) 
{  
  
  blobDilate = map(mouseY, 0, height, 0.1, 2.0);

  
  ArrayList<ArrayList<PVector>> contours = new ArrayList<ArrayList<PVector>>();
  
  
  for(int i=0; i<blobs.size(); i++) {
    ArrayList<PVector> contour = new ArrayList<PVector>();
    
    Rectangle br = blobs.get(i).getBoundingBox();
    ArrayList<PVector> points = blobs.get(i).getPoints();
    if (points.size() > 24) {
    
      for(int j=0; j<points.size(); j+=blobSkip) {
        PVector pt = points.get(j);
      
        pt.x = constrain(pt.x, 0, kinect.depthWidth()-1);
        pt.y = constrain(pt.y, 0, kinect.depthHeight()-1);
        PVector kp = getDepthMapAt((int)pt.x, (int)pt.y);
        PVector pp = convertKinectToProjector(kp);

        
        float x = pp.x;
        float y = pp.y;
        //float x = map(pp.x, br.x, br.x + br.width,  br.x - blobDilate*br.width,  br.x + br.width + blobDilate*br.width);
        //float y = map(pp.y, br.y, br.y + br.height, br.y - blobDilate*br.height, br.y + br.height + blobDilate*br.height);
        for (int k=1; k<=blobWindow; k++) {
          int idx1 = (points.size()+j-k) % points.size();
          int idx2 = (j+k) % points.size();          
          x += (window[k]*points.get(idx1).x + window[k]*points.get(idx2).x);
          y += (window[k]*points.get(idx1).y + window[k]*points.get(idx2).y);
        }
        x /= totalWindow;
        y /= totalWindow;
      
        
        contour.add(new PVector(x, y));
      }
      
      contours.add(contour);
    }
    
    
  }  
  
  return contours;
}

void setupBlobWindow() {
  totalWindow = 1.0;
  window = new float[blobWindow+1];
  window[0] = 1.0;
  for (int i=1; i<=blobWindow; i++) {
    window[i] = 1.0 - float(i)/(blobWindow+1);
    totalWindow += 2*window[i];
  }
}

