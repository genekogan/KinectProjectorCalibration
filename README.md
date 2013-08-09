## Kinect-Projector calibration

Processing code for calibrating kinect and projector together, such that projector image is automatically aligned with the physical space it is projecting onto, facilitating the projection of graphics onto moving bodies.

There is a "calibration module" program which goes through the process of calibrating the kinect and projector together by manually collecting several dozen pairs of aligned points from the two devices. The end result is a text file containing 11 numbers which represent the free parameters of the projection matrix used to convert 3d kinect points to 2d projector coordinates. This file is then used by the other programs (named "Test__") which demonstrate various applications of the calibration.

Please note that this codebase is experimental and buggy right now. In the next few weeks, I will be adding more documentation and a tutorial.

The calibration methodology/math comes from the excellent write up by [Jan Hrdlička at 3dsense blog](http://blog.3dsense.org/programming/kinect-projector-calibration-human-mapping-2/), and also uses the JAMA library for matrix math.

For other work on Projector/Kinect calibration in OpenFrameworks/vvvv, see works by Elliot Woods, Kyle McDonald, and Daito Manabe, as well as the OpenFrameworks addon ofxCamaraLucida.

If you wish to run the code, you must have SimpleOpenNI library installed into Processing 2.0.
