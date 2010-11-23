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
import rwmidi.*;
MidiInput input;
MidiOutput output;

void noteOnReceived(Note note) {
        if(note.getVelocity() != 0)
        {
          MyKeySet.keys[note.getPitch()].LatestVelocity = note.getVelocity(); 
          KeysPushed.add(MyKeySet.keys[note.getPitch()]);
        }
        else
        {
          KeysReleased.add(MyKeySet.keys[note.getPitch()]);
        }
}

void noteOffReceived(Note note) {
//Assynchronous midi note received message
          KeysReleased.add(MyKeySet.keys[note.getPitch()]);
}


