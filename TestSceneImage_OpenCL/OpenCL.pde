import static org.jocl.CL.*;
import org.jocl.*;

final int platformIndex = 0;
final long deviceType = CL_DEVICE_TYPE_ALL;
final int deviceIndex = 0;

int n;
float[] kinectDepthX, kinectDepthY, kinectDepthZ, coeffArray;
long[] global_work_size, local_work_size;
int numPlatforms, numDevices;

Pointer srcX, srcY, srcZ, calibCoeff, dst;
cl_mem memObjects[];
cl_command_queue commandQueue;
cl_program program;
cl_device_id[] devices;
cl_kernel kernel;
cl_context context;
cl_platform_id platform;
cl_context_properties contextProperties;
cl_device_id device;

String programSource =
    "__kernel void "+
    "sampleKernel(__global const float *x,"+
    "             __global const float *y,"+
    "             __global const float *z,"+
    "             __global const float *p,"+
    "             __global int *e)"+
    "{"+
    "    int gid = get_global_id(0);"+
    "    if (z[gid] > 0.0) {"+
    "      float denom = p[8]*x[gid] + p[9]*y[gid] + p[10]*z[gid] + 1.0;"+
    "      float xn = (256.0/1680.0)*( p[0]*x[gid] + p[1]*y[gid] + p[2]*z[gid] + p[3] ) / denom;"+
    "      float yn = (256.0/1050.0)*( p[4]*x[gid] + p[5]*y[gid] + p[6]*z[gid] + p[7] ) / denom;"+
    "      e[gid] = -16777216 + 256*(int)yn + (int)xn;"+
    "      if (e[gid] < -16777216) e[gid] = -16777216;"+
    "      if (e[gid] > -16711424) e[gid] = -16711424;"+
    "    } else {"+
    "      e[gid] = -16777216;"+
    "    }"+
    "}";

void setupOpenCL() 
{
  // Create input- and output data 
  n = kinect.depthWidth() * kinect.depthHeight();
  kinectDepthX = new float[n];
  kinectDepthY = new float[n];
  kinectDepthZ = new float[n];
  coeffArray = new float[11];
  for (int i=0; i<11; i++)  coeffArray[i] = projectorMatrix[i];

  srcX = Pointer.to(kinectDepthX);
  srcY = Pointer.to(kinectDepthY);
  srcZ = Pointer.to(kinectDepthZ);
  calibCoeff = Pointer.to(coeffArray);

  // Enable exceptions and subsequently omit error checks in this sample
  CL.setExceptionsEnabled(true);

  // Obtain the number of platforms
  int numPlatformsArray[] = new int[1];
  clGetPlatformIDs(0, null, numPlatformsArray);
  numPlatforms = numPlatformsArray[0];
  
  // Obtain a platform ID
  cl_platform_id platforms[] = new cl_platform_id[numPlatforms];
  clGetPlatformIDs(platforms.length, platforms, null);
  platform = platforms[platformIndex];

  // Initialize the context properties
  contextProperties = new cl_context_properties();
  contextProperties.addProperty(CL_CONTEXT_PLATFORM, platform);
  
  // Obtain the number of devices for the platform
  int numDevicesArray[] = new int[1];
  clGetDeviceIDs(platform, deviceType, 0, null, numDevicesArray);
  numDevices = numDevicesArray[0];

  // Obtain a device ID 
  devices = new cl_device_id[numDevices];
  clGetDeviceIDs(platform, deviceType, numDevices, devices, null);
  device = devices[deviceIndex];

  // Create a context for the selected device
  context = clCreateContext(
      contextProperties, 1, new cl_device_id[]{device}, 
      null, null, null);
  
  // Create a command-queue for the selected device
  commandQueue = clCreateCommandQueue(context, device, 0, null);

  // Allocate the memory objects for the input- and output data
  memObjects = new cl_mem[5];    
  memObjects[4] = clCreateBuffer(context, 
      CL_MEM_READ_WRITE, 
      Sizeof.cl_int * n, null, null);
 
  // Set the work-item dimensions
  global_work_size = new long[]{n};
  local_work_size = new long[]{1};
}

void drawOpenCL() 
{
  dst = Pointer.to(gfx_lookup.pixels);

  for (int i=0; i<n; i++) {
      kinectDepthX[i] = depthMap[i].x;
      kinectDepthY[i] = depthMap[i].y;
      kinectDepthZ[i] = depthMap[i].z;
  }
  
  memObjects[0] = clCreateBuffer(context, 
      CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR,
      Sizeof.cl_float * n, srcX, null);
  memObjects[1] = clCreateBuffer(context, 
    CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR,
    Sizeof.cl_float * n, srcY, null);
  memObjects[2] = clCreateBuffer(context, 
    CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR,
    Sizeof.cl_float * n, srcZ, null);  
  memObjects[3] = clCreateBuffer(context, 
    CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR,
    Sizeof.cl_float * n, calibCoeff, null);  
  
  // Create the program from the source code
  program = clCreateProgramWithSource(context,
      1, new String[]{ programSource }, null, null);
      
  // Build the program
  clBuildProgram(program, 0, null, null, null, null);
  
  // Create the kernel
  kernel = clCreateKernel(program, "sampleKernel", null);
  
  // Set the arguments for the kernel
  clSetKernelArg(kernel, 0, 
      Sizeof.cl_mem, Pointer.to(memObjects[0]));
  clSetKernelArg(kernel, 1, 
      Sizeof.cl_mem, Pointer.to(memObjects[1]));
  clSetKernelArg(kernel, 2, 
      Sizeof.cl_mem, Pointer.to(memObjects[2]));
  clSetKernelArg(kernel, 3, 
      Sizeof.cl_mem, Pointer.to(memObjects[3]));
  clSetKernelArg(kernel, 4, 
      Sizeof.cl_mem, Pointer.to(memObjects[4]));  
  
  // Execute the kernel
  clEnqueueNDRangeKernel(commandQueue, kernel, 1, null,
      global_work_size, local_work_size, 0, null, null);
  
  // Read the output data
  clEnqueueReadBuffer(commandQueue, memObjects[4], CL_TRUE, 0,
      n * Sizeof.cl_int, dst, 0, null, null);
}

void releaseObjects() {
  // Release kernel, program, and memory objects
  clReleaseMemObject(memObjects[0]);
  clReleaseMemObject(memObjects[1]);
  clReleaseMemObject(memObjects[2]);
  clReleaseKernel(kernel);
  clReleaseProgram(program);
  clReleaseCommandQueue(commandQueue);
  clReleaseContext(context);
}


