float maxDist = 500;

class User
{
  int userId;
  ArrayList<Fireball> fireballs;
  boolean hasFiredLeft = true;
  boolean hasFiredRight = true;

  User(int userId) {
    this.userId = userId;
    fireballs = new ArrayList<Fireball>();
  }
  
  void lookForFireballMotion() {
    PVector pTorso = getJointRealWorld(userId, SimpleOpenNI.SKEL_TORSO);
    PVector pRightHand = getJointRealWorld(userId, SimpleOpenNI.SKEL_RIGHT_HAND);      
    PVector pLeftHand = getJointRealWorld(userId, SimpleOpenNI.SKEL_LEFT_HAND);      
    float dl = dist(pTorso.x, pTorso.y, pTorso.z, pLeftHand.x, pLeftHand.y, pLeftHand.z);
    float dr = dist(pTorso.x, pTorso.y, pTorso.z, pRightHand.x, pRightHand.y, pRightHand.z);
    
    // check left hand
    if (dl > maxDist) {
      if (!hasFiredLeft) {
        PVector ctr = getProjectedJoint(userId, SimpleOpenNI.SKEL_LEFT_HAND);
        PVector torso = getProjectedJoint(userId, SimpleOpenNI.SKEL_TORSO);
        PVector vel = PVector.sub(ctr, torso);
        fireballs.add(new Fireball(ctr, vel));
        hasFiredLeft = true;
      }
    }
    else {
      hasFiredLeft = false;
    }
    // check right hand
    if (dr > maxDist) {
      if (!hasFiredRight) {
        PVector ctr = getProjectedJoint(userId, SimpleOpenNI.SKEL_RIGHT_HAND);
        PVector torso = getProjectedJoint(userId, SimpleOpenNI.SKEL_TORSO);
        PVector vel = PVector.sub(ctr, torso);
        fireballs.add(new Fireball(ctr, vel));
        hasFiredRight = true;
      }
    }
    else {
      hasFiredRight = false;
    }
  }
    
  void drawFireballs() {
    ArrayList<Fireball> next = new ArrayList<Fireball>();
    for (Fireball fireball : fireballs) {
      fireball.update();
      fireball.draw();
      if (fireball.active)  next.add(fireball);
    }
    fireballs = next;
  }
}
  
class Fireball
{
  float t;
  PVector ctr, vel;
  boolean active;
  float maxSize;
  Fireball(PVector ctr, PVector vel) {
    this.ctr = ctr;
    this.vel = vel;
    vel.setMag(5.0);
    t = 0;
    maxSize = 300;
    active = true;
  }
  
  void update() {
    ctr.add(vel);
    t += 3.0;
    if (ctr.x < -180 || ctr.x > width + 180 || ctr.y < -180 || ctr.y > height + 180) 
      active = false;
  }
  
  void draw() {
    pushMatrix();
    pushStyle();
    translate(ctr.x, ctr.y);
    image(pg, 0, 0, constrain(t, 0, maxSize), constrain(t, 0, maxSize));
    popStyle();
    popMatrix();
  }
}
