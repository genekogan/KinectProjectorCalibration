
void drawProjectedSkeleton(int userId) 
{
  if(kinect.isTrackingSkeleton(userId)) {
    PVector pHead = getProjectedJoint(userId, SimpleOpenNI.SKEL_HEAD);
    PVector pNeck = getProjectedJoint(userId, SimpleOpenNI.SKEL_NECK);
    PVector pTorso = getProjectedJoint(userId, SimpleOpenNI.SKEL_TORSO);
    PVector pLeftShoulder = getProjectedJoint(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER);
    PVector pRightShoulder = getProjectedJoint(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
    PVector pLeftElbow = getProjectedJoint(userId, SimpleOpenNI.SKEL_LEFT_ELBOW);
    PVector pRightElbow = getProjectedJoint(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW);
    PVector pLeftHand = getProjectedJoint(userId, SimpleOpenNI.SKEL_LEFT_HAND);
    PVector pRightHand = getProjectedJoint(userId, SimpleOpenNI.SKEL_RIGHT_HAND);      
    PVector pLeftHip = getProjectedJoint(userId, SimpleOpenNI.SKEL_LEFT_HIP);
    PVector pRightHip = getProjectedJoint(userId, SimpleOpenNI.SKEL_RIGHT_HIP);
    PVector pLeftKnee = getProjectedJoint(userId, SimpleOpenNI.SKEL_LEFT_KNEE);
    PVector pRightKnee = getProjectedJoint(userId, SimpleOpenNI.SKEL_RIGHT_KNEE);
    PVector pLeftFoot = getProjectedJoint(userId, SimpleOpenNI.SKEL_LEFT_FOOT);
    PVector pRightFoot = getProjectedJoint(userId, SimpleOpenNI.SKEL_RIGHT_FOOT);
    
    stroke(0, 0, 255);
    strokeWeight(16);
    line(pHead.x, pHead.y, pNeck.x, pNeck.y);
    line(pNeck.x, pNeck.y, pTorso.x, pTorso.y);
    line(pNeck.x, pNeck.y, pLeftShoulder.x, pLeftShoulder.y);
    line(pLeftShoulder.x, pLeftShoulder.y, pLeftElbow.x, pLeftElbow.y);
    line(pLeftElbow.x, pLeftElbow.y, pLeftHand.x, pLeftHand.y);
    line(pNeck.x, pNeck.y, pRightShoulder.x, pRightShoulder.y);
    line(pRightShoulder.x, pRightShoulder.y, pRightElbow.x, pRightElbow.y);
    line(pRightElbow.x, pRightElbow.y, pRightHand.x, pRightHand.y);
    line(pTorso.x, pTorso.y, pLeftHip.x, pLeftHip.y);
    line(pLeftHip.x, pLeftHip.y, pLeftKnee.x, pLeftKnee.y);
    line(pLeftKnee.x, pLeftKnee.y, pLeftFoot.x, pLeftFoot.y);
    line(pTorso.x, pTorso.y, pRightHip.x, pRightHip.y);
    line(pRightHip.x, pRightHip.y, pRightKnee.x, pRightKnee.y);
    line(pRightKnee.x, pRightKnee.y, pRightFoot.x, pRightFoot.y);   
    
    fill(255, 0, 0);
    noStroke();
    ellipse(pHead.x, pHead.y, 60, 60);
    ellipse(pNeck.x, pNeck.y, 60, 60);
    ellipse(pTorso.x, pTorso.y, 60, 60);
    ellipse(pLeftShoulder.x, pLeftShoulder.y, 60, 60);
    ellipse(pRightShoulder.x, pRightShoulder.y, 60, 60);
    ellipse(pLeftElbow.x, pLeftElbow.y, 60, 60);
    ellipse(pRightElbow.x, pRightElbow.y, 60, 60);
    ellipse(pLeftHand.x, pLeftHand.y, 60, 60);
    ellipse(pRightHand.x, pRightHand.y, 60, 60);
    ellipse(pLeftHip.x, pLeftHip.y, 60, 60);
    ellipse(pRightHip.x, pRightHip.y, 60, 60);
    ellipse(pLeftKnee.x, pLeftKnee.y, 60, 60);
    ellipse(pRightKnee.x, pRightKnee.y, 60, 60);
    ellipse(pLeftFoot.x, pLeftFoot.y, 60, 60);
    ellipse(pRightFoot.x, pRightFoot.y, 60, 60);
  }
}


PVector getProjectedJoint(int userId, int jointIdx) {
  PVector jointKinectRealWorld = new PVector();
  PVector jointProjected = new PVector();
  kinect.getJointPositionSkeleton(userId, jointIdx, jointKinectRealWorld);
  jointProjected = convertKinectToProjector(jointKinectRealWorld);
  return jointProjected;
}

PVector getJointRealWorld(int userId, int jointIdx) {
  PVector jointKinectRealWorld = new PVector();
  kinect.getJointPositionSkeleton(userId, jointIdx, jointKinectRealWorld);
  return jointKinectRealWorld;
}


// -----------------------------------------------------------------
// SimpleOpenNI events
//  - do not need to modify these...

void onNewUser(SimpleOpenNI curContext,int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  
  kinect.startTrackingSkeleton(userId);
  users.add(new User(userId));
}

void onLostUser(SimpleOpenNI curContext,int userId)
{
  println("onLostUser - userId: " + userId);
  for (User u : users)
    if (u.userId == userId)  users.remove(u);
}

void onVisibleUser(SimpleOpenNI curContext,int userId)
{
  //println("onVisibleUser - userId: " + userId);
}


