/**************************************************************
Superformula SVG grid generator
Author: Jason Webb
Date: March 27th, 2012
URL: http://cs.unk.edu/~webb

Based on superformula implementation from Form+Code: 
http://formandcode.com/code-examples/visualize-superformula
***************************************************************/
import geomerative.*;

int SCREEN_WIDTH = 800;  // Maximum width of screen
float ASPECT_RATIO = 2;  // Aspect ratio of your canvas

// Number of rows and columns
int ROWS = 2;
int COLS = 3;

//====================================
// Generate the screen height based on aspect ratio
int SCREEN_HEIGHT = (int)(SCREEN_WIDTH / ASPECT_RATIO);

// Iteration flag
boolean ITERATE = true;

// Cell dimensions
int CELL_WIDTH = SCREEN_WIDTH / COLS;
int CELL_HEIGHT = SCREEN_HEIGHT / ROWS;

// Superformula variables
float scaler, m, n1, n2, n3, iterations;

// SVG output variables
RGroup output;
RSVG saveOutput;
int fileNumber = 0;

void setup() {
  size(SCREEN_WIDTH, SCREEN_HEIGHT);
  noFill();
  smooth();
  
  RG.init(this);
}

void draw() {
  if(ITERATE) {
    background(255);
    
    // Empty out the container shape
    output = new RGroup();
    output.setFill(false);
    output.setStroke(0);
      
    // Create the grid lines
    RShape gridLines = new RShape();

    // Add row lines    
    for(int i=1; i<ROWS; i++) {
      gridLines.addMoveTo(0,i*(height/ROWS));
      gridLines.addLineTo(width, i*(height/ROWS));
    }
    
    // Add column lines
    for(int i=1; i<COLS; i++) {
      gridLines.addMoveTo(i*(width/COLS),0);
      gridLines.addLineTo(i*(width/COLS), height);
    }
    
    // Add grid lines to container shape
    output.addElement(gridLines);

    // Create each of the superformula renders  
    for(int i=0; i<COLS; i++) {
      for(int j=0; j<ROWS; j++) {       
        // Set appropriate scale
        if(CELL_WIDTH < CELL_HEIGHT)
          scaler = CELL_WIDTH * .3;
        else
          scaler = CELL_HEIGHT * .3;
        
        // Generate new seed values
        m = random(10);
        n1 = random(1);
        n2 = random(2);
        n3 = random(1);
        iterations = random(3);
        
        // Position variables
        float centerX = i*(width/COLS)+(width/COLS/2);
        float centerY = j*(height/ROWS)+(height/ROWS/2);
  
        pushMatrix();
        translate(centerX, centerY);
        
        float newscaler = scaler;
        //float scaleDecay = random(.6,.85);
        float scaleDecay = .95;
               
        for(int s = 0; s < iterations; s++) {   
            float mm = m + s;
            float nn1 = n1 + s;
            float nn2 = n2 + s;
            float nn3 = n3 + s;
            newscaler *= scaleDecay;
            float sscaler = newscaler;
                
            // Create new RShape
            RShape formula = new RShape();            
            
            RPoint[] points = superformula(mm, nn1, nn2, nn3);
            formula.addMoveTo(points[points.length-1].x * sscaler + centerX, points[points.length-1].y * sscaler + centerY);

            for(int t=1; t<points.length; t++)
              formula.addLineTo(points[t].x * sscaler + centerX, points[t].y * sscaler + centerY);
            
            output.addElement(formula);
        }
        
        popMatrix();
      }
    }
    
    // Draw everything
    output.draw();
       
    ITERATE = false;
  }
}

RPoint[] superformula(float m,float n1,float n2,float n3) {
  int numPoints = 180;
  float phi = TWO_PI / numPoints;
  RPoint[] points = new RPoint[numPoints+1];
  for (int i = 0;i <= numPoints;i++) {
    points[i] = superformulaPoint(m,n1,n2,n3,phi * i);
  }
  return points;
}

RPoint superformulaPoint(float m,float n1,float n2,float n3,float phi) {
  float r;
  float t1,t2;
  float a=1,b=1;
  float x = 0;
  float y = 0;

  t1 = cos(m * phi / 4) / a;
  t1 = abs(t1);
  t1 = pow(t1,n2);

  t2 = sin(m * phi / 4) / b;
  t2 = abs(t2);
  t2 = pow(t2,n3);

  r = pow(t1+t2,1/n1);
  if (abs(r) == 0) {
    x = 0;
    y = 0;
  }  
  else {
    r = 1 / r;
    x = r * cos(phi);
    y = r * sin(phi);
  }

  return new RPoint(x, y);
}

void keyPressed() {
  if(key == ' ') {
    ITERATE = true;
  } else if(key == 's' || key == 'S') {
    saveOutput = new RSVG();
    saveOutput.saveGroup("renders/superformula-grid-"+fileNumber+".svg", output);
    fileNumber++;
  }
}
