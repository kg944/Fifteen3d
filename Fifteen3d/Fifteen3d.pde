Controls controls;
PFont f;
boolean debug = false;
boolean spheres = true;
// size of whole puzzle
int boundingSize = 400;
// eventually will be a reference cube that rotates with the puzzle
int refSize = 50;
// reference layer size
int refLayerSize = 50;
int initialCubeDim = 2;
float offset, padding = 50;
int cubeDim, numCubes;
// coords of blank space
int bx, by, bz;
// really not sure about this structure for cubes big TBD over here
Cube[][][] cubes;
Cube[][][] sortedCubes;

// cube numbering 
/*
 * 0 1 2
 * 3 4 5
 * 6 7 8
*/

void setup() {
  size(1200, 800, P3D);
  surface.setTitle("Fifteen3d");
  
  // code config
  f = createFont("consola.ttf", 24);
  textFont(f);
  
  // set up variables
  controls = Controls.MOUSE;
  cubeDim = initialCubeDim;
  setupCubes();
}


void draw() {
  background(20);
  lights();
  pushMatrix();
  // center on bounding cube
  translate(width/2, height/2, -1*boundingSize/2);
  if (controls == Controls.MOUSE) {
    // control camera with mouse
    rotateY(map(mouseX, 0, width, -1*PI, PI));
    rotateX(map(mouseY, 0, height, PI, -1*PI));
  } else {
    rotateY(-PI/8);
    rotateX(-PI/8);
  }
  
  // bounding box TBD if keeping maybe an option
  // togglable with debug for now
  if (debug) {
    stroke(200, 200, 200, 100);
    noFill();
    box(boundingSize);
  }
  
  // simultaneously draw cubes and check if the puzzle is solved
  // probably not good to have the solution checker in the draw method
  // but its technically faster and im not a game developer
  boolean solved = drawCubes();
  
  // done drawing everything that rotate
  popMatrix();
  
  // reference cube looks weird bc of perspective, figure out later
  //drawReferenceCube();
  drawReferenceSquares();
  drawHUD(solved);
}

// draw all the text and useful info
// consider a better name for this method
void drawHUD(boolean solved) {
  pushMatrix();
  textAlign(CENTER, CENTER);
  textSize(24);
  if (solved) {
    fill(0, 255, 0);
    text("solved", width / 2, height - 75, 0);
  } else {
    fill(255, 0, 0);
    text("unsovled", width / 2, height - 75, 0);
  }
  fill(220);
  textAlign(LEFT, BOTTOM);
  textSize(14);
  text("w, a, s, d, q, e to move\ng to scramble\n\'-' and '+' to change dimensions\np to switch between shapes\nm to toggle debug", 10, height - 10, 0);
  popMatrix();
}

boolean drawCubes() {
  textAlign(CENTER, CENTER);
  textSize(24);
  // display all cubes
  int pos = 0;
  boolean solved = true;
  noStroke();
  for (int x = 0; x < cubeDim; x++) {
    for (int y = 0; y < cubeDim; y++) {
      for (int z = 0; z < cubeDim; z++) {
        if (cubes[x][y][z].num != pos) {
          solved = false; 
        }
        pos++;
        if (cubes[x][y][z].isBlank) {
          continue; 
        }
           
        fill(cubes[x][y][z].c);
        pushMatrix();
        float xt = -boundingSize/2 + (offset * x) + offset/2;
        float yt = -boundingSize/2 + (offset * y) + offset/2;
        float zt = -boundingSize/2 + (offset * z) + offset/2;
        translate(xt, yt, zt);
        
        if (spheres) {
          noStroke();
          sphere((offset - padding)/2);
        } else {
          strokeWeight(1);
          stroke(255);
          box(offset - padding);
        }
        
        String s = str(cubes[x][y][z].num);
        fill(255);
        if (debug) {
          text(s, 0, 0, (offset - padding)/2 + 1);
        }
        popMatrix(); 
      }
    }
  }
  return solved;
}

// draw each layer of the sovled cube from a top down perspective
// on the right side of the screen.
void drawReferenceSquares() {
  // spacing between edges of screen, and between layers
  int spacingBetween = 10;
  pushMatrix();
  translate(width - refLayerSize*cubeDim - spacingBetween, spacingBetween, 0);
  rectMode(CORNER);
  stroke(255);
  strokeWeight(1);
  // need to sort first
  for (int y = 0; y < cubeDim; y++) {
    for (int x = 0; x < cubeDim; x++) {
      for (int z = 0; z < cubeDim; z++) {
        if (sortedCubes[x][y][z].isBlank) {
          continue; 
        }
        fill(sortedCubes[x][y][z].c);
        rect(x*refLayerSize, z*refLayerSize + (y*refLayerSize*cubeDim + y*spacingBetween), refLayerSize, refLayerSize);
      }
    }
  }
  popMatrix();
}

