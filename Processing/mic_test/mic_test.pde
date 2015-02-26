import processing.serial.*;

Serial myPort;
int TRASH_CUTOFF = 100;
int trash_counter = 0;
StringList in_data = new StringList();

int resolution;
float rect_width;
float rect_height = 5;
FloatList bins = new FloatList();

float R = 0;

float av;
int avrange = 100;

void setup() {  
  size(displayWidth, displayHeight);
  resolution = width;
  rect_width = width / resolution;
  
  myPort = new Serial(this, "/dev/tty.usbmodem1421", 115200);
  //myPort = new Serial(this, "/dev/tty.HC-06-DevB", 115200);
  myPort.bufferUntil('\n');
  
  for (int i = 0; i < resolution; i++)
    bins.append(0);
    
  stroke(255);
  fill(255);
}


void draw() {
  background(0);
  float x;
  float y;
  
  
  av = 0;
  
  for (int i = resolution - avrange; i < resolution; i++)
    av += bins.get(i);
    
  av /= avrange;
  
  text(av, 10, 10);
  
  float r = map(av, 0, 1024, 0, 600);
  float g = map(av, 0, 1024, 200, -200);
  float b = abs(r - g);
  noStroke();
  fill(r, g, b);
  float radius = map(av, 0, 1024, 0, 2*height);
  ellipse(width/2, height/2, radius, radius);
  
  ellipse(width/4, height/4, R, R);

//  for (int i = 0; i < resolution; i++) {
//    x = i * rect_width;
//    y = map(bins.get(i), 0, 1024, height, 0);
//    rect(x, y, rect_width, height);
//  }
  
  stroke(255);
  noFill();
  beginShape();
  for (int i = 0; i < resolution; i++) {
    x = i * rect_width;
    y = map(bins.get(i), 0, 1024, height, 0);
    vertex(x, y);
  }
  endShape();
}


void serialEvent(Serial p) {
  if (trash_counter < TRASH_CUTOFF) {
    p.readString();
    trash_counter++;
  } else {
    String[] l = split(p.readString(), ',');
    in_data = new StringList();
    for (int i = 0; i < l.length; i++)
      in_data.append(l[i]);
      
    bins = shift_list(bins);
    if (in_data.size() > 0)
      bins.set(resolution - 1, float(in_data.get(0)));
      
    if (in_data.size() > 1)
      R = map(float(in_data.get(1)), 0, 1024, 0, 400);
      
  }
} 

FloatList shift_list(FloatList list) {
  FloatList result = new FloatList(list);
  
  for (int i = 0; i < result.size() - 1; i++)
    result.set(i, result.get(i + 1));
    
  return result;
}

