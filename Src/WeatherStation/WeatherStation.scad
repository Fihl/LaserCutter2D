// Weather Station boxing
// For this kit https://www.aliexpress.com/item/1005002631239114.html

// This file is for OpenSCAD, the best

include <../LaserCutter2D.scad>; 
// Modified for 2D only, based on https://github.com/bmsleight/lasercut 
// Modified 2023 by OZ1AAB, Christen Fihl, https://github.com/Fihl

$fn=60;
thickness = 3.1;    // 3mm=3.1

layout = 2;  // 0=My way, best for design, 1=Tall(y), 2=Flat(x)

doLaserCut = 1; //To export DFX file. F5+F6+Export-DXF
                //Otherwise only text (and corners shown) to SVG. F5+F6+Export-SVG (or pdf)
doSVGtext = 0;  //0 when export to DXF, to get rid of my corners (or if text goes outside of area)

x = 45;
y = 25;
z = 100;
//Finger count
fingerx = 4;    // 10mm..15mm each finger (60mm => 4)
fingery = 3;
fingerz = 8;

dispx=25.1; dispy=17.1; dispOfs=0;  //display glass
disphx=21; disphy=21.1;             //mount holes
dispXpos=15; 
dispYpos=z-30; 

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
  }
if (layout==2) { //Flat
    doTop(x,z, 0,0);
    doBottom(x,z, x+10,0);
    doRight(z,y, y+x+x+20, 0, 90);
    doLeft(z,y, y+y+x+x+30,0, 90);

    doFront(x,y, y+y+x+x+30 +y+10, 0, 90);
    doBack (x,y, y+y+x+x+30 +y+10, x+10, 90);
  }

module txt(sizex,sizey,posx,posy,s,size=3,direction=0) {
    if (doSVGtext) {
      color("red",1)
      translate([posx,posy]) rotate(direction) text(s, size);
      for (x=[0,1]) 
        for (y=[0,1]) 
          translate([sizex*x,sizey*y]) 
            circle(thickness);   //Corners into SVG
    }
}

module doFront(x,y, dx,dy, direction=0) {
  translate([dx,dy]) {
    rotate(direction) {
        if (doLaserCut)
        lasercutoutSquare(thickness=thickness, x=x, y=y,
        bumpy_finger_joints=[
                [UP, 1, fingerx],
                [RIGHT, 1, fingery],
                [LEFT, 1, fingery],
                [DOWN, 1, fingerx],     
            ],
            cutouts = [ 
            ],
            circles_remove = [
                [2, 2.5*x/8, 0],            //hole, for opening the box
            ]
        );
    }
  }
}

module doBack(x,y, dx,dy, direction=0) {
  translate([dx,dy]) {
    rotate(direction) {
        if (doLaserCut)
        lasercutoutSquare(thickness=thickness, x=x, y=y,
            bumpy_finger_joints=[
                [UP, 1, fingerx],
                [DOWN, 1, fingerx],     
                [RIGHT, 1, fingery],
                [LEFT, 1, fingery]
            ],
            circles_remove = [
            ],
            cutouts = [ 
            ]

        );
    }
  }
}

module doRight(x,y, dx,dy, direction=0) {
USBw=7;
USBh=12-USBw; //Rounded ends
USBx=15;
USBy=y/2-5;
  translate([dx,dy]) {
    rotate(direction) {
        txt(x,y,USBx+15,y/2+7,"USB",6,-90);
        if (doLaserCut)
        lasercutoutSquare(thickness=thickness, x=x, y=y,
            bumpy_finger_joints=[
                [UP, 1, fingerz],
                [DOWN, 1, fingerz],
                [RIGHT, 1, fingery],
                [LEFT, 1, fingery]
            ],
            circles_remove = [
                [2, USBx+17/2, USBy],        //uUSB=5*9.5, USBc=7*12. holes = 17
                [2, USBx-17/2, USBy],        //uUSB/USBc
                [USBw/2, USBx-USBh/2, USBy], //USBc, rounded hole. Also fits uUSB
                [USBw/2, USBx+USBh/2, USBy], //USBc, rounded hole
            //  [4, 3, 2*y/8],               //USB?
            ],
            cutouts = [ 
                [USBx-USBh/2, USBy-USBw/2, USBh, USBw], //uUSB
            //  [z-20, 6, 16, 12.5],         //DHT11
                [z-30, y/2-7.5, 20.1, 15.1], //DHT22
            ]
        );
    }
  }
}

module doLeft(x,y, dx,dy, direction=0) {
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
              [4, 20, y/2],            //Light stick
            ]
        );
    }
  }
}

module doTop(x,y, dx,dy, direction=0) {
  translate([dx,dy]) {
    rotate(direction) {
      txt(x,y,4,30,"Weather",7);
      txt(x,y,4,20,"Station",6);
      txt(x,y,4,6,"OZ1AAB",5);
        if (doLaserCut)
        lasercutoutSquare(thickness=thickness, x=x, y=y,
            bumpy_finger_joints=[
                [UP, 1, fingerx],
                [DOWN, 1, fingerx],
                [RIGHT, 1, fingerz],
                [LEFT, 1, fingerz]
                ],
            cutouts = [ 
                [dispXpos-dispx/2, dispYpos-dispy/2, dispx,dispy],   //display glass
            ],
            circles_remove = [
                [0.5, dispXpos-disphx/2, dispYpos-dispOfs-disphy/2], //display mount
                [0.5, dispXpos+disphx/2, dispYpos-dispOfs-disphy/2], //display mount
                [0.5, dispXpos-disphx/2, dispYpos-dispOfs+disphy/2], //display mount
                [0.5, dispXpos+disphx/2, dispYpos-dispOfs+disphy/2], //display mount
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
                [DOWN, 1, fingerx],
                [RIGHT, 1, fingerz],
                [LEFT, 1, fingerz]
            ],
            circles_remove = [
            ]
        );
    }
  }
}

