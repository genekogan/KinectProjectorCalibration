float ribbonWidth, ribbonNoise;
int ribbonRate, ribbonAge, ribbonSpeed, ribbonLength, ribbonMargin;
boolean ribbonColored, ribbonCurved;



void renderContours() 
{
  pushStyle();
  ArrayList<Ribbon> nextRibbons = new ArrayList<Ribbon>();
  for (Ribbon r : ribbons) {
    r.update();
    r.draw();
    if (r.age < r.maxAge)  
      nextRibbons.add(r);
  }
  ribbons = nextRibbons;
  popStyle();
}

void addNewRibbon() {
  if (contours.size() > 0) {  
    ArrayList<PVector> contour = contours.get((int)random(contours.size()));    
    Ribbon newRibbon = new Ribbon(contour);
    ribbons.add(newRibbon);
  }
}

void drawContours() {
  pushStyle();
  noFill();
  stroke(255);
  for (ArrayList<PVector> contour : contours) {
    beginShape();
    for (PVector p : contour)  curveVertex(p.x, p.y);
    endShape();
  }
  popStyle();
}

class Ribbon
{
  ArrayList<PVector> contour;
  int age, maxAge, t, n;
  color col;
  float offx, offy;
  
  Ribbon(ArrayList<PVector> contour) 
  {
    this.contour = contour;
    age = 0;
    maxAge = ribbonAge;  //(int) random(10, 20);
    t = (int) random(contour.size());
    n = (int) ribbonLength;
    offx = random(20);
    offy = random(20);
    if (ribbonColored)
      col = color(random(255), random(255), random(255), random(50, 150));
    else
      col = color(255, random(50, 150));
  }
  void update() {
    age++;
    t = (t + ribbonSpeed) % (contour.size()+1);
  }
  void draw() {  
    pushStyle();
    noFill();
    stroke(col);
    float sw = map(abs(age-maxAge/2.0), maxAge/2.0, 0, 0, ribbonWidth);
    strokeWeight(sw);
    beginShape();
    for (int i=0; i<n; i++) {
      PVector p = contour.get(((t+i)*6) % contour.size());
      float nx = map(noise(ribbonNoise*i+offx, ribbonNoise*frameCount+offx), 0, 1, -ribbonMargin, ribbonMargin);
      float ny = map(noise(ribbonNoise*i+offy, ribbonNoise*frameCount+offy), 0, 1, -ribbonMargin, ribbonMargin);
      if (ribbonCurved)  curveVertex(p.x + nx, p.y + ny);
      else               vertex(p.x + nx, p.y + ny);
    }
    endShape();
    popStyle();
  }
}



