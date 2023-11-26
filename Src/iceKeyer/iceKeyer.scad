// Box for my iceKeyer, https://Fihl.net/iceKeyer
// A CW morse keyer, without moving parts

// This file is for OpenSCAD, the best

include <../lasercutter2D.scad>; 
// Modified for 2D only, based on https://github.com/bmsleight/lasercut 
// Modified 2023 by OZ1AAB, Christen Fihl, https://github.com/Fihl

thickness = 4.1;    // 3mm=3.1, 4mm=4.1

layout = 2;  // 0=My way, best for design, 1=Tall(y), 2=Flat(x)

doLaserCut = 1; //To export DFX file. F5+F6+Export-DXF
                //Otherwise only text (and corners shown) to SVG. F5+F6+Export-SVG
doSVGtext = 0;  //0 when export to DXF, to get rid of my corners (or if text goes outside of area)
                //1 to see where text is located (take care of added circles in corners)

x = 60;
y = 40;
z = 90;
fingerx = 4;    // 10mm..15mm each finger (60mm => 4)
fingery = 3;    // 
fingerz = 5;    // 
fingerBack = 3; // Less fingers, to enable easy open from bottom (and hardcoded holes)

$fn=60;

dispx=25.1; dispy=17.1; dispOfs=0;  //display glass
disphx=21; disphy=21.1;             //mount holes
dispXpos=15; 
dispYpos=y-15; 

mic=9.71;
PADDLEx = 37-thickness;             //1' hole for paddle, from front
PADDLEx2 = PADDLEx+10;              //2' hole for paddle
PADDLEw = 12.7;                     //Paddle arm, exact

if (layout==0) { //My way, best for design
    doFront(x,y, 0,0);
    doTop(x,z, 0,y+10);
    doBack(x,y, 0,y+z+20);
    doBottom(x,z, 0,y+z+y+30);
    doRight(z,y, x+10,0);
    doLeft(z,y, -z-10,0);
  }
if (layout==1) { //Tall
    doFront(x,y, 0,0);
    doTop(x,z, 0,y+10);
    doBack(x,y, 0,y+z+20);
    doBottom(x,z, 0,y+z+y+30);
    doRight(z,y, 0,-10,-90);
    doLeft(z,y, y+10,-10,-90);
    translate([x+10,y+10])      doInnerStuff(); //Export as dxf to lasercut
  }
if (layout==2) { //Flat
    doTop(x,z, 0,0);
    doBottom(x,z, x+10,0);
    doRight(z,y, y+x+x+20, 0, 90);
    doLeft(z,y, y+y+x+x+30,0, 90);
    doFront(x,y, y+y+x+x+30 +y+10, 0, 90);
    doBack (x,y, y+y+x+x+30 +y+10, x+10, 90);
    translate([x+10,z+10])      doInnerStuff(); //Export as dxf to lasercut
  }

module txt(sizex,sizey,posx,posy,s,size=3,direction=0) {
    if (doSVGtext) {
      %  //color("red",0.6)
      translate([posx,posy]) rotate(direction) text(s, size);
      for (x=[0,1]) 
        for (y=[0,1]) 
          translate([sizex*x,sizey*y]) 
            circle(thickness);   //Corners into SVG
    }
}

PADDLEholeExact = PADDLEw;
PADDLEhole = PADDLEholeExact+2*2;
PADDLEleft = x-PADDLEhole-thickness+1*2;
module doFront(x,y, dx,dy, direction=0) {
  translate([dx,dy]) {
    rotate(direction) {
      txt(x,y,2,5,"iceKeyer", 6);
      if (doLaserCut) {
            lasercutoutSquare(thickness=thickness, x=x, y=y,
            bumpy_finger_joints=[
                    [UP, 1, fingerx],
                    [RIGHT, 1, fingery],
                    [LEFT, 1, fingery],
                    [DOWN, 1, fingerx],     
                ],
                cutouts = [ 
                    [PADDLEleft, 4, PADDLEhole, PADDLEholeExact+1], //paddle 2mm on each side, none below
                    [dispXpos-dispx/2, dispYpos-dispy/2, dispx,dispy],   //display glass
                ],
                circles_remove = [
                    [0.5, dispXpos-disphx/2, dispYpos-dispOfs-disphy/2], //display mount
                    [0.5, dispXpos+disphx/2, dispYpos-dispOfs-disphy/2], //display mount
                    [0.5, dispXpos-disphx/2, dispYpos-dispOfs+disphy/2], //display mount
                    [0.5, dispXpos+disphx/2, dispYpos-dispOfs+disphy/2], //display mount

                    //[4.8/2, PADDLEleft+(PADDLEhole)/2, y-13],     //LED
            ]
            );
        }
    }
  }
}

