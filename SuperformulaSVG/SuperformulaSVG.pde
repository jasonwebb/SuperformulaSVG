/**
 * Visualize: Superformula from Form+Code in Design, Art, and Architecture 
 * implemented in Processing by Jason Webb <http://jason-webb.info>
 * 
 * Uses Geomerative to generate SVGs for output and use in other workflows.
 *
 * Keyboard commands:
 *   Space = trigger a new iteration
 *   s = save an SVG containing all drawings on screen
 *   i = save an raster image of the screen
 *  
 * For more information about Form+Code visit http://formandcode.com
 * and http://formandcode.com/code-examples/visualize-superformula
 */
 
import geomerative.*;

// Number of rows and columns
int ROWS = 15;
int COLS = 15;

// Screen dimensions
int SCREEN_WIDTH = 1024;
int SCREEN_HEIGHT = (SCREEN_WIDTH / COLS) * ROWS;

// Resolution of drawing - more points make smoother lines
int pointsPerRevolution = 720;

// Operation flags
boolean iterate = true;
boolean invert = false;  // invert colors

// Cell dimensions
int CELL_WIDTH = SCREEN_WIDTH / COLS;
int CELL_HEIGHT = SCREEN_HEIGHT / ROWS;

// Superformula variables
int minIterations = 1,
    maxIterations = 10;

// SVG output variables
RGroup output;
RSVG saveOutput;

void setup() {
  surface.setSize(SCREEN_WIDTH, SCREEN_HEIGHT);
  
  RG.init(this);
}

void draw() {
  if(iterate) {
    float scaler;
    
    if(invert)  background(25);
    else        background(255);
    
    // Set up a new container shape
    output = new RGroup();
    output.setFill(false);
      
    // Create the grid lines =====================================================
    RShape gridLines = new RShape();
        
    if(invert)  gridLines.setStroke(#ffffff);
    else        gridLines.setStroke(#000000);
    
    gridLines.setStrokeAlpha(30);

    // Add row lines    
    for(int i=1; i<ROWS; i++) {
      gridLines.addMoveTo(0, i * (height / ROWS));
      gridLines.addLineTo(width, i * (height / ROWS));
    }
    
    // Add column lines
    for(int i=1; i<COLS; i++) {
      gridLines.addMoveTo(i * (width / COLS), 0);
      gridLines.addLineTo(i * (width / COLS), height);
    }
    
    // Add grid lines to container shape
    output.addElement(gridLines);

    // Create each of the superformula renders ==============================================
    for(int i = 0; i < COLS; i++) {
      for(int j = 0; j < ROWS; j++) {       
        // Set appropriate scale
        if(CELL_WIDTH < CELL_HEIGHT)
          scaler = CELL_WIDTH * .3;
        else
          scaler = CELL_HEIGHT * .3;
        
        // Generate new seed values
        float m = random(10);
        float n1 = random(1,2);
        float n2 = random(1,2);
        float n3 = random(1,2);
        int iterations = (int)random(minIterations, maxIterations);
        
        // Position variables
        float centerX = i * (width / COLS) + (width / COLS / 2);
        float centerY = j * (height / ROWS) + (height / ROWS / 2);
  
        pushMatrix();
        translate(centerX, centerY);
        
        float newscaler = scaler;
        float scaleDecay = random(.85,.99);
               
        for(int s = 0; s <= iterations; s++) {   
            float mm = m;
            float nn1 = n1 + s;
            float nn2 = n2 + s;
            float nn3 = n3 + s;
            newscaler *= scaleDecay;
            float sscaler = newscaler;
                
            // Create new container for this iteration
            RShape formula = new RShape();
            formula.setStrokeAlpha(200);
            
            if(invert)  formula.setStroke(#ffffff);
            else        formula.setStroke(#000000);
            
            RPoint[] points = superformula(mm, nn1, nn2, nn3);
            formula.addMoveTo(points[points.length-1].x * sscaler + centerX, points[points.length-1].y * sscaler + centerY);

            for(int t=1; t<points.length; t++) {
              formula.addLineTo(points[t].x * sscaler + centerX, points[t].y * sscaler + centerY);
            }
            
            output.addElement(formula);
        }
        
        popMatrix();
      }
    }
    
    // Draw everything
    output.draw();
       
    iterate = false;
  }
}

void keyPressed() {
  switch(key) {
    case ' ':
      iterate = true;
      break;
    case 's':
      saveOutput = new RSVG();
      saveOutput.saveGroup("svg/superformula-" + hour() + minute() + second() + ".svg", output);
      break;
    case 'i':
      save("images/superformula-" + hour() + minute() + second() + ".png");
      break;
  }
}

RPoint[] superformula(float m,float n1,float n2,float n3) {
  float phi = TWO_PI / pointsPerRevolution;
  RPoint[] points = new RPoint[pointsPerRevolution+1];
  
  for (int i = 0; i <= pointsPerRevolution;i++) {
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
  } else {
    r = 1 / r;
    x = r * cos(phi);
    y = r * sin(phi);
  }

  return new RPoint(x, y);
}