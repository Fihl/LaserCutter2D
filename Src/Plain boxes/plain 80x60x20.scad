// Box for my RYOBI buck 13.8Volt
// by OZ1AAB, Christen Fihl, https://github.com/Fihl

//All plain, just remove all circles_remove[]

// This file is for OpenSCAD, the best
include <../lasercutter2D.scad>; 

thickness = 3.1; // 3mm=3.1, 4mm=4.1

doLaserCut = 1;  //1: To export DFX file. F5+F6+Export-DXF
                 //0: Otherwise SVG, text (and corners shown)

x = 60;
y = 20;
z = 80;
fingerx = floor(x/10);     // 10mm..15mm each finger
fingery = floor(y/10);
fingerz = floor(z/10);

doFront(x,y, 0,0);
doTop(x,z, 0,y+10);
doBack(x,y, 0,y+z+20);
doBottom(x,z, 0,y+z+y+30);
doRight(z,y, x+10,0);
doLeft(z,y, -z-10,0);
translate([0,-y-5]) square([x,y]); //Extra divider, if needed

module txt(sizex,sizey,posx,posy,s,size=3,direction=0) {
    //Type % in front of following line to see text more clearly. Remove % before export!
    color("red",1)
    translate([posx,posy]) rotate(direction) text(s, size);
    if (!doLaserCut)
    //for (x=[0,1]) 
      //for (y=[0,1]) 
        //translate([sizex*x,sizey*y]) 
          circle(0.1);   //Corners into SVG, for alignment. Do NOT cut
}

module doFront(x,y, dx,dy, direction=0) {
  translate([dx,dy]) {
    rotate(direction) {
      txt(x,y,6,y/2,"Text on front. Christen Fihl");
      if (doLaserCut) {
        lasercutoutSquare(thickness=thickness, x=x, y=y,
            bumpy_finger_joints=[
                    [UP, 1, fingerx],
                    [RIGHT, 1, fingery],
                    [LEFT, 1, fingery],
                    [DOWN, 1, fingerx],     
            ]
        );
      }
    }
  }
}

module doBack(x,y, dx,dy, direction=0) {
  translate([dx,dy]) {
    rotate(direction) {
      if (doLaserCut) {
        lasercutoutSquare(thickness=thickness, x=x, y=y,
            bumpy_finger_joints=[
                [UP, 1, fingerx],
                [DOWN, 1, fingerx],     
                [RIGHT, 1, fingery],
                [LEFT, 1, fingery]
            ]
        );
      }
    }
  }
}

module doRight(x,y, dx,dy, direction=0) {
  translate([dx,dy]) {
    rotate(direction) {
      if (doLaserCut) {
        lasercutoutSquare(thickness=thickness, x=x, y=y,
            bumpy_finger_joints=[
                [UP, 1, fingerz],
                [DOWN, 1, fingerz],
                [RIGHT, 1, fingery],
                [LEFT, 1, fingery]
            ],
            circles_remove = [
                [4, 10, 0],             //misc
                [4, 25, 0],
                [4, x-10, 0],
                [4, x-25, 0],
            ]
        );
      }
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
                [4, 15, 0],             //misc
                [4, x-15, 0],
            ]
        );
    }
  }
}

module doTop(x,y, dx,dy, direction=0) {
  translate([dx,dy]) {
    rotate(direction) {
      if (doLaserCut) {
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
}

module doBottom(x,y, dx,dy, direction=0) {
screwHole = 2.8;
    translate([dx,dy]) {
    rotate(direction) {
      if (doLaserCut)
        lasercutoutSquare(thickness=thickness, x=x, y=y,
            bumpy_finger_joints=[      //bumpy_finger_joints => hard locked
            //finger_joints=[         //not bumpy_finger_joints => easy open
                [UP, 1, fingerx],
                [DOWN, 1, fingerx],
                [RIGHT, 1, fingerz],
                [LEFT, 1, fingerz]
            ]
        );
    }
  }
}
