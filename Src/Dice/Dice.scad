// A 20x20x20 mm3 dice

// This file is for OpenSCAD, the best

include <../lasercutter2D.scad>; 
// Modified for 2D only, based on https://github.com/bmsleight/lasercut 
// Modified 2023 by OZ1AAB, Christen Fihl, https://github.com/Fihl

thickness = 3.1; // 3mm=3.1, 4mm=4.1

x = 20;
y = 20;
z = 20;
fingerx = 3;
fingery = 3;
fingerz = 3;

h = 1.8; //Hole radius
m = x/2;
d2 = 5;

$fn=30;

layout=1;
if (layout==0) { //My way, best for design
    doFront(x,y, 0,0);
    doTop(x,z, 0,y+10);
    doBack(x,y, 0,y+z+20);
    doBottom(x,z, 0,y+z+y+30);
    doRight(z,y, x+10,0);
    doLeft(z,y, -z-10,0);
}
if (layout==1) { //Tall
    doFront(x,y, 0,0*(y+10));    //1
    doTop(x,z, 0,1*(y+10));      //2
    doRight(z,y, 0,2*(y+10));    //3
    doLeft(z,y, 0,3*(y+10));     //4
    doBottom(x,z, 0,4*(y+10));   //5
    doBack(x,y, 0,5*(y+10));     //6
}

module doFront(x,y, dx,dy, direction=0) {
  translate([dx,dy]) {
    rotate(direction) {
            lasercutoutSquare(thickness=thickness, x=x, y=y,
            bumpy_finger_joints=[
                    [UP, 1, fingerx],
                    [RIGHT, 1, fingery],
                    [LEFT, 1, fingery],
                    [DOWN, 1, fingerx],     
                ],
            circles_remove = [
                [ h, m, m],
            ]
            );
    }
  }
}

module doBack(x,y, dx,dy, direction=0) {
  translate([dx,dy]) {
    rotate(direction) {
        lasercutoutSquare(thickness=thickness, x=x, y=y,
            bumpy_finger_joints=[
                [UP, 1, fingerx],
                [DOWN, 1, fingerx],     
                [RIGHT, 1, fingery],
                [LEFT, 1, fingery]
            ],
            circles_remove = [
                [ h, m-d2, m-d2],
                [ h, m+d2, m-d2],
                [ h, m-d2, m+d2],
                [ h, m+d2, m+d2],
                [ h, m-d2, m],
                [ h, m+d2, m],
            ]
        );
    }
  }
}

module doRight(x,y, dx,dy, direction=0) {
  translate([dx,dy]) {
    rotate(direction) {
        lasercutoutSquare(thickness=thickness, x=x, y=y,
            bumpy_finger_joints=[
                [UP, 1, fingerz],
                [DOWN, 1, fingerz],
                [RIGHT, 1, fingery],
                [LEFT, 1, fingery]
            ],
            circles_remove = [
                [ h, m-d2, m-d2],
                [ h, m+d2, m+d2],
                [ h, m, m],
            ]
        );
    }
  }
}
module doLeft(x,y, dx,dy, direction=0) {
  translate([dx,dy]) {
    rotate(direction) {
        lasercutoutSquare(thickness=thickness, x=x, y=y,
            bumpy_finger_joints=[
                [UP, 1, fingerz],
                [DOWN, 1, fingerz],
                [RIGHT, 1, fingery],
                [LEFT, 1, fingery]
            ],
            circles_remove = [
                [ h, m+d2, m-d2],
                [ h, m+d2, m+d2],
                [ h, m-d2, m-d2],
                [ h, m-d2, m+d2],
            ]
        );
    }
  }
}

module doTop(x,y, dx,dy, direction=0) {
  translate([dx,dy]) {
    rotate(direction) {
        lasercutoutSquare(thickness=thickness, x=x, y=y,
            bumpy_finger_joints=[
                [UP, 1, fingerx],
                [DOWN, 1, fingerx],
                [RIGHT, 1, fingerz],
                [LEFT, 1, fingerz]
                ],
            circles_remove = [
                [ h, m-d2, m-d2],
                [ h, m+d2, m+d2],
            ]
        );
    }
  }
}

module doBottom(x,y, dx,dy, direction=0) {
    translate([dx,dy]) {
    rotate(direction) {
        lasercutoutSquare(thickness=thickness, x=x, y=y,
            bumpy_finger_joints=[
                [UP, 1, fingerx],
                [DOWN, 1, fingerx],
                [RIGHT, 1, fingerz],
                [LEFT, 1, fingerz]
            ],
            circles_remove = [
                [ h, m-d2, m-d2],
                [ h, m+d2, m-d2],
                [ h, m,    m],
                [ h, m-d2, m+d2],
                [ h, m+d2, m+d2],
            ]
        );
    }
  }
}

