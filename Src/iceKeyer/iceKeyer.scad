// Box for my iceKeyer, https://Fihl.net https://Fihl.net/iceKeyer
// A CW morse keyer, without moving parts

// This file is for OpenSCAD, the best

include <../lasercutter2D.scad>; 
// Modified for 2D only, based on https://github.com/bmsleight/lasercut 
// Modified 2023 by OZ1AAB, Christen Fihl, https://github.com/Fihl

thickness = 4.1; // 3mm=3.1, 4mm=4.1.  Paddles designed as 3mm

layout = 2;      // 0=My way, best for design, 1=Tall(y), 2=Flat(x). 
                 // NB: 1 & 2 includes extra stuff

doLaserCut = 1;  //To export DFX file. F5+F6+Export-DXF
                 //Otherwise only text (and corners shown), for SVG export

x = 60;
y = 30;
z = 90;
fingerx = 4;    // 10mm..15mm each finger (60mm => 4)
fingery = 3;    // 
fingerz = 5;    // 
fingerBack = 3; // Less fingers, to enable easy open from bottom (and hardcoded holes)

$fn=60;

//Display
dispx=25.1; dispy=17.1; dispOfs=0;  //display glass
disphx=21; disphy=21.1;             //mount holes
dispXpos=20;   //Screen center
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
    if (doLaserCut) {
      translate([0,2*y+2*z+170]) rotate(-90) doInnerStuff(); //Export as dxf to lasercut
      translate([x+25,15]) doPaddle();
    }
  }
if (layout==2) { //Flat
    doTop(x,z, 0,0);
    doBottom(x,z, x+10,0);
    doRight(z,y, y+x+x+20, 0, 90);
    doLeft(z,y, y+y+x+x+30,0, 90);
    doFront(x,y, y+y+x+x+30 +y+10, 0, 90);
    doBack (x,y, y+y+x+x+30 +y+10, x+10, 90);
    if (doLaserCut) {
      translate([x+10,z+10]) doInnerStuff(); //Export as dxf to lasercut
      translate([20,z+20]) doPaddle();
    }
  }

module txt(sizex,sizey,posx,posy,s,size=3,direction=0) {
    //Type % in front of following line to see text more clearly. Remove % before export!
    color("red",1)
    translate([posx,posy]) rotate(direction) text(s, size);
    if (!doLaserCut)
    for (x=[0,1]) 
      for (y=[0,1]) 
        translate([sizex*x,sizey*y]) 
          circle(thickness);   //Corners into SVG, for alignment
}

