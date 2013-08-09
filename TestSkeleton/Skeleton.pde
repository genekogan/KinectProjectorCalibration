
void drawProjectedSkeletons() 
{
  int[] userList = kinect.getUsers();
  for(int i=0; i<userList.length; i++) 
  {
    if(kinect.isTrackingSkeleton(userList[i])) {
      PVector pHead = getJoint(userList[i], SimpleOpenNI.SKEL_HEAD);
      PVector pNeck = getJoint(userList[i], SimpleOpenNI.SKEL_NECK);
      PVector pTorso = getJoint(userList[i], SimpleOpenNI.SKEL_TORSO);
      PVector pLeftShoulder = getJoint(userList[i], SimpleOpenNI.SKEL_LEFT_SHOULDER);
      PVector pRightShoulder = getJoint(userList[i], SimpleOpenNI.SKEL_RIGHT_SHOULDER);
      PVector pLeftElbow = getJoint(userList[i], SimpleOpenNI.SKEL_LEFT_ELBOW);
      PVector pRightElbow = getJoint(userList[i], SimpleOpenNI.SKEL_RIGHT_ELBOW);
      PVector pLeftHand = getJoint(userList[i], SimpleOpenNI.SKEL_LEFT_HAND);
      PVector pRightHand = getJoint(userList[i], SimpleOpenNI.SKEL_RIGHT_HAND);      
      PVector pLeftHip = getJoint(userList[i], SimpleOpenNI.SKEL_LEFT_HIP);
      PVector pRightHip = getJoint(userList[i], SimpleOpenNI.SKEL_RIGHT_HIP);
      PVector pLeftKnee = getJoint(userList[i], SimpleOpenNI.SKEL_LEFT_KNEE);
      PVector pRightKnee = getJoint(userList[i], SimpleOpenNI.SKEL_RIGHT_KNEE);
      PVector pLeftFoot = getJoint(userList[i], SimpleOpenNI.SKEL_LEFT_FOOT);
      PVector pRightFoot = getJoint(userList[i], SimpleOpenNI.SKEL_RIGHT_FOOT);
      
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
}

PVector getJoint(int userId, int jointIdx) {
  PVector jointKinectRealWorld = new PVector();
  PVector jointProjected = new PVector();
  kinect.getJointPositionSkeleton(userId, jointIdx, jointKinectRealWorld);
  jointProjected = convertKinectToProjector(jointKinectRealWorld);
  return jointProjected;
}


// -----------------------------------------------------------------
// SimpleOpenNI events
//  - do not need to modify these...

boolean  autoCalib=true;

void onNewUser(int userId)
{
  println("onNewUser - userId: " + userId);
  println("  start pose detection");
  
  if(autoCalib)
    kinect.requestCalibrationSkeleton(userId,true);
  else    
    kinect.startPoseDetection("Psi",userId);
}

void onLostUser(int userId)
{
  println("onLostUser - userId: " + userId);
}

void onExitUser(int userId)
{
  println("onExitUser - userId: " + userId);
}

void onReEnterUser(int userId)
{
  println("onReEnterUser - userId: " + userId);
}

void onStartCalibration(int userId)
{
  println("onStartCalibration - userId: " + userId);
}

void onEndCalibration(int userId, boolean successfull)
{
  println("onEndCalibration - userId: " + userId + ", successfull: " + successfull);
  
  if (successfull) 
  { 
    println("  User calibrated !!!");
    kinect.startTrackingSkeleton(userId); 
  } 
  else 
  { 
    println("  Failed to calibrate user !!!");
    println("  Start pose detection");
    kinect.startPoseDetection("Psi",userId);
  }
}

void onStartPose(String pose,int userId)
{
  println("onStartPose - userId: " + userId + ", pose: " + pose);
  println(" stop pose detection");
  
  kinect.stopPoseDetection(userId); 
  kinect.requestCalibrationSkeleton(userId, true);
 
}

void onEndPose(String pose,int userId)
{
  println("onEndPose - userId: " + userId + ", pose: " + pose);
}

