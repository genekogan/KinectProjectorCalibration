class User
{
  int userId;

  User(int userId) {
    this.userId = userId;
  }
  
  void drawFace() {
    PVector pos = getJointRealWorld(userId, SimpleOpenNI.SKEL_HEAD);
    PVector ctr = getJoint(userId, SimpleOpenNI.SKEL_HEAD);
    float s = 200;
    
    rect(ctr.x, ctr.y, s, s);
  }
}
  
