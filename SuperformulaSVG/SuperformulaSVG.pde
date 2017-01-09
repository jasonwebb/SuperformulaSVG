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
 *   r = randomize parameters
 *   n = invert colors
 *   h = hide/show UI
 *  
 * For more information about Form+Code visit http://formandcode.com
 * and http://formandcode.com/code-examples/visualize-superformula
 */
 
import geomerative.*;
import controlP5.*;

// UI elements ----------------------------------------
ControlP5 ui;
Group panel;
Group buttonsPanel;
Range aRange;
Range bRange;
Range mRange;
Range n1Range;
Range n2Range;
Range n3Range;
Range iterationsRange;
Range decayRange;
Slider rowsSlider;
Slider colsSlider;
Slider scaleSlider;
Button iterateButton;
Button randomizeButton;
Button invertColorsButton;
Button saveSVGButton;
Button saveImageButton;
Button saveParametersButton;
Button loadParametersButton;
Textlabel helpText;

// Normal color palette
color uiColorForeground = color(255*.5, 255*.5, 255*.5);
color uiColorBackground = color(50,50,50);
color uiColorLabel = color(50,50,50);
color uiColorButton = color(200,200,200);

// Inverted color palette
color uiColorLabelInverted = color(255*.8,255*.8,255*.8);

// Sizing
int handleSize = 7;
int panelWidth = 300;
int elementHeight = 20;
int elementSpacing = 1;
int sectionSpacing = 10;

// Parameters --------------------------
float a,b,m,n1,n2,n3;
int iterations;
float decay;
int rows = 1;
int cols = 1;
float highestRadius;  // used for automatically scaling drawings to fit cells

float aRangeMin = 0.01,
      aRangeMax = 4.0,
      aRangeLower, aRangeUpper;
      
float bRangeMin = 0.01,
      bRangeMax = 4.0,
      bRangeLower, bRangeUpper;
      
float mRangeMin = 0.0,
      mRangeMax = 40.0,
      mRangeLower, mRangeUpper;
      
float n1RangeMin = 0.01,
      n1RangeMax = 20.0,
      n1RangeLower, n1RangeUpper;
      
float n2RangeMin = 0.01,
      n2RangeMax = 20.0,
      n2RangeLower, n2RangeUpper;
      
float n3RangeMin = 0.01,
      n3RangeMax = 5.0,
      n3RangeLower, n3RangeUpper;
      
int iterationsRangeMin = 1,
    iterationsRangeMax = 30,
    iterationsRangeLower, iterationsRangeUpper;
    
float decayRangeMin = 0.75,
      decayRangeMax = 1.0,
      decayRangeLower, decayRangeUpper;
      
int rowsSliderMax = 5;
int colsSliderMax = 5;

// Screen dimensions
int SCREEN_WIDTH = 1280;
int SCREEN_HEIGHT = 720;

// Cell dimensions
int CELL_WIDTH = SCREEN_WIDTH / cols;
int CELL_HEIGHT = SCREEN_HEIGHT / rows;

// Resolution of drawing - more points make smoother lines
int pointsPerRevolution = 720;

// Operational flags
boolean iterate = true;
boolean invert = false;  // invert colors
boolean autoIterate = false;

// SVG output variables
RGroup output;
RSVG saveOutput;

void setup() {
  surface.setSize(SCREEN_WIDTH, SCREEN_HEIGHT);
  
  RG.init(this);
  
  setupUI();
}