// draws a small solved version of the cube in the lower corner that rotates
// with the (unsolved) puzzle
void drawReferenceCube() {
  pushMatrix();
  // reference cube
  stroke(0);
  fill(255, 0, 0);
  translate(width - 100, height - 100, -refSize/2);
  
  // control camera with mouse
  rotateY(map(mouseX, 0, width, -1*PI, PI));
  rotateX(map(mouseY, 0, height, PI, -1*PI));
  box(refSize);
  popMatrix();
}

// sets up cubes 3d array given dimension of cubes
void setupCubes() {
  offset = boundingSize / cubeDim;
  cubes = new Cube[cubeDim][cubeDim][cubeDim];
  sortedCubes = new Cube[cubeDim][cubeDim][cubeDim];;
  int num = 1;
  boolean isBlank = false;
  for (int y = 0; y < cubeDim; y++) {
    for (int z = 0; z < cubeDim; z++) {
      for (int x = 0; x < cubeDim; x++) {
        if (num == pow(cubeDim, 3)) {
          isBlank = true; 
          bx = x;
          by = y;
          bz = z;
        }
        
        // random color for now, TODO experiment with various alphas as well
        color c = color(int(random(0, 256)), int(random(0, 256)), int(random(0, 256)), 255);
        Cube temp = new Cube(cubeDim, num, c, isBlank);
        cubes[x][y][z] = temp;   
        sortedCubes[x][y][z] = temp;
        num++;    
        isBlank = false;
      }
    }
  }
}
// -1 = x, 0 = y, 1 = z
// dir: 1 for positive move, -1 for negative
void move(int axis, int dir) {
  switch (axis) {
    case -1:
      if ((dir == 1 && bz == 0) || (dir == -1 && bz == cubeDim - 1)) {
        return;
      }
      if (dir == 1) {
        Cube temp = cubes[bx][by][bz-1];
        cubes[bx][by][bz-1] = cubes[bx][by][bz];
        cubes[bx][by][bz] = temp;
        bz--;
      } else if (dir == -1) {
        Cube temp = cubes[bx][by][bz+1];
        cubes[bx][by][bz+1] = cubes[bx][by][bz];
        cubes[bx][by][bz] = temp;
        bz++;
      }
    break;
    case 0:
      if ((dir == 1 && by == 0) || (dir == -1 && by == cubeDim - 1)) {
        return;
      }
      if (dir == 1) {
        Cube temp = cubes[bx][by-1][bz];
        cubes[bx][by-1][bz] = cubes[bx][by][bz];
        cubes[bx][by][bz] = temp;
        by--;
      } else if (dir == -1) {
        Cube temp = cubes[bx][by+1][bz];
        cubes[bx][by+1][bz] = cubes[bx][by][bz];
        cubes[bx][by][bz] = temp;
        by++;
      }
    break;
    case 1:
      if ((dir == 1 && bx == 0) || (dir == -1 && bx == cubeDim - 1)) {
        return;
      }
      if (dir == 1) {
        Cube temp = cubes[bx-1][by][bz];
        cubes[bx-1][by][bz] = cubes[bx][by][bz];
        cubes[bx][by][bz] = temp;
        bx--;
      } else if (dir == -1) {
        Cube temp = cubes[bx+1][by][bz];
        cubes[bx+1][by][bz] = cubes[bx][by][bz];
        cubes[bx][by][bz] = temp;
        bx++;
      }
    break;
    default:
    break;
  }
}

void keyPressed() {
  if (key == 'w') {
    move(0, -1);
  } else if (key == 's') {
    move(0, 1); 
  } else if (key == 'a') {
    move(1, -1);
  } else if (key == 'd') {
    move(1, 1);
  }else if (key == 'q') {
    move(-1, 1);
  } else if (key == 'e') {
    move(-1, -1);
  } else if (key == '-') {
    if (cubeDim > 2) {
      cubeDim--;
      setupCubes();
    }
  } else if (key == '+') {
    if (cubeDim < 6) {
      cubeDim++;
      setupCubes();
    }
  } else if (key == 'g') {
    scramble(); 
  } else if (key == 'm') {
    debug = !debug; 
  } else if (key == 'p') {
   spheres = !spheres; 
  } else if (key == 'c') {
    if (controls == Controls.MOUSE) {
      controls = Controls.LINE_AXIS;
    } else {
      controls = Controls.MOUSE; 
    }
  }
}

boolean isSolved() {
   int pos = 0;
   for (int x = 0; x < cubeDim; x++) {
    for (int y = 0; y < cubeDim; y++) {
      for (int z = 0; z < cubeDim; z++) {
        if (cubes[x][y][z].num != pos) {
          return false;
        }
        pos++;
      }
    }
  }
  return true;
}

void scramble() {
  for (int i = 0; i < pow(cubeDim, 5); i++) {
    int axis = int(random(-2, 2));
    boolean dir = random(10) > 5;
    if (dir) {
      move(axis, 1);// theres gotta be a better way to do this 
    } else {
      move(axis, -1); 
    }
    
  }
}
