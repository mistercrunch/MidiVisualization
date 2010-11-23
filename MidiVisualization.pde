/*
    MidiBalls: A 3d music visualization that uses midi as input 
    Copyright (C) 2010 Maxime Beauchemin

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
/*
Program:           Midi Visualisation
Programmer:        Maxime Beauchemin, aka mistercrunch: maximebeauchemin@gmail.com http://mistercrunch.blogspot.com
Date Started:      Jan/Feb 2010
Purpose:           Representing midi events (music) in a way that enhances the listener's experience, helping him to understand what 
                   he hears, while conveying the beauty of music visually. 
Details:           
  General Idea:    The software uses midi, OpenGL and basic 3d physics. Colored particles in space represent notes, and forces are applied to them.
  Colors:          Each note of the scale has a specific color, color similitude is used for consonant intervals, color contrasts for dissonant ones
   
*/
//Variables
int       KEYS_LAYOUT_MODE      = 0; //0 is keyboard like, 1 is spiral
float     GRAVITY               = 2.5; //Use 3 if not 0
boolean   PAUSE                 = false;
boolean   VORTEX                = false;
boolean   REFLECTION            = true;
int       BLACK_KEYS_HIGHER     = 50;
boolean   LINUX_MODE            = true;
float     BOUNCE_RANDOMNESS     = 0.9;
float     KEY_HEIGHT            = 500;
float     CAM_DISTANCE          = 700;
float     FLOOR                 = (KEY_HEIGHT/2);
float     BOUNCE                = 0.63;
float     LIFELENGHT            = 300;
float     MAXGENERATION         = 3;
int       WIDTH                 = 900;
int       HEIGHT                = 600;
int       KEYS_WIDTH            = 30;
int       X_OFFSET              = -55;
Vect3d    v3dVortex             = new Vect3d(0,0, 0);

float degX=0;
float degY=0;

/*
//Fun variables
int       BLACK_KEYS_HIGHER   = 50;
int       KEYS_WIDTH          = 22;
int       X_OFFSET            = -50;
float     BOUNCE_RANDOMNESS   = 0.9;
boolean   KEYBOARD_MODE       = false;
boolean   VIDEO_CAPTURE       = false;
float     GRAVITY             = 3;
float     FLOOR               = 800;
float     BOUNCE              = 0.63;
float     LIFELENGHT          = 270;
float     MAXGENERATION       = 3;
int       WIDTH               = 640;
int       HEIGHT              = 480;
*/

//Program variables
int nbKeys=128;
KeySet MyKeySet;
LinkedList Particles             = new LinkedList(); //List of particles
LinkedList ParticlesToAdd        = new LinkedList(); //Cache used to store new particles created while iterating the official Particles
LinkedList KeysPushed            = new LinkedList(); //Caching assynchronous keys pushed to treat after iterating through Particles
LinkedList KeysReleased          = new LinkedList(); //Same as above for keys released events

OpenGLAbstraction gl; //Class used to abstract the OpenGL stuff, keeps main cleaner

void setup() {
  size(WIDTH, HEIGHT, OPENGL);
  frameRate(30);
  background(0);
  colorMode(HSB, 1);

  gl = new OpenGLAbstraction();

  //////////////////////////////////////////////
  //This is where you select the midi in
  int midiIndex;
  if(!LINUX_MODE)midiIndex=0;
  else midiIndex=0;
  input = RWMidi.getInputDevices()[midiIndex].createInput(this);
  //////////////////////////////////////////////
  
  MyKeySet = new KeySet(36,84);
   	

  
}

