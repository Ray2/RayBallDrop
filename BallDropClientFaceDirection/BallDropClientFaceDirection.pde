import processing.net.*;
import gab.opencv.*;
import processing.video.*;
import java.awt.Rectangle;

OpenCV opencv;
Capture cam;
Client myClient;
String data;
String ipAddress = "127.0.0.1";

int smoothFactor = 5; 
float[] pitchHistory = new float[smoothFactor];
float[] rollHistory = new float[smoothFactor];
int frameCounter = 0;

float deadZone = 10; 

float movementSpeed = 0.3; 

void setup() {
  size(640, 480);
  cam = new Capture(this, 640, 480);
  opencv = new OpenCV(this, 640, 480);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE); 
  cam.start();

  myClient = new Client(this, ipAddress, 8080);
  background(#000045);
  fill(#eeeeff);
}

void draw() {
  if (cam.available() == true) {
    cam.read();
  }

  image(cam, 0, 0);

  opencv.loadImage(cam);
  Rectangle[] faces = opencv.detect();
  noFill();
  stroke(0, 255, 0);

  for (int i = 0; i < faces.length; i++) {
    rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);
    
    int eyeLeftX = faces[i].x + faces[i].width / 4;
    int eyeRightX = faces[i].x + (3 * faces[i].width / 4);
    int eyeY = faces[i].y + faces[i].height / 4;
    int noseX = faces[i].x + faces[i].width / 2;
    int noseY = faces[i].y + faces[i].height / 2;

    estimateFaceOrientation(eyeLeftX, eyeRightX, eyeY, noseX, noseY);
  }
}

void estimateFaceOrientation(int eyeLeftX, int eyeRightX, int eyeY, int noseX, int noseY) {
  float pitch = noseY - eyeY;
  
  float roll = eyeRightX - eyeLeftX;

  pitchHistory[frameCounter % smoothFactor] = pitch;
  rollHistory[frameCounter % smoothFactor] = roll;
  frameCounter++;

  float avgPitch = 0;
  float avgRoll = 0;
  for (int i = 0; i < smoothFactor; i++) {
    avgPitch += pitchHistory[i];
    avgRoll += rollHistory[i];
  }
  avgPitch /= smoothFactor;
  avgRoll /= smoothFactor;

  if (abs(avgPitch) < deadZone) avgPitch = 0;  // Ignore small pitch movements
  if (abs(avgRoll) < deadZone) avgRoll = 0;  // Ignore small roll movements

  avgPitch *= movementSpeed;
  avgRoll *= movementSpeed;

  println("Pitch: " + avgPitch + " | Roll: " + avgRoll);

  if (avgPitch > 12) {
    println("a");
    myClient.write('a');
  } else if (avgPitch < 12) {
    println("d");
    myClient.write('d');
  }

  if (avgRoll > 25) { 
    println("s");
    myClient.write('s');
  } else if (avgRoll < 25) {
    println("w");
    myClient.write('w');
  }
}

void keyReleased() {
  myClient.write(key);
}