module doBack(x,y, dx,dy, direction=0) {
USBw=7;
USBh=12-USBw; //Rounded ends
USBx=x-USBw/2-5;
  translate([dx,dy]) {
    rotate(direction) {
      if (doLaserCut)
        lasercutoutSquare(thickness=thickness, x=x, y=y,
            bumpy_finger_joints=[
                [UP, 1, fingerBack],
                [DOWN, 1, fingerx],     
                [RIGHT, 1, fingery],
                [LEFT, 1, fingery]
            ],
            circles_remove = [
                [2, 1.5*x/6, y],            //open the box
                [2, 3.5*x/6, y],            //open
                [2, 5.5*x/6, y],            //open

                [2, USBx, y/2+17/2],        //uUSB=5*9.5, USBc=7*12. holes = 17
                [2, USBx, y/2-17/2],        //uUSB/USBc
                [USBw/2, USBx, y/2-USBh/2], //USBc, rounded hole. Also fits uUSB
                [USBw/2, USBx, y/2+USBh/2], //USBc, rounded hole

                //[7/2, x-PADDLEw-2*thickness-20, y/2],    //LF vol (maybe ON/off too)
                //[3/2, x-PADDLEw-2*thickness-20+6, y/2],  //rotary lock, 6mm offset        
            ],
            cutouts = [ 
                [USBx-USBw/2, y/2-USBh/2, USBw, USBh], //uUSB
            ]

        );
    }
  }
}

module doRight(x,y, dx,dy, direction=0) {
  translate([dx,dy]) {
    rotate(direction) {
      if (doLaserCut)
        lasercutoutSquare(thickness=thickness, x=x, y=y,
            bumpy_finger_joints=[
                [UP, 1, fingerz],
                [DOWN, 1, fingerz],
                [RIGHT, 1, fingery],
                [LEFT, 1, fingery]
            ],
            circles_remove = [
                [2, PADDLEx,  PADDLEw/2+4], 
                [2, PADDLEx2, PADDLEw/2+4], 
            ]
        );
    }
  }
}
module doInnerStuff() {
    difference() {
        square([z,y]);
        translate([PADDLEx,  PADDLEw/2+4]) circle(r=2);
        translate([PADDLEx2, PADDLEw/2+4]) circle(r=2);
        for (i=[20:15:z])
            for (j=[0,y])
                translate([i,j]) circle(r=4);     //Pass through holes (space=4mm)
    }
    W = PADDLEw+2+2*thickness+2;
    for (n=[0:2])
        translate([n*(W+2),y+5,0]) 
        difference() {
            square([W,y-n*10]);                   //Standoff pieces
            for (j=[0,y])
                translate([W/2,j]) circle(r=4);   //Pass through holes (space=4mm)
        }
    PL = PADDLEx2-PADDLEx+12;
    for (n=[0:1])
        translate([68+PADDLEw,y+5+(5+PL)*n]) 
        difference() {
            square([PADDLEw,PL]);                 //Spacers
            for (j=[6,6+PADDLEx2-PADDLEx])
                translate([PADDLEw/2,j]) circle(r=2);
        }
}

module doLeft(x,y, dx,dy, direction=0) {
  translate([dx,dy]) {
    rotate(direction) {
      txt(x,y,15+8,y-10-5,"OUT", 4);
      txt(x,y,15+8,10-5,"cw/pwr", 4);
      if (doLaserCut)
        lasercutoutSquare(thickness=thickness, x=x, y=y,
            bumpy_finger_joints=[
                [UP, 1, fingerz],
                [DOWN, 1, fingerz],
                [RIGHT, 1, fingery],
                [LEFT, 1, fingery]
            ],
            circles_remove = [
                [9/2, 15, y-10],                //3.5 jack OUT
                [9/2, 15, 10],                  //3.5 jack CW out, PWR in
                [7/2, x-30, y/2],               //rotary
                [3/2, x-30-6, y/2],             //rotary lock, 6mm offset        
                [3/2, x-30, y/2-6],             //rotary lock, 6mm offset        
                [5/2, x-10, 10],                //on-off
            ]
        );
    }
  }
}

module doTop(x,y, dx,dy, direction=0) {
  translate([dx,dy]) {
    rotate(direction) {
      txt(x,y,8,23,"iceKeyer",8);
      txt(x,y,8,13,"2023",4);
      txt(x,y,8,3,"OZ1AAB",6);
      if (doLaserCut)
        lasercutoutSquare(thickness=thickness, x=x, y=y,
            bumpy_finger_joints=[
                [UP, 1, fingerx],
                [DOWN, 1, fingerx],
                [RIGHT, 1, fingerz],
                [LEFT, 1, fingerz]
                ]
        );
    }
  }
}

module doBottom(x,y, dx,dy, direction=0) {
  translate([dx,dy]) {
    rotate(direction) {
      if (doLaserCut)
        lasercutoutSquare(thickness=thickness, x=x, y=y,
            finger_joints=[         //not bumpy_finger_joints => easy open
                [UP, 1, fingerx],
                [DOWN, 1, fingerBack],
                [RIGHT, 1, fingerz],
                [LEFT, 1, fingerz]
            ],
            circles_remove = [
                [ 1.5, 10, 10],       //magnets fix
                [ 1.5, 10, y-10],     //magnets fix
                [ 1.5, x-10, y-10],   //magnets fix
                [ 1.5, x-10, 10],     //magnets fix
                [ 1.5, x/2, y/2],     //magnets fix
                [ 10, 20, 25]         //optional speaker
            ]
        );
    }
  }
}

