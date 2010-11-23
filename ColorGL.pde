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
//Simple class to store colors in OpenGL compatible format
//Processing stores color in an int where 2bytes are used for R, G, B, A
//OpenGL needs float values between 0-1
//This class stores in OpenGL format, removing the need for conversions, thus optimising
class ColorGL
{
  float r,g,b;
  
  ColorGL()
  {
    r=g=b=0;
  }
  ColorGL(color c)
  {
    SetColor(c);
  }
  ColorGL(ColorGL inCgl)
  {
    r=inCgl.r;
    g=inCgl.g;
    b=inCgl.b;
  }
  ColorGL(float inR, float inG, float inB)
  {
    SetColor(inR, inG, inB);
  }
  
  void SetColor(color c)
  {
    int currR = (c >> 16) & 0xFF; // Like red(), but faster
    int currG = (c >> 8) & 0xFF;
    int currB = c & 0xFF;
 
    r=(float)currR/255;
    g=(float)currG/255;
    b=(float)currB/255;
  }
  void SetColor(float inR, float inG, float inB)
  {
    r=inR;
    g=inG;
    b=inB;
  }
  ColorGL Clone()
  {
    ColorGL tmp = new ColorGL(r, g, b);
    return tmp;
  }
  void Randomize(float range)
  { 
    
    r += (random(range)) - range/2;
    
    g += (random(range)) - range/2;
    b += (random(range)) - range/2;
    
    FixRange(r);
    FixRange(g);
    FixRange(b);
  }
  
  float FixRange(float a)
  {
    if (a>1)a=1;
    else if (a<0)a=1;
    return a;
  }
};