void draw() {
  if(iterate) {       
    // Set up a new container shape for output
    output = new RGroup();
    output.setFill(false);
      
    // Create the grid lines =====================================================
    RShape gridLines = new RShape();
        
    if(invert)  gridLines.setStroke(#ffffff);
    else        gridLines.setStroke(#000000);
    
    gridLines.setStrokeAlpha(30);

    // Add row lines    
    for(int i=0; i<rows; i++) {
      gridLines.addMoveTo(0, i * (height / rows));
      gridLines.addLineTo(width, i * (height / rows));
    }
    
    // Add column lines
    for(int i=1; i<cols; i++) {
      gridLines.addMoveTo(i * (width / cols), 0);
      gridLines.addLineTo(i * (width / cols), height);
    }
    
    // Add grid lines to container shape
    output.addElement(gridLines);

    // Create each of the superformula renders ==============================================
    for(int i = 0; i < cols; i++) {
      for(int j = 0; j < rows; j++) {        
        // Generate new parameter values
        a = random(aRangeLower, aRangeUpper);
        b = random(bRangeLower, bRangeUpper);
        m = random(mRangeLower, mRangeUpper);
        n1 = random(n1RangeLower, n1RangeUpper);
        n2 = random(n2RangeLower, n2RangeUpper);
        n3 = random(n3RangeLower, n3RangeUpper);
        iterations = (int)random(iterationsRangeLower, iterationsRangeUpper);
        decay = random(decayRangeLower, decayRangeUpper);
        
        println("a: " + a + ", b: " + b + ", m: " + m + ", n1: " + n1 + ", n2: " + n2 + ", n3: " + n3 + ", iterations: " + iterations + ", decay: " + decay);
        
        // Position variables
        float centerX = i * (width / cols) + (width / cols / 2);
        float centerY = j * (height / rows) + (height / rows / 2);
  
        // Scaling variables
        highestRadius = 0;
  
        pushMatrix();
        translate(centerX, centerY);
        
        float localScale = 1;
        float overallScale = 1;
        highestRadius = 0;
               
        for(int s = iterations; s > 0; s--) {
          float aa = a + s;
          float bb = b + s;
          float mm = m;
          float nn1 = n1 + s;
          float nn2 = n2 + s;
          float nn3 = n3 + s;
          localScale *= decay;
              
          // Create new container for this iteration
          RShape formula = new RShape();
          formula.setStrokeAlpha(200);
          
          if(invert)  formula.setStroke(color(255*.8,255*.8,255*.8));
          else        formula.setStroke(color(50,50,50));
          
          RPoint[] points = superformula(aa, bb, mm, nn1, nn2, nn3);

          if(s == iterations) {
            int smallestDimension;
            if(CELL_WIDTH < CELL_HEIGHT)
              smallestDimension = CELL_WIDTH;
            else
              smallestDimension = CELL_HEIGHT;
  
            overallScale = (smallestDimension*.9) / (highestRadius*2);
            println(highestRadius*2 * overallScale);
          }
          
          formula.addMoveTo(points[points.length-1].x * localScale * overallScale + centerX, points[points.length-1].y * localScale * overallScale + centerY);

          for(int t = 0; t < points.length; t++) {
            formula.addLineTo(points[t].x * localScale * overallScale + centerX, points[t].y * localScale * overallScale + centerY);
          }
          
          output.addElement(formula);
        }        
        
        popMatrix();
      }
    }
       
    iterate = false;
    println();
  }
  
  if(invert)  background(25);
  else        background(255);
  
  output.draw();
}


/**
* Core superformula implementation adapted to use Geomerative constructs
* See http://formandcode.com/code-examples/visualize-superformula
*/
RPoint[] superformula(float a, float b, float m, float n1, float n2, float n3) {
  float phi = TWO_PI / pointsPerRevolution;
  RPoint[] points = new RPoint[pointsPerRevolution+1];
  
  for (int i = 0; i <= pointsPerRevolution; i++) {
    points[i] = superformulaPoint(a, b, m, n1, n2, n3, phi * i);    
  }
  
  return points;
}

RPoint superformulaPoint(float a, float b, float m, float n1, float n2, float n3, float phi) {
  float r;
  float t1, t2;
  float x = 0;
  float y = 0;

  t1 = cos(m * phi / 4) / a;
  t1 = abs(t1);
  t1 = pow(t1, n2);

  t2 = sin(m * phi / 4) / b;
  t2 = abs(t2);
  t2 = pow(t2, n3);

  r = pow(t1 + t2, 1 / n1);
  
  if (abs(r) == 0) {
    x = 0;
    y = 0;
  } else {
    r = 1 / r;
    x = r * cos(phi);
    y = r * sin(phi);
  }
  
  if(r > highestRadius)  highestRadius = r;

  return new RPoint(x, y);
}


/**
* Set up the ControlP5 UI elements
*
* Initializes and configures all UI elements and relevant behavior, styling and positioning.
*
*/
void setupUI() {
  ui = new ControlP5(this);
  
  panel = ui.addGroup("panel")
            .setPosition(10,10)
            .hideBar();
  
  // Range sliders ===========================================================
  aRangeLower = random(aRangeMin, aRangeMax * random(1));
  aRangeUpper = random(aRangeLower, aRangeMax);  
  aRange = ui.addRange("a")  
             .setBroadcast(false)
             .setPosition(0,0)
             .setSize((int)(panelWidth * .75), elementHeight)
             .setHandleSize(handleSize)             
             .setRange(aRangeMin, aRangeMax)
             .setRangeValues(aRangeLower, aRangeUpper)
             .setBroadcast(true)             
             .setGroup(panel);

  bRangeLower = random(bRangeMin, bRangeMax * random(1));
  bRangeUpper = random(bRangeLower, bRangeMax);
  bRange = ui.addRange("b")
             .setBroadcast(false)
             .setPosition(0, elementHeight + elementSpacing)
             .setSize((int)(panelWidth * .75), elementHeight)
             .setHandleSize(handleSize)
             .setRange(bRangeMin, bRangeMax)
             .setRangeValues(bRangeLower, bRangeUpper)
             .setBroadcast(true)
             .setGroup(panel);

  mRangeLower = random(mRangeMin, mRangeMax * random(1));
  mRangeUpper = random(mRangeLower, mRangeMax);
  mRange = ui.addRange("m")
             .setBroadcast(false)
             .setPosition(0, elementHeight*2 + elementSpacing*2)
             .setSize((int)(panelWidth * .75), elementHeight)
             .setHandleSize(handleSize)
             .setRange(mRangeMin, mRangeMax)
             .setRangeValues(mRangeLower, mRangeUpper)
             .setBroadcast(true)
             .setGroup(panel);

  n1RangeLower = random(n1RangeMin, n1RangeMax * random(1));
  n1RangeUpper = random(n1RangeLower, n1RangeMax);
  n1Range = ui.addRange("n1")
              .setBroadcast(false)
              .setPosition(0, elementHeight*3 + elementSpacing*3)
              .setSize((int)(panelWidth * .75), elementHeight)
              .setHandleSize(handleSize)
              .setRange(n1RangeMin, n1RangeMax)
              .setRangeValues(n1RangeLower, n1RangeUpper)
              .setBroadcast(true)
              .setGroup(panel);

  n2RangeLower = random(n2RangeMin, n2RangeMax * random(1));
  n2RangeUpper = random(n2RangeLower, n2RangeMax);
  n2Range = ui.addRange("n2")
             .setBroadcast(false)
             .setPosition(0, elementHeight*4 + elementSpacing*4)
             .setSize((int)(panelWidth * .75), elementHeight)
             .setHandleSize(handleSize)
             .setRange(n2RangeMin, n2RangeMax)
             .setRangeValues(n2RangeLower, n2RangeUpper)
             .setBroadcast(true)
             .setGroup(panel);

  n3RangeLower = random(n3RangeMin, n3RangeMax * random(1));
  n3RangeUpper = random(n3RangeLower, n3RangeMax);
  n3Range = ui.addRange("n3")
              .setBroadcast(false)
              .setPosition(0, elementHeight*5 + elementSpacing*5)
              .setSize((int)(panelWidth * .75), elementHeight)
              .setHandleSize(handleSize)
              .setRange(n3RangeMin, n3RangeMax)
              .setRangeValues(n3RangeLower, n3RangeUpper)
              .setBroadcast(true)
              .setGroup(panel);

  iterationsRangeLower = (int)(random(iterationsRangeMin, iterationsRangeMax * random(1)));
  iterationsRangeUpper = (int)(random(iterationsRangeLower, iterationsRangeMax));
  iterationsRange = ui.addRange("iterations")
                      .setBroadcast(false)
                      .setPosition(0, elementHeight*6 + elementSpacing*6)
                      .setSize((int)(panelWidth * .75), elementHeight)
                      .setHandleSize(handleSize)
                      .setRange(iterationsRangeMin, iterationsRangeMax)
                      .setRangeValues(iterationsRangeLower, iterationsRangeUpper)
                      .setBroadcast(true)
                      .setGroup(panel);
             
  decayRangeLower = random(decayRangeMin, decayRangeMax * random(1));
  decayRangeUpper = random(decayRangeLower, decayRangeMax);
  decayRange = ui.addRange("decay")
                 .setBroadcast(false)
                 .setPosition(0, elementHeight*7 + elementSpacing*7)
                 .setSize((int)(panelWidth * .75), elementHeight)
                 .setHandleSize(handleSize)
                 .setRange(decayRangeMin, decayRangeMax)
                 .setRangeValues(decayRangeLower, decayRangeUpper)
                 .setBroadcast(true)
                 .setGroup(panel);

  // Row/column sliders ===========================================================================
  rowsSlider = ui.addSlider("rows")
                 .setPosition(0, elementHeight*8 + elementSpacing*8 + sectionSpacing)
                 .setSize((int)(panelWidth * .75), elementHeight)
                 .setRange(1, rowsSliderMax)                 
                 .setNumberOfTickMarks(colsSliderMax)
                 .snapToTickMarks(true)
                 .setGroup(panel);
                 
  colsSlider = ui.addSlider("cols")
                 .setPosition(0, elementHeight*9 + elementSpacing*9 + sectionSpacing)
                 .setSize((int)(panelWidth * .75), elementHeight)
                 .setRange(1, colsSliderMax)
                 .setColorTickMark(color(255))
                 .setNumberOfTickMarks(colsSliderMax)
                 .snapToTickMarks(true)
                 .setGroup(panel);

  // Buttons ============================================================================================
  buttonsPanel = ui.addGroup("buttons")
                   .hideBar()
                   .setGroup(panel);
            
  iterateButton = ui.addButton("iterate")
                    .setPosition(0, elementHeight*10 + elementSpacing*10 + sectionSpacing*2)
                    .setSize((int)(panelWidth * .75), elementHeight)
                    .setGroup(buttonsPanel);
                    
  randomizeButton = ui.addButton("randomize")
                      .setPosition(0, elementHeight*11 + elementSpacing*11 + sectionSpacing*2)
                      .setSize((int)(panelWidth * .75), elementHeight)
                      .setGroup(buttonsPanel);
  
  invertColorsButton = ui.addButton("toggleInvertColors")
                         .setLabel("Invert colors")
                         .setPosition(0, elementHeight*12 + elementSpacing*12 + sectionSpacing*2)
                         .setSize((int)(panelWidth * .75), elementHeight)
                         .setGroup(buttonsPanel);

  saveSVGButton = ui.addButton("saveSVG")
                    .setLabel("Save SVG")
                    .setPosition(0, elementHeight*13 + elementSpacing*13 + sectionSpacing*3)
                    .setSize((int)(panelWidth * .75), elementHeight)
                    .setGroup(buttonsPanel);
                    
  saveImageButton = ui.addButton("saveImage")
                      .setLabel("Save Image")
                      .setPosition(0, elementHeight*14 + elementSpacing*14 + sectionSpacing*3)
                      .setSize((int)(panelWidth * .75), elementHeight)
                      .setGroup(buttonsPanel);

  saveParametersButton = ui.addButton("saveParameters")
                           .setLabel("Save Parameters")
                           .setPosition(0, elementHeight*15 + elementSpacing*15 + sectionSpacing*4)
                           .setSize((int)(panelWidth * .75), elementHeight)
                           .setGroup(buttonsPanel);
                           
  loadParametersButton = ui.addButton("loadParameters")
                           .setLabel("Load Parameters")
                           .setPosition(0, elementHeight*16 + elementSpacing*16 + sectionSpacing*4)
                           .setSize((int)(panelWidth * .75), elementHeight)
                           .setGroup(buttonsPanel);
                      
  // Help text label ==========================================================================
  helpText = ui.addTextlabel("help")
               .setText("Press 'h' to show/hide UI")
               .setPosition(0, elementHeight*17 + elementSpacing*17 + sectionSpacing*4 + 5)
               .setSize(panelWidth, elementHeight)
               .setColorValue(uiColorLabel)
               .setGroup(panel);

  // Apply color palette ===============================
  panel.setColorForeground(uiColorForeground)
       .setColorBackground(uiColorBackground)
       .setColorLabel(uiColorLabel);
       
  buttonsPanel.setColorLabel(uiColorButton);
}


/**
* Handle all control events fired by ControlP5 UI elements
*
* (1) Range sliders do not automatically map to live variables, so must grab current values and store them manually
* (2) Buttons trigger custom behavior (randomizing, saving to SVG, etc), so we need to connect that functionality here
*/
void controlEvent(ControlEvent e) {
  switch(e.getName()) {
    case "a":
      aRangeLower = e.getController().getArrayValue(0);
      aRangeUpper = e.getController().getArrayValue(1);     
      if(autoIterate)  iterate = true;
      break;
    case "b":
      bRangeLower = e.getController().getArrayValue(0);
      bRangeUpper = e.getController().getArrayValue(1);
      if(autoIterate)  iterate = true;
      break;
    case "m":
      mRangeLower = e.getController().getArrayValue(0);
      mRangeUpper = e.getController().getArrayValue(1);      
      if(autoIterate)  iterate = true;
      break;
    case "n1":
      n1RangeLower = e.getController().getArrayValue(0);
      n1RangeUpper = e.getController().getArrayValue(1);
      if(autoIterate)  iterate = true;
      break;
    case "n2":
      n2RangeLower = e.getController().getArrayValue(0);
      n2RangeUpper = e.getController().getArrayValue(1);
      if(autoIterate)  iterate = true;
      break;
    case "n3":
      n3RangeLower = e.getController().getArrayValue(0);
      n3RangeUpper = e.getController().getArrayValue(1);
      if(autoIterate)  iterate = true;
      break;
    case "iterations":
      iterationsRangeLower = (int)e.getController().getArrayValue(0);
      iterationsRangeUpper = (int)e.getController().getArrayValue(1);
      if(autoIterate)  iterate = true;
      break;
    case "decay":
      decayRangeLower = e.getController().getArrayValue(0);
      decayRangeUpper = e.getController().getArrayValue(1);
      if(autoIterate)  iterate = true;
      break;
      
    case "rows":
    case "cols":
      CELL_WIDTH = SCREEN_WIDTH / cols;
      CELL_HEIGHT = SCREEN_HEIGHT / rows;
      break;
      
    case "randomize":
      randomize();
      break;      
    case "toggleInvertColors":
      invertColors();
      break;
  }  
}


/**
* Handle key presses
*
*  Space = trigger one iteration
*  s = save SVG
*  i = save raster image
*  r = randomize parameters
*  n = invert colors
*  h = hide/show UI
*  p = save parameters
*  l = load parameters
*/
void keyPressed() {
  switch(key) {
    case ' ':
      iterate = true;
      break;
    case 's':
      saveSVG();
      break;
    case 'r':
      randomize();
      break;
    case 'i':
      saveImage();
      break;
    case 'n':
      invertColors();
      break;
    case 'h':
      if(panel.isVisible())
        panel.hide();
      else
        panel.show();
      break;
    case 'p':
      saveParameters();
      break;
    case 'l':
      loadParameters();
      break;
  }
}


/**
* Randomize all parameters
*/
void randomize() {
  aRangeLower = random(aRangeMin, aRangeMax);
  aRangeUpper = random(aRangeLower, aRangeMax);
  aRange.setRangeValues(aRangeLower, aRangeUpper);
  
  bRangeLower = random(bRangeMin, bRangeMax);
  bRangeUpper = random(bRangeLower, bRangeMax);
  bRange.setRangeValues(bRangeLower, bRangeUpper);
  
  mRangeLower = random(mRangeMin, mRangeMax);
  mRangeUpper = random(mRangeLower, mRangeMax);
  mRange.setRangeValues(mRangeLower, mRangeUpper);
  
  n1RangeLower = random(n1RangeMin, n1RangeMax);
  n1RangeUpper = random(n1RangeLower, n1RangeMax);
  n1Range.setRangeValues(n1RangeLower, n1RangeUpper);
  
  n2RangeLower = random(n2RangeMin, n2RangeMax);
  n2RangeUpper = random(n2RangeLower, n2RangeMax);
  n2Range.setRangeValues(n2RangeLower, n2RangeUpper);
  
  n3RangeLower = random(n3RangeMin, n3RangeMax);
  n3RangeUpper = random(n3RangeLower, n3RangeMax);
  n3Range.setRangeValues(n3RangeLower, n3RangeUpper);
  
  iterationsRangeLower = (int)random(iterationsRangeMin, iterationsRangeMax);
  iterationsRangeUpper = (int)random(iterationsRangeLower, iterationsRangeMax);
  iterationsRange.setRangeValues(iterationsRangeLower, iterationsRangeUpper);
  
  decayRangeLower = random(decayRangeMin, decayRangeMax);
  decayRangeUpper = random(decayRangeLower, decayRangeMax);
  decayRange.setRangeValues(decayRangeLower, decayRangeUpper);
  
  if(autoIterate)  iterate = true;
}

/**
* Invert the color palette
*/
void invertColors() {
  invert = !invert;
  
  if(invert) {
    panel.setColorLabel(uiColorLabelInverted);
    colsSlider.setColorTickMark(color(25));
    helpText.setColorValue(uiColorLabelInverted);
    buttonsPanel.setColorLabel(uiColorButton);    
  } else {
    panel.setColorLabel(uiColorLabel);
    colsSlider.setColorTickMark(color(255));
    helpText.setColorValue(uiColorLabel);
    buttonsPanel.setColorLabel(uiColorButton);
  }
}


/**
* Save an SVG containing the current geometry
*/
void saveSVG() {
  saveOutput = new RSVG();
  saveOutput.saveGroup("svg/superformula-" + hour() + minute() + second() + ".svg", output);
}


/**
* Save a raster image (PNG) of current screen
*/
void saveImage() {
  save("images/superformula-" + hour() + minute() + second() + ".png");
}


/**
* Saves current ControlP5 UI values to a chosen JSON file
*/
void saveParameters() {
  selectOutput("Save parameters file", "saveParametersTo");
}

void saveParametersTo(File file) {
  if(file != null) {
    String fullPath = file.getAbsolutePath();
    ui.saveProperties(fullPath);    
  }
}


/**
* Load previously saved ControlP5 UI values from a selected JSON file
*/
void loadParameters() {
  selectInput("Choose a parameters file", "loadParametersFrom");
}

void loadParametersFrom(File file) {
  if(file != null) {
    String fullPath = file.getAbsolutePath();
    
    if(fullPath.substring(fullPath.length() - 4, fullPath.length()).equals("json")) {
      ui.loadProperties(fullPath);
      iterate = true;
    } else {
      println("Not a valid file type.");
    }
  }
}