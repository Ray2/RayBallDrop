import processing.net.*;
import gab.opencv.*;
import processing.video.*;
import java.awt.Rectangle;

OpenCV opencv;
Capture cam;
Client myClient;
String data;
String ipAddress = "127.0.0.1"; //127.0.0.1
 
void setup() {
  size(640, 480);
  cam = new Capture(this, 640, 480);
  opencv = new OpenCV(this, 640, 480);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE); //face detection model
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

  //display camera
  image(cam, 0, 0);

  //face detect
  opencv.loadImage(cam);
  Rectangle[] faces = opencv.detect();
  noFill();
  stroke(0, 255, 0);

  //rect on face
  for (int i = 0; i < faces.length; i++) {
    rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);

   //calc face center
    int centerX = faces[i].x + faces[i].width / 2;
    int centerY = faces[i].y + faces[i].height / 2;

    //paddle follow face center
    mapFaceToPaddle(centerX, centerY);
  }
}

void mapFaceToPaddle(int faceX, int faceY) {
  //screen center x and y
  int centerScreenX = width / 2;
  int centerScreenY = height / 2;

  // faceX and faceY to paddle movement
  if (faceX < centerScreenX - 160) {
    println("a");
    myClient.write('d');
  } else if (faceX > centerScreenX + 160) {
    println("d");
    myClient.write('a');
  }

  if (faceY < centerScreenY - 50) {
    println("w");
    myClient.write('w');
  } else if (faceY > centerScreenY + 50) {
    println("s");
    myClient.write('s');
  }
}

void keyReleased() {
  // send out anything that's typed:
  myClient.write(key);
}