void draw() {
  //println(frameRate);
  //println(Particles.size());  
  //gl.Background(color(0),0.1);
  
  gl.OpenGLStartDraw();
  background(0);
  
  Iterator it = Particles.listIterator(); 
  while ( it.hasNext() ) 
  {
    Particle p = (Particle)it.next();
    if( (!p.isKeyPushed && p.Age>p.LifeLenght ))
    {  
      //Particle has ended it's lifecycle, remove
       it.remove();
    }  
    else
    { 
      //Move the particle and draw
      if(!PAUSE)p.Move();
      p.Draw();
    }
  }
  
  if(LINUX_MODE)
  {
    if(!keyPressed)
    {
      AllOff();
      lastFrameNoteNumber = 0;
    }
  }
  
  //Treating the buffers
  PushKeys(); //Note played during the animation are now treated
  ReleaseKeys();//Note released during the animation can now be treated
  
  //Particles created during the animation are now added to the Particles list
  Particles.addAll(ParticlesToAdd);
  ParticlesToAdd.clear();
  
  float percX=(((float)mouseX/2 ) -((float)width*3)/4) / width;
  float percY=(float)mouseY/1.6 / (height*2);
  
  
  degX = percX * 360;
  degY = percY * 360;
  
  float radX = percX * 6.28;
  float radY = percY * 6.28;
  
  //camera(sin(radX) * CAM_DISTANCE, sin(radY) * CAM_DISTANCE,cos(radX) * CAM_DISTANCE,   0,0,0,   0,1,0);
  //gl.renderImage(new Vect3d(0,0,0), 300, new ColorGL(1,1,1), 1);
  
  gl.OpenGLEndDraw();
  camera(sin(radX) * -sin(radY) * CAM_DISTANCE, -cos(radY) * CAM_DISTANCE, cos(radX) * -sin(radY) * CAM_DISTANCE,   0,0,0,   0,1,0);
  
}



void ReleaseKeys()
{
  LinkedList tmp = KeysReleased;
  KeysReleased = new LinkedList(); 
  
  Iterator it = tmp.listIterator();
  while ( it.hasNext() ) 
  {
    Key k = (Key)it.next();
    k.Release();
  }
  tmp.clear();
}

void PushKeys()
{
  LinkedList tmp = KeysPushed;
  KeysPushed = new LinkedList(); 
  
  Iterator it = tmp.listIterator();
  while ( it.hasNext() ) 
  {
    Key k = (Key)it.next();
    k.Push(k.LatestVelocity);
  }
  tmp.clear();
}

void AllOff()
//Sets all notes off
{
  for(int i=0;i<nbKeys;i++)
  {
    MyKeySet.keys[i].Release();
  }
}


int lastFrameNoteNumber = 0;


      
void keyPressed()
//Processing's keypressed event
{
  if (key == CODED) {
    if       (keyCode == UP)    CAM_DISTANCE-=50;
    else if  (keyCode == DOWN)  CAM_DISTANCE+=50;
  }
  else if (key=='P')  
      PAUSE=!PAUSE;
  else if (key=='G')  
      if (GRAVITY==3)GRAVITY=0;else GRAVITY=3;
      
  if(LINUX_MODE)
  {
    int NoteNumber=0;
    NoteNumber=NoteFromChar(key);
    if (key=='x')
      AllOff();
    
    else if(NoteNumber!=lastFrameNoteNumber)
    {
      MyKeySet.keys[NoteNumber].Push(64);
    }

    lastFrameNoteNumber=NoteNumber;
  }
}

int NoteFromChar(char c)
//Returns a notenumber based on a keyboard character (using this to test the software when not around an actual midi keyboard or in linux where i have not midi driver...)
{ 
  int baseC=48;
  int NoteNumber;
  switch(c)
    {
      case 'a': NoteNumber=baseC+0;break;
      case 'w': NoteNumber=baseC+1;break;
      case 's': NoteNumber=baseC+2;break;
      case 'e': NoteNumber=baseC+3;break;
      case 'd': NoteNumber=baseC+4;break;
      case 'f': NoteNumber=baseC+5;break;
      case 't': NoteNumber=baseC+6;break;
      case 'g': NoteNumber=baseC+7;break;
      case 'y': NoteNumber=baseC+8;break;
      case 'h': NoteNumber=baseC+9;break;
      case 'u': NoteNumber=baseC+10;break;
      case 'j': NoteNumber=baseC+11;break;
      case 'k': NoteNumber=baseC+12;break;
      case 'o': NoteNumber=baseC+13;break;
      case 'l': NoteNumber=baseC+14;break;
      case 'p': NoteNumber=baseC+15;break;
      case ';': NoteNumber=baseC+16;break;
      default : NoteNumber=0; break;
    }  
   return NoteNumber;
}