PADDLEholeExact = PADDLEw;
PADDLEhole = PADDLEholeExact+2*2;
PADDLEleft = x-PADDLEhole-thickness+1*2;
module doFront(x,y, dx,dy, direction=0) {
  translate([dx,dy]) {
    rotate(direction) {
      txt(x,y,PADDLEleft,PADDLEhole+5,"iceKeyer", 3);
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
USBx=20;
USBy=22;
  translate([dx,dy]) {
    rotate(direction) {
      txt(x,y,x-5,10+2,"OUT xmit", 4,180);
      txt(x,y,x-5,20+2,"USB", 4,180);
      if (doLaserCut)
        lasercutoutSquare(thickness=thickness, x=x, y=y,
            bumpy_finger_joints=[
                [UP, 1, fingerBack],
                [DOWN, 1, fingerx],     
                [RIGHT, 1, fingery],
                [LEFT, 1, fingery]
            ],
            circles_remove = [
                [2, 5.5*x/6, y],            //open the box
                [9/2, USBx, 10],            //3.5 jack CW OUT to radio

                [2, USBx+17/2, USBy],        //uUSB=5*9.5, USBc=7*12. holes = 17
                [2, USBx-17/2, USBy],        //uUSB/USBc
                [USBw/2, USBx-USBh/2, USBy], //USBc, rounded hole. Also fits uUSB
                [USBw/2, USBx+USBh/2, USBy], //USBc, rounded hole

//                [2, USBx, y/2+17/2],        //uUSB=5*9.5, USBc=7*12. holes = 17
//                [2, USBx, y/2-17/2],        //uUSB/USBc
//                [USBw/2, USBx, y/2-USBh/2], //USBc, rounded hole. Also fits uUSB
//                [USBw/2, USBx, y/2+USBh/2], //USBc, rounded hole

                //[7/2, x-PADDLEw-2*thickness-20, y/2],    //LF vol (maybe ON/off too)
                //[3/2, x-PADDLEw-2*thickness-20+6, y/2],  //rotary lock, 6mm offset        
            ],
            cutouts = [ 
               [USBx-USBh/2, USBy-USBw/2, USBh, USBw], //uUSB
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
        translate([85+PADDLEw,y-30+(5+PL)*n]) 
        difference() {
            square([PADDLEw,PL]);                 //Spacers
            for (j=[6,6+PADDLEx2-PADDLEx])
                translate([PADDLEw/2,j]) circle(r=2);
        }
}

module doLeft(x,y, dx,dy, direction=0) {
  translate([dx,dy]) {
    rotate(direction) {
      txt(x,y,15-5,20,"KEY", 4);
      txt(x,y,35-5,20,"pwr", 4);
      if (doLaserCut)
        lasercutoutSquare(thickness=thickness, x=x, y=y,
            bumpy_finger_joints=[
                [UP, 1, fingerz],
                [DOWN, 1, fingerz],
                [RIGHT, 1, fingery],
                [LEFT, 1, fingery]
            ],
            circles_remove = [
                [9/2, 15, 10],                  //3.5 jack OUT
                [9/2, 35, 10],                  //3.5 jack CW out, PWR in
                [7/2, x-30, y/2],               //rotary
                [3/2, x-30-6, y/2],             //rotary lock, 6mm offset        
                [3/2, x-30, y/2-6],             //rotary lock, 6mm offset        
                [5/2, x-10, y-10],              //on-off
            ]
        );
    }
  }
}

module doTop(x,y, dx,dy, direction=0) {
  translate([dx,dy]) {
    rotate(direction) {
      txt(x,y,8,y-10,"Guide",6);
      txt(x,y,8,y-15,"Start: Key R");
      txt(x,y,8,y-20,"Turn ...");
      txt(x,y,8,y-25,"...");
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
screwHole = 2.8;
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
                [ screwHole/2, 10, 10],       //magnets fix
                [ screwHole/2, 10, y-10],     //magnets fix
                [ screwHole/2, x-10, y-10],   //magnets fix
                [ screwHole/2, x-10, 10],     //magnets fix
                [ screwHole/2, x/2, y/2],     //magnets fix
            ]
        );
    }
  }
}


//Paddles

// F5+ F6 + Export as dxf to Lightburn import

W=40;
H=12.7; //Load cell width

module doPaddle() {
    translate([25,0]) fixture();
    translate([-2,55]) rotate(180) doOne();
    doOne();
}

module doOne() {
    paddle(0); //1 for base only (test)
    difference() {
        arm();
        paddle(1);
    }
}

//One between both paddel peaces
module fixture() {
    square([10,H],center=true);
    square([3,H+2*3], center=true);
}

module paddle(plateonly) {
$fn=64;
    difference() {
        circle(d=30);
        for(i = [1 : 360 / 12 : 360])
            rotate([0, 0, i]) translate([10, plateonly*100, 0]) circle(d=4);
        for(i = [1 : 360 / 6 : 360])
            rotate([0, 0, i]) translate([5.5, plateonly*100, 0]) circle(d=2.5);
        circle(d=4);
    }
}

module arm() {
    difference() {
        roundedsquare(H,W,3);
        translate([H/2,W-5, 0]) circle(d=4);
        translate([H/2,W-15, 0]) circle(d=4);
    }
}

module roundedsquare(xx, yy, radius) 
{
    deg = [0,90,270,180];
    difference()
    {   
        square([xx,yy]);
        for (x=[0,1])
        for (y=[0,1])
            translate([x*xx,y*yy,0])
            rotate(deg[x+2*y])
            difference(){
                translate([-.5,-.5]) square([radius+.5,radius+.5]);
                translate([radius,radius]) circle(radius, $fn=32);
            }
    }
}

