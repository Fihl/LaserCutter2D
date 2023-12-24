// Box for my HUB75 64x64 display. 19cm 
// 2023 by OZ1AAB, Christen Fihl, https://Fihl.net 

// This file is for OpenSCAD, the best
include <../lasercutter2D.scad>; 

thickness = 3.1; // 3mm=3.1, 4mm=4.1
$fn=30;

x = 189-2*thickness;
y = 50;
z = x;
fingerx = 19;
fingery = 5;
fingerz = 19;

t=8;      //Top
lr = 20;  //LeftRight

layout=0;

if (layout==0) { //My way, best for design
    doFront(x,y, 0,0);
    doTop(x,z, 0, y+10);
    doBack(x,y, 0,y+z+20);
    doBottom(x,z, 0,y+z+y+30);
    doRight(z,y, x+10,0);
    doLeft(z,y, -z-10,0);
}
if (layout==1) { //Tall, for cutting
    doFront(x,y, 0,0);
    doRight(z,y, 0,y+10);
    doLeft(z,y, 0,y+10+y+10);
    doBack(x,y, 0,y+10+y+10+y+10);
    doBottom(x,z, 0, y+10+y+10+y+10+y+10);
    doTop(x,z, 0, z+10+y+10+y+10+y+10+y+10);
}

module doFront(x,y, dx,dy, direction=0) {
  translate([dx,dy]) {
    rotate(direction) {
            lasercutoutSquare(thickness=thickness, x=x, y=y,
            bumpy_finger_joints=[
                    [RIGHT, 1, fingery],
                    [LEFT, 1, fingery],
                    [DOWN, 1, fingerx],    
                    [UP, 1, fingerx],   
                ]

            );
    }
  }
}

module doTop(x,y, dx,dy, direction=0) {
    RPiW = 90/2; //Half
    RPiL = 60/2; //Half
    RPiX = 90;
    RPiY = 50;
    translate([dx,dy]) {
    rotate(direction) {
        lasercutoutSquare(thickness=thickness, x=x, y=y,
            bumpy_finger_joints=[
                [UP, 1, fingerx],
                [DOWN, 1, fingerx],
                [RIGHT, 1, fingerz],
                [LEFT, 1, fingerz],
            ],
        cutouts = [ 
                [15, y-15-70, 160, 70],
            ],
        circles_remove = [
                //negative side
                [ 2, x/2-170/2, y/2+145/2],
                [ 2, x/2-170/2, y/2-145/2],
                //plus side
                [ 2, x/2+170/2, y/2+145/2],
                [ 2, x/2+170/2, y/2-145/2],
                //middle
                [ 2, x/2-170/2, y/2],
                [ 2, x/2+170/2, y/2],
        
                [1.5, RPiX - RPiW, RPiY - RPiL],
                [1.5, RPiX + RPiW, RPiY - RPiL],
                [1.5, RPiX - RPiW, RPiY + RPiL],
                [1.5, RPiX + RPiW, RPiY + RPiL],
                //rpi small
                [1.5, RPiX - 58/2, RPiY - 23/2],
                [1.5, RPiX + 58/2, RPiY - 23/2],
                [1.5, RPiX - 58/2, RPiY + 23/2],
                [1.5, RPiX + 58/2, RPiY + 23/2],
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
                [DOWN, 1, fingerx],
                [RIGHT, 1, fingery],
                [LEFT, 1, fingery],
                [UP, 1, fingerx],   
            ]
        );
    }
  }
}

module doRight(x,y, dx,dy, direction=0) {
USBx=30;
USBy=15;
USBholes=17/2;  // uUSB, USBc
USBw=7;
USBh=12-USBw; //Rounded ends
  translate([dx,dy]) {
    rotate(direction) {
        lasercutoutSquare(thickness=thickness, x=x, y=y,
            bumpy_finger_joints=[
                [DOWN, 1, fingerz],
                [RIGHT, 1, fingery],
                [LEFT, 1, fingery],
                [UP, 1, fingerz],   
            ],
            circles_remove = [
                [2, USBx+USBholes, USBy],
                [2, USBx-USBholes, USBy],
                [USBw/2, USBx-USBh/2, USBy],
                [USBw/2, USBx+USBh/2, USBy],
            ],
            cutouts = [ 
                [USBx-USBh/2, USBy-USBw/2, USBh, USBw],
            ]
        );
    }
  }
}
module doLeft(x,y, dx,dy, direction=0) {
USBx=x-30;
USBy=15;
USBw=11.2;
USBh=12.2;
USBholes1=30/2;   //USB-B   I do have both 27 & 30 mm models
USBholes2=27/2;   //USB-B
  translate([dx,dy]) {
    rotate(direction) {
        lasercutoutSquare(thickness=thickness, x=x, y=y,
            bumpy_finger_joints=[
                [DOWN, 1, fingerz],
                [RIGHT, 1, fingery],
                [LEFT, 1, fingery],
                [UP, 1, fingerz],
            ],
            circles_remove = [
                [2, USBx+USBholes1, USBy],
                [2, USBx-USBholes1, USBy],        //USBb
                [2, USBx+USBholes2, USBy],
                [2, USBx-USBholes2, USBy],        //USBb
            ],
            cutouts = [ 
                [USBx-USBh/2, USBy-USBw/2, USBh, USBw], //USBb
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
            ]
        );
    }
  }
}
