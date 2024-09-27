import processing.net.*;
import gab.opencv.*;
import processing.video.*;
import java.awt.Rectangle;

OpenCV opencv;
Capture cam;
Client myClient;
String data;
String ipAddress = "127.0.0.1";

void setup() {
  size(640, 480);
  cam = new Capture(this, 640, 480);
  opencv = new OpenCV(this, 640, 480);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  // Load face detection model
  cam.start();

  // Connect to server on port 8080
  myClient = new Client(this, ipAddress, 8080);
  background(#000045);
  fill(#eeeeff);
}

void draw() {
  // Read camera frame
  if (cam.available() == true) {
    cam.read();
  }
  
  //scale(-1, 1);
  image(cam, -640, 0);

  //face detect
  opencv.loadImage(cam);
  Rectangle[] faces = opencv.detect();
  noFill();
  stroke(0, 255, 0);
  
  //rect on face
  for (int i = 0; i < faces.length; i++) {
    rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);

    detectHeadMovement(faces[i].x, faces[i].y);
  }
}

float sensitivityX = 0.5;
float sensitivityY = 0.7;

void detectHeadMovement(int x, int y) {
  int centerX = width / 2;
  int centerY = height / 2;

  //sens scale
  float scaledX = (x - centerX) * sensitivityX;
  float scaledY = (y - centerY) * sensitivityY;

  //paddle movement
  if (scaledX < -75) {
    myClient.write('d');
  } else if (scaledX > 75) {
    myClient.write('a');
  }

  if (scaledY < -50) {
    myClient.write('w');
  } else if (scaledY > 50) {
    myClient.write('s');
  }
}


void keyReleased() {
  // send out anything that's typed:
  myClient.write(key);
}
