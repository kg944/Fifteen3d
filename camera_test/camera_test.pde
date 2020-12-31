int cubeSize = 200;

void setup() {
  size(500, 500, P3D);
  background(0);
  noFill();
}


void draw() {
  background(255);
  lights();
  translate(width/2, height/2, -100);
  rotateY(map(mouseX, 0, width, -1*PI/2, PI/2));
  rotateX(map(mouseY, 0, height, PI/2, -1*PI/2));
  stroke(100, 255, 100);
  box(200);
  stroke(250, 100, 100);
  box(40);
}
