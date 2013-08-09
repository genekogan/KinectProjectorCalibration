int[] kinectSkeletonJoints;
boolean autoCalib = true;
float[][] userColors;


void setupKinect() 
{
  kinect = new SimpleOpenNI(this);
  kinect.setMirror(false);
  kinect.enableDepth();
  kinect.enableScene();
  kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
    
  kinectSkeletonJoints = new int[]{ SimpleOpenNI.SKEL_HEAD, 
      SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND, 
      SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND, 
      SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT, 
      SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT };

  userColors = new float[11][];
  userColors[0] = new float[]{ 0.0, 1.0, 1.0 };
  userColors[1] = new float[]{ 0.0, 0.0, 1.0 };
  userColors[2] = new float[]{ 0.0, 1.0, 0.0 };
  userColors[3] = new float[]{ 1.0, 1.0, 0.0 };
  userColors[4] = new float[]{ 1.0, 0.0, 0.0 };
  userColors[5] = new float[]{ 1.0, 0.5, 0.0 };
  userColors[6] = new float[]{ 0.5, 1.0, 0.0 };
  userColors[7] = new float[]{ 0.0, 0.5, 1.0 };
  userColors[8] = new float[]{ 0.5, 0.0, 1.0 };
  userColors[9] = new float[]{ 1.0, 1.0, 0.5 };
  userColors[10]= new float[]{ 1.0, 1.0, 1.0 };
}

PVector getJoint(int userId, int jointId) {
  PVector jointPos3d = new PVector();
  kinect.getJointPositionSkeleton(userId, jointId, jointPos3d);
  return jointPos3d;
}

PVector getJointProjective(int userId, int jointId) {
  PVector jointPos3d = new PVector();
  PVector jointPos2d = new PVector();
  kinect.getJointPositionSkeleton(userId, jointId, jointPos3d);
  kinect.convertRealWorldToProjective(jointPos3d, jointPos2d);
  return jointPos2d;
}



// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(int userId)
{
  println("onNewUser - userId: " + userId);
  println("  start pose detection");
  
  if(autoCalib)
    kinect.requestCalibrationSkeleton(userId,true);
  else    
    kinect.startPoseDetection("Psi",userId);
    
  users.add(new User(userId));
}


void onLostUser(int userId)
{
  println("onLostUser - userId: " + userId);
  
  for (User u : users)
    if (u.userId == userId) users.remove(u);
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
