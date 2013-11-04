
ArrayList<PVector> getTorsos() 
{
  ArrayList<PVector> torsos = new ArrayList<PVector>();
  int[] userList = kinect.getUsers();
  for(int i=0; i<userList.length; i++) 
  {
    if(kinect.isTrackingSkeleton(userList[i])) {
      torsos.add(getProjectedJoint(userList[i], SimpleOpenNI.SKEL_TORSO));
    }
  } 
  return torsos;  
}

PVector getProjectedJoint(int userId, int jointIdx) {
  PVector jointKinectRealWorld = new PVector();
  PVector jointProjected = new PVector();
  kinect.getJointPositionSkeleton(userId, jointIdx, jointKinectRealWorld);
  jointProjected = convertKinectToProjector(jointKinectRealWorld);
  return jointProjected;
}


// -----------------------------------------------------------------
// SimpleOpenNI events
//  - do not need to modify these...

void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  
  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}


